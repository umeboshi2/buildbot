#!/bin/bash


deps="debhelper build-essential pkg-config libaldmb1-dev libfreetype6-dev libtheora-dev libvorbis-dev libogg-dev"

install_deps $deps

git clone git://github.com/adventuregamestudio/ags.git ags-src
cd ags-src
make --directory=Engine
cd Engine
mkdir ags.dir
mv ags ags.dir
mv ags.dir ags

arch=$(uname -m)
if [ "$arch" = "i686" ]; then
    BIT=32
    TRIPLET=i386-linux-gnu
elif [ "$arch" = "x86_64" ]; then
    BIT=64
    TRIPLET=x86_64-linux-gnu
else
    echo "Unsupported architecture $arch"
    exit 2
fi

mkdir -p ags/data/licenses
mkdir ags/data/lib$BIT

for library in \
    liballeg.so.4.4 \
    libaldmb.so.1 \
    libdumb.so.1 \
    libfreetype.so.6 \
    libogg.so.0 \
    libtheora.so.0 \
    libvorbis.so.0 \
    libvorbisfile.so.3 \
    allegro/4.4.2/alleg-alsadigi.so \
    allegro/4.4.2/alleg-alsamidi.so \
    allegro/4.4.2/modules.lst; do
        cp -L /usr/lib/$TRIPLET/$library ags/data/lib$BIT
done

for package in \
    liballegro4.4 \
    libdumb1 \
    libfreetype6 \
    libogg0 \
    libtheora0 \
    libvorbis0a; do
        cp /usr/share/doc/$package/copyright ags/data/licenses/$package-copyright
done

(
cat << 'EOF'
#!/bin/sh
SCRIPTPATH="$(dirname "$(readlink -f $0)")"
if test "x$@" = "x-h" -o "x$@" = "x--help"
then
    echo "Usage:" "$(basename "$(readlink -f $0)")" "[<ags options>]"
    echo ""
fi
if test $(uname -m) = x86_64
then
    ALLEGRO_MODULES="$SCRIPTPATH/data/lib64" "$SCRIPTPATH/ags" "$@"
else
    ALLEGRO_MODULES="$SCRIPTPATH/data/lib32" "$SCRIPTPATH/ags" "$@"
fi
EOF
) > ags/ags.sh

strip ags/ags
chown -R 1000:1000 ags
version=$(ags/ags | grep version | cut -d' ' -f 3)
ags_archive=ags-${version}-${arch}.tar.gz
tar czf $ags_archive ags
chown 1000:1000 $ags_archive
