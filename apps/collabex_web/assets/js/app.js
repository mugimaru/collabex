import '../css/app.scss';

import setupEditor from './editor';

setupEditor('editor', 'users-list');

const newSessionBtn = document.getElementById('new-session-btn');

if (newSessionBtn) {
  newSessionBtn.onclick = () => {
    window.location = `${window.location}e/${Math.random().toString(36).substring(7)}`;
  };
}
