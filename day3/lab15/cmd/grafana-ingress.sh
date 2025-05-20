#!/bin/bash

# Get system hostname
HOSTNAME=$(hostname)

# Validate it's running on the correct machine
if [[ ! "$HOSTNAME" =~ ^vmk3s001-stu[0-9]{2}$ ]]; then
  echo "❌ This script must be run on student machine 1 (e.g., vmk3s001-stu07). Current host: $HOSTNAME"
  exit 1
fi

# Extract stuXX from hostname
STUID=$(echo "$HOSTNAME" | grep -o 'stu[0-9]\{2\}')

# Check if the g-ingress.yaml file exists
if [ ! -f g-ingress.yaml ]; then
  echo "❌ g-ingress.yaml not found in current directory."
  exit 1
fi

# Prepare a temp file with stuXX replaced
MODIFIED_FILE="g-ingress-patched.yaml"
sed "s/stuXX/${STUID}/g" g-ingress.yaml > "$MODIFIED_FILE"

# Apply the Ingress
echo "🚀 Applying patched Ingress for $STUID..."
kubectl apply -f "$MODIFIED_FILE"

# Wait for TLS certificate to be provisioned (loop with timeout)
echo "⏳ Waiting for TLS certificate to be ready..."
for i in {1..20}; do
  STATUS=$(kubectl get ingress grafana-ingress -n grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [[ -n "$STATUS" ]]; then
    echo "✅ Ingress has IP: $STATUS"
    break
  fi
  sleep 5
done

# Get Grafana admin password
echo "🔐 Fetching Grafana admin password..."
GRAFANA_PASS=$(kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

# Display final output
URL="https://grafana.app.${STUID}.steven.asia"
echo ""
echo "🎉 Grafana is now accessible!"
echo "🔗 URL: $URL"
echo "👤 Username: admin"
echo "🔑 Password: $GRAFANA_PASS"
