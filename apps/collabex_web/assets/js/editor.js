import * as monaco from 'monaco-editor';
import * as MonacoCollabExt from '@convergencelabs/monaco-collab-ext';

const defaultTheme = 'vs-light';
const editorThemes = { 'vs-light': 'VS light', 'vs-dark': 'VS dark' };
Object.entries(require('monaco-themes/themes/themelist.json')).forEach(([themeId, themeName]) => {
  monaco.editor.defineTheme(themeId, require(`monaco-themes/themes/${themeName}.json`));
  editorThemes[themeId] = themeName;
});

const defaultLang = 'markdown';

const users = {};

function getRandomColor() {
  const letters = '0123456789ABCDEF';
  let color = '#';
  for (let i = 0; i < 6; i += 1) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

function askUserName() {
  const userName = prompt('Enter your name');
  if (userName === '' || userName === null) {
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

function renderUsersList(usersObj) {
  let html = '';
  Object.values(usersObj).forEach((user) => {
    html += `<li style="color: ${user.color}">${user.name}</li>`;
  });

  return html;
}

function setupEditor(socket, editorId, usersUlid, themesSelectId, modesSelectId) {
  const editorElem = document.getElementById(editorId);
  const usersUl = document.getElementById(usersUlid);

  if (editorElem == null || usersUl == null) {
    return null;
  }

  const themesSelect = document.getElementById(themesSelectId);
  let html = '';
  Object.entries(editorThemes).forEach(([themeId, themeName]) => {
    html += `<option value="${themeId}">${themeName}</option>`;
  });
  themesSelect.innerHTML = html;
  themesSelect.addEventListener('change', () => { monaco.editor.setTheme(themesSelect.options[themesSelect.selectedIndex].value); });

  const modesSelect = document.getElementById(modesSelectId);
  html = '';
  monaco.languages.getLanguages().forEach((lang) => {
    const selected = (lang.id === defaultLang) ? 'selected="selected"' : '';
    html += `<option value="${lang.id}" ${selected}>${lang.aliases[0] || lang.id}</option>`;
  });
  modesSelect.innerHTML = html;

  const channel = socket.channel(`editors:${editorElem.getAttribute('data-topic')}`, { user_name: getUserName(), user_color: getRandomColor() });

  const editor = monaco.editor.create(editorElem, {
    theme: defaultTheme,
    language: defaultLang,
    minimap: {
      enabled: false,
    },
    readOnly: true,
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
      channel.push('delete', { index, length });
    },
  });
  const userSelections = {};
  const selectionManager = new MonacoCollabExt.RemoteSelectionManager({ editor });

  editor.onDidChangeCursorSelection((e) => {
    const startOffset = editor.getModel().getOffsetAt(e.selection.getStartPosition());
    const endOffset = editor.getModel().getOffsetAt(e.selection.getEndPosition());
    channel.push('changeCursorSelection', { startOffset, endOffset });
  });

  channel.join()
    .receive('ok', (resp) => {
      editor.updateOptions({ readOnly: false });
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

      resp.users.forEach((user) => {
        users[user.name] = user;
        userSelections[user.name] = selectionManager.addSelection(user.name, user.color, user.name);
      });
      usersUl.innerHTML = renderUsersList(users);

      modesSelect.addEventListener('change', () => {
        monaco.editor.setModelLanguage(editor.getModel(), modesSelect.value);
        channel.push('changeEditorMode', { mode: modesSelect.value });
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

      channel.on('user_joined', (payload) => {
        users[payload.user.name] = payload.user;
        userSelections[payload.user.name] = selectionManager.addSelection(payload.user.name, payload.user.color, payload.user.name);
        usersUl.innerHTML = renderUsersList(users);
      });

      channel.on('user_left', (payload) => {
        delete users[payload.user.name];
        userSelections[payload.user.name].dispose();
        delete userSelections[payload.user.name];

        usersUl.innerHTML = renderUsersList(users);
      });

      channel.on('cursorSelectionChanged', (payload) => {
        selectionManager.setSelectionOffsets(payload.user.name, payload.startOffset, payload.endOffset);
      });

      channel.on('editorModeChanged', (payload) => {
        for (let i = 0; i < modesSelect.options.length; i += 1) {
          if (modesSelect.options[i].value === payload.mode) {
            modesSelect.selectedIndex = i;
            break;
          }
        }

        monaco.editor.setModelLanguage(editor.getModel(), payload.mode);
      });
    });

  return null;
}

export default setupEditor;
