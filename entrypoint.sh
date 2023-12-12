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

# Prepare the POST request
POST_URL="https://api.diaload.com/appservice/releases"

# Make the POST request using curl
HTTP_RESPONSE=$(curl -X POST $POST_URL \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "X-App-Origin: cli" \
     -H "Accept: application/json" \
     -H "Accept-Language: en-US" \
     -F "app_id=$APP_ID" \
     -F "release_notes=$COMBINED_RELEASE_NOTES" \
     -F "source=actions" \
     -F "group_id=$GROUP_ID" \
     -F "file=@$FILE" \
     -w '%{http_code}' -o response.json -s)

     echo "HTTP Response Code: $HTTP_RESPONSE"

     # Check if the response is not a success code (200-299)
     if [ $HTTP_RESPONSE -lt 200 ] || [ $HTTP_RESPONSE -gt 299 ]; then
          ERROR_CODE=$(jq -r '.error_code' response.json)
          ERROR_MESSAGE=$(jq -r '.message' response.json)

          echo "Failed to create new release: $ERROR_MESSAGE, Error code - $ERROR_CODE"
          exit 1
     fi

# Add any additional handling or commands as needed
