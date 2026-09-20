#!/bin/bash
# Keep a single tracking issue in sync with the scheduled scan of the published
# images: opened or updated while findings exist, closed once they are gone. One
# issue instead of one per run, so that the history stays readable.
#
# Environment:
#   SUMMARY_DIR directory holding the trivy-summary-<image>.md files
#   IMAGES      space separated images that were expected to be scanned
#   RUN_URL     link back to the workflow run
#   GH_TOKEN    token with issues:write, read by the gh CLI
set -euo pipefail

SUMMARY_DIR="${SUMMARY_DIR:-summaries}"
RUN_URL="${RUN_URL:-}"
ISSUE_TITLE="${ISSUE_TITLE:-Vulnerable published images}"
ISSUE_LABEL="${ISSUE_LABEL:-security}"

read -r -a images <<<"${IMAGES:-}"

findings="$(mktemp)"
report="$(mktemp)"
trap 'rm -f "${findings}" "${report}"' EXIT

for image in "${images[@]}"; do
	summary="${SUMMARY_DIR}/trivy-summary-${image}.md"

	# A missing summary means the scan itself failed, which is a finding too:
	# staying silent about it would look exactly like a clean image.
	if [ ! -f "${summary}" ]; then
		printf '### %s\n\nThe scan did not complete.\n\n' "${image}" >>"${findings}"
		continue
	fi

	cat "${summary}" >>"${findings}"
done

# gh refuses to use a label that does not exist yet, as a filter and on an issue.
gh label create "${ISSUE_LABEL}" --color d93f0b \
	--description "Vulnerabilities in the published images" >/dev/null 2>&1 || true

issue=$(gh issue list --state open --label "${ISSUE_LABEL}" --json number,title \
	--jq "[.[] | select(.title == \"${ISSUE_TITLE}\")] | .[0].number // empty")

if [ ! -s "${findings}" ]; then
	echo "No findings with a fix available."

	if [ -n "${issue}" ]; then
		gh issue close "${issue}" \
			--comment "All published images are free of findings with a fix available again. See ${RUN_URL}."
	fi

	exit 0
fi

{
	echo "The scheduled Trivy scan of the published images reported findings."
	echo
	cat "${findings}"
	echo "### How to fix this"
	echo
	echo "1. \`gh workflow run build.yml -f no-cache=true\` rebuilds without the layer cache, which is what"
	echo "   re-resolves the \`apk\` and \`apt\` packages. It refreshes \`main\`, \`nightly\` and \`sha-*\`."
	echo "2. \`:latest\` only moves with a release: \`gh workflow run release.yml\` forces one."
	echo
	echo "Findings without a fix are left out here, the Security tab has the full report."
	echo
	echo "Updated by [this workflow run](${RUN_URL})."
} >"${report}"

cat "${report}"

if [ -n "${issue}" ]; then
	gh issue edit "${issue}" --body-file "${report}"
else
	gh issue create --title "${ISSUE_TITLE}" --body-file "${report}" --label "${ISSUE_LABEL}"
fi
