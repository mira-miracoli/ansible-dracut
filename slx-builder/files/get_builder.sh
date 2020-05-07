#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# Copyright Torben Sickert (info["~at~"]torben.website) 29.10.2015
#           Janosch Dobler (info["~at~"]jandob.com) 29.10.2015
#           Jonathan Bauer (jonathan.bauer@rz.uni-freiburg.de) 19.09.2019
#           Thiago Abdo    (tjabdo@inf.ufpr.br) 06-11-2019

# License
# -------
# This library written by Torben Sickert and Janosch Dobler stand under a
# creative commons naming 3.0 unported license.
# see http://creativecommons.org/licenses/by/3.0/deed.de
## endregion

# Get opt
# Download from the right place
# End.


verbose="no"
debug="no"
version="build_versions"

print_help_message() {
	echo "Downloader for systemd-init"
	echo "Can set the env file with --version(default is build_versions)"
	echo "$0: [--dev] [--verbose] [--version <version_file>] [--debug]"
	exit "${1:-0}"
}

parse_command_line() {
	while true; do
		case "$1" in
			--help)
				shift
				print_help_message 0
				;;
			--verbose)
				shift
				verbose='yes'
				;;
			--debug)
				shift
				verbose='yes'
				debug='yes'
				set -x
				;;
			--version)
				shift
				version="$1"
				shift
				;;
			'')
				break
				;;
			*)
				echo "Error with given option \"$1\": This argument is not available."
				print_help_message 1
		esac
	done
	return 0
}
vecho() {
	if [ $verbose == "yes" ]; then
		echo $@
	fi
}

git_parser() {
	branch=$1
	commit=$2
	path=$3
	url=$4
	vecho "> git b-$branch c-$commit p-$path u-$url"
	vecho "> args: $@"

	gitargs=()
	if [[ -n "$branch" ]]; then
		gitargs+=("--single-branch --branch $branch")
	fi
	rm -rf $path
	if [[ -z $commit ]]; then
		version=$branch
	else
		version=$commit
	fi
	revision=$version
	git clone --depth 1 --branch ${branch} git:${url} ${path}
	pushd $path
	i=50
	while ! git rev-parse --quiet --verify $version^{commit}; do
		git fetch --depth=$((i+=50));
	done
	git reset --hard $version
	popd
}

github_parser() {
	branch=$1
	commit=$2
	path=$3
	url=$4
	vecho "> github b-$branch c-$commit p-$path u-$url"
	vecho "> args: $@"
	git_parser "$branch" "$commit" "$path" "$url"
}

gitslx_parser() {
	branch=$1
	commit=$2
	path=$3
	url=$4
	vecho "> gitslx b-$branch c-$commit p-$path u-$url"
	vecho "> args: $@"
	git_parser "$branch" "$commit" "$path" "$url"
}

dracut_parser() {
	branch=$1
	commit=$2
	path=$3
	url=$4

	dracut_version=${branch}
	dracut_resource_url="$url-$dracut_version.tar.gz"
	if [[ ! -f "${path}/install/dracut-install" ]]; then
		mkdir --parents "${path}"
		echo "Download and extract dracut version $dracut_version"
		curl --location "$dracut_resource_url" | tar --extract --gzip \
		     --directory "${path}" --strip-components 1
	fi
}

parse_command_line $@

. $version

vecho "Verbose: $verbose"
vecho "version_file: $version"
vecho "modules: ${modules[@]}"

for i in "${modules[@]}"; do
	echo $i
	eval \$\{${i}_handler\}_parser \"\$${i}_branch\" \"\$${i}_commit\" \"\$${i}_path\" \"\$${i}_url\"
done

pushd ${systemd_init_path}
git submodule foreach '
	for p in $(find ${toplevel}/builder/patches/${path##*/} -type f -name "*.patch" | sort -n); do
		patch -p1 < $p || echo "Failed to patch $path with $p - expect errors."
	done 2>/dev/null
'
popd

