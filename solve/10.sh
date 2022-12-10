#!/usr/bin/env bash

part1() {
	cat $1 |
		sed -e 's/noop/0/' -Ee 's/addx (.*)/0\n\1/' |
		sed -Ee 's/^([[:digit:]]+)/p\n\1+/' -Ee 's/^-([[:digit:]]+)/p\n\1-/' |
		dc -e1 -f - |
		nl -w2 -s' ' |
		grep -E "^(20|60|100|140|180|220) " |
		sed -E -e 's/([[:digit:]]+) (-*[[:digit:]]+)/\1*\2/' |
		paste -sd+ |
		bc
}

part2() {
	echo
	cat $1 |
		sed -e 's/noop/0/' -Ee 's/addx (.*)/0\n\1/' |
		sed -Ee 's/^([[:digit:]]+)/p\n\1+/' -Ee 's/^-([[:digit:]]+)/p\n\1-/' |
		dc -e1 -f - |
		nl -v0 -w2 -s' ' |
		sed -E -e 's/([[:digit:]]+) (-*[[:digit:]]+)/((\1%40-(\2))^2 <= 1)/' |
		bc |
		tr '0' '.' | tr '1' '#' |
		paste -sd'\0' |
		fold -w40

}
echo part 1: "$(part1 $1)"
echo part 2: "$(part2 $1)"
