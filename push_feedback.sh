#!/bin/bash

# Check if a file with remote names is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file_with_remotes>"
  exit 1
fi

# Read the file containing remote names
remote_file="$1"

if [ ! -f "$remote_file" ]; then
  echo "File $remote_file does not exist."
  exit 1
fi

# Loop through each remote in the file
while IFS= read -r remote; do
  if [ -n "$remote" ]; then
    echo "Processing remote: $remote"

    # Add the remote
     git remote add temp_remote "$remote"

    # Push HEAD to the 'feedback' branch on the remote
    git push temp_remote HEAD:feedback

    # Remove the remote
    git remote remove temp_remote

    echo "Finished processing remote: $remote"
  fi
done < "$remote_file"

echo "All remotes processed."
