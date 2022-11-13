## Common release automation

There are lots of different ways to do release automation. The particular release automation here is designed around
these principles:

* Avoid loosening of branch protection rules, in particular
  * Require a pull request before merging
  * Require approvals
  * Require review from Code Owners
  * Require status checks to pass before merging
* Make releases from release branches

As an added benefit, submitting automated changes via pull request provides nice visibility of these changes to everyone
monitoring the repository.

Submitting these changes via pull requests is not as cumbersome as you may imagine. Since these automated pull requests
are coming from a bot account, the same person who triggers the workflows that generate the pull requests can still
approve and merge them.

## Table of Contents

- [Workflows that generate pull requests](#workflows-that-generate-pull-requests)
- [Prepare release branch](#prepare-release-branch)
- [Prepare patch](#prepare-patch)
- [Backport pull requests to a release branch](#backport-pull-requests-to-a-release-branch)
- [Release](#release)
- [Update the change log with the release date](#update-the-change-log-with-the-release-date)
- [Send a pull request to another repository](#send-a-pull-request-to-another-repository)

See the [RELEASING.md](../RELEASING.md) that goes with the automation below.

### Workflows that generate pull requests

Since you can't push directly to `main` or to release branches from workflows (due to branch protections),
the next best thing is to generate a pull request from the workflow and use a bot which has signed the CLA as commit author.

```yaml
      - name: Use CLA approved github bot
        run: |
          git config user.name opentelemetrybot
          git config user.email 107717825+opentelemetrybot@users.noreply.github.com
```

[Furthermore][]:

> When you use the repository's `GITHUB_TOKEN` to perform tasks, events triggered by the
`GITHUB_TOKEN` will not create a new workflow run. This prevents you from accidentally creating
recursive workflow runs.

And so it is also helpful to create a [Personal Access Token][] for the bot and use
`${{ secrets.BOT_TOKEN }}` instead of `${{ secrets.GITHUB_TOKEN }}` in your workflows.

[Furthermore]: https://docs.github.com/en/actions/security-guides/automatic-token-authentication#using-the-github_token-in-a-workflow
[Personal Access Token]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

### Prepare release branch

Uses release branch naming convention `release/v*`.

The specifics below depend a lot on your specific version updating needs.

For OpenTelemetry Java repositories, the version in `main` always ends with `-SNAPSHOT`,
so preparing the release branch involves

* removing `-SNAPSHOT` from the version on the release branch
  (e.g. updating the version from `1.2.0-SNAPSHOT` to `1.2.0`)
* updating the version to the next `-SNAPSHOT` on `main`
  (e.g. updating the version from `1.2.0-SNAPSHOT` to `1.3.0-SNAPSHOT`)

See [prepare-release-branch.yml](../.github/workflows/prepare-release-branch.yml).

### Prepare patch

The specifics depend a lot on the build tool and your version updating needs.

For OpenTelemetry Java repositories, we have a workflow which generates a pull request
against the release branch to update the version (e.g. from `1.2.0` to `1.2.1`).

See [prepare-patch-release.yml](../.github/workflows/prepare-patch-release.yml).

### Backport pull requests to a release branch

Having a workflow generate backport pull requests is nice because then you know that it was a clean
cherry-pick and that it does not require re-review.

See [backport.yml](../.github/workflows/backport.yml).

### Release

See [release.yml](../.github/workflows/release.yml).

#### Create the GitHub release

Add `--draft` to the `gh release create` command if you want to review the release before hitting
the "Publish release" button yourself.

You will need to remove `--discussion-category announcements` if you add `--draft`
(you can still choose whether to select "Create a discussion for this release" before
hitting the "Publish release" button).

See [release.yml](../.github/workflows/release.yml).

#### Update the change log with the release date

See [release.yml](../.github/workflows/release.yml).

#### Send a pull request to another repository

For example to send a PR to notify/update another repository that a new release is available
as part of the release workflow.

Note that the [Personal Access Token][] used will need `workflow` (Update GitHub Action workflows)
permission since if workflows have been updated upstream it will be updating the workflows of the
origin repository when it pushes the branch.

[Personal Access Token]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

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

      - name: Use CLA approved github bot
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
