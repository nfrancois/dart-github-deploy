#!/bin/bash 

# Install packages
function dependencies {
   pub install   	
}

# Run build script if exist
function build {
	if [ -f "bin/build.sh" ];
	then
		bin/build.sh
	fi  	
}

# Run test if exist
function runTests {
	if [ -f "build.dart" ];
	then
		dart build.dart
	fi
}

# Compile dart to js
function compileToJs {
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

# Modify files organisation for deploy
function prepareDeploy {
	# Copy package links
	copySymLink ./packages/
	copySymLink .

	# Rewrite new .gitignore
	echo "pubspec.*" > .gitignore
	echo ".gitignore" >> .gitignore
	echo "*.deps" >> .gitignore  
	echo "deploy.sh" >> .gitignore
	echo "Readme.md" >> .gitignore 
	git rm .gitignore --cached

	# Clean unused dir
	rm pubspec.*
	#rm test
	#rm bin
	# Cleaning : web/* to root
	rm -rf web/packages
	mv web/* .
	rm -rf web
}

# Deploy to github page
function deploy {
	git add -A
	git commit -m 'Deploy to github pages'
	git remote add github $1
	git push --force github master:gh-pages
}


if [ $# -ne 2 ]
then
  echo "Usage: deploy [remote] [dartScriptPath] ...."
  echo "Example :"
  echo "./deploy.sh git@github.com:nfrancois/balle.git web/balle.dart"
  exit 65
fi

remote=$1
shift
dependencies
for param in "$*"
do
	compileToJs $param
done
build
runTests $2
prepareDeploy 
deploy $remote
