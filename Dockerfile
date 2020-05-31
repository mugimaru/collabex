FROM node:12-alpine as build-node

ENV NODE_ENV=prod

RUN mkdir -p /app
COPY ./apps/collabex_web/assets /app/apps/collabex_web/assets
# TODO: do not require prefetched deps
COPY ./deps/phoenix /app/deps/phoenix
WORKDIR /app

RUN npm install --prefix apps/collabex_web/assets
RUN npm run deploy --prefix apps/collabex_web/assets

FROM elixir:1.10.3-alpine as build-elixir

RUN apk add --update git
ENV MIX_ENV=prod

RUN mix local.hex --force && \
  mix local.rebar --force

RUN mkdir /app
COPY ./ /app
WORKDIR /app

RUN mix deps.get
RUN mix deps.compile

COPY --from=build-node /app/apps/collabex_web/priv/static ./apps/collabex_web/priv/static
RUN cd apps/collabex_web && mix phx.digest

RUN mix release --overwrite

FROM alpine

ARG VERSION

LABEL name="Collabex"
LABEL maintainer="pochi.73@gmail.com"
LABEL version=$VERSION

RUN apk add --update bash openssl
WORKDIR /app

COPY --from=build-elixir /app/_build/prod/rel/collabex ./
COPY --from=build-elixir /app/apps/collabex_web/priv/static ./apps/collabex_web/priv/static

EXPOSE 4000

ENTRYPOINT [ "./bin/collabex" ]
CMD ["start"]