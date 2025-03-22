#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Construct the path to initAdmin.js
INIT_ADMIN_SCRIPT="$SCRIPT_DIR/../../scripts/initAdmin.js"

# Variables from command-line arguments or use default values
SERVER=${1:-"localhost:5010"}
ADMIN_EMAIL=${2:-"admin@example.com"}
ADMIN_PASSWORD=${3:-"admin123"}
NEW_ADMIN_EMAIL=${4:-"newadmin@example.com"}
NEW_ADMIN_PASSWORD=${5:-"newadmin123"}
NEW_ADMIN_USERNAME=${6:-"newadmin"}
NEW_ADMIN_ROLE=${7:-"admin"}

API_URL="http://$SERVER/api"
LOGIN_ENDPOINT="/users/login"
REGISTER_ADMIN_ENDPOINT="/users/register/admin"

# Initialize the administrator and capture the output
echo "Initializing the administrator..."
init_output=$(node "$INIT_ADMIN_SCRIPT")

# Extract the admin password from the output
ADMIN_PASSWORD=$(echo "$init_output" | grep -oP '(?<=Admin password: ).*')

# Check if the password was extracted successfully
if [ -z "$ADMIN_PASSWORD" ]; then
    echo "❌ Failed to initialize the administrator or retrieve the password."
    exit 1
fi

echo "✅ Administrator initialized with password: $ADMIN_PASSWORD"

# Login as Admin to get the token
echo "Logging in as Admin..."
LOGIN_URL="$API_URL$LOGIN_ENDPOINT"
login_response=$(curl -s -X POST $LOGIN_URL \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"$ADMIN_EMAIL\", \"password\": \"$ADMIN_PASSWORD\"}")

# Debugging: Print the raw login response
echo "🔹 Raw Login Response: $login_response"

ADMIN_TOKEN=$(echo "$login_response" | jq -r '.token')

# Check if the token was retrieved successfully
if [ -z "$ADMIN_TOKEN" ] || [ "$ADMIN_TOKEN" == "null" ]; then
    echo "❌ Failed to retrieve admin token. Response: $login_response"
    exit 1
fi

echo "✅ Admin token retrieved: $ADMIN_TOKEN"

# Create the new admin user using the standalone script
echo "🔹 Creating a new admin user..."
create_admin_response=$(bash "$SCRIPT_DIR/../utils/create_admin.sh" "$SERVER" "$ADMIN_TOKEN" "$NEW_ADMIN_USERNAME" "$NEW_ADMIN_EMAIL" "$NEW_ADMIN_PASSWORD" "$NEW_ADMIN_ROLE")


# Extract the HTTP status code and response body
http_code=$(echo "$create_admin_response" | tail -n2 | head -n1)
response_body=$(echo "$create_admin_response" | head -n-2)

# Print the response
echo "Response: $response_body"

# Check the response status code
if [ "$http_code" -eq 201 ]; then
    echo "✅ New admin user created successfully"
    echo "Response: $response_body"
elif [ "$http_code" -eq 400 ]; then
    echo "⚠️ New admin user already exists"
    echo "Response: $response_body"
else
    echo "❌ Failed to create new admin user. HTTP status code: $http_code"
    echo "Response: $response_body"
fi