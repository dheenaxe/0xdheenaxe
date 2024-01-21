#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Define the path to the packages file
packages_file="packages.txt"

# Check if the packages file exists
if [ ! -f "$packages_file" ]; then
    echo "Error: Packages file '$packages_file' not found."
    exit 1
fi

# Initialize an array to store packages with errors
packages_with_errors=()

# Initialize an associative array to store reasons for package failures
declare -A failed_packages_reasons

# Print a header for better readability
echo "-----------------------"
echo "Package Installation Script"
echo "-----------------------"

# Read each line from the file and install the packages
while IFS= read -r package; do
    echo -n "Installing $package... "
    if apt install -y "$package" > /dev/null 2>&1; then
        echo "OK"
    else
        echo "Failed"
        packages_with_errors+=("$package")
        # Store the reason for failure
        failed_packages_reasons["$package"]="$(apt install -y "$package" 2>&1 | tail -n +4)"
    fi
done < "$packages_file"

# Display a summary of installation results
echo "-----------------------"
echo "Installation Summary:"
if [ ${#packages_with_errors[@]} -eq 0 ]; then
    echo "All packages have been successfully installed."
else
    echo "Packages with installation errors:"
    for error_package in "${packages_with_errors[@]}"; do
        echo "- $error_package"
    done
fi
echo "-----------------------"

# Display reasons for package failures, if any
if [ ${#failed_packages_reasons[@]} -gt 0 ]; then
    echo "Failed Packages and Reasons:"
    for package in "${!failed_packages_reasons[@]}"; do
        echo "- $package: ${failed_packages_reasons[$package]}"
    done
    echo "-----------------------"
fi
