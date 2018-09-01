#!/bin/bash

filename="$1" # get filename from command line argument

echo "Processing file: $filename"

while read -r line
do
    if [ -z "$line" ] # skip blank lines
    then
        echo "Blank line, skipping."
    else
        proto="$(echo $line | grep :// | sed -e's,^\(.*://\).*,\1,g')"
        # remove the protocol
        url="$(echo ${line/$proto/})"

	# extract the host
        host="$(echo ${url/$user@/} | cut -d/ -f1)"

        # extract the path (if any)
        path="$(echo $url | grep / | cut -d/ -f2-)"

	# extract the directory
        directory="$(echo $path | grep -P '^.*[\\\/]' -o)"

	# set the download directory
        downloaddir="/media/hoard/to_move/$host/$directory"

        echo "$URL: $line"

	# Add the file to aria2.
        curl http://localhost:6800/jsonrpc -H "Content-Type: application/json" -H "Accept: application/json" --data '{"jsonrpc": "2 .0","id":1,"method": "aria2.addUri", "params":["token:secret_token", ["'"$line"'"], {"dir":"'"$downloaddir"'","pause":"true", "http-user":"apache_user", "http-passwd":"apache_password"}]}'
        echo "Downloading file to $downloaddir."
    fi
done < "$filename"
