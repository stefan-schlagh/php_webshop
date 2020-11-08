# php Webshop

## 1. create secrets file

this file should be in the root directory of this repository
required args: 
  * ### EMAIL_SERVICE=
    * the email service you want to use, for example smtp.gmail.com
  * ### EMAIL_USER=
  * ### EMAIL_PASSWORD=

## 2. copy the files in build into the root directory of this repository
  * delete the default nginx.conf and docker-compose-yml files
## 3. add your own email address
  * docker-compose.yml --> CERTBOT_EMAIL
````yaml
nginx-proxy:
    build: ./docker-nginx-certbot/src
    restart: always
    ports: 
      - "80:80"
      - "443:443"
    environment:
      CERTBOT_EMAIL: yourEmail
    volumes:
      - ./nginx:/etc/nginx/user.conf.d:ro
      - letsencrypt:/etc/letsencrypt
````
## 4. add your own domain
  * nginx/nginx.conf
  * replace yourdomain.com
````conf
server {
    listen              443 ssl;
    server_name         yourDomain.com;
    ssl_certificate     /etc/letsencrypt/live/yourDomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourDomain.com/privkey.pem;

    location / {
        proxy_pass http://web-server;
    }
}
````
## 5. install dependencies

````shell
sh installDepemdencies.sh
````
does not work on Windows

## 6. start

````shell
docker-compose up -d
````

### phpmyadmin

can be reached at localhost:5000
* user: root
* password: secret

### webshop

can be reached at localhost:8080