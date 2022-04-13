# Repository settings

Repository settings in addition to what's documented already at
https://github.com/open-telemetry/community/blob/main/docs/how-to-configure-new-repository.md.

## General settings

* Automatically delete head branches: CHECKED

  (So that bot PR branches will be deleted)

## Branch protection settings

Branch protections settings in what's documented already at
https://github.com/open-telemetry/community/blob/main/docs/how-to-configure-new-repository.md#policies.

### `main` and `release/*`

* Status checks that are required:

  * required-status-check

### `**/**`

* Allow deletions: CHECKED

  (So that bot PR branches can be deleted)
