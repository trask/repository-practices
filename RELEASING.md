# Release instructions

TODO update link targets below from https://github.com/trask/repository-template to your repository

## Preparing a new major or minor release

* Merge a pull request to `main` updating the `CHANGELOG.md`.
  * The heading for the release should include the release version but not the release date, e.g.
    `## Version 1.9.0 (unreleased)`.
  * Use `.github/scripts/draft-change-log-entries.sh` as a starting point for writing the change
    log.
* Run the [Prepare release branch workflow](https://github.com/trask/repository-template/actions/workflows/prepare-release-branch.yml).
  * Press the "Run workflow" button, and leave the default branch `main` selected.
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
  * The heading for the release should include the release version but not the release date, e.g.
    `## Version 1.9.1 (Unreleased)`.
* Run the [Prepare patch release workflow](https://github.com/trask/repository-template/actions/workflows/prepare-patch-release.yml).
  * Press the "Run workflow" button, then select the release branch from the dropdown list,
    e.g. `release/v1.9.x`, and click the "Run workflow" button below that.
* Review and merge the pull request that it creates.

## Making the release

* Run the [Release workflow](https://github.com/trask/repository-template/actions/workflows/release.yml).
  * Press the "Run workflow" button, then select the release branch from the dropdown list,
    e.g. `release/v1.9.x`, and click the "Run workflow" button below that.
  * This workflow will publish the artifacts and publish a GitHub release with release notes based on the change log.

## After the release

* Run the [Merge change log to main workflow](https://github.com/trask/repository-template/actions/workflows/merge-change-log-to-main.yml).
  * Press the "Run workflow" button, then select the release branch from the dropdown list,
    e.g. `release/v1.9.x`, and click the "Run workflow" button below that.
  * This will create a pull request that merges the change log updates from the release branch
    back to `main`.
  * Note: this workflow will fail if there have been conflicting change log updates introduced in `main`,
    in which case you will need to merge the change log updates manually and send your own pull
    request against `main`.
* Review and merge the pull request that it creates.

## Notes about "pre-releases"

* Pre-release versions (e.g. `1.9.0-rc.1`) are supported, and will cause a "short-term" release branch to be created
  based on the full version name (e.g. `release/v1.9.0-rc.1` instead of a "long-term" release branch name like
  `release/v1.9.x`).
* Patch releases are not supported on short-term release branches.
* The version in `main` in this case will be bumped to the release version (e.g. `1.9.0-dev`).
* To make a second pre-release version, manually update the version in `main`
  (e.g. update it from `1.9.0-dev` to `1.9.0-rc.2-dev`)
  before running the prepare release branch workflow for that release.
