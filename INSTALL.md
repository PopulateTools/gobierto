# Server installation guide

Check our online documentation at https://gobierto.readme.io/docs/server-installation-guide


## Docker 


Stop all
```
docker stop $(docker ps -q) && docker rm $(docker ps -qa)
```

Up
```
cp .env.example .env
cp config/database.yml.example config/database.yml
docker-compose up
```