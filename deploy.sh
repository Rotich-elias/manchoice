#!/bin/bash

# Manchoice Flutter App - Firebase Deployment Script
# This script builds and deploys the Flutter web app to Firebase Hosting

set -e  # Exit on error

echo "================================================"
echo "Manchoice Flutter App - Firebase Deployment"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${YELLOW}Warning: Firebase CLI is not installed${NC}"
    echo "Installing Firebase CLI..."
    npm install -g firebase-tools
fi

# Step 1: Clean previous builds
echo -e "${YELLOW}[1/6] Cleaning previous builds...${NC}"
flutter clean
rm -rf build/

# Step 2: Get dependencies
echo -e "${YELLOW}[2/6] Getting Flutter dependencies...${NC}"
flutter pub get

# Step 3: Run tests (optional, comment out if you don't have tests)
# echo -e "${YELLOW}[3/6] Running tests...${NC}"
# flutter test

# Step 4: Build web app for production
echo -e "${YELLOW}[3/6] Building Flutter web app for production...${NC}"
echo "This may take a few minutes..."
flutter build web --release --web-renderer html

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo -e "${RED}Error: Build failed. build/web directory not found.${NC}"
    exit 1
fi

# Step 5: Check Firebase configuration
echo -e "${YELLOW}[4/6] Checking Firebase configuration...${NC}"
if [ ! -f "firebase.json" ]; then
    echo -e "${RED}Error: firebase.json not found. Please run 'firebase init' first.${NC}"
    exit 1
fi

# Step 6: Login to Firebase (if not already logged in)
echo -e "${YELLOW}[5/6] Checking Firebase authentication...${NC}"
firebase login --reauth 2>/dev/null || true

# Step 7: Deploy to Firebase
echo -e "${YELLOW}[6/6] Deploying to Firebase Hosting...${NC}"
firebase deploy --only hosting

# Success message
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Deployment successful!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Your app should be available at:"
firebase hosting:sites:list

echo ""
echo -e "${YELLOW}Important:${NC} Make sure you've updated the production API URL in:"
echo "  lib/config/api_config.dart (_prodBaseUrl)"
echo ""
