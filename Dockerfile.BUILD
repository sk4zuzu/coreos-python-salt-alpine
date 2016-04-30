FROM alpine

RUN apk update && apk add git file tar xz curl vim
RUN apk add autoconf automake cmake make gcc g++ swig
RUN apk add musl-dev zlib-dev openssl-dev zeromq-dev

WORKDIR /tmp
RUN git clone https://github.com/NixOS/patchelf

WORKDIR /tmp/patchelf
RUN ./bootstrap.sh
RUN LDFLAGS='-static -static-libgcc -static-libstdc++' ./configure --prefix=/opt/python
RUN make -j4 install

ENV PY_VERSION_MAJOR=2 \
    PY_VERSION_MINOR=7 \
    PY_VERSION_PATCH=11

WORKDIR /tmp
RUN git clone https://github.com/python-cmake-buildsystem/python-cmake-buildsystem
WORKDIR /tmp/python-cmake-buildsystem
RUN mkdir build
WORKDIR build
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/python .. \
          -DBUILD_LIBPYTHON_SHARED=ON \
          -DBUILD_LIBPYTHON_STATIC=OFF \
          -DBUILD_EXTENSIONS_AS_BUILTIN=ON \
          -DENABLE_LINUXAUDIODEV=OFF \
          -DENABLE_OSSAUDIODEV=OFF \
          -DENABLE_CRYPT=ON \
          -DENABLE_SSL=ON \
          -DENABLE_ZLIB=ON

RUN make -j4 install

WORKDIR /tmp
RUN curl -ksLO https://bootstrap.pypa.io/get-pip.py

ENV PYPI_SALT_VERSION 2015.8.8.2

WORKDIR /opt/python
ENV LD_LIBRARY_PATH /opt/python/lib
RUN bin/python /tmp/get-pip.py --no-wheel
RUN bin/pip install salt==$PYPI_SALT_VERSION
RUN find -type f|xargs file|grep 'ELF 64-bit'|cut -d: -f1|xargs strip --strip-unneeded
ADD relocate.sh /opt/python/bin/relocate.sh
RUN bin/relocate.sh
RUN /bin/rm -rf bin/relocate.sh include lib/pkgconfig share
RUN find -type f -name '*.pyc'|xargs /bin/rm -f
RUN /bin/mv -f bin/python bin/python.bin
ADD python /opt/python/bin/python

WORKDIR /opt
RUN tar cf python.tar python && xz -e -9 python.tar

WORKDIR /opt/python
CMD /bin/sh

# vim:ts=4:sw=4:et:syn=dockerfile:
