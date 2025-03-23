#!/bin/bash

# Get the current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Variables
SERVER=${1:-"localhost:5010"}
ADMIN_EMAIL=${2:-"admin@example.com"}
ADMIN_PASSWORD=${3:-"admin123"}
PRODUCT_NAME=${4:-"New Product"}
PRODUCT_DESCRIPTION=${5:-"Product Description"}
PRODUCT_PRICE=${6:-100.00}
PRODUCT_STOCK=${7:-10}

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

# Call the standalone create product script and capture the response
echo "🔹 Creating a product with category ID: $random_category_id"
create_product_response=$(bash "$SCRIPT_DIR/../utils/create_product.sh" "$SERVER" "$token" "$PRODUCT_NAME" "$PRODUCT_DESCRIPTION" "$PRODUCT_PRICE" "$PRODUCT_STOCK" "$random_category_id")
echo "🔹 Create Product Response: $create_product_response"