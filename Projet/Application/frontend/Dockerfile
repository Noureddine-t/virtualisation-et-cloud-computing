FROM nginx:latest

COPY . /usr/share/nginx/html

LABEL app="frontend"

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
