require_bash() {
	if (("${BASH_VERSION%%.*}" < $1)); then
		echo "Minimum bash version $1 required"
		exit -1
	fi
}
