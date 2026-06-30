FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar paquetes
RUN apt-get update && apt-get install -y \
    openssh-server \
    vsftpd \
    telnetd \
    openbsd-inetd \
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
    nano \
    sudo \
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
    echo "userlist_file=/etc/vsftpd.userlist" && \
    echo "root" >> /etc/vsftpd.userlist

# Configurar Telnet (se activa automáticamente en inetd, pero aseguramos que esté habilitado)
RUN sed -i 's/^#telnet/telnet/' /etc/inetd.conf || true

# Configurar Apache y PHP
RUN a2enmod auth_basic && \
    a2enmod php8.2 && \
    a2enmod rewrite

# Copiar script de login y archivos de autenticación básica
COPY script_login.php /var/www/html/
RUN mkdir -p /var/www/html/privado
RUN touch /var/www/html/privado/.htaccess
RUN touch /var/www/html/privado/.htpasswd
RUN chown -R www-data:www-data /var/www/html/privado

RUN echo 'AuthType Basic' >> /var/www/html/.htaccess && \
    echo 'AuthName "Acceso restringido"'>> /var/www/html/.htaccess  && \
    echo 'AuthUserFile' >> /var/www/html/privado/.htpasswd && \
    echo 'Require valid-user' >> /var/www/html/.htaccess


#Crear el usuario de prueba
RUN htpasswd -bc /var/www/html/privado/.htpasswd prueba prueba123


# Configurar phpMyAdmin (acceso root con contraseña)
RUN echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/app-password-confirm password root" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/mysql/admin-pass password root" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/mysql/app-pass password root" | debconf-set-selections && \
    echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections && \
    dpkg-reconfigure -f noninteractive phpmyadmin

# Sobrescribir la configuración de phpMyAdmin con la personalizada
COPY config.inc.php /etc/phpmyadmin/config.inc.php

# Configurar fail2ban para SSH
RUN cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local && \
    sed -i 's/^enabled = false/enabled = true/' /etc/fail2ban/jail.local && \
    sed -i 's/^\[sshd\]/[sshd]\nenabled = true/' /etc/fail2ban/jail.local

# Copiar script de entrada (con permisos de ejecución)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 21 23 80

ENTRYPOINT ["/entrypoint.sh"]
