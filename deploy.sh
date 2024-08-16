#!/bin/bash

DOCKER_USERNAME=$1
IMAGE_TAG=$2

# 새 컨테이너 시작
docker pull $DOCKER_USERNAME/JPAWEB:$IMAGE_TAG
docker run -d --name app-blue -p 8081:8080 $DOCKER_USERNAME/JPAWEB:$IMAGE_TAG

# 헬스 체크
for i in {1..10}
do
  if curl -s http://localhost:8081/health | grep -q "UP"
  then
    echo "New container is healthy"
    break
  fi
  if [ $i -eq 10 ]
  then
    echo "New container is not healthy"
    exit 1
  fi
  sleep 5
done

# 트래픽 전환
if docker ps -a | grep -q app-green
then
  docker stop app-green
  docker rm app-green
  docker rename app-blue app-green
else
  docker rename app-blue app-green
fi

# Nginx 설정 업데이트 (가정: Nginx를 사용하여 리버스 프록시 설정)
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo nginx -s reload

# 이전 컨테이너 정리
docker system prune -af 
