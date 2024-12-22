#!/bin/bash

# Get version from GitHub environment variable
version=${VERSION}

# Check if version is provided
if [ -z "$version" ]
then
    echo "No version specified. No kernel or clang will be cloned. Exiting..."
    exit 1
fi

# Convert the YAML file to JSON
json=$(python -c "import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout)" < sources.yaml)

# Parse the JSON file
clone_commands=$(echo "$json" | jq -r '.SusFs.clone[]')
susfs_copy_to_kernel=$(echo "$json" | jq -r '.SusFs.copy[]')
kernelSU_commands=$(echo "$json" | jq -r '.KernelSU.susfs[]')

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

# Print the commands that will be executed
echo -e "\033[31mClone.sh will execute following commands corresponding to ${version}:\033[0m"
echo "$clone_commands" | while read -r command; do
    echo -e "\033[32m$command\033[0m"
done
echo "$susfs_copy" | while read -r command; do
    echo -e "\033[32m$command\033[0m"
done
echo "$susfs_kernelsu_copy" | while read -r command; do
    echo -e "\033[32m$command\033[0m"
done

# KERNEL_ROOT="kernel"

# Clone the kernel and append clone path to the command
echo "$clone_commands" | while read -r command; do
    eval "$command susfs4ksu"
done

echo "$susfs_copy_to_kernel" | while read -r command; do
    eval "$command"
done
