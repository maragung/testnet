#!/bin/bash

sudo apt install jq -y

# Get all container IDs matching the filter
container_ids=$(docker ps -a --filter "ancestor=nillion/retailtoken-accuser:v1.0.0" -q)

# Stop and remove each container
for id in $container_ids; do
    echo "Stopping container $id..."
    docker stop $id
    
    echo "Removing container $id..."
    docker rm $id
done

# Print all stopped and removed container IDs
if [ -n "$container_ids" ]; then
    echo "Selected containers have been stopped and removed: $container_ids"
else
    echo "No containers were stopped or removed."
fi

# Get the latest block height
LATEST_BLOCK=$(curl -s http://65.109.222.111:26657/status | jq -r .result.sync_info.latest_block_height)

# Run the Docker container with the latest block height
docker run -v ./nillion/accuser:/var/tmp nillion/retailtoken-accuser:v1.0.0 accuse --rpc-endpoint "https://nillion-testnet-rpc.polkachu.com" --block-start $LATEST_BLOCK
