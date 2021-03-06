#!/bin/bash
set -eo pipefail

if [[ $# -ne 2 ]]; then
    echo "Syntax: release [CURRENT_VERSION] [NEXT_VERSION]"
    exit 1
fi

if [[ -n $(git status -z) ]]; then
    echo "Repository not clean, ensure you have committed all your changes"
    exit 1
fi

CURRENT=$1
NEXT=$2

# Building
npm ci
npx ng build common
npx ng build custom-palette && cp -R projects/custom-palette/styles dist/custom-palette/

# Create new tag
git tag -a $CURRENT -m $CURRENT

# Publish tag
git push --tags

# Bump version
sed -i '' "s/$CURRENT/$NEXT/" projects/common/package.json
sed -i '' "s/$CURRENT/$NEXT/" projects/custom-palette/package.json

# Update develop with new bumped version
git commit -a -m"Bumped version ($NEXT) [ci skip]"
git push
