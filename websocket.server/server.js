const WebSocket = require('ws');

const server = new WebSocket.Server({ port: 8080 });

let rooms = {};

server.on('connection', (ws) => {
  console.log('新玩家連線');

  ws.on('message', (message) => {
    const data = JSON.parse(message);
    const { type, roomId, playerName } = data;

    switch (type) {
      case 'join':
        if (!rooms[roomId]) {
          rooms[roomId] = { players: [], host: playerName };
        }
        rooms[roomId].players.push({
          name: playerName,
          ready: false,
          avatar: data.avatar ?? 'avatar1.png', // 新增：預設頭像
        });
        broadcastRoomUpdate(roomId);
        break;

      case 'toggle_ready':
        const player = rooms[roomId]?.players.find(p => p.name === playerName);
        if (player) {
          player.ready = data.ready;
          broadcastRoomUpdate(roomId);
        }
        break;

      case 'start_game':
        broadcast(roomId, {
          type: 'game_start',
        });
        break;

      case 'click':
        broadcast(roomId, {
          type: 'click_result',
          playerName: playerName,
          delta: data.delta,
        });
        break;

      case 'restart_game':
        broadcast(roomId, {
          type: 'restart_game',
        });
        break;

      case 'send_quick_message':
        broadcast(roomId, {
          type: 'quick_message',
          playerName: playerName,
          message: data.message,
        });
        break;

      default:
        break;
    }
  });

  ws.on('close', () => {
    console.log('玩家斷線');
    removePlayerFromRooms(ws);
  });
});

function broadcastRoomUpdate(roomId) {
  const room = rooms[roomId];
  if (room) {
    const data = {
      type: 'room_update',
      players: room.players,
      host: room.host,
    };
    broadcast(roomId, data);
  }
}

function broadcast(roomId, data) {
  server.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  });
}

function removePlayerFromRooms(ws) {
  for (const roomId in rooms) {
    rooms[roomId].players = rooms[roomId].players.filter(p => p.ws !== ws);
    if (rooms[roomId].players.length === 0) {
      delete rooms[roomId];
    }
  }
}

console.log('✅ WebSocket 伺服器已啟動在 ws://localhost:8080');
