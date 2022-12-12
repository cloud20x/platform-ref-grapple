. ./vars.sh

echo -n "${AWSID}" > ./access-key
echo -n "${AWSKEY}" > ./secret-access-key
kubectl -n orm-system create secret generic awssm-secret --from-file=./access-key  --from-file=./secret-access-key 2>/dev/null || true

echo "install grpl"
helm upgrade --install ${CPSYS} oci://public.ecr.aws/p7h7z5g3/grpl -n ${CPSYS} --create-namespace 
