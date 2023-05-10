# delete-workflows-runs

This action deletes all workflows' runs for a given repository.

## Inputs

| Name | Description | Required |
| --- | --- | --- |
| `owner` | Owner of the repository | true |
| `name` | Name of the repository | true |
| `token` | Token used to get and delete the workflows' runs | true |

## Permissions

The token provided must have the following permissions over the given repository:

- Read access to metadata
- Read and Write access to actions

## Example usage

```yaml
name: delete-workflows-runs
on:
  workflow_dispatch:
    inputs:
      repo_name:
        description: "Specify the name of the repository"
        required: true
        type: string

jobs:
  delete-workflows-runs:
    runs-on: ubuntu-latest
    steps:
      - uses: christosgalano/delete-workflow-runs@v1.0.0
        with:
          owner: ${{ github.repository_owner }}
          repo: ${{ inputs.repo_name }}
          token: ${{ secrets.WORKFLOWS_PAT }}
```
