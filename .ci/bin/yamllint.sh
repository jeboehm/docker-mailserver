#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"

cd $DIR/../../

FILES=$(find . -type f -name \*.yml)
HASERRORS=false
IGNORE=""

for file in $FILES
do
    echo "Running yamllint for $file..."
    docker run --rm -i -v $PWD:/app:ro sdesbure/yamllint yamllint -c /app/.ci/yamllint.yml /app/$file

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
