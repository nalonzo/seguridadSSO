#!/bin/bash
set -e

# Iniciar MariaDB
service mariadb start

# Configurar usuario root para phpMyAdmin (si no existe)
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null || true

# Iniciar SSH
service ssh start

# Iniciar vsftpd
service vsftpd start

# Iniciar Telnet (xinetd)
service xinetd start

# Iniciar Apache
service apache2 start

# Iniciar fail2ban
service fail2ban start

# Mantener el contenedor activo
tail -f /dev/null
