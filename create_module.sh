#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: ./create_module.sh <provider> <module_name>"
    exit 1
fi

PROVIDER=$1
MODULE=$2

echo "Is this a standalone module? [y/n]"
read IS_STANDALONE

if [ "$IS_STANDALONE" == "y" ]; then
    MODULE_PATH="${PROVIDER}/standalone_resources/${MODULE}"
else
    MODULE_PATH="${PROVIDER}/${MODULE}"
fi

# Create the directories and files
mkdir -p "${MODULE_PATH}"

touch "${MODULE_PATH}/README.md"
touch "${MODULE_PATH}/main.tf"
touch "${MODULE_PATH}/variables.tf"
touch "${MODULE_PATH}/outputs.tf"

echo "Module $MODULE has been created successfully in the path: $MODULE_PATH"
