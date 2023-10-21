#!/bin/sh
set -e

VERSION="${1}"
COMPONENTS="mda mta db filter ssl virus web"

if [ "${VERSION}" = "" ]
then
    echo "Expected version string!"

    exit 1
fi

for COMPONENT in ${COMPONENTS}
do
    SOURCE_IMAGE="jeboehm/mailserver-${COMPONENT}:latest"
    TAGS="jeboehm/mailserver-${COMPONENT}:${VERSION} ghcr.io/jeboehm/mailserver-${COMPONENT}:latest ghcr.io/jeboehm/mailserver-${COMPONENT}:${VERSION}"

    for TAG in ${TAGS}
    do
        docker tag "${SOURCE_IMAGE}" "${TAG}"
    done

    if [ "${VERSION}" != "next" ]
    then
        echo "Pushing ${COMPONENT} latest..."

        docker push "jeboehm/mailserver-${COMPONENT}:latest"
        docker push "ghcr.io/jeboehm/mailserver-${COMPONENT}:latest"
    fi

    echo "Pushing ${COMPONENT} ${VERSION}..."

    docker push "jeboehm/mailserver-${COMPONENT}:${VERSION}"
    docker push "ghcr.io/jeboehm/mailserver-${COMPONENT}:${VERSION}"
done

exit 0
