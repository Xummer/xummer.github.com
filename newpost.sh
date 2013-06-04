#!/bin/sh

postDir="./_post/"
postName=$(date +"%Y-%m-%d")"-"$(echo $1 | tr ' ' '-')".md"
postPath=${postDir}${postName}

if [ ! -f $postPath ]; then
	touch $postPath
	echo '---'>>$postPath
	echo 'layout: post'>>$postPath
	echo "title: "$1"">>$postPath
	echo "date: `date '+%Y-%m-%d %T'`">>$postPath
	echo 'meta: ture'>>$postPath
	echo '---'>>$postPath
else
	echo "$postPath is already exist"
	exit 0
fi 
