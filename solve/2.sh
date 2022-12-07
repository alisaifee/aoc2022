#!/usr/bin/env bash
input=$1

part1() {
	cat $input | sed -E -e 's/A Y/6+Y/' -e 's/B Z/6+Z/' -e 's/C X/6+X/' -e 's/A Z/Z/' -e 's/B X/X/' -e 's/C Y/Y/' -e 's/A X/3+X/' -e 's/B Y/3+Y/' -e 's/C Z/3+Z/' | sed -e 's/X/1/' -e 's/Y/2/' -e 's/Z/3/' | bc | paste -sd+ | bc
}

part2() {
	cat $input | sed -E -e 's/(.*) Y/\1+3/' -e 's/(.*) Z/\1+6/' -e 's/(.*) X/\1+0/' | sed -e 's/A+6/Y+6/' -e 's/B+6/Z+6/' -e 's/C+6/X+6/' -e 's/A+0/Z+0/' -e 's/B+0/X+0/' -e 's/C+0/Y+0/' | sed -e 's/A/X/' -e 's/B/Y/' -e 's/C/Z/' | sed -e 's/X/1/' -e 's/Y/2/' -e 's/Z/3/' | bc | paste -sd+ | bc
}

echo part1: $(part1)
echo part2: $(part2)
