#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
PRODUCTS_ENDPOINT="/products"
TOKEN=$2
PRODUCT_NAME=${3:-"Laptop"}
PRODUCT_DESCRIPTION=${4:-"Powerful gaming laptop"}
PRODUCT_PRICE=${5:-1500}
PRODUCT_STOCK=${6:-10}
PRODUCT_CATEGORY=${7:-"Electronics"}
PRODUCT_IMAGE=${8:-"https://example.com/laptop.jpg"}

# Function to create a product
create_product() {
    response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL$PRODUCTS_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "{
          \"name\": \"$PRODUCT_NAME\",
          \"description\": \"$PRODUCT_DESCRIPTION\",
          \"price\": $PRODUCT_PRICE,
          \"stock\": $PRODUCT_STOCK,
          \"category\": \"$PRODUCT_CATEGORY\",
          \"image\": \"$PRODUCT_IMAGE\"
        }")

    # Extract the HTTP status code from the response
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')

    # Check the response status code
    if [ "$http_code" -eq 201 ]; then
        echo "✅ Product created successfully"
        echo "Response: $response_body"
    else
        echo "❌ Failed to create product. HTTP status code: $http_code"
        echo "Response: $response_body"
    fi
}

# Call the create_product function
create_product