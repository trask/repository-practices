# Release instructions

TODO update link targets below from https://github.com/trask/repository-template to your repository

## Preparing a new major or minor release

* Merge a pull request to `main` updating the `CHANGELOG.md`.
  * The heading for the unreleased entries should be `## Unreleased`.
  * You can use `.github/scripts/draft-change-log-entries.sh` as a starting point for writing the change
    log if you do not add change log entries in their respective PRs.
* Run the [Prepare release branch workflow](https://github.com/trask/repository-template/actions/workflows/prepare-release-branch.yml).
  * Press the "Run workflow" button, and leave the default branch `main` selected.
    * If making a pre-release (e.g. release candidate), enter the pre-release version number, e.g. `1.9.0-rc.2`.
      (otherwise the workflow will pick up the version from `main` and just remove the `-dev` suffix).
  * Review and merge the two pull requests that it creates
    (one is targeted to the release branch and one is targeted to `main`).

## Preparing a new patch release

* Backport pull request(s) to the release branch.
  * Run the [Backport workflow](https://github.com/trask/repository-template/actions/workflows/backport.yml).
  * Press the "Run workflow" button, then select the release branch from the dropdown list,
    e.g. `release/v1.9.x`, then enter the pull request number that you want to backport,
    then click the "Run workflow" button below that.
  * Review and merge the backport pull request that it generates.
* Merge a pull request to the release branch updating the `CHANGELOG.md`.
  * The heading for the unreleased entries should be `## Unreleased`.
* Run the [Prepare patch release workflow](https://github.com/trask/repository-template/actions/workflows/prepare-patch-release.yml).
  * Press the "Run workflow" button, then select the release branch from the dropdown list,
    e.g. `release/v1.9.x`, and click the "Run workflow" button below that.
  * Review and merge the pull request that it creates for updating the version.

## Making the release

* Run the [Release workflow](https://github.com/trask/repository-template/actions/workflows/release.yml).
  * Press the "Run workflow" button, then select the release branch from the dropdown list,
    e.g. `release/v1.9.x`, and click the "Run workflow" button below that.
  * This workflow will publish the artifacts and publish a GitHub release with release notes based on the change log.
  * Review and merge the pull request that it creates for updating the change log in main
    (note that if this is not a patch release then the change log on main may already be up-to-date,
    in which case no pull request will be created).

## Notes about "pre-releases"

* Pre-release versions (e.g. `1.9.0-rc.2`) are supported, and will cause a "short-term" release branch to be created
  based on the full version name (e.g. `release/v1.9.0-rc.2` instead of a "long-term" release branch name like
  `release/v1.9.x`).
* Patch releases are not supported on short-term release branches.
* The version in `main` in this case will be bumped to the release version (e.g. `1.9.0-dev`).
