docker exec -i $MONGO_DB_NAME sh -c 'mongorestore --archive' < {dumpfile}
