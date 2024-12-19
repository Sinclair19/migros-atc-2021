#!/bin/bash

docker rm cont-moving

ssh welt@192.168.172.128 'echo "123456" | sudo -S docker checkpoint create cont-moving ckpt1'

docker create --name cont-moving --network rdma-net --ip 10.0.1.7 \
   --security-opt seccomp:unconfined --ulimit memlock=1073741824 \
   --cap-add=ALL --memory=1g --kernel-memory=1G --device /dev/infiniband/ \
   migros/perftest:latest ib_send_bw -d rxe0 -n 100000

SRC_ID=$(ssh welt@192.168.172.128 'echo "123456" | sudo -S docker inspect --format="{{.Id}}" cont-moving')
DEST_ID=$(docker inspect --format="{{.Id}}" cont-moving)
CONTAINERS=/var/lib/docker/containers/

echo 64 > /proc/sys/net/rdma_rxe/last_qpn 
echo 64 > /proc/sys/net/rdma_rxe/last_mrn
scp -r welt@192.168.172.128:$CONTAINERS/$SRC_ID/checkpoints/ckpt1 $CONTAINERS/$DEST_ID/checkpoints/

ssh welt@192.168.172.128 'echo "123456" | sudo -S docker rm cont-moving'

docker start cont-moving --checkpoint ckpt1
