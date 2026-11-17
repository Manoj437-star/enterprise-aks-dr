FROM node:18-alpine

WORKDIR /app

COPY src/package.json ./
RUN npm install --omit=dev

COPY src/app.js ./

EXPOSE 8080

USER node

CMD ["node", "app.js"]
