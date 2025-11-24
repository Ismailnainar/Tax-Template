# Use official nginx image (small, stable)
FROM nginx:stable-alpine AS run

# Allow override of the build output directory (default: Flutter web output)
ARG BUILD_DIR=build/web

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built Flutter web app into nginx html folder
COPY ${BUILD_DIR} /usr/share/nginx/html

# Replace default nginx.conf with our SPA-friendly config (optional)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose HTTP (optional; Dockerfile metadata only)
EXPOSE 80

# Start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
