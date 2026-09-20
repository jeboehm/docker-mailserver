#!/bin/bash
# Render the findings of a Trivy JSON report as Markdown and count them.
#
# Only findings that have a fix available are listed: the others cannot be acted
# on here and would drown the report. They still reach the Security tab through
# the SARIF upload, which is where triage and dismissal belong.
#
# Writes the number of findings to GITHUB_OUTPUT as `fixable` and the report to
# GITHUB_STEP_SUMMARY when running in GitHub Actions, and always prints it.
#
# Environment:
#   REPORT     Trivy JSON report to read (default: trivy-results.json)
#   CATEGORY   image name, used as the heading of the section
#   SUMMARY    file the Markdown is written to
#   SEVERITIES comma separated severities that count as a finding
set -euo pipefail

REPORT="${REPORT:-trivy-results.json}"
CATEGORY="${CATEGORY:-image}"
SUMMARY="${SUMMARY:-trivy-summary.md}"
SEVERITIES="${SEVERITIES:-CRITICAL,HIGH}"

severities=$(printf '%s' "${SEVERITIES}" | jq -R 'split(",")')

# shellcheck disable=SC2016 # $sev and $name are jq variables, not shell ones.
filter='
	def findings:
		[.Results[]? | (.Vulnerabilities // [])[]
			| select((.FixedVersion // "") != "")
			| select(.Severity as $s | $sev | index($s))];
	def leaks:
		[.Results[]? | .Target as $target | (.Secrets // [])[] | . + {Target: $target}];
'

# shellcheck disable=SC2016 # The jq program interpolates with \(), not with the shell.
jq -r --arg name "${CATEGORY}" --argjson sev "${severities}" "${filter}"'
	(findings | map("| \(.Severity) | \(.PkgName) | \(.InstalledVersion) | \(.FixedVersion) | [\(.VulnerabilityID)](\(.PrimaryURL // "")) |") | unique) as $rows
	| (leaks | map("| \(.Severity) | \(.RuleID) | \(.Title) | \(.Target) |") | unique) as $secrets
	| if ($rows | length) + ($secrets | length) == 0 then empty
		else
			["### \($name)", ""]
			+ (if ($rows | length) > 0 then
				["| Severity | Package | Installed | Fixed | ID |", "| --- | --- | --- | --- | --- |"] + $rows + [""]
			else [] end)
			+ (if ($secrets | length) > 0 then
				["#### Secrets", "", "| Severity | Rule | Title | File |", "| --- | --- | --- | --- |"] + $secrets + [""]
			else [] end)
		end
	| .[]
' "${REPORT}" >"${SUMMARY}"

fixable=$(jq --argjson sev "${severities}" "${filter}"'(findings | length) + (leaks | length)' "${REPORT}")

if [ -s "${SUMMARY}" ]; then
	cat "${SUMMARY}"

	if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
		cat "${SUMMARY}" >>"${GITHUB_STEP_SUMMARY}"
	fi
else
	echo "No findings with a fix available in ${CATEGORY}."
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
	echo "fixable=${fixable}" >>"${GITHUB_OUTPUT}"
fi
