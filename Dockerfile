# Build stage
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Serve stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
# Cloud Run requires listening on port 8080 (default) or the PORT env var
# We'll use a custom nginx config to handle the PORT env var usually, 
# but for simple static serving on Cloud Run, sed replacement is a common pattern.
# However, the default nginx listens on 80. Cloud Run injects PORT=8080.
# A simple way is to configure nginx to listen on 8080.
RUN sed -i 's/listen       80;/listen       8080;/g' /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
