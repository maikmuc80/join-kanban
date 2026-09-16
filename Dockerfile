# Stufe 1: Angular bauen
# Node fest gepinnt — die Angular CLI 22 verlangt >= 22.22.3.
FROM node:22.23.1-alpine AS build

WORKDIR /app

# Erst die Manifeste kopieren, damit der npm-Layer im Cache bleibt,
# solange sich die Abhaengigkeiten nicht aendern.
COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stufe 2: statisch ausliefern
FROM nginx:1.29-alpine AS runtime

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/join-project/browser /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ >/dev/null 2>&1 || exit 1

CMD ["nginx", "-g", "daemon off;"]
