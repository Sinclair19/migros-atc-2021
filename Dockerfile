FROM debian:bookworm

ADD rdma-core.tar.gz /
ADD perftest.tar.gz /

#RUN apt-get update && \
#  apt-get install -f -y build-essential cmake gcc libudev-dev libnl-3-dev \
#  libnl-route-3-dev pkg-config cython3 \
#  autoconf libtool-bin git pandoc python-docutils gfortran libgfortran5 && \
#  useradd -m user && \
#  cd /rdma-core && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. && make -j $(nproc) && make install && \
#  make -j $(nproc) && make install && \
#  cd /perftest && ./autogen.sh && ./configure && make && make install && \
#  apt purge -y autoconf libtool-bin git pandoc python-docutils \
#  cmake gcc pkg-config && \
#  apt autoremove -y && apt-get clean -y && apt-get autoclean -y && \
#  rm -rf /perftest /rdma-core && \
#  echo 'user:user' | chpasswd

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential cmake gcc libudev-dev libnl-3-dev \
  libnl-route-3-dev pkg-config cython3 automake autoconf libtool-bin git \
  pandoc python3 python3-dev python3-docutils python3-distutils gfortran libgfortran5 && \
  rm -rf /var/lib/apt/lists/*

RUN useradd -m user

# Build RDMA Core
RUN cd /rdma-core && \
  mkdir build && cd build && \
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. && \
  make -j$(nproc) && make install

# Build Perftest
RUN cd /perftest && \
  ./autogen.sh && ./configure && autoupdate && autoreconf -fiv && make -j$(nproc) && make install

# Clean up
RUN apt-get purge -y autoconf libtool-bin git pandoc python-docutils && \
  apt-get autoremove -y && apt-get clean -y && rm -rf /perftest /rdma-core
  

USER user

