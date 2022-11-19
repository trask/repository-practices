# Repository settings

Repository settings in addition to what's documented already at
<https://github.com/open-telemetry/community/blob/main/docs/how-to-configure-new-repository.md>.

## General > Pull Requests

* Automatically delete head branches: CHECKED

  (So that bot PR branches will be deleted)

## Branch protections

### `main`

* Status checks that are required:

  * EasyCLA
  * required-status-check

### `release/*`

Same settings as above for `main`, except:

* Restrict pushes that create matching branches: UNCHECKED

  (So that opentelemetrybot can create release branches)

### `dependabot/**/*` and `opentelemetrybot/**/*`

* Require status checks to pass before merging: UNCHECKED

  (So that dependabot PRs can be rebased)

* Restrict who can push to matching branches: UNCHECKED

  (So that bots can create PR branches in this repository)

* Allow force pushes > Everyone

  (So that dependabot PRs can be rebased)

* Allow deletions: CHECKED

  (So that bot PR branches can be deleted)

### `**/**`

* Status checks that are required:

  EasyCLA
