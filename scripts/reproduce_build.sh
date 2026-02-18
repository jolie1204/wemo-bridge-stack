#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${WORKSPACE:-$HOME/wemo-stack}"

WEMO_MATTER_SHA="91aa7d545853cc6eaedd51df61caf22ed987d9f3"
OPENWEMO_SHA="4c173e6b15eb487dd75e4da62b2ec358b1677ce4"
CHIP_SHA="8effa808dd9fa195ec0294f0ad67c80a86dd4975"
PUPNP_SHA="1124f692772f673a0dc8d5371f50c0d334905b1c"

log() { printf '[reproduce_build] %s\n' "$*"; }

clone_or_update() {
  local repo_url="$1"
  local dir="$2"
  if [[ ! -d "$dir/.git" ]]; then
    git clone "$repo_url" "$dir"
  else
    git -C "$dir" fetch --all --tags --quiet || true
  fi
}

checkout_pin() {
  local dir="$1"
  local ref="$2"
  git -C "$dir" checkout "$ref"
}

mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

log "Cloning/updating repos under $WORKSPACE"
clone_or_update https://github.com/jolie1204/wemo-matter-bridge.git wemo-matter-bridge
clone_or_update https://github.com/jolie1204/openwemo-bridge-core.git openwemo-bridge-core
clone_or_update https://github.com/jolie1204/connectedhomeip.git connectedhomeip
clone_or_update https://github.com/jolie1204/pupnp.git pupnp

log "Checking out pinned SHAs"
checkout_pin wemo-matter-bridge "$WEMO_MATTER_SHA"
checkout_pin openwemo-bridge-core "$OPENWEMO_SHA"
checkout_pin connectedhomeip "$CHIP_SHA"
checkout_pin pupnp "$PUPNP_SHA"

log "Building pupnp (local source, no /usr/local dependency)"
cd "$WORKSPACE/pupnp"
./bootstrap || true
./configure
make -j

log "Applying openwemo UpnpInit2 compatibility patch if needed"
OPENWEMO_CTRL="$WORKSPACE/openwemo-bridge-core/wemo_ctrl/wemo_ctrl.c"
if grep -q 'UpnpInit2(ifname, port, DeviceUDN)' "$OPENWEMO_CTRL"; then
  sed -i 's/UpnpInit2(ifname, port, DeviceUDN)/UpnpInit2(ifname, port)/' "$OPENWEMO_CTRL"
fi

log "Building openwemo-bridge-core against local pupnp"
cd "$WORKSPACE/openwemo-bridge-core"
make clean
make -j UPNP_BASE="$WORKSPACE/pupnp"

log "Ensuring required CHIP submodules for Linux bridge build"
git -C "$WORKSPACE/connectedhomeip" submodule update --init --recursive \
  third_party/pigweed/repo \
  third_party/jsoncpp/repo \
  third_party/nlassert/repo \
  third_party/nlio/repo \
  third_party/mbedtls/repo \
  third_party/boringssl/repo/src \
  third_party/perfetto/repo

log "Applying wemo-matter-bridge compatibility fixes"
WMB_MAIN_CPP="$WORKSPACE/wemo-matter-bridge/matter-bridge-app/main.cpp"
sed -i 's#<platform/DefaultTimerDelegate.h>#<app/DefaultTimerDelegate.h>#' "$WMB_MAIN_CPP"

log "Applying wemo-matter-bridge BUILD.gn compatibility fixes"
WMB_BUILD_GN="$WORKSPACE/wemo-matter-bridge/matter-bridge-app/BUILD.gn"
# 1) portable runtime rpath
sed -E -i 's#-Wl,-rpath,/home/[^/]+/wemo-matter(-claude)?/openwemo-bridge-core/wemo_engine#-Wl,-rpath,\\$ORIGIN#' "$WMB_BUILD_GN"
sed -i 's#-Wl,-rpath,\$ORIGIN#-Wl,-rpath,\\$ORIGIN#' "$WMB_BUILD_GN"
# 2) ensure identify-server dep for CHIP v1.5 include visibility
if ! grep -q 'identify-server:identify-server' "$WMB_BUILD_GN"; then
  sed -i '/examples\/platform\/linux:app-main"/a\    "${chip_root}/src/app/clusters/identify-server:identify-server",' "$WMB_BUILD_GN"
fi

log "Building Matter bridge app"
cd "$WORKSPACE/wemo-matter-bridge/matter-bridge-app"
./build_wemo_bridge.sh

log "Build complete"
log "wemo_ctrl: $WORKSPACE/openwemo-bridge-core/wemo_ctrl/wemo_ctrl"
log "wemo-bridge-app: $WORKSPACE/wemo-matter-bridge/matter-bridge-app/out/ethernet/wemo-bridge-app"
