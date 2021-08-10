#!/bin/bash
IFS=' '
filename='md5hashes.txt'

while read line; do
    read -a strarr <<< "$line"
    ./bin/create_work --appname onechunk \
        --result_template templates/onechunk_out \
        --remote_file "https://ssg.seedfinding.com/tasks/get?taskid=${strarr[0]}"\
        "${strarr[1]}" \
        "${strarr[2]}" \
        --priority 12000 \
        --min_quorum 2 \
        --credit 2500 \
        --delay_bound 259200
done < $filename