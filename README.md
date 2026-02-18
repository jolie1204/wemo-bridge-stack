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


## Quick Start

### 1) Clone sibling repos
```bash
mkdir -p ~/wemo-stack && cd ~/wemo-stack
git clone git@github.com:jolie1204/wemo-matter-bridge.git
git clone git@github.com:jolie1204/openwemo-bridge-core.git
git clone git@github.com:jolie1204/connectedhomeip.git
git clone git@github.com:jolie1204/pupnp.git
```

### 2) Check out pinned baselines
Use SHAs/tags from [`DEPENDENCY_PINS.md`](./DEPENDENCY_PINS.md).

### 3) Build in order
1. `pupnp` (if needed by your environment)
2. `openwemo-bridge-core` (`wemo_ctrl`, `wemo_engine`)
3. `wemo-matter-bridge/matter-bridge-app`

Example for bridge app:
```bash
cd ~/wemo-stack/wemo-matter-bridge/matter-bridge-app
./build_wemo_bridge.sh
```

### 4) Deploy and start
If your environment uses `bridge_stack.sh`:
```bash
cd ~/wemo-stack
./bin/bridge_stack.sh stop
cp wemo-matter-bridge/matter-bridge-app/out/ethernet/wemo-bridge-app ./bin/wemo-bridge-app
./bin/bridge_stack.sh start
./bin/bridge_stack.sh status
```

### 5) Verify
```bash
rg -n "WeMo bind|Added device|Device\[" ~/wemo-stack/var/log/wemo_bridge.log | tail -n 200
```

Then commission the bridge in your Matter controller app (Google Home, etc.).

## Recommended Read Order
1. `wemo-matter-bridge/docs/HOWTO.md`
2. [`DEPENDENCY_PINS.md`](./DEPENDENCY_PINS.md)
3. `wemo-matter-bridge/COMPATIBILITY.md`
4. `wemo-matter-bridge/ROADMAP.md`

## Architecture At a Glance
1. `wemo_ctrl` discovers and controls WeMo LAN devices via UPNP.
2. `wemo-bridge-app` bridges those devices as Matter endpoints.
3. Controller apps (Google Home, etc.) interact with Matter endpoints.
4. State/events are exchanged locally between bridge app and `wemo_ctrl` over IPC.

## Build and Deploy Order
1. Build/install `pupnp` (if your environment does not already provide a compatible build).
2. Build `openwemo-bridge-core` (`wemo_ctrl` and `wemo_engine`).
3. Build `wemo-matter-bridge/matter-bridge-app` against pinned `connectedhomeip`.
4. Deploy binaries and start stack with your runtime script.

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
