#!/bin/bash
input=$1

part1() {
	cat $input | tr '\r\n' '+' | sed 's/++/\r\n/g' | sed -e 's/^+$//' | bc | sort -nr | head -n 1 | awk '{sum+=$1}END{print sum}'
}

part2() {
	cat $input | tr '\r\n' '+' | sed 's/++/\r\n/g' | sed -e 's/^+$//' | bc | sort -nr | head -n 3 | awk '{sum+=$1}END{print sum}'
}

echo part1: $(part1)
echo part2: $(part2)
