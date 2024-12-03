#!/bin/bash

if ! kubectl version &> /dev/null; then
  echo "kubectl is not set up or cluster is not reachable. Please configure it first."
  exit 1
fi

echo "Current Kubernetes context:"
kubectl config current-context
read -p "Is this the correct cluster? (yes/no): " CONFIRM_CLUSTER
if [[ "$CONFIRM_CLUSTER" != "yes" ]]; then
  echo "Please switch to the correct Kubernetes cluster and rerun the script."
  exit 1
fi

read -p "Is it okay to create the 'production' namespace? (yes/no): " CONFIRM_NAMESPACE
if [[ "$CONFIRM_NAMESPACE" != "yes" ]]; then
  exit 1
fi

read -p "Are IAM policies correctly attached to allow creating Load Balancers? (yes/no): " CONFIRM_IAM
if [[ "$CONFIRM_IAM" != "yes" ]]; then
  echo "Please attach the required IAM policies and rerun the script."
  exit 1
fi

cd terraform/production || exit 1

terraform init

terraform plan

terraform apply -var="image_tag=1.0.0-prod"

SERVICE_IP="$(kubectl get svc mytomorrows-flask-service -n production -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

if [[ -z "$SERVICE_IP" ]]; then
  echo "Failed to retrieve external IP. Please check the service status."
  exit 1
fi

echo "Service will be available at: http://$SERVICE_IP"
echo "Waiting until Load Balancer is created by AWS.."

TIMEOUT=120
SERVICE_ENDPOINT="http://$SERVICE_IP"
while true; do
  echo "Trying to reach service at $SERVICE_ENDPOINT..."
  RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null "$SERVICE_ENDPOINT")
  echo "Response code: $RESPONSE"
  if [[ "$RESPONSE" == "200" ]]; then
    echo "Service is ready and responded with status code 200."
    break
  fi
  sleep 5
  TIMEOUT=$((TIMEOUT - 5))
  if (( TIMEOUT <= 0 )); then
    echo "Service did not become ready within 2 minutes."
    exit 1
  fi
done

CONFIG_OUTPUT=$(curl -sf "http://$SERVICE_IP/config" || echo "Failed to retrieve /config")

if [[ "$CONFIG_OUTPUT" == "Failed to retrieve /config" ]]; then
  echo "Failed to reach /config endpoint. Deployment might be incorrect."
  exit 1
else
  echo "/config endpoint response: $CONFIG_OUTPUT"
fi

echo "Deployment successful"

exit 0
