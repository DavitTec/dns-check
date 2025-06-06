#!/bin/bash
# update-version.sh - Update version numbers in dns-check scripts
new_version=$(node -p "require('./package.json').version")
sed -i "s/Version: [0-9.]*$/Version: $new_version/" ./src/dns-check.sh
sed -i "s/version=[0-9.]*$/version=$new_version/" ./test/test_dns-check.sh
git add src/dns-check.sh test/test_dns-check.sh package.json
git commit -m "chore: update version to $new_version"
echo "Version updated to $new_version"
