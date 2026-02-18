# Dependency Pins

This document defines the known-good dependency set for the WeMo bridge stack.

## Current Baseline Pins
| Component | Repo | Branch/Tag | Pinned SHA | Notes |
|---|---|---|---|---|
| Matter bridge | `jolie1204/wemo-matter-bridge` | `master` | `91aa7d545853cc6eaedd51df61caf22ed987d9f3` | Known-compatible with public openwemo APIs; stack script applies required build compatibility patches. |
| WeMo core | `jolie1204/openwemo-bridge-core` | `main` | `4c173e6b15eb487dd75e4da62b2ec358b1677ce4` | Source of `wemo_ctrl` + `wemo_engine`. |
| CHIP fork | `jolie1204/connectedhomeip` | `wemo-v1.5.0.1` | `8effa808dd9fa195ec0294f0ad67c80a86dd4975` | Stable baseline for bridge compatibility. |
| UPNP SDK | `jolie1204/pupnp` | `main` | `1124f692772f673a0dc8d5371f50c0d334905b1c` | Used by WeMo LAN/UPNP layer. |

## Pinning Rules
1. Always pin by full commit SHA for releases.
2. Record any local patches applied to dependencies.
3. Update one dependency at a time where possible.
4. Re-run commissioning and control validation after each pin change.

## Update Procedure
1. Create an update branch in each affected repo.
2. Update target dependency SHA/tag.
3. Build full stack from clean checkout.
4. Run smoke validation:
   - discovery
   - on/off
   - dimmer level
   - restart persistence
5. If successful, update this file and release notes.
6. Promote by merging update branch and tagging stack release.

## Rollback Procedure
1. Stop running services.
2. Restore previous known-good SHAs.
3. Rebuild/deploy binaries from previous pins.
4. Restart stack.
5. Verify behavior returns to baseline.

## Notes
- For CHIP upgrades, validate endpoint identity/mapping behavior carefully in controller apps.
- For UPNP/pupnp changes, validate device discovery stability and command latency.
