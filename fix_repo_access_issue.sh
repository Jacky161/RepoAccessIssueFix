#!/usr/bin/env bash
set -e

# Script to fix "Repository Access Issue". Affected students will be reinvited to their repos and need to accept the invite in their email after running this.

source .env

if [[ -z ${GH_ORG} ]]; then
    echo "Error: GH_ORG env variable is not set."
    exit 1
fi

if [[ -z ${ASSIGNMENT} ]]; then
    echo "Error: ASSIGNMENT env variable is not set."
    exit 1
fi

# Change the repo limit if you have >1000 in your organization
all_repos="$(gh repo list "${GH_ORG}" --limit 1000 --json name | jq -r ".[].name | select(startswith(\"${ASSIGNMENT}\"))")"

# Iterate over all repos corresponding to the assignment
while IFS= read -r repo; do
    full="${GH_ORG}/${repo}"

    # Use GitHub's api to get a list of invitations and extract the invite id, username, and the inviter
    invites="$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/${full}/invitations" | jq '.[] | "\(.id),\(.invitee.login),\(.inviter.login)"')"

    while IFS=',' read -r id user inviter; do
        # If the ID / User doesn't exist then we don't need to do anything
        if [[ -z ${id} ]]; then continue; fi
        if [[ -z ${user} ]]; then continue; fi
        if [[ -z ${inviter} ]]; then continue; fi

        echo "Invite ID          : ${id:1}"
        echo "GitHub Repo        : ${repo}"
        echo "Student GH Username: ${user}"
        echo "Inviter GH Username: ${inviter::-1}"

        # Don't reinvite people who were already processed
        if [ ${inviter::-1} != "github-classroom[bot]" ]; then
            echo "Student has already been reinvited. Skipping."
            echo ""
            continue
        fi

        echo "Revoking invite for ${user} in $repo"
        gh api --method DELETE -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/${full}/invitations/${id:1}"
        echo "Re-inviting ${user}"
        sleep 1
        gh api --method PUT -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/${full}/collaborators/${user}" -f 'permission=write' --silent

        echo ""
    done <<< "$invites"

done <<< "$all_repos"
