FROM alpine:latest

# Устанавливаем OpenSSH и необходимые пакеты
RUN apk add --no-cache openssh openssh-server-pam

# Создаем директорию для SSH и пользователя
# Генерируем ключи хоста для SSH
RUN ssh-keygen -A
RUN mkdir -p /var/run/sshd /home/sshuser/.ssh

# Создаем пользователя для SSH-подключений
RUN adduser -D -s /bin/sh sshuser && \
    echo "sshuser:sshuser" | chpasswd

# Настраиваем SSH для подключения по ключу
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config

# Создаем директорию для authorized_keys
RUN mkdir -p /home/sshuser/.ssh && \
    chown -R sshuser:sshuser /home/sshuser/.ssh && \
    chmod 700 /home/sshuser/.ssh

# Копируем публичный ключ (замените на свой)
COPY id_rsa.pub /home/sshuser/.ssh/authorized_keys
RUN chown sshuser:sshuser /home/sshuser/.ssh/authorized_keys && \
    chmod 600 /home/sshuser/.ssh/authorized_keys

# Экспозируем порт 22
EXPOSE 22 9000

# Запускаем SSH-сервер в foreground режиме
CMD ["/usr/sbin/sshd", "-D", "-e"]



