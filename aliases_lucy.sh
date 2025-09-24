#!/usr/bin/env bash
# Alias para Lucy (ejecutar dentro de lucy_stack/)

COMPOSE_FILE="docker-compose.yml"

# Stack control
alias lucy='echo "Comandos: up, down, ps, logs, bash, artisan, composer, node, npm";'
alias lucy.up='docker compose -f ${COMPOSE_FILE} up -d'
alias lucy.down='docker compose -f ${COMPOSE_FILE} down'
alias lucy.ps='docker compose -f ${COMPOSE_FILE} ps'
alias lucy.logs='docker compose -f ${COMPOSE_FILE} logs -f --tail=100'
alias lucy.bash='docker compose -f ${COMPOSE_FILE} exec app bash'

# Herramientas dentro del contenedor
alias lucy.artisan='docker compose -f ${COMPOSE_FILE} exec app php artisan'
alias lucy.composer='docker compose -f ${COMPOSE_FILE} exec app composer'
alias lucy.node='docker compose -f ${COMPOSE_FILE} exec app node'
alias lucy.npm='docker compose -f ${COMPOSE_FILE} exec app npm'
