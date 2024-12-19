#!/bin/bash

sudo modprobe rdma_rxe

sudo rdma link add rxe0 type rxe netdev ens37