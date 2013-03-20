#!/bin/sh

# Generate an index.html file with no multiplex secret
sed 's/13634557480795333820//' index_5d9f71b71b207b9e665820c0dce67bdb.html > index.html

# Launch the Node server
node ./reveal/plugin/multiplex/index.js 

