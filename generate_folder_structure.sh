#!/bin/bash

# Determine the current working directory
CURRENT_DIR=$(pwd)

# Check for tree using Homebrew, installs it if needed
if ! command -v tree &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew install tree
fi

# Create the Folder Structure.md file in the Tests directory
mkdir -p "$CURRENT_DIR/Tests/PlaybackSDKTests"
echo "# Folder Structure" > "$CURRENT_DIR/Tests/PlaybackSDKTests/Folder Structure.md"
echo "" >> "$CURRENT_DIR/Tests/PlaybackSDKTests/Folder Structure.md"

cd "$CURRENT_DIR/Tests/"
tree --noreport -I "*.md" "PlaybackSDKTests" >> "$CURRENT_DIR/Tests/PlaybackSDKTests/Folder Structure.md"
echo "Folder Structure.md generated successfully in $CURRENT_DIR/Tests/PlaybackSDKTests"

# Create the Folder Structure.md file in the Sources directory
mkdir -p "$CURRENT_DIR/Sources/PlaybackSDK"
echo "# Folder Structure" > "$CURRENT_DIR/Sources/PlaybackSDK/Folder Structure.md"
echo "" >> "$CURRENT_DIR/Sources/PlaybackSDK/Folder Structure.md"

cd "$CURRENT_DIR/Sources/"
tree --noreport -I "*.md|*.docc|*.xcprivacy" "PlaybackSDK" >> "$CURRENT_DIR/Sources/PlaybackSDK/Folder Structure.md"
echo "Folder Structure.md generated successfully in $CURRENT_DIR/Sources/PlaybackSDK"
