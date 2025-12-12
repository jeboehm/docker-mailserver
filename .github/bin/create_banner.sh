#!/bin/sh
# Create a banner for the entrypoint scripts in the container images.
set -e

if [ "$#" -lt 2 ]; then
	echo "Usage: $0 <revision> <version>"
	exit 1
fi

REVISION="$1"
VERSION="$2"
TARGETS="filter mda mta unbound web"

for TARGET in $TARGETS; do
	echo "Creating banner for $TARGET container.."

	if ! [ -d "target/$TARGET/rootfs" ]; then
		echo "Target $TARGET/rootfs not found"
		exit 1
	fi

	cat <<EOF >"target/$TARGET/rootfs/.banner.sh"
#!/bin/sh
# Display welcome banner on container startup
set -e

# Get component name from TARGET environment variable or script location
COMPONENT="\${TARGET:-${TARGET}}"

# Display banner
echo ""
echo "~~ Welcome to docker-mailserver ~~"
echo ""
echo "component: \${COMPONENT} ~~ revision: ${REVISION} ~~ version: ${VERSION}"
echo "docs: https://jeboehm.github.io/docker-mailserver/"
echo "support: https://github.com/jeboehm/docker-mailserver/issues"
echo ""
EOF

	chmod +x "target/$TARGET/rootfs/.banner.sh"
done
