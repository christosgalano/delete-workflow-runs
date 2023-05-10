# delete-workflow-runs

This action deletes the workflow runs for a given repository. You can delete the runs of a specific workflow or all the runs of the repository.

## Inputs

| Name | Description | Required | Default |
| --- | --- | --- | --- |
| `owner` | Owner of the repository | true | |
| `name` | Name of the repository | true | |
| `token` | Token used to get and delete the workflow' runs | true | `GITHUB_TOKEN` |
| `workflow` | Name of the workflow to delete its runs | false | all |

The `workflow` input is optional. If no value is provided or the value provided is "all", then all the runs of the repository will be deleted.

## Permissions

The token provided must have the following permissions over the given repository:

- Read access to metadata
- Read and Write access to actions

## Examples of usage

### Delete all the runs of a repository

```yaml
- uses: christosgalano/delete-workflow-runs@v1.0.0
  with:
    owner: ${{ inputs.repository_owner }}
    repo: ${{ inputs.repository_name }}
    token: ${{ secrets.workflow_PAT }}
    # workflow: "all" can be omitted since it is the default value
```

### Delete the runs of a specific workflow

```yaml
- uses: christosgalano/delete-workflow-runs@v1.0.0
  with:
    owner: ${{ inputs.repository_owner }}
    repo: ${{ inputs.repository_name }}
    token: ${{ secrets.workflow_PAT }}
    workflow: ${{ inputs.workflow_name }}
```

### Delete the runs of multiple workflows

```yaml
delete-runs:
  runs-on: ubuntu-latest
  strategy:
    matrix:
      workflow:
        - workflow1
        - workflow2
        - workflow3
  steps:
    - uses: christosgalano/delete-workflow-runs@v1.0.0
      with:
        owner: ${{ inputs.repository_owner }}
        repo: ${{ inputs.repository_name }}
        token: ${{ secrets.workflow_PAT }}
        workflow: ${{ matrix.workflow }}
```
