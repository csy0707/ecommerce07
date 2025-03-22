#!/bin/bash

# Get the current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Variables
SERVER=${1:-"localhost:5010"}
ADMIN_USERNAME=${2:-"admin@example.com"}
ADMIN_PASSWORD=${3:-"admin123"}

UPDATED_PRODUCT_NAME="Updated Product"
UPDATED_PRODUCT_PRICE=99.99
UPDATED_PRODUCT_DESCRIPTION="Updated description"

# Main script
echo "🔹 Starting the update product test script..."

# Call the standalone login script and capture the token
token=$(bash "$SCRIPT_DIR/../utils/admin_login.sh" "$SERVER" "$ADMIN_USERNAME" "$ADMIN_PASSWORD")
if [[ -z "$token" ]]; then
    echo "❌ Login failed"
    exit 1
fi

echo "🔹 Admin Token: $token"

# Call the standalone get products script and capture the response
products_response=$(bash "$SCRIPT_DIR/../utils/get_products.sh" "$SERVER" "$token")

# Debugging: Print the raw products response
echo "🔹 Raw Products Response: $products_response"

# Attempt to parse product IDs
product_ids=$(echo $products_response | jq -r '.[]._id' 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Failed to parse product IDs. Exiting."
    exit 1
fi

product_id_array=($product_ids)
echo "🔹 Number of products: ${#product_id_array[@]} " 

# Check if there are no products
if [ ${#product_id_array[@]} -eq 0 ]; then
    echo "❌ No products found. Exiting."
    exit 1
fi

random_product_id=${product_id_array[$RANDOM % ${#product_id_array[@]}]}

# Call the standalone update product script and capture the response
update_response=$(bash "$SCRIPT_DIR/../utils/update_product.sh" "$SERVER" "$token" "$random_product_id" "$UPDATED_PRODUCT_NAME" "$UPDATED_PRODUCT_PRICE" "$UPDATED_PRODUCT_DESCRIPTION")
echo "🔹 Update response: $update_response"

echo "🔹 Finished the update product test script."