#!/bin/sh
REQUEST_METHOD=$(printenv REQUEST_METHOD)
CONTENT_LENGTH=$(printenv CONTENT_LENGTH | sed -En "s#(\d+)#\1#p")
CONTENT=$(head -c "$CONTENT_LENGTH" <&0)

if [[ "$CONTENT" =~ ^[a-zA-Z0-9=\&]$ ]]; then
    echo "content-type: text/plain"
    echo ""
    echo "403"
    echo ""
    exit 0
fi

if [ "$REQUEST_METHOD" != "POST" ]; then
    echo "content-type: text/plain"
    echo ""
    echo "Invalid request method: $REQUEST_METHOD, expected POST"
    echo ""
    exit 0
fi

TIMEPOINTS=$(echo "$CONTENT" | sed -En "s#.*timepoints=(\d+).*#\1#p")
FRAMES=$(echo "$CONTENT" | sed -En "s#.*frames=(\d+).*#\1#p")
STOP=$(echo "$CONTENT" | sed -En "s#.*stop=(T|F).*#\1#p")

if [ "$TIMEPOINTS" = "" ] || [ "$FRAMES" = "" ] || [ "$STOP" = "" ]; then
    echo "content-type: text/plain"
    echo ""
    echo "Invalid values ($CONTENT_LENGTH): $CONTENT"
    echo ""
    exit 0
fi

printf "%s %s %s" "$TIMEPOINTS" "$FRAMES" "$STOP" > /simu-req
echo -e "POST /containers/fortrants_simu/kill?signal=SIGUSR1 HTTP/1.0\r\n" | nc -w 1 -U /var/run/docker.sock >> /dev/null

echo "Content-Type: text/html; charset=UTF-8"
echo ""
echo "<!doctype html>"
echo "<head>"
echo "<meta http-equiv='Refresh' content='3;url=/'>"
echo "<title>FortrAnts</title>"
echo "</head>"
echo "<body>"
echo "<p>"
echo "Issued request for $TIMEPOINTS timepoints and $FRAMES frames."
echo "</p>"
echo "</body>"
echo "</html>"
echo ""
