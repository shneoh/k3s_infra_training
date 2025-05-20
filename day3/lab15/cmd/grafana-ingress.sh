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

# Determine script directory to find g-ingress.yaml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INGRESS_TEMPLATE="${SCRIPT_DIR}/g-ingress.yaml"
MODIFIED_FILE="${SCRIPT_DIR}/g-ingress-patched.yaml"

# Check if the file exists
if [ ! -f "$INGRESS_TEMPLATE" ]; then
  echo "❌ g-ingress.yaml not found at $INGRESS_TEMPLATE"
  exit 1
fi

# Replace stuXX with actual student ID
sed "s/stuXX/${STUID}/g" "$INGRESS_TEMPLATE" > "$MODIFIED_FILE"

# Apply the patched file
echo "🚀 Applying patched Ingress for $STUID..."
kubectl apply -f "$MODIFIED_FILE"

# Wait for TLS cert (Ingress IP allocation)
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

# Output access details
URL="https://grafana.app.${STUID}.steven.asia"
echo ""
echo "🎉 Grafana is now accessible!"
echo "🔗 URL: $URL"
echo "👤 Username: admin"
echo "🔑 Password: $GRAFANA_PASS"
