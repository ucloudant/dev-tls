# use this self-generated certificate only in dev, IT IS NOT SECURE!
FROM ucloudant/nginx

# persistent / runtime deps
RUN apk add --no-cache \
		nss-tools \
	;

WORKDIR /certs

COPY mkcert-v1.4.1-linux-amd64 /usr/local/bin/mkcert
RUN set -eux; \
	chmod +x /usr/local/bin/mkcert; \
	mkcert --cert-file localhost.crt --key-file localhost.key localhost 127.0.0.1 ::1; \
	# the file must be named server.pem - the default certificate path in webpack-dev-server
	cat localhost.key localhost.crt > server.pem; \
	# export the root CA cert, but not the root CA key
	cp "$(mkcert -CAROOT)/rootCA.pem" /certs/localCA.crt

VOLUME /certs

# add redirect from http://localhost to https://localhost
RUN set -eux; \
	{ \
		echo 'server {'; \
		echo '    return 301 https://$host$request_uri;'; \
		echo '}'; \
	} | tee /etc/nginx/conf.d/default.conf
