#!/bin/sh
# מחליף את $BACKEND_URL ב-nginx.conf עם הערך האמיתי מה-environment
envsubst '${BACKEND_URL}' < /etc/nginx/conf.d/default.conf > /tmp/default.conf
cp /tmp/default.conf /etc/nginx/conf.d/default.conf

# מפעיל nginx בפורגראונד
exec nginx -g 'daemon off;'
