#!/bin/sh

VERSION="${1}"
COMPONENTS="mda mta db filter ssl virus web"

if [ "${VERSION}" == "" ]
then
    echo "Expected version string!"

    exit 1
fi

for component in $COMPONENTS
do
    docker tag jeboehm/mailserver-$component:latest jeboehm/mailserver-$component:${VERSION}
    
    if [ "${VERSION}" != "next" ]
    then
        docker push jeboehm/mailserver-$component:latest
    fi
    
    docker push jeboehm/mailserver-$component:${VERSION}
done
