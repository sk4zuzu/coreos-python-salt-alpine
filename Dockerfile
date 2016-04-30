FROM scratch

ADD python.tar.xz /opt

ENV LD_LIBRARY_PATH /opt/python/lib

CMD ["/opt/python/bin/python.bin","-c","import shutil;shutil.copytree('/opt/python','/destdir/python',symlinks=True)"]

# vim:ts=4:sw=4:et:
