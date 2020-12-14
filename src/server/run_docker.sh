# Prelim - ensure DB connection strings go to host.docker.internal,
# e.g., `LEAF_APP_DB=Server=host.docker.internal;Database=LeafDB;uid=sa;Password=<pass>`

# Build image
docker build -t leaf_api .

# Run container
docker run -it -d \
    --name leaf_api_1 \
    -p 5001:5001 \
    -v /Users/nicdobbins/.keys/leaf:/.keys \
    -v $SERILOG_DIR:/logs \
    -e LEAF_APP_DB=$LEAF_APP_DB \
    -e LEAF_CLIN_DB=$LEAF_CLIN_DB \
    -e LEAF_JWT_KEY_PW=$LEAF_JWT_KEY_PW \
    -e SERILOG_DIR=$SERILOG_DIR \
    leaf_api