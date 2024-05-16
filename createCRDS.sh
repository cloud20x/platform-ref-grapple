
. ./vars.sh

if ! yq >/dev/null 2>&1; then
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
        sudo chmod +x /usr/bin/yq
fi

echo "----"
echo "extend CRD for DataSources"

docker run --rm -it ${BEBASEIMAGE}:${BEBASEIMAGEVERSION} cat /usr/local/lib/node_modules/\@loopback/cli/lib/connectors.json > connectors.json

BASELOCATIONDS=".spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.datasources.items"
dstypes=("mysql" "postgresql" "kv-redis" "kv-memory" "memory")
yq -i "del(${BASELOCATIONDS}.properties.spec.properties.*)" grapi/definition.yaml
for z in ${dstypes[*]}; do 

  dstype=$z
  echo "extend CRD for datasource type: $dstype"
  desc="specs for datasource type ${dstype}"
  yq -i "${BASELOCATIONDS}.properties.spec.properties += {\"${dstype}\": { \"description\": \"${desc}\", \"type\": \"object\", \"properties\": {} } }" grapi/definition.yaml
  setting="name"
  desc="please provide a name for the datasource"
  type="string"
  yq -i "${BASELOCATIONDS}.properties.spec.properties.${dstype}.properties += {\"${setting}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
  setting="connector"
  desc="please provide the connector type for the datasource"
  type="string"
  yq -i "${BASELOCATIONDS}.properties.spec.properties.${dstype}.properties += {\"${setting}\": { \"description\": \"${desc}\", \"type\": \"${type}\", \"default\": \"${dstype}\" } }" grapi/definition.yaml
  cat connectors.json | jq -r ".\"${dstype}\".settings | keys[]" | while read -r setting; do 
    # echo "do something with ${setting}"; 
    desc="spec for ${setting} for datasource ${dstype}"
    type="string"
    yq -i "${BASELOCATIONDS}.properties.spec.properties.${dstype}.properties += {\"${setting}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
  done

done

