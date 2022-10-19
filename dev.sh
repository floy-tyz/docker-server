WARNING='\033[1;33m'
NC='\033[0m'

ENV_ABSOLUTE_PATH=$(realpath "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env.local")

if test -f "$ENV_ABSOLUTE_PATH"; then
    docker compose --env-file .env.local -f docker-compose.yaml -f docker-compose.dev.yaml up --build -d
else
    echo ""
    printf "%b%s do not exist%b\n" "$WARNING" "$ENV_ABSOLUTE_PATH" "$NC"
    echo ""
    exit
fi