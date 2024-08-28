. ./vars.sh

echo "install grpl"
# helm upgrade --install grpl-init oci://public.ecr.aws/p7h7z5g3/grpl-init -n ${CPSYS} --create-namespace --wait
# kubectl crossplane update configuration grsf grpl/grsf || kubectl crossplane install configuration grpl/grsf

# echo "install grpl"
# helm upgrade --install grpl-init oci://public.ecr.aws/p7h7z5g3/grpl-init -n ${CPSYS} --create-namespace --wait
# sleep 10
# helm upgrade --install grpl oci://public.ecr.aws/p7h7z5g3/grpl -n ${CPSYS} --create-namespace --wait

# echo "install grpl"
# echo "deploy the provider config"
# cat <<EOF | kubectl apply -n ${CPSYS} -f -
# apiVersion: kubernetes.crossplane.io/v1alpha1
# kind: ProviderConfig
# metadata:
#   name: kubernetes-provider
# spec:
#   credentials:
#     source: InjectedIdentity
# EOF

# ensure that crossplane user has permissions:
# k edit clusterrole crossplane
# cat hack/crossplane-cluster-admin-rolebinding.yaml

# ensure that crossplane user has permissions:
# k edit clusterrole crossplane
# cat hack/crossplane-cluster-admin-rolebinding.yaml

# if ${PROVIDERKUBERNETES}; then
#   # ensure that crossplane kubernetes user has permissions:
#   SA=$(kubectl -n ${CPSYS} get sa -o name | grep provider-kubernetes | sed -e 's|serviceaccount\/|grpl-system:|g' | sed "s|grpl-system|${CPSYS}|g")
#   kubectl create clusterrolebinding crossplane-provider-kubernetes-admin-binding --clusterrole cluster-admin --serviceaccount="${SA}" 
#   # temporary - need for a better solution

# cat <<EOF | kubectl apply -n ${CPSYS} -f -
# apiVersion: kubernetes.crossplane.io/v1alpha1
# kind: ProviderConfig
# metadata:
#   name: kubernetes-provider
# spec:
#   credentials:
#     source: InjectedIdentity
# EOF

# fi
# if ${PROVIDERHELM}; then
#   # ensure that crossplane helm user has permissions:
#   SA=$(kubectl -n ${CPSYS} get sa -o name | grep provider-helm | sed -e 's|serviceaccount\/|grpl-system:|g' | sed "s|grpl-system|${CPSYS}|g")
#   kubectl create clusterrolebinding crossplane-provider-helm-admin-binding --clusterrole cluster-admin --serviceaccount="${SA}" 
#   # temporary - need for a better solution

# cat <<EOF | kubectl apply -n ${CPSYS} -f -
# apiVersion: helm.crossplane.io/v1beta1
# kind: ProviderConfig
# metadata:
#   name: helm-provider-config
# spec:
#   credentials:
#     source: InjectedIdentity
# EOF

# fi

