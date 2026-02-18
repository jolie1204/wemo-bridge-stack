# WeMo Bridge Stack

Umbrella repository for the post-Belkin-support local WeMo migration stack.

## Purpose
Keep legacy WeMo LAN devices usable through Matter with a local-first bridge architecture.

## Stack Components
- [`wemo-matter-bridge`](https://github.com/jolie1204/wemo-matter-bridge)
  - Matter bridge app and integration logic.
- [`openwemo-bridge-core`](https://github.com/jolie1204/openwemo-bridge-core)
  - WeMo LAN control core (`wemo_ctrl`, IPC broker, UPNP integration).
- [`connectedhomeip`](https://github.com/jolie1204/connectedhomeip)
  - Pinned CHIP fork for bridge compatibility.
- [`pupnp`](https://github.com/jolie1204/pupnp)
  - Portable UPNP SDK used by WeMo control components.

## Reproducible Build (Recommended)
Use the stack script to clone, pin, build, and apply known compatibility fixes.

```bash
cd <path-to-this-repo>
WORKSPACE="${WORKSPACE:-$HOME/wemo-stack}" ./scripts/reproduce_build.sh
```

The script:
1. Clones/updates sibling repos under `$WORKSPACE`.
2. Checks out pinned SHAs from `DEPENDENCY_PINS.md`.
3. Builds `pupnp` from source (no dependency on `/usr/local` installation).
4. Builds `openwemo-bridge-core` with `UPNP_BASE=$WORKSPACE/pupnp`.
5. Applies the current `UpnpInit2` compatibility patch when needed.
6. Builds `wemo-matter-bridge/matter-bridge-app`.

## Manual Quick Start

### 1) Define workspace
```bash
export WORKSPACE="${WORKSPACE:-$HOME/wemo-stack}"
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"
```

### 2) Clone sibling repos
```bash
git clone https://github.com/jolie1204/wemo-matter-bridge.git
git clone https://github.com/jolie1204/openwemo-bridge-core.git
git clone https://github.com/jolie1204/connectedhomeip.git
git clone https://github.com/jolie1204/pupnp.git
```

### 3) Check out pinned baselines
Use SHAs/tags from [`DEPENDENCY_PINS.md`](./DEPENDENCY_PINS.md).

### 4) Build in order
1. `pupnp`
2. `openwemo-bridge-core` (`wemo_ctrl`, `wemo_engine`) with `UPNP_BASE="$WORKSPACE/pupnp"`
3. `wemo-matter-bridge/matter-bridge-app`

Example for bridge app:
```bash
cd "$WORKSPACE/wemo-matter-bridge/matter-bridge-app"
./build_wemo_bridge.sh
```

### 5) Deploy and start
Preferred deployment helper:
```bash
cd "$WORKSPACE/wemo-matter-bridge"
./scripts/install_bridge_stack.sh --workspace "$WORKSPACE"
```

If your environment already has `bridge_stack.sh`:
```bash
cd "$WORKSPACE"
./bin/bridge_stack.sh stop
cp wemo-matter-bridge/matter-bridge-app/out/ethernet/wemo-bridge-app ./bin/wemo-bridge-app
./bin/bridge_stack.sh start
./bin/bridge_stack.sh status
```

### 6) Verify
```bash
rg -n "WeMo bind|Added device|Device\[" "$WORKSPACE/var/log/wemo_bridge.log" | tail -n 200
```

Then commission the bridge in your Matter controller app (Google Home, etc.).

## Recommended Read Order
1. `wemo-matter-bridge/docs/CODEX_SETUP.md`
2. `wemo-matter-bridge/docs/HOWTO.md`
3. [`DEPENDENCY_PINS.md`](./DEPENDENCY_PINS.md)
4. `wemo-matter-bridge/COMPATIBILITY.md`

## Architecture At a Glance
1. `wemo_ctrl` discovers and controls WeMo LAN devices via UPNP.
2. `wemo-bridge-app` bridges those devices as Matter endpoints.
3. Controller apps (Google Home, etc.) interact with Matter endpoints.
4. State/events are exchanged locally between bridge app and `wemo_ctrl` over IPC.

## Upgrade Policy
- Do not track bleeding edge by default.
- Pin all dependency SHAs and update intentionally.
- Validate with smoke tests before promoting a new pin set.

## Minimum Smoke Validation
1. All expected WeMo devices discovered and bridged.
2. On/off control works for switch endpoints.
3. Dimming and level persistence work for dimmers.
4. Restart stack and confirm endpoint/control stability.

## Support and Reporting
When filing issues include:
1. Stack pin set (`DEPENDENCY_PINS.md` revision or exact SHAs).
2. Controller app/version and platform.
3. Relevant log snippets (`wemo_bridge.log`, `wemo_ctrl.log`).
4. Timestamped repro steps.
