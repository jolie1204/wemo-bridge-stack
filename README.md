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
