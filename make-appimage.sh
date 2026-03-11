#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/odamex/odamex/refs/heads/stable/media/icon_odalaunch_512.png
export DESKTOP=https://raw.githubusercontent.com/odamex/odamex/refs/heads/stable/packaging/linux/net.odamex.Odamex.Launcher.desktop
export APPNAME=Odamex
export USE_HOST_DRIVERS_EXPERIMENTAL=1

# on archlinux qt5-wayland also adds the server side plugins
# remove them so that they do not get deployed
rm -rf /usr/lib/qt/plugins/wayland-graphics-integration-server

# Deploy dependencies
quick-sharun /usr/bin/odalaunch /usr/bin/odamex /usr/bin/odasrv

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
