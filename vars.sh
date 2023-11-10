CPSYS=grpl-system
PACKAGE=grsf.xpkg
CONFIGPKG=grpl/grsf
VERSION=0.0.1
TESTNS=grpl-test

PROVIDERKUBERNETES=false
PROVIDERHELM=true

BEBASEIMAGE="patrickriegler/loopback"
BEBASEIMAGEVERSION="v0.97"
UIBASEIMAGE="patrickriegler/cloud20x-ui-modules"
UIBASEIMAGEVERSION="0.1.15"

if [ "$(uname -s)" = "Darwin" ]; then 
    SED=gsed
else
    SED=sed
fi
