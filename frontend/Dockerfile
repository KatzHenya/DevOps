# Stage 1: Build — העתקת קבצי HTML סטטיים
FROM nginx:alpine AS builder

COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf


# Stage 2: Runtime — Nginx עם תמיכה בהחלפת env vars
FROM nginx:alpine

# envsubst מגיע עם nginx:alpine — מחליף $BACKEND_URL ב-nginx.conf
COPY --from=builder /usr/share/nginx/html /usr/share/nginx/html
COPY --from=builder /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# סקריפט הפעלה שמחליף env vars ב-nginx.conf ומפעיל nginx
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
