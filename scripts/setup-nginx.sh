#!/bin/bash

set -e

echo "=== Nginx 설치 시작 ==="

sudo apt-get update
sudo apt-get install -y nginx

echo "=== 웹 파일 배포 ==="

sudo mkdir -p /var/www/cloud-portfolio

sudo cp /tmp/index.html /var/www/cloud-portfolio/index.html

echo "=== Nginx 사이트 설정 ==="

sudo tee /etc/nginx/sites-available/cloud-portfolio > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;

    server_name _;

    root /var/www/cloud-portfolio;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location = /health {
        default_type text/plain;
        return 200 "OK\n";
    }
}
EOF

sudo rm -f /etc/nginx/sites-enabled/default

sudo ln -sf \
    /etc/nginx/sites-available/cloud-portfolio \
    /etc/nginx/sites-enabled/cloud-portfolio

echo "=== Nginx 설정 검사 ==="

sudo nginx -t

echo "=== Nginx 실행 ==="

sudo systemctl enable nginx
sudo systemctl restart nginx

echo "=== 로컬 접속 테스트 ==="

curl -I http://localhost

echo "=== Health Check 테스트 ==="

curl http://localhost/health

echo
echo "=== Nginx 설정 완료 ==="