# Common build checks

## Table of Contents

- [Automated check for markdown links](#automated-check-for-markdown-links)
- [Automated check for misspellings](#automated-check-for-misspellings)
- [Markdown lint](#markdown-lint)
- [Running checks against changed files only](#running-checks-against-changed-files-only)

### Automated check for markdown links

https://github.com/tcort/markdown-link-check checks markdown files for valid links and anchors.

It is recommended to not make this a required check for pull requests to avoid blocking pull
requests if external links break.

See [build.yml][], [reusable-markdown-link-check.yml][] and [markdown-link-check-with-retry.sh][].

[build.yml]: ../.github/workflows/build.yml
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

### Automated check for misspellings

https://github.com/client9/misspell only checks against known misspellings,
so while it's not a comprehensive spell checker, it doesn't produce false positives,
and so doesn't get in your way.

It is recommended to not make this a required check for pull requests to avoid blocking pull
requests if new misspellings are added to the misspell dictionary.

See [build.yml][] and [misspell-check.yml][].

[build.yml]: ../.github/workflows/build.yml
[reusable-misspell-check.yml]: ../.github/workflows/reusable-misspell-check.yml

If you need to exclude some files for any reason:

```yaml
      - name: Run misspell
        run: |
          find . -type f \
                 -not -path './somedir/*' \
               | xargs bin/misspell -error

```

### Markdown lint

Specification repo uses https://github.com/DavidAnson/markdownlint.

Go, JavaScript repos use https://github.com/avto-dev/markdown-lint github action.

C++ uses markdownlint-cli (which is same that is used by avto-dev/markdown-lint github action).

TODO

### Running checks against changed files only

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
          curl -L -o ./install-misspell.sh https://git.io/misspell
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
