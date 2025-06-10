#!/bin/bash
cd /app
php artisan migrate --force || true

# Crear servidor que responde
cat > server.js << 'EOF'
const http = require('http');
const { exec } = require('child_process');

const server = http.createServer((req, res) => {
  if (req.url === '/') {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({status: 'ok'}));
  } else {
    exec(`php /app/public/index.php ${req.url}`, (error, stdout) => {
      res.writeHead(200, {'Content-Type': 'application/json'});
      res.end(stdout || JSON.stringify({error: error?.message}));
    });
  }
});

server.listen(process.env.PORT || 8080);
console.log('Server running on port', process.env.PORT || 8080);
EOF

node server.js