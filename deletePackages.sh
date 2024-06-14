#!/bin/bash

# Prompt for variables
read -p "Enter the Jamf Pro URL (e.g., https://your.jamf.server:8443): " JAMF_URL
read -p "Enter the Package IDs (comma-separated): " PACKAGE_IDS
read -p "Enter your Jamf Pro username: " USERNAME
read -sp "Enter your Jamf Pro password: " PASSWORD
echo

# Variable declarations
bearerToken=""
tokenExpirationEpoch="0"

getBearerToken() {
    response=$(curl -s -u "$USERNAME:$PASSWORD" "$JAMF_URL/api/v1/auth/token" -X POST)
    bearerToken=$(echo "$response" | plutil -extract token raw -)
    if [ -z "$bearerToken" ] || [ "$bearerToken" == "null" ]; then
        echo "Failed to get token. Please check your username and password."
        exit 1
    fi
    tokenExpiration=$(echo "$response" | plutil -extract expires raw - | awk -F . '{print $1}')
    tokenExpirationEpoch=$(date -j -f "%Y-%m-%dT%T" "$tokenExpiration" +"%s")
}

checkTokenExpiration() {
    nowEpochUTC=$(date -j -f "%Y-%m-%dT%T" "$(date -u +"%Y-%m-%dT%T")" +"%s")
    if [[ $tokenExpirationEpoch -gt $nowEpochUTC ]]; then
        echo "Token valid until the following epoch time: $tokenExpirationEpoch"
    else
        echo "No valid token available, getting new token"
        getBearerToken
    fi
}

invalidateToken() {
    responseCode=$(curl -w "%{http_code}" -H "Authorization: Bearer ${bearerToken}" $JAMF_URL/api/v1/auth/invalidate-token -X POST -s -o /dev/null)
    if [[ ${responseCode} == 204 ]]; then
        echo "Token successfully invalidated"
        bearerToken=""
        tokenExpirationEpoch="0"
    elif [[ ${responseCode} == 401 ]]; then
        echo "Token already invalid"
    else
        echo "An unknown error occurred invalidating the token"
    fi
}

# Get a valid token
getBearerToken

# Convert comma-separated PACKAGE_IDS to an array
IFS=',' read -r -a PACKAGE_ID_ARRAY <<< "$PACKAGE_IDS"

# Loop through each package ID and delete the package
for PACKAGE_ID in "${PACKAGE_ID_ARRAY[@]}"; do
    DELETE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE -L "$JAMF_URL/JSSResource/packages/id/$PACKAGE_ID" -H "Accept: application/xml" -H "Authorization: Bearer $bearerToken")

    # Check the response
    if [ "$DELETE_RESPONSE" -eq 200 ]; then
        echo "Package ID $PACKAGE_ID deleted successfully."
    elif [ "$DELETE_RESPONSE" -eq 404 ]; then
        echo "Package ID $PACKAGE_ID not found."
    else
        echo "Failed to delete package ID $PACKAGE_ID. HTTP response code: $DELETE_RESPONSE"
    fi
done

# Invalidate the token
invalidateToken
