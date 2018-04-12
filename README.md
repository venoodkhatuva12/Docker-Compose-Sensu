# Docker-Compose-Sensu

Sensu server and other things on OracleLinux:6.9 in Docker.

Docker compose will bring up 3 containers:

1. **rabbitmq**: This is used as a transport for sensu. Sensu checks and results are published here.

2. **redis**: This is used as a data store for things such as client registry and check results.

3. **sensu**: This container will contain processes related to sensu (uchiwa, sensu-api, sensu-server, sensu-client).

## Installation

```
git clone git@github.com:venoodkhatuva12/Docker-Compose-Sensu.git
```

## How To Run

```
cd Docker-Compose-Sensu
docker-compose up -d
docker-compose up --build 
```

## URL Access

### URL uchiwa

* `http://ServerIP:3000/`

The default user/pass are admin:admin123. It is _highly recommended_ that you change this password in `files/uchiwa.json`

### URL sensu API

* `http://serverIP:4567/`

The default user/pass are admin:admin123. It is _highly recommended_ that you change this password in `files/uchiwa.json` and `files/config.json`


## License

FOSS (Free Operating System and Software)
