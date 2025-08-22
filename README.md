# SSH Server Docker Container

Docker-контейнер с SSH-сервером на базе Alpine Linux.

## Особенности

- Alpine Linux (легковесный образ)
- OpenSSH сервер
- Подключение только по SSH-ключу (пароли отключены)
- Пользователь `sshuser` для SSH-подключений
- Порт 9000 доступен только внутри Docker-сети

## Порты

- **Порт 22** → маппится на **2222** хоста (SSH доступен извне)
- **Порт 9000** → доступен только **внутри Docker-сети**

### Назначение портов:

- **2222** - внешний доступ к SSH-серверу
- **9000** - внутренний порт для API, прокси или других сервисов

### Доступ к порту 9000:

- Из другого контейнера: `curl http://ssh-server:9000`
- Изнутри контейнера: `curl http://localhost:9000`
- Для отладки: `docker exec -it ssh-server sh`
- Порт 22 (SSH) и 9000 (внутренний) экспозированы

## Подготовка

1. Создайте SSH-ключ (если у вас его нет):

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

2. Скопируйте публичный ключ в директорию проекта:

```bash
cp ~/.ssh/id_rsa.pub ./id_rsa.pub
```

## Сборка и запуск

### Сборка образа

```bash
docker build -t ssh-server .
```

### Запуск контейнера

```bash
docker run -d -p 2222:22 --name ssh-container ssh-server
```

### Подключение по SSH

```bash
ssh -p 2222 sshuser@localhost
```

## Docker Compose

Создайте файл `docker-compose.yml`:

```yaml
version: "3.8"
services:
    ssh-server:
        build: .
        ports:
            - "2222:22"
            - "9000:9000"
        volumes:
            - ./id_rsa.pub:/home/sshuser/.ssh/authorized_keys
        restart: unless-stopped
```

Запуск:

```bash
docker-compose up -d
```

## Безопасность

- Root-доступ отключен
- Парольная аутентификация отключена
- Только SSH-ключи разрешены
- Пользователь `sshuser` имеет ограниченные права

## Настройка

Для изменения конфигурации SSH отредактируйте соответствующие строки в
Dockerfile или создайте собственный `sshd_config`.
