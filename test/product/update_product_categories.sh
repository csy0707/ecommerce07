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

# Call the standalone view products script and capture the response
echo "🔹 Viewing all products..."
products_response=$(bash "$SCRIPT_DIR/../utils/get_products.sh" "$SERVER" "$token")
echo "🔹 Products Response: $products_response"

# Parse product IDs from the response
product_ids=$(echo $products_response | jq -r '.[]._id')
product_id_array=($product_ids)

# Check if there are no products
if [ ${#product_id_array[@]} -eq 0 ]; then
    echo "❌ No products found. Exiting."
    exit 1
fi

# Select a random product ID
random_product_id=${product_id_array[$RANDOM % ${#product_id_array[@]}]}

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

# Call the standalone update product categories script and capture the response
echo "🔹 Updating product with ID: $random_product_id with category: $random_category_id"
update_product_response=$(bash "$SCRIPT_DIR/../utils/update_product_category.sh" "$SERVER" "$token" "$random_product_id" "$random_category_id")
echo "🔹 Update Product Response: $update_product_response"