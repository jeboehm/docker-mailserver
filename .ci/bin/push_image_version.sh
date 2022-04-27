#!/bin/sh

COMPONENTS="mda mta db filter ssl virus web"

for component in $COMPONENTS
do
    docker tag jeboehm/mailserver-$component:latest jeboehm/mailserver-$component:$1
    
    docker push jeboehm/mailserver-$component:latest
    docker push jeboehm/mailserver-$component:$1
done
