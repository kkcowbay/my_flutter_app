const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

let rooms = {};

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    const data = JSON.parse(message);
    const { type, roomId, playerName } = data;

    switch (type) {
      case 'join_room':
        if (!rooms[roomId]) rooms[roomId] = [];
        rooms[roomId].push({ ws, playerName, ready: false });
        broadcastRoom(roomId);
        break;

      case 'toggle_ready':
        const players = rooms[roomId];
        const player = players.find(p => p.playerName === playerName);
        if (player) player.ready = data.ready;
        broadcastRoom(roomId);

        // 如果所有人都 ready，自動開始遊戲
        if (players.every(p => p.ready)) {
          players.forEach(p => p.ws.send(JSON.stringify({ type: 'game_start' })));
        }
        break;

      case 'click':
        // 實作記錄玩家秒數與排名邏輯（你已有完整版本）
        break;
    }
  });
});

function broadcastRoom(roomId) {
  const players = rooms[roomId] || [];
  const playerList = players.map(p => ({ playerName: p.playerName, ready: p.ready }));
  const msg = JSON.stringify({ type: 'room_update', players: playerList });
  players.forEach(p => p.ws.send(msg));
}

console.log("✅ WebSocket server running on ws://localhost:8080");
