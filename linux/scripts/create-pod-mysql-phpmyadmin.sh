#!/usr/bin/env bash
set -euo pipefail

# Default values
POD_NAME="db-pod"
MYSQL_PORT=3306
PMA_PORT=8080
MYSQL_ROOT_PW="StrongRootPW"
MYSQL_USER="usr"
MYSQL_PASSWORD="usr"
MYSQL_DATABASE="app"
MYSQL_VERSION="8.0"
PMA_VERSION="latest"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -name)
      POD_NAME="$2"
      shift 2
      ;;
    -mysql-port)
      MYSQL_PORT="$2"
      shift 2
      ;;
    -pma-port)
      PMA_PORT="$2"
      shift 2
      ;;
    -mysql-version)
      MYSQL_VERSION="$2"
      shift 2
      ;;
    -pma-version)
      PMA_VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [-name POD_NAME] [-mysql-port PORT] [-pma-port PORT] [-mysql-version VERSION] [-pma-version VERSION]"
      exit 1
      ;;
  esac
done

MYSQL_NAME="mysql-${POD_NAME}"
PMA_NAME="phpmyadmin-${POD_NAME}"

# Create pod
podman pod create \
  --name "${POD_NAME}" \
  -p ${MYSQL_PORT}:3306 \
  -p ${PMA_PORT}:80

# Start MySQL
podman run -d \
  --pod "${POD_NAME}" \
  --name "${MYSQL_NAME}" \
  -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PW}" \
  -e MYSQL_DATABASE="${MYSQL_DATABASE}" \
  -e MYSQL_USER="${MYSQL_USER}" \
  -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
  docker.io/library/mysql:${MYSQL_VERSION}

# Start phpMyAdmin
podman run -d \
  --pod "${POD_NAME}" \
  --name "${PMA_NAME}" \
  -e PMA_HOST="${MYSQL_NAME}" \
  -e PMA_USER="root" \
  -e PMA_PASSWORD="${MYSQL_ROOT_PW}" \
  docker.io/phpmyadmin/phpmyadmin:${PMA_VERSION}

# Output info
echo "✅ MySQL ${MYSQL_VERSION} running on localhost:${MYSQL_PORT}"
echo "✅ phpMyAdmin ${PMA_VERSION} at http://localhost:${PMA_PORT}/"

