#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-08-13 19:38:39 +0100 (Thu, 13 Aug 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC1090
. "$srcdir/lib/gcp.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Lists GCP Projects and checks project is configured

Can optionally specify a project id to switch to (will switch back to original project on any exit except kill -9)

$gcp_info_formatting_help
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<project_id>]"

help_usage "$@"

if [ $# -gt 0 ]; then
    project_id="$1"
    shift || :
    current_project="$(gcloud config list --format="value(core.project)")"
    if [ -n "$current_project" ]; then
        # want interpolation now not at exit
        # shellcheck disable=SC2064
        trap "gcloud config set project '$current_project'" EXIT
    else
        trap "gcloud config unset project" EXIT
    fi
    gcloud config set project "$project_id"
    echo
    echo
fi


# Project
cat <<EOF
# ============================================================================ #
#                                P r o j e c t s
# ============================================================================ #

EOF

gcp_info "GCP Projects" gcloud projects list
echo
echo "Checking project is configured..."
# unreliable only errors when not initially set, but gives (unset) if you were to 'gcloud config unset project'
#if ! gcloud config get-value project &>/dev/null; then
# ok, but ugly and format dependent
#if ! gcloud config list | grep '^project[[:space:]]='; then
# best
if ! gcloud info --format="get(config.project)" | grep -q .; then
    cat <<EOF

ERROR: You need to configure your Google Cloud project first

Select one from the project IDs above:

gcloud config set project <id>
EOF
    exit 1
fi
