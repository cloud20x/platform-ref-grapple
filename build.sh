. ./vars.sh

# cleanup previous builds
rm -R target 2>/dev/null
mkdir -p target 2>/dev/null

# update the CRDS according to the latest loopback image
./createCRDS.sh

# update image versions automatically from a central place
sed -i "s,beimage:.*,beimage: ${BEBASEIMAGE},g" grapi/composition.yaml
sed -i "s,beimagetag:.*,beimagetag: ${BEBASEIMAGEVERSION},g" grapi/composition.yaml
sed -i "s,uiimage:.*,uiimage: ${UIBASEIMAGE},g" gruim/composition.yaml
sed -i "s,uiimagetag:.*,uiimagetag: ${UIBASEIMAGEVERSION},g" gruim/composition.yaml

# build the crossplane package
echo "build the package"
kubectl crossplane build configuration --name=${PACKAGE} --ignore=".gitpod.yml,examples/*,hack/*,.github/*/*,target/*,*.sh,cluster/*,cluster/*/*,network/*,test/*,test/*/*,grsf/*"
# kubectl crossplane build configuration --name ${PACKAGE} --ignore ".gitpod.yml,examples/*,hack/*,.github/*/*,target/*,*.sh,cluster/*,cluster/*/*,grapi/*,test/*,test/*/*"

mv ${PACKAGE} ./target/
