
if ! yq >/dev/null 2>&1; then
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
        sudo chmod +x /usr/bin/yq
fi

echo "----"
echo "extend CRD for DataSources"

dstypes=("mysql" "postgres" "model" "repository" "rest-crud" "service" "openapi" "relation") 



echo
echo

# exit

echo "----"
BASELOCATION=".spec.versions[0].schema.openAPIV3Schema.properties.spec.properties"

# for z in $(echo "discover controller model repository rest-crud service openapi relation"); do 
clis=("discover" "controller" "model" "repository" "rest-crud" "service" "openapi" "relation") 
crds=("discoveries" "controllers" "models" "repositories" "restcruds" "services" "openapis" "relations")
c=0
for z in ${clis[*]}; do 
  echo "---"
  cli=$z
  crd=${crds[${c}]}
  echo "extend CRD for $crd"
  echo "cli: $cli"
  echo "crd: $crd"
  docker run --rm -it patrickriegler/loopback:v0.93 cat /usr/local/lib/node_modules/\@loopback/cli/generators/${cli}/index.js > ${cli}.js
  yq -i "del(${BASELOCATION}.${crd}.items.properties.spec.properties.*)" grapi/definition.yaml
  for i in $(grep "this.option(" ${cli}.js | sed "s,this.option(',," | sed "s,'\, {.*,,g" | tr -d '\r'); do
    name=$i
    # echo grep "this.option(.*${name}" -A6 ${cli}.js 
    type=$(grep "this.option(.*${name}" -A6 ${cli}.js | grep -m1 "type:" | sed "s,^.*type: ,,g" | sed "s|,.*||g" | sed "s|}.*||g" | tr '[:upper:]' '[:lower:]')
    echo "Patching: $name --- $type"
    yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${name}\", \"type\": \"${type}\" } }" grapi/definition.yaml
  done
  if [ "${crd}" = "discoveries" ]; then
    name=disableCamelCase
    type=boolean
    echo "Patching: $name --- $type"
    yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${name}\", \"type\": \"${type}\" } }" grapi/definition.yaml
    # name=yes
    # type=string
    # echo "Patching: $name --- $type"
    # yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${name}\", \"type\": \"${type}\" } }" grapi/definition.yaml
  fi
  # rm ${z}.js
  ((c++))
done


