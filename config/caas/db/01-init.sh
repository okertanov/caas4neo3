#!/bin/bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD;
export TOKENVALS=$( cat $APP_DB_TOKENS );
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE USER $API_DB_USER WITH PASSWORD '$API_DB_PASSWORD';
  CREATE DATABASE $API_DB_DATABASE;
  GRANT ALL PRIVILEGES ON DATABASE $API_DB_DATABASE TO $API_DB_USER;
  \connect $API_DB_DATABASE $API_DB_USER
  BEGIN;
    DROP TABLE IF EXISTS "Tokens";
    CREATE TABLE "Tokens" (
	  "Id" SERIAL PRIMARY KEY,
      "Guid" UUID NOT NULL,
      "Token" VARCHAR(500) NOT NULL,
      "ExpirationDate" DATE NOT NULL,
      "Active" BOOLEAN NOT NULL,
      "ClientId" INT,
      "Description" VARCHAR(200),
      "Rates" INT
	);
	CREATE INDEX idx_token_id ON "Tokens" ("Id");
  COMMIT;
  BEGIN;
    INSERT INTO "Tokens"("Guid", "Token", "ExpirationDate", "Active", "ClientId", "Description", "Rates")
    VALUES
    $TOKENVALS
  COMMIT;
EOSQL
