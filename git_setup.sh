#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Define the path to the repositories file
repositories_file="repositories.txt"
output_folder="/opt/"

# Check if the repositories file exists
if [ ! -f "$repositories_file" ]; then
    echo "Error: Repositories file '$repositories_file' not found."
    exit 1
fi

# Initialize an array to store repositories with errors
repositories_with_errors=()

# Print a header for better readability
echo "-----------------------"
echo "Git Repository Cloning Script"
echo "-----------------------"

# Check if the output folder exists, if not, create it
if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

# Read each line from the file and clone the repositories
while IFS= read -r repo_url; do
    # Extract the repository name from the URL
    repo_name=$(basename "$repo_url" .git)

    # Check if the repository already exists in the output folder
    if [ -d "$output_folder$repo_name" ]; then
        echo "Repository '$repo_name' already exists. Skipping..."
    else
        echo -n "Cloning $repo_name... "
        # Clone the repository with --recursive parameter
        git clone --recursive "$repo_url" "$output_folder$repo_name" > /dev/null 2>&1

        # Check if the clone was successful
        if [ $? -eq 0 ]; then
            echo "OK"
        else
            echo "Failed"
            repositories_with_errors+=("$repo_name")
        fi
    fi
done < "$repositories_file"

# Display a summary of cloning results
echo "-----------------------"
echo "Cloning Summary:"
if [ ${#repositories_with_errors[@]} -eq 0 ]; then
    echo "All repositories have been successfully cloned."
else
    echo "Repositories with cloning errors:"
    for error_repo in "${repositories_with_errors[@]}"; do
        echo "- $error_repo"
    done
fi
echo "-----------------------"
