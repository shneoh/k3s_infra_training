#!/bin/bash

# Validate hostname
HOSTNAME=$(hostname)
if [[ ! "$HOSTNAME" =~ ^vmk3s001-stu[0-9]{2}$ ]]; then
  echo "❌ This script must be run on vmk3s001-stuXX. Current host: $HOSTNAME"
  exit 1
fi

# Extract stuXX from hostname
STUID=$(echo "$HOSTNAME" | grep -o 'stu[0-9]\{2\}')
echo "🔍 Detected Student ID: $STUID"

# Define variables
USERNAME="admin"
#Commented this because basic auth don't support 
#PASSWORD=$(openssl rand -base64 12)
PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)
#HTPASSWD=$(htpasswd -nb "$USERNAME" "$PASSWORD" | openssl base64)
HTPASSWD=$(htpasswd -nb "$USERNAME" "$PASSWORD")

# Create BasicAuth Secret
echo "🔐 Creating basic auth secret in 'linkerd-viz' namespace..."
kubectl create secret generic viz-authsecret \
  -n linkerd-viz \
  --from-literal=users="$HTPASSWD" \
  --dry-run=client -o yaml | kubectl apply -f -

# Replace stuXX in ingress template
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INGRESS_TEMPLATE="${SCRIPT_DIR}/linkerd-ingress.yaml"
PATCHED_INGRESS="${SCRIPT_DIR}/linkerd-ingress-patched.yaml"

if [ ! -f "$INGRESS_TEMPLATE" ]; then
  echo "❌ linkerd-ingress.yaml not found at $INGRESS_TEMPLATE"
  exit 1
fi

sed "s/stuXX/${STUID}/g" "$INGRESS_TEMPLATE" > "$PATCHED_INGRESS"

# Apply the Ingress
echo "🚀 Applying secured Linkerd Viz ingress..."
kubectl apply -f "$PATCHED_INGRESS"

# Wait for Ingress IP / TLS cert readiness
echo "⏳ Waiting for Ingress to be provisioned..."
for i in {1..20}; do
  IP=$(kubectl get ingress linkerd-viz-ingress -n linkerd-viz -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [[ -n "$IP" ]]; then
    echo "✅ Ingress IP assigned: $IP"
    break
  fi
  sleep 5
done

# ---------------------------------------
# PATCH ENFORCED-HOST TO WILDCARD (.*)
# ---------------------------------------

echo "📄 Dumping linkerd-viz web deployment to YAML..."
DEPLOY_DUMP_PATH="./linkerd-web-patched.yaml"
kubectl get deploy web -n linkerd-viz -o yaml > "$DEPLOY_DUMP_PATH"

echo "🔧 Replacing enforced-host regex with wildcard '.*' in the YAML (inline-safe)..."
sed -i 's|-enforced-host=[^"]*|-enforced-host=.*|g' "$DEPLOY_DUMP_PATH"

echo "🚀 Applying patched deployment..."
kubectl apply -f "$DEPLOY_DUMP_PATH"

echo "🔁 Restarting web pod to apply new enforced-host setting..."
kubectl rollout restart deployment web -n linkerd-viz

echo "✅ Done: --enforced-host set to .* (wildcard)"


#rm -rf $DEPLOY_DUMP_PATH $PATCHED_INGRESS




# Final Output
echo ""
echo "🎉 Linkerd Viz is now accessible at:"
echo "🔗 https://viz.app.${STUID}.steven.asia"
echo "👤 Username: $USERNAME"
echo "🔑 Password: $PASSWORD"

# Save to .secret in current dir
cat <<EOF > .secret
Linkerd Viz Access Details
==========================
URL:      https://viz.app.${STUID}.steven.asia
Username: ${USERNAME}
Password: ${PASSWORD}
EOF

echo "📁 Login credentials saved to $(pwd)/.secret"
