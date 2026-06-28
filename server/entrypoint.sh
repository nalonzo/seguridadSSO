#!/bin/bash
set -e  # Opcional: si quieres que falle en cualquier error, pero mejor usar manejo explícito

# Iniciar MariaDB (con inicialización si es necesario)
if ! service mariadb status > /dev/null 2>&1; then
    echo "Iniciando MariaDB..."
    service mariadb start || { echo "Fallo al iniciar MariaDB"; exit 1; }

    # Configurar root sin contraseña para phpMyAdmin
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null || true
    # Establecer contraseña para root y crear usuario admin

    mysql -e "CREATE USER IF NOT EXISTS 'phpmyadmin'@'localhost' IDENTIFIED BY 'root';" 2>/dev/null || true
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost' WITH GRANT OPTION;" 2>/dev/null || true
    mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true
    mysql < /usr/share/phpmyadmin/sql/create_tables.sql 2>/dev/null || true

    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; FLUSH PRIVILEGES;" 2>/dev/null || true
    mysql -e "CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null || true
    mysql -e "CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null || true
fi

# Iniciar SSH
service ssh start || echo "SSH ya iniciado"

# Iniciar FTP
service vsftpd start || echo "vsftpd ya iniciado"

# Iniciar el superservidor (para Telnet)
service openbsd-inetd start || echo "openbsd-inetd ya iniciado"

# Iniciar Apache
service apache2 start || echo "Apache ya iniciado"

# Iniciar fail2ban
service fail2ban start || echo "fail2ban ya iniciado"

# Mantener el contenedor activo
tail -f /dev/null

