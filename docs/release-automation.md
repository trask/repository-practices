# Release automation

## Table of Contents

- [Overview](#overview)
- [Change log management](#change-log-management)
- [Prepare release branch](#prepare-release-branch)
- [Prepare patch](#prepare-patch)
- [Backport pull requests to a release branch](#backport-pull-requests-to-a-release-branch)
- [Release](#release)
- [Update the change log with the release date](#update-the-change-log-with-the-release-date)

## Overview

There are lots of different ways to do release automation. The particular release automation here is
designed around these principles:

* Avoid loosening of branch protection rules, in particular
  * Require a pull request before merging
  * Require approvals
  * Require review from Code Owners
  * Require status checks to pass before merging
* Make releases from release branches

As an added benefit, submitting automated changes via pull request provides nice visibility of these
changes to everyone monitoring the repository.

Submitting automated changes via pull requests is not as cumbersome as you may imagine. Since these
automated pull requests are coming from a bot account, the same person who triggers the workflows
that generate the pull requests can still approve and merge them.

## RELEASING.md

See an example [RELEASING.md](../RELEASING.md) that goes with the automation described below.

## Change log management

TODO

## Prepare release branch

Uses release branch naming convention `release/v*`.

The specifics below depend a lot on your specific version updating needs.

For OpenTelemetry Java repositories, the version in `main` always ends with `-SNAPSHOT`,
so preparing the release branch involves

* removing `-SNAPSHOT` from the version on the release branch
  (e.g. updating the version from `1.2.0-SNAPSHOT` to `1.2.0`)
* updating the version to the next `-SNAPSHOT` on `main`
  (e.g. updating the version from `1.2.0-SNAPSHOT` to `1.3.0-SNAPSHOT`)

See [prepare-release-branch.yml](../.github/workflows/prepare-release-branch.yml).

## Prepare patch

The specifics depend a lot on the build tool and your version updating needs.

For OpenTelemetry Java repositories, we have a workflow which generates a pull request
against the release branch to update the version (e.g. from `1.2.0` to `1.2.1`).

See [prepare-patch-release.yml](../.github/workflows/prepare-patch-release.yml).

## Backport pull requests to a release branch

Having a workflow generate backport pull requests is nice because then you know that it was a clean
cherry-pick and that it does not require re-review.

See [backport.yml](../.github/workflows/backport.yml).

## Release

See [release.yml](../.github/workflows/release.yml).

### Create the GitHub release

Add `--draft` to the `gh release create` command if you want to review the release before hitting
the "Publish release" button yourself.

You will need to remove `--discussion-category announcements` if you add `--draft`
(you can still choose whether to select "Create a discussion for this release" before
hitting the "Publish release" button).

See [release.yml](../.github/workflows/release.yml).

### Update the change log with the release date

See [release.yml](../.github/workflows/release.yml).
