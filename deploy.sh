#!/bin/bash 

# Install packages
function dependencies {
   echo "Download dependencies..."
   pub install   	
}

# Run build script if exist
function build {
	if [ -f "bin/runTests.sh" ];
	then
		echo "Run build..."
		dart build.dart 
	fi  	
}

# Run test if exist
function runTests {
	if [ -f "bin/runTests.sh" ];
	then
		echo "Run build..."
		bin/runTests.sh
	fi
}

# Compile dart to js
function compileToJs {
   echo "Compile to js..."
   dart2js --checked --minify --out=$1.js $1
}

# Replace package symlinks with real files
function copySymLink {
	echo "Copy Sym Link..."
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
	echo "Prepare deploy..."
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
	# Cleaning : $1/* to root
	echo "Adding files from " $1
	rm -rf $1/packages
	mv $1/* .
	rm -rf $1
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
dependencies
#shift
#for param in "$*"
#do
compileToJs $2
#done
build
runTests 
dirToDeploy=`echo $2 | cut -d'|' -f1`
prepareDeploy $runTests
deploy $remote
