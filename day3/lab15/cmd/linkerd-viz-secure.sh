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
PASSWORD=$(openssl rand -base64 12)
HTPASSWD=$(htpasswd -nbB "$USERNAME" "$PASSWORD" | openssl base64)

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

# Final Output
echo ""
echo "🎉 Linkerd Viz is now accessible at:"
echo "🔗 https://viz.app.${STUID}.steven.asia"
echo "👤 Username: $USERNAME"
echo "🔑 Password: $PASSWORD"
