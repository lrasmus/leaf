# dev
docker build -t leaf_ui_client -f Dockerfile.dev .

# prod
#docker build -t leaf_ui_client -f Dockerfile .

docker run -it -d \
    --name leaf_ui_client_1 \
    -p 3000:3000 \
    leaf_ui_client