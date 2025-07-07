#!/bin/bash

# LuCI Mobile Release Script
# Usage: ./scripts/release.sh [major|minor|patch]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "This script must be run from the project root directory"
    exit 1
fi

# Check if git is clean
if [ -n "$(git status --porcelain)" ]; then
    print_error "Working directory is not clean. Please commit or stash your changes first."
    exit 1
fi

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
print_status "Current version: $CURRENT_VERSION"

# Parse version components
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Determine release type
RELEASE_TYPE=${1:-patch}

case $RELEASE_TYPE in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_PATCH=0
        ;;
    minor)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_PATCH=0
        ;;
    patch)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$((PATCH + 1))
        ;;
    *)
        print_error "Invalid release type. Use: major, minor, or patch"
        exit 1
        ;;
esac

NEW_VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
TAG_VERSION="v$NEW_VERSION"

print_status "New version: $NEW_VERSION"
print_status "Tag version: $TAG_VERSION"

# Confirm release
read -p "Do you want to create release $TAG_VERSION? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Release cancelled"
    exit 0
fi

# Update pubspec.yaml
print_status "Updating pubspec.yaml..."
sed -i.bak "s/^version: .*/version: $NEW_VERSION+1/" pubspec.yaml
rm pubspec.yaml.bak

# Run tests
print_status "Running tests..."
flutter test

# Analyze code
print_status "Analyzing code..."
flutter analyze

# Build APK
print_status "Building APK..."
flutter build apk --release

# Commit changes
print_status "Committing changes..."
git add pubspec.yaml
git commit -m "chore: bump version to $NEW_VERSION"

# Create and push tag
print_status "Creating tag $TAG_VERSION..."
git tag -a "$TAG_VERSION" -m "Release $TAG_VERSION"
git push origin main
git push origin "$TAG_VERSION"

print_status "Release $TAG_VERSION created successfully!"
print_status "APK built at: build/app/outputs/flutter-apk/app-release.apk"
print_status "You can now create a release on GitHub with the tag $TAG_VERSION"

# Optional: Create GitHub release using gh CLI if available
if command -v gh &> /dev/null; then
    read -p "Do you want to create a GitHub release now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Creating GitHub release..."
        gh release create "$TAG_VERSION" \
            --title "LuCI Mobile $NEW_VERSION" \
            --notes "Release $NEW_VERSION of LuCI Mobile" \
            build/app/outputs/flutter-apk/app-release.apk
        print_status "GitHub release created!"
    fi
fi 