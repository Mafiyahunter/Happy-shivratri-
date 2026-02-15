# Dockerfile - Complete Working Version with Health Check
FROM nginx:alpine

# Install curl for health check
RUN apk add --no-cache curl

# Remove default nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy all HTML files
COPY index.html /usr/share/nginx/html/
COPY creator.html /usr/share/nginx/html/
COPY loading.html /usr/share/nginx/html/
COPY mahadev.html /usr/share/nginx/html/

# Create custom nginx config with proper health check endpoint
RUN echo 'server { \
    listen 8080; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Health check endpoint \
    location /health { \
        access_log off; \
        return 200 "healthy\n"; \
        add_header Content-Type text/plain; \
    } \
    \
    # Main app \
    location / { \
        try_files $uri $uri/ /index.html; \
        add_header Cache-Control "no-cache"; \
    } \
    \
    # Error pages \
    error_page 404 /index.html; \
}' > /etc/nginx/conf.d/default.conf

# Test nginx configuration
RUN nginx -t

# Create a simple health check script
RUN echo '#!/bin/sh \
if [ -f /tmp/nginx.pid ]; then \
    curl -f http://localhost:8080/health || exit 1; \
else \
    exit 1; \
fi' > /healthcheck.sh && chmod +x /healthcheck.sh

# Set up health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD /healthcheck.sh

# Create a startup script
RUN echo '#!/bin/sh \
echo "Starting Nginx..." \
nginx -t \
exec nginx -g "daemon off;"' > /start.sh && chmod +x /start.sh

EXPOSE 8080

# Start nginx
CMD ["/start.sh"]
