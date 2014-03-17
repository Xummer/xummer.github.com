#!/bin/sh

if [ -z "$1" ]; then
	echo " no parameter ! "
	exit 1
fi

postDir="./_posts/"
postName=$(date +"%Y-%m-%d")"-"$(echo $1 | tr ' ' '-')".md"
postPath=${postDir}${postName}

if [ ! -f $postPath ]; then
	touch $postPath
        echo '---\n''layout: post\n'"title: "$1"\n""date: `date '+%Y-%m-%d %    T'`\n"'meta: ture\n''---\n\n\n''-以上-'>>$postPath
	echo "created new post <$postName> in $postPath"
        pbcopy < $postPath
        open $postPath
else
	echo "$postPath is already exist"
	exit 0
fi 
