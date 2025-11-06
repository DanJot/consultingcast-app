const net = require('net');
const http = require('http');

const MYSQL_HOST = '10.1.55.10';
const MYSQL_PORT = 3306;
const PROXY_PORT = 3307; // Porta local para proxy

console.log('🚀 Servidor Proxy TCP iniciado');
console.log(`📡 A escutar na porta ${PROXY_PORT}`);
console.log(`🔄 A reencaminhar para ${MYSQL_HOST}:${MYSQL_PORT}`);
console.log('\n⚠️  IMPORTANTE: Este servidor corre LOCALMENTE');
console.log('   Para acesso remoto, precisa de túnel externo (ngrok, etc)\n');

const server = net.createServer((clientSocket) => {
  console.log(`[${new Date().toLocaleTimeString()}] Cliente conectado: ${clientSocket.remoteAddress}`);
  
  const mysqlSocket = net.createConnection({
    host: MYSQL_HOST,
    port: MYSQL_PORT
  }, () => {
    console.log(`[${new Date().toLocaleTimeString()}] Conectado ao MySQL`);
  });

  clientSocket.pipe(mysqlSocket);
  mysqlSocket.pipe(clientSocket);

  clientSocket.on('error', (err) => {
    console.error(`[${new Date().toLocaleTimeString()}] Erro cliente:`, err.message);
    mysqlSocket.end();
  });

  mysqlSocket.on('error', (err) => {
    console.error(`[${new Date().toLocaleTimeString()}] Erro MySQL:`, err.message);
    clientSocket.end();
  });

  clientSocket.on('close', () => {
    console.log(`[${new Date().toLocaleTimeString()}] Cliente desconectado`);
    mysqlSocket.end();
  });

  mysqlSocket.on('close', () => {
    clientSocket.end();
  });
});

server.listen(PROXY_PORT, () => {
  console.log(`✅ Proxy TCP pronto em localhost:${PROXY_PORT}`);
  console.log(`\n💡 Para usar no Railway, precisa de túnel externo:`);
  console.log(`   - ngrok tcp ${PROXY_PORT}`);
  console.log(`   - Ou Cloudflare Tunnel`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`❌ Porta ${PROXY_PORT} já está em uso!`);
    console.error(`   Muda PROXY_PORT no código ou fecha o processo que usa essa porta.`);
  } else {
    console.error('Erro:', err);
  }
});

