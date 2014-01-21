#!/bin/bash 

# Install packages
function dependencies {
   echo "Download dependencies..."
   pub get   	
}

# Run test if exist
function runTests {
	if [ -f "test/run.sh" ];
	then
		echo "Run tests..."
		test/run.sh
	fi
}

# Deploy
function build {
	if [ -f "build.dart" ];
	then
		echo "Build...."
		dart build.dart
	fi	
	echo "Build deployment..."
	pub build
}

# Modify files organisation for deploy
function prepareDeploy {
	echo "Prepare deploy..."

	# Rewrite new .gitignore
	echo ".gitignore" > .gitignore 
	echo "deploy.sh" >> .gitignore
	echo "Readme.md" >> .gitignore
	git rm .gitignore --cached

	# Clean unused dir
	rm pubspec.*
	rm -rf packages
	rm -rf test
	rm -rf bin
	rm -rf web
	cp -r build/* .
	rm -rf build
}

# Deploy to github page
function deploy {
	ls -l
	git add -A
	git commit -m 'Deploy to github pages'
	git remote add github git@github.com:$1.git
	git push --force github master:gh-pages
}


if [ $# -ne 1 ]
then
  echo "Usage: deploy [user/project]"
  echo "Example :"
  echo "./deploy.sh nfrancois/balle"
  exit 65
fi

remote=$1
dependencies
runTests 
build
prepareDeploy
deploy $remote
