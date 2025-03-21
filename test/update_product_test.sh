#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
LOGIN_ENDPOINT="/users/login"
PRODUCTS_ENDPOINT="/products"
ADMIN_USERNAME=${2:-"admin@example.com"}
ADMIN_PASSWORD=${3:-"admin123"}


UPDATED_PRODUCT_NAME="Updated Product"
UPDATED_PRODUCT_PRICE=99.99
UPDATED_PRODUCT_DESCRIPTION="Updated description"

# Function to login and get the token
login() {
    response=$(curl -s -X POST "$API_URL$LOGIN_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "{\"email\": \"$ADMIN_USERNAME\", \"password\": \"$ADMIN_PASSWORD\"}")

    token=$(echo $response | jq -r '.token')
    if [ "$token" == "null" ] || [ -z "$token" ]; then
        exit 1
    fi

    echo $token
}

# Function to get all products
get_products() {
    token=$1

    response=$(curl -s -X GET "$API_URL$PRODUCTS_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token")

    echo $response
}

# Function to update the product
update_product() {
    token=$1
    product_id=$2

    response=$(curl -s -X PUT "$API_URL$PRODUCTS_ENDPOINT/$product_id" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token" \
        -d "{
            \"name\": \"$UPDATED_PRODUCT_NAME\",
            \"price\": $UPDATED_PRODUCT_PRICE,
            \"description\": \"$UPDATED_PRODUCT_DESCRIPTION\"
        }")

    echo $response
}

# Main script
echo "🔹 Starting the update product test script..."

token=$(login)
if [[ -z "$token" ]]; then
    echo "❌ Login failed"
    exit 1
fi

echo "🔹 Admin Token: $token"

products_response=$(get_products $token)

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

update_response=$(update_product $token $random_product_id)
echo "🔹 Update response: $update_response"

echo "🔹 Finished the update product test script."