import '../css/app.scss';

import { Socket } from 'phoenix';
import setupEditor from './editor';


const socket = new Socket('/socket', { params: {} });
socket.connect();

setupEditor(socket, 'editor', 'users-list', 'themes-select');

const newSessionBtn = document.getElementById('new-session-btn');

if (newSessionBtn) {
  newSessionBtn.onclick = () => {
    window.location = `${window.location}e/${Math.random().toString(36).substring(7)}`;
  };
}
