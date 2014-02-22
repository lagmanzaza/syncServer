#!/bin/bash
#for server 1.7 or newer
varPath="function/var.sh"
if [ -f $varPath ];then	source $varPath;
else echo "source var.sh failed!";exit;fi

main(){
local dir=$thisServerPath/logs

case $1 in
	all)
local files=($(ls $dir/*.gz))
	;;
	last)
local yesterday=`date --date="-1 day" +%F`
local today=`date +%F`
local files=($(ls $dir/${yesterday}*.gz))
local files+=($(ls $dir/${today}*.gz))
local files+=($dir/latest.log)
	;;
	clean)
rm -f $dir/*.chat
	;;
	*)
for i; do
local files+=(`ls $dir/${i}*.gz`)
done
	;;
esac

if [ "$files" == '' ];then echo "files empty";exit;fi

local chatResult="$dir/result.chat"
local latest="$dir/latest.log"

echo "" > $chatResult
for ((i=0; i<${#files[@]}; i++)); do
	local gzfile=${files[$i]}
	local file=${gzfile/.gz/}
	if [ "$file" == "$latest" ];then
		`cat $file|grep "$chatRegex" > $file.chat`;
	elif [ -f $file.chat ];then
		echo "$file.chat exist";
	else
		gzip -d $gzfile
		`cat $file|grep "$chatRegex" > $file.chat`;
		gzip $file
	fi
	echo "#${file}.chat" >> $chatResult
	`cat $file.chat >> $chatResult`;
done

cat $chatResult
}
main $@
