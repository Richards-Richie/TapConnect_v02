FROM node:20.11.1

WORKDIR /TapConnect_backend

COPY package*json .

RUN npm install 

COPY . .

CMD node index.js