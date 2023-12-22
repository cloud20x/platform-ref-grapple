CPSYS=grpl-system
PACKAGE=grsf.xpkg
CONFIGPKG=grpl/grsf
VERSION=0.1.2
TESTNS=grpl-test

PROVIDERKUBERNETES=false
PROVIDERHELM=true

BEBASEIMAGE="patrickriegler/loopback"
BEBASEIMAGEVERSION="v0.103"
UIBASEIMAGE="patrickriegler/cloud20x-ui-modules"
UIBASEIMAGEVERSION="0.1.15"

if [ "$(uname -s)" = "Darwin" ]; then 
    SED=gsed
    GREP=ggrep
else
    SED=sed
    GREP=grep
fi
