#!/bin/bash

# Get the current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

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
ADMIN_TOKEN=$(bash "$SCRIPT_DIR/../utils/admin_login.sh" "$SERVER" "$ADMIN_EMAIL" "$ADMIN_PASSWORD")

echo "Admin Token: $ADMIN_TOKEN"

# Check if the token was retrieved successfully
if [ -z "$ADMIN_TOKEN" ]; then
    echo "❌ Failed to retrieve admin token."
    exit 1
fi

# 3️⃣ Create a product using admin token
echo "🔹 Creating a product..."
CREATE_PRODUCT_RESPONSE=$(bash "$SCRIPT_DIR/../utils/create_product.sh" "$SERVER" "$ADMIN_TOKEN")

# Debugging: Print the create product response
echo "🔹 Create Product Response: $CREATE_PRODUCT_RESPONSE"