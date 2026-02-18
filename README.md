# WeMo Bridge Stack

Umbrella repository for the post-Belkin-support local WeMo migration stack.

## Repositories
- [`wemo-matter-bridge`](https://github.com/jolie1204/wemo-matter-bridge)
  - Matter bridge app and integration logic
- [`openwemo-bridge-core`](https://github.com/jolie1204/openwemo-bridge-core)
  - WeMo LAN control core (`wemo_ctrl`, IPC, UPnP integration)
- [`connectedhomeip`](https://github.com/jolie1204/connectedhomeip)
  - Pinned fork used for bridge compatibility

## Dependencies
- [`pupnp`](https://github.com/jolie1204/pupnp)
  - Portable UPnP SDK used by WeMo LAN control components

## Recommended Entry Point
1. Read setup and operations guide in:
   - `wemo-matter-bridge/docs/HOWTO.md`
2. Check compatibility and known caveats:
   - `wemo-matter-bridge/COMPATIBILITY.md`
3. Follow roadmap and release priorities:
   - `wemo-matter-bridge/ROADMAP.md`

## Goal
Keep legacy WeMo LAN devices usable via Matter with local-first reliability.
