# Collabex

Collaborative code editor with [Microsoft/monaco-editor](https://microsoft.github.io/monaco-editor/), [convergencelabs/monaco-collab-ext](https://github.com/convergencelabs/monaco-collab-ext) and [phoenix framework](https://github.com/phoenixframework/phoenix).


## Run [docker image](https://hub.docker.com/r/mugimaru/collabex)

    docker run -p 4000:4000 mugimaru/collabex:0.1.0 start

## Development

Clone the repo, install deps and start the server

    mix deps.get
    npm install --prefix apps/collabex_web/assets
    mix phx.server

Run tests, linters, etc with

    mix check

## Build docker image

Clone the repo and run

    make build-docker-image

Run it

    docker run -p 4000:4000 collabex:0.1.0 start

Publish to your registry

    make push-docker-image DOCKER_REPO=dockerhub_username_or_repo_url
