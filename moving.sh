#!/bin/bash

docker rm cont-moving

ssh root@192.168.172.130 docker checkpoint create cont-moving ckpt1

docker create --name cont-moving --network rdma-net --ip 10.0.1.7 \
   --security-opt seccomp:unconfined --ulimit memlock=1073741824 \
   --cap-add=ALL --memory=1g --kernel-memory=1G --device /dev/infiniband/ \
   docker-repo/perftest:latest ib_send_bw -d rocep2s4 -n 100000

SRC_ID=$(ssh root@192.168.172.130 docker inspect --format="{{.Id}}" cont-moving)
DEST_ID=$(docker inspect --format="{{.Id}}" cont-moving)
CONTAINERS=/var/lib/docker/containers

echo 64 > /proc/sys/net/rdma_rxe/last_qpn 
echo 64 > /proc/sys/net/rdma_rxe/last_mrn
scp -r root@192.168.172.130:$CONTAINERS/$SRC_ID/checkpoints/ckpt1 $CONTAINERS/$DEST_ID/checkpoints/

ssh root@192.168.172.130 docker rm cont-moving

docker start cont-moving --checkpoint ckpt1
