#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	asciidoc	   \
	autoconf	   \
	automake	   \
	cmake	       \
	cpptrace	   \
	fltk		   \
	gtest		   \
	jsoncpp		   \
	libdecor	   \
	miniupnpc	   \
	portmidi	   \
	qt5-wayland    \
	sdl2_mixer     \
    timidity++	   \
	wxwidgets-gtk3

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building DeuTex..."
echo "---------------------------------------------------------------"
REPO="https://github.com/Doom-Utils/deutex"
git clone --depth 1 "$REPO" ./deutex

cd ./deutex
./bootstrap
./configure --prefix=/usr
make -j$(nproc) install
cd ../

echo "Building stable version of Odamex..."
echo "---------------------------------------------------------------"
REPO="https://github.com/odamex/odamex"
VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | sed 's/.*\///; s/\^{}//; s/^v//' | grep -E '^[0-9]+(\.[0-9]+)*$' | tail -n1)"
git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./odamex
echo "$VERSION" > ~/version

export CFLAGS CXXFLAGS
CFLAGS+=" -DSDL20"
CXXFLAGS+=" -DSDL20"
cmake -S ./odamex -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX='/usr' \
    -DBUILD_OR_FAIL=ON \
    -DBUILD_TESTS=OFF \
    -DUSE_LTO=OFF \
    -DENABLE_PORTMIDI=ON \
    -DUSE_INTERNAL_CPPTRACE=OFF \
    -DUSE_INTERNAL_CURL=OFF \
    -DUSE_INTERNAL_FLTK=OFF \
	-DUSE_INTERNAL_GTEST=OFF \
    -DUSE_INTERNAL_JSONCPP=OFF \
    -DUSE_INTERNAL_LIBADLMIDI=ON \
    -DUSE_INTERNAL_MINIUPNP=OFF \
    -DUSE_INTERNAL_PNG=OFF \
    -DUSE_INTERNAL_ZLIB=OFF \
    -DUSE_INTERNAL_ZSTD=OFF \
    -DUSE_INTERNAL_WXWIDGETS=OFF \
	-DUSE_MINIUPNP=ON
cmake --build build -j$(nproc)
cmake --install build
