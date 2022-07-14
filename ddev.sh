if test -f "./.env.local"; then
    docker compose --env-file .env.local -f docker-compose.yaml -f docker-compose.dev.yaml up --build -d
else
    docker compose -f docker-compose.yaml -f docker-compose.dev.yaml up --build -d
fi
