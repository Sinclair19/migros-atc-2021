#!/bin/bash

docker rm --force cont-moving
docker rm --force cont-static

echo 16 > /proc/sys/net/rdma_rxe/last_qpn 
echo 16 > /proc/sys/net/rdma_rxe/last_mrn
docker run --rm --name cont-static --network rdma-net --ip 10.0.1.6 \
   --security-opt seccomp:unconfined --ulimit memlock=1073741824 \
   --cap-add=ALL --memory=1g --kernel-memory=1G --device /dev/infiniband/ \
   docker-repo/perftest:latest ib_send_bw -d rocep2s4 -n 100000 10.0.1.7 -b
