# Collabex

Collaborative code editor with [Microsoft/monaco-editor](https://microsoft.github.io/monaco-editor/), [convergencelabs/monaco-collab-ext](https://github.com/convergencelabs/monaco-collab-ext) and [phoenix framework](https://github.com/phoenixframework/phoenix).

## TODO

- [x] Simplest proof of concept
- [x] Handle join/leave properly
- [x] Display users list
- [ ] Display cursor and selection
- [x] Root page with "new session" button

## Usage

Clone the repo, install deps and start the server

    mix deps.get
    npm install --prefix apps/collabex_web/assets
    mix phx.server

Hit `http://localhost:4000/e/some-session-id` in yout browser.