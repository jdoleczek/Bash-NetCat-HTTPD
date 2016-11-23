#!/bin/bash
# promyk.doleczek.pl
# LICENSE MIT

PORT=${1:-8080}
FILES=${2:-"./"}

NS=$(netstat -taupen 2>/dev/null | grep ":$PORT ")
test -n "$NS" && echo "Port $PORT is already taken" && exit 1

echo -e "\n\tHTTPD started for files in $FILES:"

for IP in $(ifconfig | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1) ; do
    echo -e "\tlistening at $IP:$PORT"
done

echo -e "\n"
FIFO="/tmp/httpd$PORT"
rm -f $FIFO
mkfifo $FIFO
trap ctrl_c INT

function ctrl_c() {
    rm -f $FIFO && echo -e "\n\tServer shut down.\n" && exit
}

while true; do (
    read req < $FIFO;
    req=$(echo $req | cut -d" " -f2 | cut -d"#" -f1 | cut -d"?" -f1 | cut -c2-);
    >&2 echo -e -n "\tRequest: \"$req\"\t";
    test -z "$req" && req="index.html"

    if [ -f "$FILES$req" ] ; then
        ext="${req##*.}"
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

        case "$ext" in
            "html" | "htm") CONTENTTYPE="text/html; charset=UTF-8" ;;
            "json") CONTENTTYPE="application/json; charset=UTF-8" ;;
            "css" | "less" | "sass") CONTENTTYPE="text/css" ;;
            "txt") CONTENTTYPE="text/plain" ;;
            "xml") CONTENTTYPE="text/xml" ;;
            "js") CONTENTTYPE="application/javascript" ;;
            "jpg" | "jpeg") CONTENTTYPE="image/jpeg" ;;
            "png") CONTENTTYPE="image/png" ;;
            "gif") CONTENTTYPE="image/gif" ;;
            "ico") CONTENTTYPE="image/x-icon" ;;
            "wav") CONTENTTYPE="audio/wav" ;;
            "mp3") CONTENTTYPE="audio/mpeg3" ;;
            "avi") CONTENTTYPE="video/avi" ;;
            "mp4" | "mpg" | "mpeg" | "mpe") CONTENTTYPE="video/mpeg" ;;
            *) CONTENTTYPE="application/octet-stream"
        esac

        echo "HTTP/1.x 200 OK"
        echo "Date: $(LC_TIME=en_US date -u)"
        echo "Server: promyk.doleczek.pl"
        echo "Connection: close"
        echo "Pragma: public"
        echo "Content-Type: $CONTENTTYPE"
        FILESIZE=$(wc -c < "$FILES$req")
        echo -e "Content-Length: $FILESIZE\n"
        cat "$FILES$req"
        >&2 echo "[ ok ]"
    else
        echo -e "HTTP/1.x 404 Not found\n\n<h1>File not found.</h1>"
        >&2 echo "[ no file ]"
    fi
) | nc -l -k -w 1 -p $PORT > $FIFO; done;
