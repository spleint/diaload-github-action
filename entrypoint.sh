#!/bin/bash

# Fail the script if any command fails
set -e

# Inputs are available as environment variables
API_TOKEN=$INPUT_API_TOKEN
APP_ID=$INPUT_APP_ID
FILE=$INPUT_FILE
RELEASE_NOTES=$INPUT_RELEASE_NOTES
GIT_RELEASE_NOTES=$INPUT_GIT_RELEASE_NOTES
INCLUDE_GIT_COMMIT_ID=$INPUT_INCLUDE_GIT_COMMIT_ID
GROUP_ID=$INPUT_GROUP_ID
WORKSPACE_ID=$INPUT_WORKSPACE_ID

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
echo "Workspace ID: $WORKSPACE_ID"
echo "token ID: $API_TOKEN "

# Prepare the POST request
POST_URL="https://api.diaload.com/appservice/releases"
POST_FIELDS="app_id=$APP_ID&release_notes=$COMBINED_RELEASE_NOTES&source=actions"

# Add optional fields if provided
if [ -n "$GROUP_ID" ]; then
    POST_FIELDS="$POST_FIELDS&group_id=$GROUP_ID"
fi

if [ -n "$WORKSPACE_ID" ]; then
    POST_FIELDS="$POST_FIELDS&organisation_id=$WORKSPACE_ID"
fi

# Make the POST request using curl
curl -X POST $POST_URL \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "X-App-Origin: cli" \
     -H "Accept: application/json" \
     -H "Accept-Language: en-US" \
     -F "app_id=$APP_ID" \
     -F "release_notes=$COMBINED_RELEASE_NOTES" \
     -F "source=actions" \
     -F "group_id=$GROUP_ID" \
     -F "organisation_id=$WORKSPACE_ID" \
     -F "file=@$FILE"

# Add any additional handling or commands as needed
