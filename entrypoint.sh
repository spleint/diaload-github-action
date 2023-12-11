#!/bin/bash

# Fail the script if any command fails
set -e

# Your inputs are available as environment variables
API_TOKEN=$INPUT_API_TOKEN
APP_ID=$INPUT_APP_ID
FILE=$INPUT_FILE
RELEASE_NOTES=$INPUT_RELEASE_NOTES
GIT_RELEASE_NOTES=$INPUT_GIT_RELEASE_NOTES
INCLUDE_GIT_COMMIT_ID=$INPUT_INCLUDE_GIT_COMMIT_ID
GROUP_ID=$INPUT_GROUP_ID

# Install diaload-cli
yarn global add diaload-cli

export DIALOAD_ACCESS_TOKEN=$API_TOKEN

# Combine release notes if both are provided
COMBINED_RELEASE_NOTES="$RELEASE_NOTES"
if [ "$GIT_RELEASE_NOTES" = "true" ]; then
    LAST_GIT_COMMIT_MSG=$(git log -1 --pretty=%B)
    COMBINED_RELEASE_NOTES="$COMBINED_RELEASE_NOTES\n\n$LAST_GIT_COMMIT_MSG"
fi

if [ "$INCLUDE_GIT_COMMIT_ID" = "true" ]; then
    LAST_GIT_COMMIT_ID=$(git rev-parse HEAD)
    COMBINED_RELEASE_NOTES="$COMBINED_RELEASE_NOTES\n\nCommit ID: $LAST_GIT_COMMIT_ID"
fi

# Echo inputs for debugging (Sensitive data is not logged)
echo "App ID: $APP_ID"
echo "File: $FILE"
echo "Group ID: $GROUP_ID"

# Using diaload-cli to create a release
# Add the -g parameter if GROUP_ID is provided
if [ -n "$GROUP_ID" ]; then
    diaload create-release -n "$COMBINED_RELEASE_NOTES" -a "$APP_ID" -f "$FILE" -g "$GROUP_ID"
else
    diaload create-release -n "$COMBINED_RELEASE_NOTES" -a "$APP_ID" -f "$FILE"
fi

# Add any additional handling or commands as needed
