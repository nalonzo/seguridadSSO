FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar paquetes
RUN apt-get update && apt-get install -y \
    openssh-server \
    vsftpd \
    apache2 \
    libapache2-mod-php \
    php-mysql \
    mariadb-server \
    phpmyadmin \
    nftables \
    fail2ban \
    apache2-utils \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configurar SSH
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Configurar FTP (vsftpd)
RUN echo "anonymous_enable=NO" >> /etc/vsftpd.conf && \
    echo "local_enable=YES" >> /etc/vsftpd.conf && \
    echo "write_enable=YES" >> /etc/vsftpd.conf && \
    echo "local_umask=022" >> /etc/vsftpd.conf && \
    echo "dirmessage_enable=YES" >> /etc/vsftpd.conf && \
    echo "xferlog_enable=YES" >> /etc/vsftpd.conf && \
    echo "connect_from_port_20=YES" >> /etc/vsftpd.conf && \
    echo "xferlog_std_format=YES" >> /etc/vsftpd.conf && \
    echo "listen=YES" >> /etc/vsftpd.conf && \
    echo "pam_service_name=vsftpd" >> /etc/vsftpd.conf && \
    echo "userlist_enable=YES" >> /etc/vsftpd.conf && \
    echo "userlist_deny=NO" >> /etc/vsftpd.conf && \
    echo "userlist_file=/etc/vsftpd.userlist" >> /etc/vsftpd.conf && \
    echo "root" >> /etc/vsftpd.userlist

# Configurar Apache y PHP
RUN a2enmod auth_basic && \
    a2enmod php8.2 && \
    a2enmod rewrite
COPY script_login.php /var/www/html/
RUN mkdir /var/www/html/privado
RUN touch /var/www/html/.htaccess
RUN touch /var/www/html/.htpasswd

# Configurar AuthType Basic
RUN echo 'AuthType Basic' >> /var/www/html/.htaccess && \
    echo 'AuthName "Acceso restringido"'>> /var/www/html/.htaccess  && \
    echo 'AuthUserFile' >> /var/www/html/privado/.htpasswd && \
    echo 'Require valid-user' >> /var/www/html/.htaccess

# Configurar phpMyAdmin (acceso root público)
# Respondemos a las preguntas de configuración con debconf
RUN echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/app-password-confirm password root" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/mysql/admin-pass password root" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/mysql/app-pass password root" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections && \
    dpkg-reconfigure -f noninteractive phpmyadmin

# Copiar configuración de phpMyAdmin para permitir root sin contraseña (opcional)
RUN sed -i "s/\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = false;/\$cfg['Servers'][\$i]['AllowNoPassword'] = true;/" /etc/phpmyadmin/config.inc.php

# Configurar fail2ban para SSH (básico)
RUN cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local && \
    sed -i 's/^enabled = false/enabled = true/' /etc/fail2ban/jail.local && \
    sed -i 's/^\[sshd\]/[sshd]\nenabled = true/' /etc/fail2ban/jail.local

# Copiar script de entrada
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Exponer puertos
EXPOSE 22 21 23 80

# Iniciar servicios con supervisord o script
ENTRYPOINT ["/entrypoint.sh"]
