#!/bin/sh

find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec sed -i .sed 's/\$PROJECT_NAME/'$1'/g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec sed -i .sed 's/\$USERNAME/'$2'/g' {} \;
find . -path ./.git -prune -o -name '*.sed' -exec rm {} \;

rm -rf .git