FROM node:13.12.0-alpine as build-step

# set working directory
RUN mkdir /app
WORKDIR /app

# install app dependencies
COPY package.json /app
COPY . /app
RUN npm install \
    && npm run build --prod

FROM nginx:1.17.1-alpine
COPY --from=build-step /app/build /usr/share/nginx/html