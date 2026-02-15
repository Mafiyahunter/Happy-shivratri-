# Dockerfile
FROM nginx:alpine

# Copy all HTML files to nginx
COPY index.html /usr/share/nginx/html/
COPY creator.html /usr/share/nginx/html/
COPY loading.html /usr/share/nginx/html/
COPY mahadev.html /usr/share/nginx/html/

# Expose port 8080 (Koyeb uses 8080 by default)
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
