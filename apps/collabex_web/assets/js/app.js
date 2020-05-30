import "../css/app.scss"

import * as monaco from 'monaco-editor'
import * as MonacoCollabExt from '@convergencelabs/monaco-collab-ext'

import { Socket } from "phoenix"
let socket = new Socket("/socket", { params: {} })
socket.connect()
const userName = Math.random().toString(36).substring(7)

let channel = socket.channel("editors:default", { user_name: userName })

const editor = monaco.editor.create(document.getElementById("editor"), {
  theme: 'vs-dark',
  language: 'markdown',
  minimap: {
    enabled: false,
  },
});

const contentManager = new MonacoCollabExt.EditorContentManager({
  editor: editor,
  onInsert (index, text) {
    channel.push("insert", { index, text })
  },
  onReplace (index, length, text) {
    channel.push("replace", { index, text, length })
  },
  onDelete (index, length) {
    channel.push(["delete", { index, length }])
  }
});

channel.join()
  .receive("ok", resp => {
    for (const item of resp.events) {
      switch (item.event_type) {
        case "insert":
          contentManager.insert(item.event.index, item.event.text)
          break;
        case "delete":
          contentManager.delete(item.event.index, item.event.length)
          break;
        case "replace":
          contentManager.replace(item.event.index, item.event.length, item.event.text)
          break;
      }
    }

    channel.on("inserted", payload => {
      console.log(payload)
      contentManager.insert(payload.event.index, payload.event.text)
    })

    channel.on("deleted", payload => {
      contentManager.delete(payload.event.index, payload.event.length)
    })

    channel.on("replaced", payload => {
      contentManager.replace(payload.event.index, payload.event.length, payload.event.text)
    })
  })
  .receive("error", resp => { alert("Unable to join") })
