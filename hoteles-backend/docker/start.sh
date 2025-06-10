#!/bin/bash
set -e

cd /app

# Crear archivo simple que responde inmediatamente
echo '<?php echo "OK";' > public/index.php

echo "✅ Starting on port ${PORT:-8080}"
exec php -S 0.0.0.0:${PORT:-8080} -t public/