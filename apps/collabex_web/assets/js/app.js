// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

import * as monaco from 'monaco-editor'
import * as MonacoCollabExt from '@convergencelabs/monaco-collab-ext'


function createEditor(elemId) {
  return monaco.editor.create(document.getElementById(elemId), {
    theme: 'vs-dark',
    language: 'markdown',
    minimap: {
      enabled: false,
    },
  });
}

const source = createEditor('source')

const target = createEditor('target')
const targetContentManager = new MonacoCollabExt.EditorContentManager({
  editor: target
});

const contentManager = new MonacoCollabExt.EditorContentManager({
  editor: source,
  onInsert(index, text) {
    target.updateOptions({readOnly: false});
    targetContentManager.insert(index, text);
    target.updateOptions({readOnly: true});
  },
  onReplace(index, length, text) {
    target.updateOptions({readOnly: false});
    targetContentManager.replace(index, length, text);
    target.updateOptions({readOnly: true});
  },
  onDelete(index, length) {
    target.updateOptions({readOnly: false});
    targetContentManager.delete(index, length);
    target.updateOptions({readOnly: true});
  }
});