rm connectors.json

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
  docker run --rm -it ${BEBASEIMAGE}:${BEBASEIMAGEVERSION} cat /usr/local/lib/node_modules/\@loopback/cli/generators/${cli}/index.js > ${cli}.js
  yq -i "del(${BASELOCATION}.${crd}.items.properties.spec.properties.*)" grapi/definition.yaml
  # names are probably not even necessary here...
  # if [ "${crd}" != "nonamesfor" ]; then
  #   name=name
  #   type=string
  #   echo "Patching: $name --- $type"
  #   yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${name}\", \"type\": \"${type}\" } }" grapi/definition.yaml
  # fi
  for i in $(${GREP} "this.option(" ${cli}.js | ${SED} "s,this.option(',," | ${SED} "s,'\, {.*,,g" | tr -d '\r'); do
    name=$i
    # echo ${GREP} "this.option(.*${name}" -A6 ${cli}.js 
    type=$(${GREP} "this.option(.*${name}" -A6 ${cli}.js | ${GREP} -m1 "type:" | ${SED} "s,^.*type: ,,g" | ${SED} "s|,.*||g" | ${SED} "s|}.*||g" | tr '[:upper:]' '[:lower:]')
    desc=$(${GREP} "this.option(.*${name}" -A6 ${cli}.js | ${GREP} -m1 -A2 "description:" | ${SED} "s,^.*description: g.f(,,g" | ${GREP} -o "'.*'" | head -n 1 | ${SED} "s,',,g")
    echo "Patching: $name --- $type"
    if [ "${crd}" = "discoveries" ] && [ "${name}" = "outdir" ]; then
      echo ${GREP} "this.option(.*${name}" -A6 ${cli}.js | ${GREP} -m1 -A2 "description:" 
      echo $(${GREP} "this.option(.*${name}" -A6 ${cli}.js | ${GREP} -m1 -A2 "description:")
      echo $desc
    fi
    # echo yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
    yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
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
    # yq -i "with(${BASELOCATION}.${crd}.items.properties.spec.properties.yes ; . | key style=\"single\" ) " grapi/definition.yaml
  fi
  if [ "${crd}" = "models" ]; then
    name=name
    type=string
    echo "Patching: $name --- $type"
    yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${name}\", \"type\": \"${type}\" } }" grapi/definition.yaml

    name=properties
    type=object
    echo "Patching: $name --- $type"
    yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${name}\", \"type\": \"${type}\" } }" grapi/definition.yaml
    yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties.properties.additionalProperties += {\"type\": \"object\" }" grapi/definition.yaml

    ${GREP} "  name:" ${cli}.js | while read -r line ; do
      if [[ "$line" != *"name: \`Entity"* ]] && [[ "$line" != *"name: 'modelBaseClass"* ]] && [[ "$line" != *"name: 'allowAdditionalProperties"* ]]; then
        n=$(echo $line | sed 's,name:,,g' | sed -e 's/[^[:alnum:]|-]//g')
        # echo "Processing $line"
        # echo "name: $n"
        # grep $line ${cli}.js -A5 | grep "type: "
        if [ "$n" = "propName" ]; then
          t=string
        elif [ "$n" = "default" ]; then
          t=string
        else
          # echo "----"
          # echo $line
          t=$(${GREP} "$line" ${cli}.js -A5 | grep "type: " | sed 's,type:,,g' | sed -e 's/[^[:alnum:]|-]//g')
          if [ "$t" = "list" ]; then t=string; fi
          if [ "$t" = "confirm" ]; then t=boolean; fi
        fi
        # run the patching for all, but the propName - if injected in the the lb4 command, it won't work...
        if [ "$n" != "propName" ]; then
          echo "Patching: $n --- $t"
          yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties.properties.additionalProperties.properties += {\"${n}\": { \"description\": \"${n}\", \"type\": \"${t}\" } }" grapi/definition.yaml
        fi
      fi
    done

    # at the end of models structure generation, add:
    name=length
    type=string
    echo "Patching: $name --- $type"
    yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties.properties.additionalProperties.properties += {\"${name}\": { \"description\": \"${name}\", \"type\": \"${type}\" } }" grapi/definition.yaml


  fi
  rm ${z}.js
  ((c++))
done



# extend CRD for CACHECONFIGS
echo "----"
echo "extend CRD for CACHECONFIGS"
crd=cacheconfigs
BASELOCATION=".spec.versions[0].schema.openAPIV3Schema.properties.spec.properties"
yq -i "del(${BASELOCATION}.${crd}.items.properties.spec.properties.*)" grapi/definition.yaml
name="redisDS"
desc="Please specify here the name of the cache datasource (kv-redis datasource) to be used as cache storage"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="cacheTTL"
desc="Please specify here the cache TTL for the cache storage"
type="integer"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="openApis"
desc="Please specify here the name of the openapi specification that shall be cached"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="exclude"
desc="Please specify here, which endpoints shall be excluded from the cache"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="include"
desc="Please specify here, which endpoints shall be included in the cache"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml


# extend CRD for Fuzzy Search
echo "----"
echo "extend CRD for CACHECONFIGS"
crd=fuzzysearch
BASELOCATION=".spec.versions[0].schema.openAPIV3Schema.properties.spec.properties"
yq -i "del(${BASELOCATION}.${crd}.items.properties.spec.properties.*)" grapi/definition.yaml
name="fuzzy"
desc="Please specify here if a fuzzy search should be made available for each endpoint"
type="boolean"
default="true"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" , \"default\": ${default} } }" grapi/definition.yaml
name="centralFuzzy"
desc="Please specify here if a central fuzzy endpoint over all endpoints shall be made available"
type="boolean"
default="false"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" , \"default\": ${default} } }" grapi/definition.yaml
name="datasource"
desc="Please specify here the name of the datasource for which the fuzzy search endpoint shall be generated"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="appName"
desc="Please specify here the application name for the fuzzy endpoint"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="include"
desc="Please specify here includes for the fuzzy endpoint"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="exclude"
desc="Please specify here excludes for the fuzzy endpoint"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml

# {"fuzzy": true, "centralFuzzy": false, "datasource": "jcscherrer", "appName": "Grpl", "include": "kundes"}

