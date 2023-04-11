#FROM node:16
FROM node:16.3.0-alpine as builder
# Create app directory
WORKDIR /usr/src/app
COPY . .
RUN npm install
RUN npm run build

FROM nginx:latest

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy dist folder fro build stage to nginx public folder
COPY --from=builder /usr/src/app/dist/frontend /usr/share/nginx/html
EXPOSE 8080