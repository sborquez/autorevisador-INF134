#!/usr/bin/python2
import sys
import re

regex = "(==[0-9]+== LEAK SUMMARY:\n)(==[0-9]+== +definitely lost: )(?P<definitive>[0-9,]+)( bytes in [0-9,]+ blocks\n)"
regex += "(==[0-9]+== +indirectly lost: )(?P<indirectly>[0-9,]+)( bytes in [0-9,]+ blocks\n)"
regex += "(==[0-9]+== +possibly lost: )(?P<possibly>[0-9,]+)( bytes in [0-9,]+ blocks\n)"

leak_summary = re.compile(regex, flags=re.MULTILINE)

with open(sys.argv[1]) as data:
    summary = data.read()

match = leak_summary.search(summary)

print match.group("definitive")+"-"+match.group("indirectly")+"-"+match.group("possibly")
