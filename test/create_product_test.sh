#!/bin/bash

# Variables
SERVER="localhost:5010"
API_URL="http://$SERVER/api"
REGISTER_ENDPOINT="/users/register"
LOGIN_ENDPOINT="/users/login"
PRODUCTS_ENDPOINT="/products"

# Get command-line arguments for admin email and password
ADMIN_EMAIL=${1:-"admin@example.com"}
ADMIN_PASSWORD=${2:-"admin123"}

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
-d '{
  "name": "Laptop",
  "description": "Powerful gaming laptop",
  "price": 1500,
  "stock": 10,
  "category": "Electronics",
  "image": "https://example.com/laptop.jpg"
}')

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