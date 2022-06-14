FROM node:16-alpine

RUN mkdir /src

COPY ./index.js /src
COPY ./package.json /src
COPY ./package-lock.json /src

RUN chown node -R /src

WORKDIR /src

RUN npm ci --omit=dev

EXPOSE 3000

CMD [ "npm", "start" ]