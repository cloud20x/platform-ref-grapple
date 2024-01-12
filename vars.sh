CPSYS=grpl-system
PACKAGE=grsf.xpkg
CONFIGPKG=grpl/grsf
VERSION=0.2.0
TESTNS=grpl-test

PROVIDERKUBERNETES=false
PROVIDERHELM=true

BEBASEIMAGE="grpl/loopback"
BEBASEIMAGEVERSION="v0.112"
UIBASEIMAGE="grpl/cloud20x-ui-modules"
UIBASEIMAGEVERSION="0.1.38"

if [ "$(uname -s)" = "Darwin" ]; then 
    SED=gsed
    GREP=ggrep
else
    SED=sed
    GREP=grep
fi
