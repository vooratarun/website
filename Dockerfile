# Use the official Nginx image as base
FROM nginx:latest

# Copy the custom index.html file into the Nginx document root
COPY index.html /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80