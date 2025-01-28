#!/bin/bash

# Check if a file with repository URLs is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file_with_repos>"
  exit 1
fi

# Check if template.md exists
if [ ! -f "feedback.md" ]; then
  echo "Error: feedback.md file not found in the current directory."
  exit 1
fi

# Read the file containing repository URLs
repo_file="$1"

if [ ! -f "$repo_file" ]; then
  echo "File $repo_file does not exist."
  exit 1
fi

# Loop through each repository in the file
while IFS= read -r repo; do
  if [ -n "$repo" ]; then
    echo "Processing repository: $repo"

  # Extract the owner/repo part from the SSH URL
    repo_name=$(echo "$repo" | sed -E 's#git@github.com:(.*)\.git#\1#')

    # Check if repo_name is valid
    if [ -z "$repo_name" ]; then
      echo "Failed to parse repository name from $repo. Skipping."
      continue
    fi
    echo "Processing repo: $repo_name"

    # Check if the 'submission' branch exists on the remote
    branch_exists=$(git ls-remote --heads "$repo" submission | wc -l)

    if [ "$branch_exists" -eq 1 ]; then
      echo "Branch 'submission' exists on $repo_name. Using 'submission'."
      source_branch="submission"
    else
      echo "Branch 'submission' does not exist. Checking for 'main'."
      main_exists=$(git ls-remote --heads "$repo" main | wc -l)

      if [ "$main_exists" -eq 1 ]; then
        echo "Branch 'main' exists on $repo_name. Using 'main'."
        source_branch="main"
      else
        echo "Neither 'submission' nor 'main' branch exists on $repo_name. Skipping."
        continue
      fi
    fi

    # Create the pull request using hub (GitHub CLI)
    gh api repos/${repo_name}/pulls \
      -X POST \
      -f base=feedback \
      -f head=${source_branch} \
      -f title="Feedback" \
      -f body="$(cat feedback.md)"

    if [ $? -eq 0 ]; then
      echo "Pull request created successfully for $repo."
    else
      echo "Failed to create pull request for $repo."
    fi
  fi
done < "$repo_file"

echo "All repositories processed."
