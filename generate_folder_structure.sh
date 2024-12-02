#!/bin/bash

# Determine the current working directory
CURRENT_DIR=$(pwd)

# Create the Folder Structure.md file in the specified directory
mkdir -p "$CURRENT_DIR/Tests/PlaybackSDKTests"
echo "# Folder Structure" > "$CURRENT_DIR/Tests/PlaybackSDKTests/Folder Structure.md"
echo "" >> "$CURRENT_DIR/Tests/PlaybackSDKTests/Folder Structure.md"
echo "This file represents the folder structure of the project." >> "$CURRENT_DIR/Tests/PlaybackSDKTests/Folder Structure.md"
echo "You can update it with the actual structure if needed." >> "$CURRENT_DIR/Tests/PlaybackSDKTests/Folder Structure.md"

echo "Folder Structure.md generated successfully in $CURRENT_DIR/Tests/PlaybackSDKTests"