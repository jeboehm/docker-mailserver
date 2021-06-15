#!/bin/sh
IGNORE_RULES="DL3018 DL3059"
DIR="$(cd "$(dirname "$0")" && pwd)"

cd $DIR/../../

FILES=$(find . -type f -name Dockerfile)
HASERRORS=false
IGNORE=""

for ignore_rule in $IGNORE_RULES
do
    IGNORE="$IGNORE --ignore $ignore_rule"
done

for file in $FILES
do
    echo "Running hadolint for $file..."
    docker run --rm -i hadolint/hadolint hadolint $IGNORE - < $file

    if [ $? != 0 ]
    then
        HASERRORS=true
    fi

    echo "============================="
done

if [ $HASERRORS = "true" ]
then
    echo "Found errors."
    exit 1
fi

echo "No errors found."
exit 0
