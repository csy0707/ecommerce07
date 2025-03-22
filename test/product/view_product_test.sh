#!/bin/bash

# Get the current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Variables
SERVER=${1:-"localhost:5010"}
USER_EMAIL=${2:-"test0707@example.com"}
USER_PASSWORD=${3:-"password123"}

# Main script
echo "🔹 Starting the view product test script..."

# Call the standalone login script and capture the token
token=$(bash "$SCRIPT_DIR/../utils/login.sh" "$SERVER" "$USER_EMAIL" "$USER_PASSWORD")
if [[ -z "$token" ]]; then
    echo "❌ Login failed"
    exit 1
fi

echo "🔹 User Token: $token"

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

# Check if there are no products
if [ ${#product_id_array[@]} -eq 0 ]; then
    echo "❌ No products found. Exiting."
    exit 1
fi

random_product_id=${product_id_array[$RANDOM % ${#product_id_array[@]}]}

# Call the standalone view product script and capture the response
echo "🔹 Viewing a random product..."
view_response=$(bash "$SCRIPT_DIR/../utils/view_product.sh" "$SERVER" "$token" "$random_product_id")
echo "🔹 View response: $view_response"

echo "🔹 Finished the view product test script."