. ./vars.sh

echo -n "${AWSID}" > ./access-key
echo -n "${AWSKEY}" > ./secret-access-key
kubectl -n orm-system create secret generic awssm-secret --from-file=./access-key  --from-file=./secret-access-key 2>/dev/null || true

