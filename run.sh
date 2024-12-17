git add .
git commit -m "update version"
git push origin main

ver=$(git tag | tail -1)
ver=${ver:1}
new_ver=$(echo "$ver + 0.1" | bc)
new_ver=v$new_ver

git tag -a $new_ver -m "version v$new_ver"
git push origin $new_ver