# Linting

## Table of Contents

- [Check for broken markdown links](#check-for-broken-markdown-links)
- [Check for markdown style issues](#check-for-markdown-style-issues)
- [Check for shell script issues](#check-for-shell-script-issues)
- [Check for misspellings](#check-for-misspellings)
- [Running checks against changed files only](#running-checks-against-changed-files-only)

## Check for broken markdown links

<https://github.com/tcort/markdown-link-check> checks markdown files for valid links and anchors.

It is recommended to NOT make this a required check for pull requests to avoid blocking pull
requests if external links break.

There is a reusable workflow at
<https://github.com/trask/.workflows/blob/main/.github/workflows/markdown-link-check.yml>
which can be used, e.g.

```
  markdown-link-check:
    # release branches are excluded to avoid unnecessary maintenance
    if: "!startsWith(github.ref_name, 'release/')"
    uses: trask/.workflows/.github/workflows/markdown-link-check.yml@main
    with:
      config-file: .github/config/markdown-link-check-config.json
```

The file `.github/scripts/markdown-link-check-config.json` is for configuring the markdown link
check:

```json
{
  "retryOn429": true
}
```

`retryOn429` helps with GitHub throttling.

If you run into sites sending back `403` to the link checker bot, you can add `403` to the
`aliveStatusCodes`, e.g.

```json
{
  "retryOn429": true,
  "aliveStatusCodes": [
    200,
    403
  ]
}
```

## Check for markdown style issues

<https://github.com/igorshubovych/markdownlint-cli> is a style checker and lint tool for markdown
files.

There is a reusable workflow at
<https://github.com/trask/.workflows/blob/main/.github/workflows/markdown-style-check.yml>
which can be used, e.g.

```
  markdown-style-check:
    # release branches are excluded to avoid unnecessary maintenance
    if: "!startsWith(github.ref_name, 'release/')"
    uses: trask/.workflows/.github/workflows/markdown-style-check.yml@main
    with:
      config-file: .github/config/markdown-style-check-config.yml
```

The file `.github/scripts/markdown-style-check-config.yml` is for configuring the markdown style
check.

## Check for shell script issues

<https://github.com/koalaman/shellcheck> gives warnings and suggestions for bash/sh shell scripts.

There is a reusable workflow at
<https://github.com/trask/.workflows/blob/main/.github/workflows/markdown-style-check.yml>
which can be used, e.g.

```
  shell-script-check:
    # release branches are excluded to avoid unnecessary maintenance
    if: "!startsWith(github.ref_name, 'release/')"
    uses: trask/.workflows/.github/workflows/shell-script-check.yml@main
```

## Check for misspellings

<https://github.com/client9/misspell> only checks against known misspellings,
so while it's not a comprehensive spell checker, it doesn't produce false positives,
and so doesn't get in your way.

It is recommended to NOT make this a required check for pull requests to avoid blocking pull
requests if new misspellings are added to the misspell dictionary.

There is a reusable workflow at
<https://github.com/trask/.workflows/blob/main/.github/workflows/misspell-check.yml>
which can be used, e.g.

```
  misspell-check:
    # release branches are excluded to avoid unnecessary maintenance
    if: "!startsWith(github.ref_name, 'release/')"
    uses: trask/.workflows/.github/workflows/misspell-check.yml@main
```

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
