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
        downloaddir="/media/path/to/basedir/$host/$directory"

        # get the filename without the querystring
        filename="$(echo $(basename $path) | sed -e 's,\?.*$,,g')"

        echo "URL: $line"
        echo "FILENAME: $filename"
        if [ -z "$filename" ] # This URL doesn't have a file name.
        then
            echo "URL does not have file name, skipping."
        else
	    # Add the file to aria2.
            curl http://localhost:6800/jsonrpc -H "Content-Type: application/json" -H "Accept: application/json" --data '{"jsonrpc": "2 .0","id":1,"method": "aria2.addUri", "params":["token:secret_token", ["'"$line"'"], {"dir":"'"$downloaddir"'","pause":"true","continue":"true", "http-user":"apache_user", "http-passwd":"apache_password"}]}'
            echo "Downloading file to $downloaddir."
        fi
    fi
done < "$filename"
