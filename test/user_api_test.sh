#!/bin/bash

# Set variables from command-line arguments or use default values
SERVER=${1:-"localhost:5010"}
USER=${2:-"test0707"}
EMAIL=${3:-"test0707@example.com"}
PASSWORD=${4:-"password123"}

API_URL="http://$SERVER/api"
REGISTER_ENDPOINT="/users/register"
LOGIN_ENDPOINT="/users/login"
PROFILE_ENDPOINT="/users/profile"
LOGOUT_ENDPOINT="/users/logout"

# 0️⃣ Test User Registration
echo "🔹 Testing User Registration..."
REGISTER_URL="$API_URL$REGISTER_ENDPOINT"
REGISTER_RESPONSE=$(curl -s -X POST $REGISTER_URL \
-H "Content-Type: application/json" \
-d "{\"username\": \"$USER\", \"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}")

REGISTER_SUCCESS=$(echo "$REGISTER_RESPONSE" | jq -r '.message')
if [[ "$REGISTER_SUCCESS" == "User registered successfully" ]]; then
    echo "✅ Registration successful!"
else
    echo "⚠️ Registration may have failed: $REGISTER_RESPONSE"
fi

# 1️⃣ Test Login and Retrieve JWT Token
LOGIN_URL="$API_URL$LOGIN_ENDPOINT"
TOKEN=$(curl -s -X POST $LOGIN_URL \
-H "Content-Type: application/json" \
-d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}" | jq -r '.token')

# Check if Token is retrieved successfully
if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
    echo "❌ Login failed: Could not retrieve token."
    exit 1
else
    echo "✅ Login successful! Token: $TOKEN"
fi

# 2️⃣ Test Retrieve User Profile
PROFILE_URL="$API_URL$PROFILE_ENDPOINT"
curl -X GET $PROFILE_URL \
-H "Authorization: Bearer $TOKEN"

# 3️⃣ Test logout the user
LOGOUT_URL="$API_URL$LOGOUT_ENDPOINT"
LOGOUT_RESPONSE=$(curl -s -X POST $LOGOUT_URL \
-H "Authorization: Bearer $TOKEN")

LOGOUT_MESSAGE=$(echo "$LOGOUT_RESPONSE" | jq -r '.message')
if [[ "$LOGOUT_MESSAGE" == "Logged out successfully" ]]; then
    echo "✅ Logout successful!"
else
    echo "❌ Logout may have failed: $LOGOUT_RESPONSE"
fi

# 4️⃣ Test Retrieve User Profile after logout (should be unauthorized)
PROFILE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X GET $PROFILE_URL \
-H "Authorization: Bearer $TOKEN")

if [[ "$PROFILE_RESPONSE" == "401" ]]; then
    echo "✅ Token is invalid after logout (expected behavior)"
else
    echo "❌ Token still works after logout, something is wrong"
fi