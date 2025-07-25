#!/bin/sh

set -eu

IP_CLIENT=172.18.0.3/24
IP_SERVER=172.18.0.2/24
IP_ROUTER_CLIENT=172.18.0.254/24
IP_ROUTER_SERVER=172.18.0.253/24
SUDO=sudo
IMAGE=docker.io/ubuntu:noble
BRNAME=laboratorio

setup_prerequisites() {
	$SUDO apt install -y podman bridge-utils
}

check() {
	$SUDO podman ps -a | grep "$1"
}

execute() {
	$SUDO podman exec -ti $@
}

check_client() {
	check client
}

execute_client() {
	execute client $@
}

setup_client() {
	setup_pod client
}

check_server() {
	check server
}

execute_server() {
	execute server $@
}

setup_server() {
	setup_pod server
}

check_router() {
	check router
}

execute_router() {
	execute router $@
}

setup_router() {
	setup_pod router
}

setup_pod() {
	if ! "check_$1" ; then
		# Put the container in background waiting for commands
		$SUDO podman run --privileged --network=default  -d -h "$1" --name "$1" "$IMAGE" sleep 99999999
		# Idempotent
		$SUDO podman start "$1"
		execute "$1" /usr/bin/apt update
		execute "$1" /usr/bin/apt upgrade -y
		execute "$1" /usr/bin/apt install -y iproute2 inetutils-ping
	fi

	# Idempotent
	$SUDO podman start "$1"
}

cleanup() {
	for pod in router client server ; do
		$SUDO podman kill $pod || true
		$SUDO podman rm $pod || true
	done

}

get_netns() {
	basename "$($SUDO podman inspect --format '{{.NetworkSettings.SandboxKey}}' "$1")"
}

setup_network() {
	# Create networking interfaces
	$SUDO ip link add veth-cli-rtr type veth peer name veth-rtr-cli
	$SUDO ip link set veth-cli-rtr netns "$(get_netns client)"
	$SUDO ip link set veth-rtr-cli netns "$(get_netns router)"

	$SUDO ip link add veth-srv-rtr type veth peer name veth-rtr-srv
	$SUDO ip link set veth-srv-rtr netns "$(get_netns server)"
	$SUDO ip link set veth-rtr-srv netns "$(get_netns router)"
}

if test "$#" -eq 1; then
	if test "$1" = "cleanup"; then
		cleanup
		exit 0
	fi
fi

if test $# -lt 1; then
	setup_prerequisites
fi

setup_router
setup_client
setup_server

if test $# -lt 1 ; then
	setup_network
fi

if test $# -gt 1; then
	TARGET="$1"
	shift
	"execute_$TARGET" "$@"
fi

