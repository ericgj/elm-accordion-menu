#!/bin/bash

# Adapted from a more complex script by unsoundscapes:
#   https://github.com/w0rm/elm-gigs/blob/master/gh-pages.sh

set -e

rm -rf gh-pages || exit 0;

mkdir -p gh-pages

# compile and copy assets
cd examples
elm make Simple.elm --yes --output ../gh-pages/simple.js
cp index.html ../gh-pages/index.html
cd ..

# init branch and commit
cd gh-pages
git init
git config user.name "Eric Gjertsen"
git config user.email "ericgj72@gmail.com"
git add .
git commit -m "Deploy to GitHub Pages"
git push --force git@github.com:ericgj/elm-accordion-menu.git master:gh-pages
cd ..
