# Linting

## Table of Contents

- [Check for broken markdown links](#check-for-broken-markdown-links)
- [Markdown linting](#markdown-linting)
- [Shell script linting](#shell-script-linting)
- [Check for misspellings](#check-for-misspellings)
- [Running checks against changed files only](#running-checks-against-changed-files-only)

## Check for broken markdown links

<https://github.com/tcort/markdown-link-check> checks markdown files for valid links and anchors.

It is recommended to NOT make this a required check for pull requests to avoid blocking pull
requests if external links break.

See [reusable-markdown-link-check.yml][] and [markdown-link-check-with-retry.sh][].

[reusable-markdown-link-check.yml]: ../.github/workflows/reusable-markdown-link-check.yml
[markdown-link-check-with-retry.sh]: ../.github/scripts/markdown-link-check-with-retry.sh

The file `.github/scripts/markdown-link-check-config.json` is for configuring the markdown link check:

```json
{
  "retryOn429": true
}
```

`retryOn429` helps with GitHub throttling.

If you run into sites sending back `403` to the link checker bot, you can add `403` to the `aliveStatusCodes`, e.g.

```json
{
  "retryOn429": true,
  "aliveStatusCodes": [
    200,
    403
  ]
}
```

## Markdown linting

<https://github.com/igorshubovych/markdownlint-cli> is a style checker and lint tool for markdown
files.

See [reusable-markdown-lint.yml](../.github/workflows/reusable-markdown-lint.yml).

## Shell script linting

<https://github.com/koalaman/shellcheck> gives warnings and suggestions for bash/sh shell scripts.

See [reusable-shell-script-check.yml](../.github/workflows/reusable-shell-script-check.yml).

## Check for misspellings

<https://github.com/client9/misspell> only checks against known misspellings,
so while it's not a comprehensive spell checker, it doesn't produce false positives,
and so doesn't get in your way.

It is recommended to NOT make this a required check for pull requests to avoid blocking pull
requests if new misspellings are added to the misspell dictionary.

See [build.yml](../.github/workflows/build.yml) and [misspell-check.yml](../.github/workflows/misspell-check.yml).

If you need to exclude some files for any reason:

```yaml
      - name: Run misspell
        run: |
          find . -type f \
                 -not -path './somedir/*' \
               | xargs bin/misspell -error

```

## Running checks against changed files only

If for some reason some check is running slow, or generates failures on pull requests unrelated to changed files,
an option is to run it only against changed files on pull requests.

(note, it probably doesn't make sense to do this for link checks, since it's possible for changes in one file
to break a link in an unchanged file)

Here's an example of doing this with the above `misspell-check` workflow:

```yaml
  misspell-check:
    # release branches are excluded to avoid unnecessary maintenance if new misspellings are
    # added to the misspell dictionary
    if: ${{ !startsWith(github.ref_name, 'release/') }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        if: ${{ github.event_name == 'pull_request' }}
        with:
          # target branch is needed to perform a diff and check only the changed files
          ref: ${{ github.base_ref }}

      - uses: actions/checkout@v3

      - name: Install misspell
        run: |
          curl -L -o install-misspell.sh https://git.io/misspell
          sh ./install-misspell.sh

      - name: Run misspell (diff)
        if: ${{ github.event_name == 'pull_request' }}
        run: |
          git diff --name-only --diff-filter=ACMRTUXB origin/$GITHUB_BASE_REF \
            | xargs bin/misspell -error

      - name: Run misspell (full)
        if: ${{ github.event_name != 'pull_request' }}
        run: bin/misspell -error .
```
