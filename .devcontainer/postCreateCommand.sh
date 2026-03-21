#!/bin/bash
set -e

MYSQL_HOST="${MYSQL_HOST:-db}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-password}"

ORACLE_HOST="${ORACLE_HOST:-oracle}"
ORACLE_PORT="${ORACLE_PORT:-1521}"
ORACLE_SERVICE="${ORACLE_SERVICE:-XEPDB1}"
ORACLE_USER="${ORACLE_USER:-user}"
ORACLE_PASSWORD="${ORACLE_PASSWORD:-password}"

echo "Waiting for MySQL to be ready..."
mysql_ready=false
for i in {1..60}; do
  if mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" &> /dev/null; then
    echo "MySQL is ready!"
    mysql_ready=true
    break
  fi
  sleep 2
done

if [ "$mysql_ready" != "true" ]; then
  echo "MySQL did not become ready in time."
  exit 1
fi

echo "Waiting for Oracle to be ready..."
oracle_ready=false
for i in {1..180}; do
  if printf 'exit\n' | sqlplus -L "${ORACLE_USER}/${ORACLE_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE}" &> /dev/null; then
    echo "Oracle is ready!"
    oracle_ready=true
    break
  fi
  sleep 2
done

if [ "$oracle_ready" != "true" ]; then
  echo "Oracle did not become ready in time using ${ORACLE_USER}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE}."
  exit 1
fi

echo "All databases are ready!"
