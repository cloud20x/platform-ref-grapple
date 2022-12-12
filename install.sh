. ./vars.sh

echo "install grpl"
helm upgrade --install ${CPSYS} oci://public.ecr.aws/p7h7z5g3/grpl -n ${CPSYS} --create-namespace 
