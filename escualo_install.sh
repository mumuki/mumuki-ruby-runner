#/bin/bash
REV=$1

echo "[Escualo::RSpecServer] Fetching GIT revision"
echo -n $REV > version

echo "[Escualo::RSpecServer] Pulling docker image"
docker pull mumuki/mumuki-rspec-worker