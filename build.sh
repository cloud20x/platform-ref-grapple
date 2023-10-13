. ./vars.sh

# cleanup previous builds
rm -R target 2>/dev/null
mkdir -p target 2>/dev/null

# update the CRDS according to the latest loopback image
./createCRDS.sh

# build the crossplane package
echo "build the package"
kubectl crossplane build configuration --name=${PACKAGE} --ignore=".gitpod.yml,examples/*,hack/*,.github/*/*,target/*,*.sh,cluster/*,cluster/*/*,network/*,test/*,test/*/*,grsf/*"
# kubectl crossplane build configuration --name ${PACKAGE} --ignore ".gitpod.yml,examples/*,hack/*,.github/*/*,target/*,*.sh,cluster/*,cluster/*/*,grapi/*,test/*,test/*/*"

mv ${PACKAGE} ./target/
