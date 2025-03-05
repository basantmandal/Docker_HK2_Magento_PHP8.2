FROM basantmandal/hk2-php8.2-fpm:1.0

# Current Working User 
ARG USER

# GIT Cred Update
ARG GIT_USER_NAME
ARG GIT_USER_EMAIL_ID
RUN git config --global user.name $GIT_USER_NAME
RUN git config --global user.email $GIT_USER_EMAIL_ID
RUN git config --global credential.helper store

# Email Config Update
ARG EMAIL_NO_REPLY
RUN echo "account default" > /etc/msmtprc
RUN echo "host mailhog" >> /etc/msmtprc
RUN echo "from $EMAIL_NO_REPLY" >> /etc/msmtprc
RUN echo "port 1025" >> /etc/msmtprc
RUN echo "tls off" >> /etc/msmtprc

# Set working directory
WORKDIR /var/www/html