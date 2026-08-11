#!/bin/bash
# Make the third-party test images available, preferring the local archive cache
# over a registry pull.
#
# Environment:
#   MODE       docker | kind | none   where the images should end up
#   SKIP       space separated images from the list that are not needed
#   IMAGE_LIST path to the image list (default: .github/images.txt)
#   CACHE_DIR  path to the archive cache (default: /tmp/docker-images)
set -euo pipefail

LIST="${IMAGE_LIST:-.github/images.txt}"
CACHE_DIR="${CACHE_DIR:-/tmp/docker-images}"
MODE="${MODE:-docker}"
SKIP="${SKIP:-}"

mkdir -p "${CACHE_DIR}"

archive() {
	echo "${CACHE_DIR}/$(echo "$1" | tr '/:' '-').tar"
}

wanted=()
while read -r image; do
	case "${image}" in '' | \#*) continue ;; esac

	case " ${SKIP} " in
	*" ${image} "*)
		echo "Skipping ${image}, not needed for this test case"
		continue
		;;
	esac

	wanted+=("${image}")
done <"${LIST}"

missing=()
for image in "${wanted[@]}"; do
	if [ ! -f "$(archive "${image}")" ]; then
		missing+=("${image}")
	fi
done

if [ "${#missing[@]}" -gt 0 ]; then
	echo "::group::Pulling ${#missing[@]} image(s) not present in the cache"
	printf '%s\n' "${missing[@]}" | xargs -P 4 -n 1 docker pull
	for image in "${missing[@]}"; do
		docker save "${image}" -o "$(archive "${image}")"
	done
	echo "::endgroup::"
fi

for image in "${wanted[@]}"; do
	case "${MODE}" in
	kind)
		echo "::group::Loading ${image} into the kind cluster"
		kind load image-archive "$(archive "${image}")"
		echo "::endgroup::"
		;;
	docker)
		if ! docker image inspect "${image}" >/dev/null 2>&1; then
			echo "::group::Loading ${image} into docker"
			docker load --input "$(archive "${image}")"
			echo "::endgroup::"
		fi
		;;
	none) ;;
	*)
		echo "Unknown MODE: ${MODE}" >&2
		exit 1
		;;
	esac
done
