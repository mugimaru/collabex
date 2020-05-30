import '../css/app.scss';

import * as monaco from 'monaco-editor';
import * as MonacoCollabExt from '@convergencelabs/monaco-collab-ext';

import { Socket } from 'phoenix';

const socket = new Socket('/socket', { params: {} });
socket.connect();

function askUserName() {
  const userName = prompt('Enter your name');
  if (userName === '') {
    return askUserName();
  }

  localStorage.setItem('userName', userName);
  return userName;
}

function getUserName() {
  const userName = localStorage.getItem('userName');
  if (userName !== null) {
    return userName;
  }

  return askUserName();
}

const editorElem = document.getElementById('editor');

const channel = socket.channel(`editors:${editorElem.getAttribute('data-topic')}`, { user_name: getUserName() });

const editor = monaco.editor.create(editorElem, {
  theme: 'vs-dark',
  language: 'markdown',
  minimap: {
    enabled: false,
  },
});

const contentManager = new MonacoCollabExt.EditorContentManager({
  editor,
  onInsert(index, text) {
    channel.push('insert', { index, text });
  },
  onReplace(index, length, text) {
    channel.push('replace', { index, text, length });
  },
  onDelete(index, length) {
    channel.push(['delete', { index, length }]);
  },
});

channel.join()
  .receive('ok', (resp) => {
    resp.events.forEach((item) => {
      switch (item.event_type) {
        case 'insert':
          contentManager.insert(item.event.index, item.event.text);
          break;
        case 'delete':
          contentManager.delete(item.event.index, item.event.length);
          break;
        case 'replace':
          contentManager.replace(item.event.index, item.event.length, item.event.text);
          break;
        default:
          break;
      }
    });

    channel.on('inserted', (payload) => {
      contentManager.insert(payload.event.index, payload.event.text);
    });

    channel.on('deleted', (payload) => {
      contentManager.delete(payload.event.index, payload.event.length);
    });

    channel.on('replaced', (payload) => {
      contentManager.replace(payload.event.index, payload.event.length, payload.event.text);
    });
  });
