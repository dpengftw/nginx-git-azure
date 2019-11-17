FROM yobasystems/alpine:3.9.0-amd64

# run update
RUN apk update

# install git
RUN apk add --no-cache coreutils git nginx openssh openrc supervisor

# add scripts
ADD scripts/start.sh /start.sh
ADD scripts/pull /usr/bin/pull
ADD scripts/push /usr/bin/push

# openssh conf
RUN echo "Port 2222" >> /etc/ssh/sshd_config && \
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
/usr/bin/ssh-keygen -A && \
echo "root:Docker!" | /usr/sbin/chpasswd

# setup permissions
RUN chmod 755 /usr/bin/pull && chmod 755 /usr/bin/push && chmod 755 /start.sh

# copy our nginx config
RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/supervisord.conf /etc/supervisord.conf

# setup nginx site conf
RUN rm -Rf /etc/nginx/sites-available/* && mkdir -p /run/nginx && chown nginx:nginx /run/nginx && \
mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
rm -Rf /var/www/* && \
mkdir /var/www/html/
ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf
ADD conf/nginx-site-ssl.conf /etc/nginx/sites-available/default-ssl.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf && \
# forward request and error logs to docker log collector
ln -sf /dev/stdout /var/log/nginx/access.log && \
ln -sf /dev/stderr /var/log/nginx/error.log

# run post commands
EXPOSE 443 80 2222
CMD ["/start.sh"]
