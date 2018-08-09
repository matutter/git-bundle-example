#!/bin/bash 

dir="work-tree"
rm $dir "$dir-2" -rf
mkdir -p $dir
pushd $dir

git init
for i in {1..6}; do
    f="$i.txt"
    echo "File #$i" > $f
    git add $f
    git commit -m "Making commit #$i"
done
 
ls

rev=`git rev-list --all | head -3 | tail -1`
echo "Bundling $rev"

function tag {
  tag="x-$1"
  echo "$tag"
  git tag $tag $1 
}

revtag=`tag $rev`
tag `git rev-list --max-parents=0 $rev`
#for parent in $(git rev-list ${rev}^@); do
#tag $parent
#done

git bundle create ../bundle --tags='x-*'
git bundle create ../bundle-2 $revtag..HEAD

initial_rev=`git rev-list HEAD | tail -1`
if git bundle list-heads ../bundle | grep $initial_rev; then
  echo "Exported initial commit: $initial_rev"
else
  echo "Failed export a complete history..." && exit
fi

popd
dir="$dir-2"
mkdir -p $dir
pushd $dir
git init
git pull ../bundle "x-$rev"
git rev-list --all
git pull ../bundle-2 HEAD
git rev-list --all

