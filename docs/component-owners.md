## Configuring component owners for contrib repositories

Using CODEOWNERS to assign reviewers requires all reviewers to have write access to the repository,
which brings along a lot of [additional permissions][].

[additional permissions]: https://docs.github.com/en/organizations/managing-access-to-your-organizations-repositories/repository-roles-for-an-organization#permissions-for-each-role

The [component owners action](https://github.com/dyladan/component-owners#component-owners)
works similarly, but does not require granting write access.

### `.github/workflows/assign-reviewers.yml`

```yaml
# assigns reviewers to pull requests in a similar way as CODEOWNERS, but doesn't require
# reviewers to have write access to the repository
# see .github/component_owners.yaml for the list of components and their owners
name: Assign reviewers

on:
  # pull_request_target is needed instead of just pull_request
  # because repository write permission is needed to assign reviewers
  pull_request_target:

jobs:
  assign-reviewers:
    runs-on: ubuntu-latest
    steps:
      - uses: dyladan/component-owners@main
```

### `.github/component_owners.yaml`

In the [opentelemetry-java-contrib](https://github.com/open-telemetry/opentelemetry-java-contrib)
repository we have created labels for each component, and have given all component owners triager
rights so that they can assign labels and triage issues for their component(s).

```yaml
# this file is used by .github/workflows/assign-reviewers.yml to assign component owners as
# reviewers to pull requests that touch files in their component(s)
#
# component owners must be members of the GitHub OpenTelemetry organization
# so that they can be assigned as reviewers
#
# when updating this file, don't forget to update the component owners sections
# in the associated README.md and update the associated `comp:*` labels if needed
components:
  dir1:
    - owner1  <-- GitHub username
    - owner2
```

### `dir1/README.md`

```markdown

...

## Component owners

- [Person One](https://github.com/owner1), Company1
- [Person Two](https://github.com/owner2), Company2

Learn more about component owners in [component_owners.yml].

[component_owners.yml]: ../.github/component_owners.yml
```
