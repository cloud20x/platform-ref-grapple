CPSYS=grpl-system
PACKAGE=grsf.xpkg
CONFIGPKG=grpl/grsf
VERSION=0.2.4
TESTNS=grpl-test

PROVIDERKUBERNETES=false
PROVIDERHELM=true

BEBASEIMAGE="grpl/grapi"
BEBASEIMAGEVERSION="0.2.4"
UIBASEIMAGE="grpl/gruim"
UIBASEIMAGEVERSION="0.2.4"

if [ "$(uname -s)" = "Darwin" ]; then 
    SED=gsed
    GREP=ggrep
else
    SED=sed
    GREP=grep
fi
