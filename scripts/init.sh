#!/bin/sh

sagcc list inventory products --wait-for-cc

if [ -d $SAG_HOME/profiles/SPM/bin ]; then
    $SAG_HOME/profiles/SPM/bin/startup.sh
fi

echo -e "\n"
echo "####################"
echo "# Initialization   #"
echo "####################"
echo -e "\n"

if [ ! -z $LICENSES_URL ]; then
    # https://solutionbook.softwareag.com/sb-web/page/detail_page.xhtml?guid=1227042885&type=platforms
    echo "Importing license keys from: $LICENSES_URL ..."
    curl -o licenses.zip $LICENSES_URL && \
    sagcc add license-tools keys -i licenses.zip && \
    rm licenses.zip
else
    echo "SKIP: LICENSES_URL env var is not set. No license keys are imported"    
fi

if [ ! -z $REPO_HOST ]; then
    echo "Registering $REPO_PRODUCT and $REPO_FIX repositories on $REPO_HOST ..."
    sagcc exec templates composite apply sag-cc-creds-dev --sync-job -c 5
    sagcc exec templates composite apply sag-cc-builder-dev --sync-job -c 5 \
        repo.product=$REPO_PRODUCT repo.fix=$REPO_FIX repo.host=$REPO_HOST --sync-job
else
    echo "SKIP: REPO_HOST env var is not set. No repositories are registered"
fi
