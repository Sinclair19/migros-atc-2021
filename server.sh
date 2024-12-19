#!/bin/bash

docker rm --force cont-moving

docker create --name cont-moving --network rdma-net --ip 10.0.1.7 \
   --security-opt seccomp:unconfined --ulimit memlock=1073741824 \
   --cap-add=ALL --memory=1g --kernel-memory=1G --device /dev/infiniband/ \
   migros/perftest:latest ib_send_bw -d rxe0 -n 100000 -b

echo 64 > /proc/sys/net/rdma_rxe/last_qpn
echo 64 > /proc/sys/net/rdma_rxe/last_mrn
docker start cont-moving
