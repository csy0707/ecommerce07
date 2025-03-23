#!/bin/bash

# Get the current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Variables
SERVER=${1:-"localhost:5010"}
ADMIN_EMAIL=${2:-"admin@example.com"}
ADMIN_PASSWORD=${3:-"admin123"}
CATEGORY_NAMES=${4:-"Electronics,Books,Clothing,Home,Beauty,Sports,Toys,Automotive,Groceries,Health"}

# Call the standalone login script and capture the token
echo "🔹 Logging in as Admin..."
token=$(bash "$SCRIPT_DIR/../utils/login.sh" "$SERVER" "$ADMIN_EMAIL" "$ADMIN_PASSWORD")
if [[ -z "$token" ]]; then
    echo "❌ Login failed"
    exit 1
fi

echo "🔹 Admin Token: $token"

# Main script to add multiple categories
IFS=',' read -ra CATEGORIES <<< "$CATEGORY_NAMES"
for category in "${CATEGORIES[@]}"; do
    echo "🔹 Adding category: $category"
    response=$(bash "$SCRIPT_DIR/../utils/add_category.sh" "$SERVER" "$token" "$category")
    echo "🔹 Add Category Response for '$category_name': $response"
done