ARG NODE_VERSION=18.13.0

###############
# BUILD stage #
###############
FROM node:${NODE_VERSION}-alpine as build-stage

# Fixes error on `react-scripts-build`
# error:0308010C:digital envelope routines::unsupported https://stackoverflow.com/questions/69692842/error-message-error0308010cdigital-envelope-routinesunsupported
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN apk add --no-cache --virtual .build-deps \
  build-base \
  python3 \
  git \
  && apk add --no-cache \
  bash \
  curl \
  && rm -rf /var/cache/apk/*

# Install dependencies
WORKDIR /app
COPY package.json yarn.lock lerna.json tsconfig.json ./
COPY packages/ui/package.json \ 
  packages/ui/
COPY packages/server/package.json \ 
  packages/server/
COPY packages/common/package.json \ 
  packages/common/
RUN yarn --frozen-lockfile --non-interactive --ignore-optional

# Build common
WORKDIR /app/packages/common/
COPY packages/common/ .
RUN yarn build
# Results in dist/*

# Build admin-ui
WORKDIR /app/packages/ui/
COPY packages/ui/ .
RUN yarn build
# Results in build/*

# Build server
WORKDIR /app/packages/server/
COPY packages/server/ .
RUN yarn build
# Results in dist/*

###############
# FINAL stage #
###############

FROM node:${NODE_VERSION}-alpine
ENV NODE_ENV=production
WORKDIR /app

# Copy root app
COPY --from=build-stage /app/node_modules ./node_modules
COPY --from=build-stage /app/package.json ./package.json
# Copy common
COPY --from=build-stage /app/packages/common/dist ./packages/common/dist
COPY --from=build-stage /app/packages/common/node_modules ./packages/common/node_modules
COPY --from=build-stage /app/packages/common/package.json ./packages/common/package.json
# Copy ui
COPY --from=build-stage /app/packages/ui/build ./uiBuild
# Copy server
COPY --from=build-stage /app/packages/server/dist /app/packages/server/dist
COPY --from=build-stage /app/packages/server/node_modules /app/packages/server/node_modules
COPY --from=build-stage /app/packages/server/package.json /app/packages/server/package.json

CMD [ "node", "packages/server/dist/index" ]