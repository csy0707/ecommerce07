#!/bin/bash

# Variables
SERVER=${1:-"localhost:5010"}
API_URL="http://$SERVER/api"
REGISTER_ENDPOINT="/users/register"
LOGIN_ENDPOINT="/users/login"
PRODUCTS_ENDPOINT="/products"

# Get command-line arguments for admin email and password
ADMIN_EMAIL=${2:-"admin@example.com"}
ADMIN_PASSWORD=${3:-"admin123"}

# Product details
PRODUCT_NAME="Laptop"
PRODUCT_DESCRIPTION="Powerful gaming laptop"
PRODUCT_PRICE=1500
PRODUCT_STOCK=10
PRODUCT_CATEGORY="Electronics"
PRODUCT_IMAGE="https://example.com/laptop.jpg"

# Function to login and get the token
login() {
    response=$(curl -s -X POST "$API_URL$LOGIN_ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "{\"email\": \"$ADMIN_EMAIL\", \"password\": \"$ADMIN_PASSWORD\"}")

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

# Function to remove a product
remove_product() {
    token=$1
    product_id=$2

    response=$(curl -s -X DELETE "$API_URL$PRODUCTS_ENDPOINT/$product_id" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token")

    echo $response
}

# 1️⃣ Register an admin user
echo "🔹 Registering Admin User..."
REGISTER_ADMIN_RESPONSE=$(curl -s -X POST "$API_URL$REGISTER_ENDPOINT" \
-H "Content-Type: application/json" \
-d "{\"username\": \"admin\", \"email\": \"$ADMIN_EMAIL\", \"password\": \"$ADMIN_PASSWORD\", \"role\": \"admin\"}")

echo "Admin Registration Response: $REGISTER_ADMIN_RESPONSE"

# 2️⃣ Login as Admin
echo "🔹 Logging in as Admin..."
ADMIN_TOKEN=$(curl -s -X POST "$API_URL$LOGIN_ENDPOINT" \
-H "Content-Type: application/json" \
-d "{\"email\": \"$ADMIN_EMAIL\", \"password\": \"$ADMIN_PASSWORD\"}" | jq -r '.token')

echo "Admin Token: $ADMIN_TOKEN"

# Check if the token was retrieved successfully
if [ -z "$ADMIN_TOKEN" ]; then
    echo "❌ Failed to retrieve admin token."
    exit 1
fi

# 3️⃣ Create a product using admin token
echo "🔹 Creating a product..."
CREATE_PRODUCT_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL$PRODUCTS_ENDPOINT" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-d "{
  \"name\": \"$PRODUCT_NAME\",
  \"description\": \"$PRODUCT_DESCRIPTION\",
  \"price\": $PRODUCT_PRICE,
  \"stock\": $PRODUCT_STOCK,
  \"category\": \"$PRODUCT_CATEGORY\",
  \"image\": \"$PRODUCT_IMAGE\"
}")

# Extract the HTTP status code from the response
http_code=$(echo "$CREATE_PRODUCT_RESPONSE" | tail -n1)
response_body=$(echo "$CREATE_PRODUCT_RESPONSE" | sed '$d')

# Check the response status code
if [ "$http_code" -eq 201 ]; then
    echo "✅ Product created successfully"
    echo "Response: $response_body"
else
    echo "❌ Failed to create product. HTTP status code: $http_code"
    echo "Response: $response_body"
fi

# Main script
echo "🔹 Starting the remove product test script..."

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

# Check if there are no products
if [ ${#product_id_array[@]} -eq 0 ]; then
    echo "❌ No products found. Exiting."
    exit 1
fi

random_product_id=${product_id_array[$RANDOM % ${#product_id_array[@]}]}

# Remove a random product
echo "🔹 Removing a random product..."
remove_response=$(remove_product $token $random_product_id)
echo "🔹 Remove response: $remove_response"

echo "🔹 Finished the remove product test script."

