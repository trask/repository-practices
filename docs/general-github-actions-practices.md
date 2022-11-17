# General GitHub Actions practices

## Table of Contents

- [Have a single required status check for pull requests](#have-a-single-required-status-check-for-pull-requests)
- [Configure "cancel-in-progress" on pull request workflows](#configure-cancel-in-progress-on-pull-request-workflows)
- [Prefer `gh` cli over third-party GitHub actions for simple tasks](#prefer-gh-cli-over-third-party-github-actions-for-simple-tasks)
- [Use GitHub action cache to make builds faster and less flaky](#use-github-action-cache-to-make-builds-faster-and-less-flaky)
- [Workflow file naming conventions](#workflow-file-naming-conventions)
- [Workflow YAML style guide](#workflow-yaml-style-guide)

## Have a single required status check for pull requests

This avoids needing to modify branch protection required status checks as individual jobs
(and job matrix items) come and go.

```yaml
  required-status-check:
    needs:
      - aaa
      - bbb
      - ccc
    runs-on: ubuntu-latest
    if: always()
    steps:
      - if: >
          needs.aaa.result != 'success' ||
          needs.bbb.result != 'success' ||
          needs.ccc.result != 'success'
        run: exit 1
```

If you have multiple workflows that run on pull requests, there are a couple of options:

* If they have the same `on` triggers, they can be merged into a single workflow.
* Otherwise turn them into
  [reusable workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows),
  and call them from a single workflow.

## Configure "cancel-in-progress" on pull request workflows

If the pull request build takes some time, and the author submits several revisions in a short
period of time, this can end up consuming a lot of GitHub Actions runners.

If your pull request workflow only runs on `pull_request`:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number }}
  cancel-in-progress: true
```

If your pull request workflow is shared and also runs on CI (i.e. on merge to `main` or release branch):

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.sha }}
  cancel-in-progress: true
```

## Prefer `gh` cli over third-party GitHub actions for simple tasks

For example, creating an issue or creating a pull request is just as easy using `gh` cli as using a third-party GitHub action.

This preference is because `gh` cli is generally more secure and has less breaking changes
compared to third-party GitHub actions.

## Use GitHub action cache to make builds faster and less flaky

This is very build tool specific so no specific tips here on how to implement.

## Workflow file naming conventions

Not sure if it's worth sharing these last two sections across all of OpenTelemetry,
but I think it's worth having this level of consistency across the Java repos.

Use `.yml` extension instead of `.yaml`.

* `.github/workflows/build.yml` - primary build workflow (CI)
* `.github/workflows/build-pull-request.yml` - pull request workflow (if `build.yml` isn't used also for pull requests)
* `.github/workflows/build-daily.yml` - if you have a daily build in addition to normal CI builds
* `.github/workflows/reusable-*.yml` - reusable workflows, unfortunately these cannot be located in subdirectories (yet?)
* `.github/workflows/backport.yml`
* `.github/workflows/codeql-daily.yml`

## Workflow YAML style guide

Workflow names - [Sentence case](https://en.wikipedia.org/wiki/Letter_case#Sentence_case)

Job names - [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case)

Step names - [Sentence case](https://en.wikipedia.org/wiki/Letter_case#Sentence_case)
