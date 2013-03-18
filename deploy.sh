#!/bin/bash 

# compile dart to js
function compile {
   pub install
   dart2js --checked --minify --out=$1.js $1
}

# Replace package symlinks with real files
function copySymLink {
	for dir in $(find $1 -type l)
	do
		local rawDir=$(readlink -f $dir)
		echo Copy $rawDir to $dir 
		cp -r $rawDir $dir.tmp
		rm -r $dir
		mv $dir.tmp $dir
	done
}

function prepareDeploy {
	rm pubspec.*
	# Copy package links
	copySymLink ./packages/
	copySymLink .

	# Rewrite new .gitignore
	echo "pubspec.*" > .gitignore
	echo ".gitignore" >> .gitignore
	echo "*.deps" >> .gitignore  
	echo "deploy.sh" >> .gitignore 
	git rm .gitignore --cached
	# Cleaning : web/* to root
	rm -rf web/packages
	mv web/* .
	rm -rf web
}

function deploy {
	git add -A
	git commit -m 'Deploy to github pages'
	git remote add github $1
	git push --force github master:gh-pages
}


if [ $# -ne 2 ]
then
  echo "Usage: TODO "
  exit 65
fi

compile $1
prepareDeploy 
deploy $2