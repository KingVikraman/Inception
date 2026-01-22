all: up

up:
        @mkdir -p /home/rvikrama/data/mariadb
        @mkdir -p /home/rvikrama/data/wordpress
        docker-compose -f srcs/docker-compose.yml up -d --build

down:
        docker-compose -f srcs/docker-compose.yml down

clean: down
        docker system prune -af
        @sudo rm -rf /home/data/mariadb
        @sudo rm -rf /home/rvikrama/wordpress

re: clean all

.PHONY: all up down clean re