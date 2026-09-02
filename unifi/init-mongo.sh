#!/usr/bin/env bash
set -Eeuo pipefail

required_variables=(
  MONGO_INITDB_ROOT_USERNAME
  MONGO_INITDB_ROOT_PASSWORD
  MONGO_USER
  MONGO_PASS
  MONGO_DBNAME
  MONGO_AUTHSOURCE
)

for variable in "${required_variables[@]}"; do
  if [[ -z "${!variable:-}" ]]; then
    echo "MongoDB initialization error: ${variable} is not set" >&2
    exit 1
  fi
done

# A quoted heredoc and process.env avoid treating credentials as JavaScript.
# This is important when a password contains quotes, backslashes, or '$'.
mongosh --quiet --host 127.0.0.1 --port 27017 <<'MONGOSH'
const env = process.env;
const rootDb = db.getSiblingDB("admin");

if (!rootDb.auth(env.MONGO_INITDB_ROOT_USERNAME, env.MONGO_INITDB_ROOT_PASSWORD)) {
  throw new Error("could not authenticate as the MongoDB root user");
}

// UniFi authenticates this user against MONGO_AUTHSOURCE (admin in compose.yml)
// and uses separate application, statistics, audit, and restore databases.
const authDb = db.getSiblingDB(env.MONGO_AUTHSOURCE);
const roles = [
  { role: "clusterMonitor", db: "admin" },
  { role: "dbOwner", db: env.MONGO_DBNAME },
  { role: "dbOwner", db: `${env.MONGO_DBNAME}_stat` },
  { role: "dbOwner", db: `${env.MONGO_DBNAME}_audit` },
  { role: "dbOwner", db: `${env.MONGO_DBNAME}_restore` }
];

if (authDb.getUser(env.MONGO_USER)) {
  authDb.updateUser(env.MONGO_USER, { pwd: env.MONGO_PASS, roles });
  print(`Updated MongoDB user '${env.MONGO_USER}' in '${env.MONGO_AUTHSOURCE}'`);
} else {
  authDb.createUser({ user: env.MONGO_USER, pwd: env.MONGO_PASS, roles });
  print(`Created MongoDB user '${env.MONGO_USER}' in '${env.MONGO_AUTHSOURCE}'`);
}
MONGOSH
