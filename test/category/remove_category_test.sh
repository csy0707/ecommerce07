#!/bin/bash

# Get the current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Variables
SERVER=${1:-"localhost:5010"}
ADMIN_EMAIL=${2:-"admin@example.com"}
ADMIN_PASSWORD=${3:-"admin123"}

# Call the standalone login script and capture the token
echo "🔹 Logging in as Admin..."
token=$(bash "$SCRIPT_DIR/../utils/login.sh" "$SERVER" "$ADMIN_EMAIL" "$ADMIN_PASSWORD")
if [[ -z "$token" ]]; then
    echo "❌ Login failed"
    exit 1
fi

echo "🔹 Admin Token: $token"

# Call the standalone view categories script and capture the response
echo "🔹 Viewing all categories..."
categories_response=$(bash "$SCRIPT_DIR/../utils/view_categories.sh" "$SERVER" "$token")
echo "🔹 Categories Response: $categories_response"

# Parse category IDs from the response
category_ids=$(echo $categories_response | jq -r '.[]._id')
category_id_array=($category_ids)

# Check if there are no categories
if [ ${#category_id_array[@]} -eq 0 ]; then
    echo "❌ No categories found. Exiting."
    exit 1
fi

# Select a random category ID
random_category_id=${category_id_array[$RANDOM % ${#category_id_array[@]}]}

# Call the standalone remove category script and capture the response
echo "🔹 Removing a random category..."
remove_response=$(bash "$SCRIPT_DIR/../utils/remove_category.sh" "$SERVER" "$token" "$random_category_id")
echo "🔹 Remove Category Response: $remove_response"