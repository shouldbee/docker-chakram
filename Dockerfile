FROM node:4.1.1-slim

RUN npm install -g --silent mocha coffee-script chakram@1.0.1 && \
  npm -g cache clean --silent

ENV NODE_PATH /usr/local/lib/node_modules

ENTRYPOINT ["mocha", "--compilers", "coffee:coffee-script/register"]
