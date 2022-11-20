# General automation

## Table of Contents

- [Overview](#overview)
- [EasyCLA required status check](#easycla-required-status-check)
- [Workflows not running on automatically created pull requests](#workflows-not-running-on-automatically-created-pull-requests)
- [Create a pull request targeting another repository](#create-a-pull-request-targeting-another-repository)

## Overview

Automation is a bit tricky in because of these branch protection rules which are required on
OpenTelemetry repositories:

* Require a pull request before merging
* Require approvals
* Require review from Code Owners
* Require status checks to pass before merging

So, instead of automation being able to push a commit directly to `main` or `release/*`, it must
instead push the commit to a staging branch, and create a pull request to `main` or `release/*`,
which can then go through the above branch protection rules before being merge.

This workflow of going through pull requests is not as cumbersome as you may imagine. Since these
automated pull requests are coming from a bot account, the maintainer who triggers the workflow
that generates the pull requests can then just go and review/approve and merge it.

## EasyCLA required status check

The automated pull requests have to pass the EasyCLA required status check before they can be
merged.

The [@opentelemetrybot][] has signed the CNCF CLA, so you can use it to author the commit:

```
git config user.name opentelemetrybot
git config user.email 107717825+opentelemetrybot@users.noreply.github.com
```

## Workflows not running on automatically created pull requests

When you use the repository's `GITHUB_TOKEN` to perform tasks, events triggered by the
`GITHUB_TOKEN` will not create a new workflow run. This prevents you from accidentally creating
recursive workflow runs, but is also not very convenient because you have to manually trigger
workflow runs on all automatically generated pull requests by closing and re-opening the pull
request.

By using a [Personal Access Token][] for [@opentelemetrybot][]
to create the pull request, the above restriction does not apply, and workflows will run normally.

Important: this does not require giving [@opentelemetrybot][]] any permissions to your repository.
You are using the repository's `GITHUB_TOKEN` to push the commit to a staging branch in the
repository, and then using [@opentelemetrybot][]]'s PAT to create just the pull request (which any
github user has rights to do).

[Personal Access Token]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
[@opentelemetrybot]: https://github.com/opentelemetrybot

## Create a pull request targeting another repository

Important: it is generally easier and preferable to add polling github action in the other
repository.

For example to send a PR to notify/update another repository that a new release is available
as part of the release workflow.

Note that the [Personal Access Token][] used will need `workflow` (Update GitHub Action workflows)
permission since if workflows have been updated upstream it will be updating the workflows of the
origin repository when it pushes the branch.

```yaml
      - name: Sync opentelemetry-operator fork
        env:
          # this is the personal access token used for "gh repo sync" below
          GH_TOKEN: ${{ secrets.BOT_TOKEN }}
        run: |
          # synchronizing the fork is fast, and avoids the need to fetch the full upstream repo
          # (fetching the upstream repo with "--depth 1" would lead to "shallow update not allowed"
          #  error when pushing back to the origin repo)
          gh repo sync opentelemetrybot/opentelemetry-operator \
              --source open-telemetry/opentelemetry-operator \
              --force

      - uses: actions/checkout@v3
        with:
          repository: opentelemetrybot/opentelemetry-operator
          # this is the personal access token used for "git push" below
          token: ${{ secrets.BOT_TOKEN }}

      - name: Update version
        run: |
          echo $VERSION > autoinstrumentation/java/version.txt

      - name: Use CLA approved github account
        run: |
          git config user.name opentelemetrybot
          git config user.email 107717825+opentelemetrybot@users.noreply.github.com

      - name: Create pull request against opentelemetry-operator
        env:
          # this is the personal access token used for "gh pr create" below
          GH_TOKEN: ${{ secrets.BOT_TOKEN }}
        run: |
          message="Update the javaagent version to $VERSION"
          body="Update the javaagent version to \`$VERSION\`."
          branch="update-opentelemetry-javaagent-to-$VERSION"

          # gh pr create doesn't have a way to explicitly specify different head and base
          # repositories currently, but it will implicitly pick up the head from a different
          # repository if you set up a tracking branch

          git checkout -b $branch
          git commit -a -m "$message"
          git push --set-upstream origin $branch
          gh pr create --title "$message" \
                       --body "$body" \
                       --repo open-telemetry/opentelemetry-operator \
                       --base main
```
