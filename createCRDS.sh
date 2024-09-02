
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
  desc="Please specify the specs for datasource type ${dstype}"
  yq -i "${BASELOCATIONDS}.properties.spec.properties += {\"${dstype}\": { \"description\": \"${desc}\", \"type\": \"object\", \"properties\": {} } }" grapi/definition.yaml
  setting="name"
  desc="Please provide a name for the datasource"
  type="string"
  yq -i "${BASELOCATIONDS}.properties.spec.properties.${dstype}.properties += {\"${setting}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
  setting="connector"
  desc="Please provide the connector type for the datasource - Default: ${dstype}"
  type="string"
  yq -i "${BASELOCATIONDS}.properties.spec.properties.${dstype}.properties += {\"${setting}\": { \"description\": \"${desc}\", \"type\": \"${type}\", \"default\": \"${dstype}\" } }" grapi/definition.yaml
  cat connectors.json | jq -r ".\"${dstype}\".settings | keys[]" | while read -r setting; do 
    # echo "do something with ${setting}"; 
    desc="Spec for ${setting} for datasource ${dstype}"
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
          case $n in
            "type")
              d="Please define the type of the field (e.g. 'string', 'array', 'number')"
              ;;
            "required")
              d="Please define whether the field is required (boolean, e.g. true / false) (if the field is generated, it is NOT required)"
              ;;
            "id")
              d="Please define if the field is an ID (unique identifier for this model)"
              ;;
            "default")
              d="Please define the default value for the field (e.g. 'myvalue')"
              ;;
            "generated")
              d="Please define, if the field is autogenerated by the underlying system (e.g. database) (boolean, e.g. true / false) (false, if defaultFn is defined)"
              ;;
            "itemType")
              d="Please define the type of the item if type = array (e.g. 'string', 'number')"
              ;;
            *)
              d=${n}
              ;;
          esac
          yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties.properties.additionalProperties.properties += {\"${n}\": { \"description\": \"${d}\", \"type\": \"${t}\" } }" grapi/definition.yaml
        fi
      fi
    done

    # at the end of models structure generation, add:
    name=length
    type=string
    description="Please define the length of the field (e.g. 20 (for 20 characters))"
    echo "Patching: $name --- $type"
    yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties.properties.additionalProperties.properties += {\"${name}\": { \"description\": \"${description}\", \"type\": \"${type}\" } }" grapi/definition.yaml

    # at the end of models structure generation, add:
    name=defaultFn
    type=string
    description="Please define the default function for the field (e.g. 'uuid' (for ID string fields), 'now' (for date fields))"
    echo "Patching: $name --- $type"
    yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties.properties.additionalProperties.properties += {\"${name}\": { \"description\": \"${description}\", \"type\": \"${type}\" } }" grapi/definition.yaml


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
desc="Please specify here the cache TTL for the cache storage in seconds\nexample:\n60000"
type="integer"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="openApis"
desc="Please specify here the name of the openapi specification that shall be cached\nOnly specify a reference to the name of the openapi resource in the grapi (grapple API)"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="exclude"
desc="Please specify here, which endpoints shall be excluded from the cache\nexample:\n*:employees/*"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="include"
desc="Please specify here, which endpoints shall be included in the cache\nexample:\n*:customers/*\nif specified, everything else is excluded."
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml


# extend CRD for Fuzzy Search
echo "----"
echo "extend CRD for fuzzysearch"
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
desc="Please specify here the name of the datasource for which\nthe fuzzy search endpoint shall be generated\nSpecify only the name of the datasource as a reference"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="appName"
desc="Please specify here the application name for the fuzzy endpoint"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="include"
desc="Please specify here includes for the fuzzy endpoint\nexample:\n*:customers/*"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml
name="exclude"
desc="Please specify here excludes for the fuzzy endpoint\nexample:\n*:employees/*"
type="string"
echo "Patching: $name --- $type"
yq -i "${BASELOCATION}.${crd}.items.properties.spec.properties += {\"${name}\": { \"description\": \"${desc}\", \"type\": \"${type}\" } }" grapi/definition.yaml

# {"fuzzy": true, "centralFuzzy": false, "datasource": "jcscherrer", "appName": "Grpl", "include": "kundes"}

