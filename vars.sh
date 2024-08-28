CPSYS=grpl-system
PACKAGE=grsf.xpkg
CONFIGPKG=grpl/grsf
VERSION=0.2.5
TESTNS=grpl-test

PROVIDERKUBERNETES=false
PROVIDERHELM=true

BEBASEIMAGE="grpl/grapi"
BEBASEIMAGEVERSION="0.2.5"
UIBASEIMAGE="grpl/gruim"
UIBASEIMAGEVERSION="0.2.5"

if [ "$(uname -s)" = "Darwin" ]; then 
    SED=gsed
    GREP=ggrep
else
    SED=sed
    GREP=grep
fi
