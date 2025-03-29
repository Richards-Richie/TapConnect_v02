FROM node:20.11.1

WORKDIR /TapConnect_backend

COPY package*json .

RUN npm install 

COPY . .

ENV PORT=5555
ENV WSURL=5566

EXPOSE 5555 5566

CMD node index.js