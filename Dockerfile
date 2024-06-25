ARG NODE_VERSION=22
FROM node:${NODE_VERSION} AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
COPY . /app
WORKDIR /app

FROM base AS prod-deps
RUN pnpm install --prod --frozen-lockfile

FROM base AS build
RUN pnpm install --frozen-lockfile
RUN pnpm run build

# TODO: Only copy the necessary files: package.json, pnpm-lock.yaml, output directory
FROM base AS prod
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/build /app/build
EXPOSE 3000
CMD ["node", "build"]