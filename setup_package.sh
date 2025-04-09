#!/bin/bash

# if node_modules exists, remove it
if [ -d node_modules ]; then
  echo "node_modules exists, removing it..."

  # continue Y/N

  read -p "Do you want to remove it? (y/n) " answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    echo "Removing node_modules..."
    rm -rf node_modules
  else
    echo "Exiting script."
    exit 1
  fi
else
  echo "OK node_modules does not exist, creating it..."
fi

# if package.json exists, remove it
if [ -f package.json ]; then
  echo "package.json exists, removing it..."

  # continue Y/N

  read -p "Do you want to remove it? (y/n) " answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    echo "Removing package.json..."
    rm -f package.json
  else
    echo "Exiting script."
    exit 1
  fi
else
  echo "OK package.json does not exist, creating it..."
  # create package.json
fi

#remove node_modules and pnpm-lock.yaml
rm -rf node_modules pnpm-lock.yaml
# remove package.json
rm -f package.json

# setup_package.sh
# Setup pnpm package
# Install
pnpm init
PROJECT_NAME="dns-check"
site="davit.ie"
author="David Mullins"

# Initialize monorepo with pnpm workspaces
echo "Initializing pnpm workspace..."
#mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME" || exit
pnpm pkg set name="$PROJECT_NAME"
pnpm pkg set author="$author"
pnpm pkg set site="$site"
pnpm pkg set version="0.0.1"
pnpm pkg set description="A test testing"
pnpm pkg set private=true --json
#pnpm pkg set repository="{ type: git, url: git+https://github.com/DavitTec/$PROJECT_NAME.git\}"
pnpm pkg set keywords[0]='bash' keywords[1]='nodejs' keywords[2]='html'
pnpm pkg set author="David Mullins"
pnpm pkg set license="https://github.com/DavitTec/$PROJECT_NAME/blob/master/LICENSE"
pnpm pkg set bugs="url: https://github.com/DavitTec/$PROJECT_NAME/issues"
pnpm pkg set homepage="https://github.com/DavitTec/$PROJECT_NAME#readme"
pnpm pkg set repository='{"type": "git", "url": "git+https://github.com/DavitTec/'$PROJECT_NAME'.git"}' --json

pnpm add --save-dev standard-version

pnpm pkg set scripts.release="standard-version && ./update-version.sh"
pnpm pkg set scripts.prelease="standard-version --prerelease"
pnpm pkg set scripts.test="./test/test_dns-check.sh"
#pnpm add -D typescript ts-node @types/node
#pnpm add - eslint prettier eslint-config-prettier eslint-plugin-prettier

exit 0

# Create tsconfig.json
cat <<EOL >tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "CommonJS",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.spec.ts"]
}
EOL
