#!/bin/sh

find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec sed -i .sed 's/\$PROJECT_NAME/'$1'/g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec sed -i .sed 's/\$USERNAME/'$2'/g' {} \;
find . -path ./.git -prune -o -name '*.sed' -exec rm {} \;

rm -rf .git

mv project_name $1
cd ..
mv django-bare-bones $1-django
cd $1-django