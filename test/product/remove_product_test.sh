#!/bin/bash

# Get the current script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

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
CREATE_PRODUCT_RESPONSE=$(bash "$SCRIPT_DIR/../utils/create_product.sh" "$SERVER" "$ADMIN_TOKEN" "$PRODUCT_NAME" "$PRODUCT_DESCRIPTION" "$PRODUCT_PRICE" "$PRODUCT_STOCK" "$PRODUCT_CATEGORY" "$PRODUCT_IMAGE")

# Debugging: Print the create product response
echo "🔹 Create Product Response: $CREATE_PRODUCT_RESPONSE"

# Main script
echo "🔹 Starting the remove product test script..."

# Call the standalone get products script and capture the response
products_response=$(bash "$SCRIPT_DIR/../utils/get_products.sh" "$SERVER" "$ADMIN_TOKEN")

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

# Call the standalone remove product script and capture the response
echo "🔹 Removing a random product..."
remove_response=$(bash "$SCRIPT_DIR/../utils/remove_product.sh" "$SERVER" "$ADMIN_TOKEN" "$random_product_id")
echo "🔹 Remove response: $remove_response"

echo "🔹 Finished the remove product test script."

