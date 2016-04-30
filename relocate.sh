#!/usr/bin/env sh

set -x
set -e

PREFIX='/opt/python'

detect_elf_files() {
    xargs file|\
    grep 'ELF 64-bit'|\
    cut -d: -f1
}

detect_so_libs() {
    detect_elf_files|\
    xargs -n1 ldd 2>/dev/null|\
    grep -v ldd|\
    grep '=>'|\
    awk '{print $3}'|\
    sort|\
    uniq
}

collect_so_libs() {
    echo "$*"|\
    xargs -n1|\
    sort|\
    uniq|\
    grep -v "$PREFIX"|\
    xargs -n1 -i{} /bin/cp -f {} "$PREFIX/lib"
}

create_so_symlinks() {
    cd $PREFIX/lib
    for SO_LIB in `find * -type f -name '*.so.*.*.*' -maxdepth 1`; do
        SYMLINK=`echo "$SO_LIB"|grep -o '^.*[.]so[.][^.]*'`
        ln -s "$SO_LIB" "$SYMLINK"
    done
    cd -
}

patch_python() {
    $PREFIX/bin/patchelf --replace-needed "libpython2.7.so" "$PREFIX/lib/libpython2.7.so" $PREFIX/bin/python
    $PREFIX/bin/patchelf --replace-needed "libz.so.1" "$PREFIX/lib/libz.so.1" $PREFIX/bin/python
    $PREFIX/bin/patchelf --replace-needed "libssl.so.1.0.0" "$PREFIX/lib/libssl.so.1.0.0" $PREFIX/bin/python
    $PREFIX/bin/patchelf --replace-needed "libcrypto.so.1.0.0" "$PREFIX/lib/libcrypto.so.1.0.0" $PREFIX/bin/python
    $PREFIX/bin/patchelf --set-interpreter "$PREFIX/lib/ld-musl-x86_64.so.1" $PREFIX/bin/python
}

patch_salt() {
    local rsax931_py="$PREFIX/lib/python2.7/site-packages/salt/utils/rsax931.py"
    [ -f "$rsax931_py" ] && sed -i "s%lib = find_library('crypto')%lib = '$PREFIX/lib/libcrypto.so.1.0.0'%" $rsax931_py
}

STAGE1=`find $PREFIX/* -type f|detect_so_libs`
STAGE2=`echo "$STAGE1"|detect_so_libs`  # paranoid!
STAGE3=`echo "$STAGE2"|detect_so_libs`  # \:D/

collect_so_libs "$STAGE1" "$STAGE2" "$STAGE3"
create_so_symlinks
patch_python
patch_salt

# vim:ts=4:sw=4:et:
