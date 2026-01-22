Dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
        nginx \
        openssl \
        && rm -rf /var/lib/apt/lists/*

RUN openssl req -x509 -nodes -days 365 -newkey  rsa:2048 \
        -keyout /etc/ssl/private/nginx-selfsigned.key \
        -out /etc/ssl/certs/nginx-selfsigned.crt \
        -subj "/C=MY/ST=KL/L=KualaLumpur/0=42/OU=42/CN=rvikrama.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]