. ./vars.sh

echo "publish the package"
kubectl crossplane push configuration ${CONFIGPKG}:${VERSION} -f target/${PACKAGE}
