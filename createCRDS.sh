
if ! yq >/dev/null 2>&1; then
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
        sudo chmod +x /usr/bin/yq
fi


echo "----"
echo "create CRD for discovery"

yq -i "del(.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.discoveries.items.properties.spec.properties.*)" grapi/definition.yaml

for i in $(docker run --rm -it patrickriegler/loopback:v0.92 grep "this.option(" /usr/local/lib/node_modules/\@loopback/cli/generators/discover/index.js | sed "s,this.option(',," | sed "s,'\, {,,g"); do 
    echo "create spec: $i"

done

