#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
PRODUCTS_FILTER_ENDPOINT="/products/filter"
TOKEN=$2
CATEGORY_NAME=${3:-"Electronics"}

# Function to view products filtered by category name
view_products_by_category() {
    response=$(curl -s -X GET "$API_URL$PRODUCTS_FILTER_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -G --data-urlencode "category=$CATEGORY_NAME")

    echo $response
}

# Call the view_products_by_category function and print the response
view_products_by_category