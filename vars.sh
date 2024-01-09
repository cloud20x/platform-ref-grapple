CPSYS=grpl-system
PACKAGE=grsf.xpkg
CONFIGPKG=grpl/grsf
VERSION=0.2.0
TESTNS=grpl-test

PROVIDERKUBERNETES=false
PROVIDERHELM=true

BEBASEIMAGE="patrickriegler/loopback"
BEBASEIMAGEVERSION="v0.112"
UIBASEIMAGE="patrickriegler/cloud20x-ui-modules"
UIBASEIMAGEVERSION="0.1.37"

if [ "$(uname -s)" = "Darwin" ]; then 
    SED=gsed
    GREP=ggrep
else
    SED=sed
    GREP=grep
fi
