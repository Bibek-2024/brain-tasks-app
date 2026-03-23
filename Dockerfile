FROM nginx:alpine

RUN apk add --no-cache curl

# Remove default config and copy your custom one
RUN rm /etc/nginx/conf.d/default.conf
COPY default.conf /etc/nginx/conf.d/

# Copy the build output from the repo's dist folder
RUN rm -rf /usr/share/nginx/html/*
COPY dist/ /usr/share/nginx/html/

# Match the internal port specified in default.conf
EXPOSE 3000

# Internal Docker Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["nginx", "-g", "daemon off;"]FROM nginx:alpine
RUN apk add --no-cache curl
# Remove default config and copy your custom one
RUN rm /etc/nginx/conf.d/default.conf
COPY default.conf /etc/nginx/conf.d/
# Copy the build output from your local machine/CodeBuild
RUN rm -rf /usr/share/nginx/html/*
COPY dist/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
