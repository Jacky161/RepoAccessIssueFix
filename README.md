# RepoAccessIssueFix
Fix script for "Repository Access Issue" in GitHub Classroom. This script will need to be run periodically as students run into the issue. This saves time over manually reinviting all affected students.

## Dependencies
These can be installed from your Linux distribution's package manager.
- [GitHub CLI](https://cli.github.com/)
- [jq](https://jqlang.org/)

## Usage
Make sure you are logged into GitHub CLI. You can login by running `gh auth login`.

1. Edit the `.env` file with the GitHub organization of your course and the affected assignment prefix. All GitHub Classroom student repos should follow a naming scheme `{ASSIGNMENT}-{StudentGitHubUsername}`. Fill in the `ASSIGNMENT` variable with the proper prefix.
2. Run the `fix_repo_access_issue.sh` script. The script will detect which students need to be reinvited and send them invites accordingly.
3. Notify students to check their email for a new invite to their assignment repo.
