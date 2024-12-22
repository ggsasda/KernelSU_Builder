#!/bin/bash

# Define some colors
GREEN='\033[32m'
RED='\033[31m'
NC='\033[0m' # No Color

# Get version from GitHub environment variable
version=${VERSION}
kernelsu_version=${KERNELSU_VERSION}

# Convert the YAML file to JSON using Python
json=$(python -c "import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout)" < sources.yaml)

# Check if json is empty
if [ -z "$json" ]
then
    echo -e "${RED}Failed to convert YAML to JSON. Exiting...${NC}"
    exit 1
fi

# Parse the JSON file to get the commands corresponding to the kernelSU_version
kernelSU_commands=$(echo "$json" | jq -r '.KernelSU.next[]')

# Print the commands that will be executed
echo -e "${GREEN}kernelSU.sh will execute following commands:${NC}"
echo "$kernelSU_commands" | while read -r command; do
    # Replace the placeholder with the actual value
    echo -e "${RED}$command${NC}"
done

# Enter kernel directory
cd kernel

# Execute the commands
echo "$kernelSU_commands" | while read -r command; do
    # Replace the placeholder with the actual value
    eval "$command"
done