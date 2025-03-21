#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
LOGIN_ENDPOINT="/users/login"
PRODUCTS_ENDPOINT="/products"
USER_EMAIL=${2:-"test0707@example.com"}
USER_PASSWORD=${3:-"password123"}

# Function to login and get the token
login() {
    response=$(curl -s -X POST "$API_URL$LOGIN_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "{\"email\": \"$USER_EMAIL\", \"password\": \"$USER_PASSWORD\"}")

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

# Function to view a product
view_product() {
    token=$1
    product_id=$2

    response=$(curl -s -X GET "$API_URL$PRODUCTS_ENDPOINT/$product_id" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token")

    echo $response
}

# Main script
echo "🔹 Starting the view product test script..."

token=$(login)
if [[ -z "$token" ]]; then
    echo "❌ Login failed"
    exit 1
fi

echo "🔹 User Token: $token"

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

# Check if there are no products
if [ ${#product_id_array[@]} -eq 0 ]; then
    echo "❌ No products found. Exiting."
    exit 1
fi

random_product_id=${product_id_array[$RANDOM % ${#product_id_array[@]}]}

# View a random product
echo "🔹 Viewing a random product..."
view_response=$(view_product $token $random_product_id)
echo "🔹 View response: $view_response"

echo "🔹 Finished the view product test script."