FROM gliderlabs/alpine:3.4

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# run update
RUN apk update

# install git
RUN apk add git nginx

# Add Scripts
ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push
ADD scripts/letsencrypt-setup /usr/bin/letsencrypt-setup
ADD scripts/letsencrypt-renew /usr/bin/letsencrypt-renew
ADD scripts/docker-hook /usr/bin/docker-hook
ADD scripts/hook-listener /usr/bin/hook-listener

# Setup permissions
RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push && chmod 755 /usr/bin/letsencrypt-setup && chmod 755 /usr/bin/letsencrypt-renew && chmod 755 /start.sh
RUN chmod +x /usr/bin/docker-hook
RUN chmod +x /usr/bin/hook-listener

# Copy our nginx config
RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

# Copy supervisor config
ADD conf/supervisord.conf /etc/supervisord.conf

# Setup nginx site conf
RUN rm -Rf /etc/nginx/sites-available/*
RUN mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
mkdir -p /etc/nginx/ssl/ && \
rm -Rf /var/www/* && \
mkdir /var/www/html/
ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf
ADD conf/nginx-site-ssl.conf /etc/nginx/sites-available/default-ssl.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run
EXPOSE 443 80
CMD ["/start.sh"]
