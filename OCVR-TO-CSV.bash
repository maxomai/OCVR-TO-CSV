#!/bin/bash

# OCVR-TO-CSV.bash
# The purpose of this script is to parse an OCVR (Oregon Centralized Voter
# Registration) system report, in TXT format, to a CSV. The CSV is printed to
# standard output.
#
# Run as follows:
#     OCVR-TO-CSV.bash (name of report) > (name of csv)
#
# Copyright is at the end of the source file
#
# Note: this could probably run faster, but I just wanted to get it working.
#
# Changes 2020-June-12: removed gender detection (no longer necessary), added whitespace removal for names,
# cut off first names after 20 characters, eliminated space between ZIP and +4
# Changes 2021-Feb-8: Need to strip extraneous leading double quote from last names

PRECINCTINDICATOR="Precinct :,"


PRECINCT=""

echo "PRECINCT,VOTER ID,LAST NAME,FIRST NAME,MAILING STREET ADDRESS,MAILING CITY,MAILING STATE,MAILING ZIP,PHYSICAL ADDRESS,PHYSICAL CITY,PHYSICAL STATE,PHYSICAL ZIP,STATUS,PHONE,ASSIGNMENT"


function parse_address() {
	local address="$*"
	local zipcode=""
	local street=""
	local city=""
	local state=$(echo $address | rev | cut -d" " -f 2 | rev )
	if [[ $state =~ ^[0-9]5* ]]; then
		#process as zip+4
		zipcode=$(echo $address | rev | cut -d" " -f 1-2 | rev | tr -d '[:space:]' )
		street=$(echo $address | rev | cut -d" " -f5- | rev)
		city=$(echo $address | rev | cut -d" " -f 4 | rev )
		state=$(echo $address | rev | cut -d" " -f 3 | rev )
	else
		street=$(echo $address | rev | cut -d" " -f4- | rev)
		city=$(echo $address | rev | cut -d" " -f 3 | rev )
		zipcode=$(echo $address | rev | cut -d" " -f 1 | rev )
	fi
	local result="$street,$city,$state,$zipcode"
	echo $result
}

while IFS= read line
do
	if [[ "$line" == *"$PRECINCTINDICATOR"* ]]; then
		PRECINCT=$(echo $line | cut -d',' -f 2 | tr -d '\r');
	elif [[ "$line" =~ ^[0-9]6* ]]; then
		id=$(echo $line | cut -d"," -f 1);
		lastname_with_leading_quote=$(echo $line | cut -d"," -f 2);
		lastname=${lastname_with_leading_quote:1}; #Need to remove extraneous leading quote
		firstname=$(echo $line | cut -d"," -f 3 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -d" " -f 1 | cut -c -20);
		ma_string=$(echo $line | cut -d"," -f 4);
		ma_parsed=$(parse_address $ma_string);
		pa_string=$(echo $line | cut -d"," -f 5);
		pa_parsed=$(parse_address $pa_string);
		the_rest=$(echo $line | cut -d"," -f 6-);
		echo "$PRECINCT,$id,$lastname,$firstname,$ma_parsed,$pa_parsed,$the_rest"
	fi
done < "${1:-/dev/stdin}"

#Copyright 2018-2021, Michael C Smith (mike@mikesmithfororegon.com)
#Former Second Vice-Chair, Democratic Party of Multnomah County (https://multdems.org/)
#Chair, Gun Owners Caucus, Democratic Party of Oregon (https://dpo.org/caucuses/gun-owners-caucus/)
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
