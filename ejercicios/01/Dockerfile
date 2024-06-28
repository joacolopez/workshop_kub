# Pull nginx image
FROM nginx:alpine

# Copy index.html to default nginx directory
COPY index.html /usr/share/nginx/html/index.html

# Expose 8080 port
EXPOSE 8080

# nginx exec args
CMD ["nginx", "-g", "daemon off;"]
