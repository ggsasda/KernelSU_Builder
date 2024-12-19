#!/bin/bash

# Define some colors
GREEN='\033[32m'
RED='\033[31m'
NC='\033[0m' # No Color

# Get version from GitHub environment variable
version=${VERSION}
kernelsu_version=${KERNELSU_NEXT_VERSION}

# Convert the YAML file to JSON using Python
json=$(python -c "import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout)" < sources.yaml)

# Check if JSON conversion was successful
if [ -z "$json" ]; then
    echo -e "${RED}Failed to convert YAML to JSON. Exiting...${NC}"
    exit 1
fi

# Parse the JSON file to get the kernelSU version commands from KernelSU_Next corresponding to the VERSION environment variable
kernelSU_commands=$(echo "$json" | jq -r '.KernelSU_Next.version[]')
kernelSU_susfs_commands=$(echo "$json" | jq -r '.KernelSU_Next.susfs[]')

# Check if commands were retrieved successfully
if [ -z "$kernelSU_commands" ]; then
    echo -e "${RED}Failed to parse JSON or no commands found for the specified version ($version). Exiting...${NC}"
    exit 1
fi

# Print the commands that will be executed
echo -e "${GREEN}kernelSU.sh will execute the following commands:${NC}"
echo "$kernelSU_commands" | while read -r command; do
    # Replace the placeholder with the actual value
    command=${command//kernelsu-version/$kernelsu_version}
    echo -e "${RED}$command${NC}"
done

# Enter kernel directory
cd kernel || { echo -e "${RED}Failed to enter kernel directory. Exiting...${NC}"; exit 1; }

if [ "${KERNELSU_SUSFS}" == "true" ]; then
echo "$kernelSU_susfs_commands" | while read -r command; do
    # Replace the placeholder with the actual value
    eval "$command"
done
else
# Execute the commands
echo "$kernelSU_commands" | while read -r command; do
    # Replace the placeholder with the actual value
    eval "$command"
done
fi