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

MALEPCPINDICATOR="Precinct Committee Person - Male"
FEMALEPCPINDICATOR="Precinct Committee Person - Female"
#Note: OCVR reports did not include nonbinary gender PCPs at the time this was written.
PRECINCTINDICATOR="Precinct :,"

MALESTRING="Male"
FEMALESTRING="Female"

PRECINCT=""
GENDERSTRING=""

echo "PRECINCT,GENDER,VOTER ID,LAST NAME,FIRST NAME,MAILING STREET ADDRESS,MAILING CITY,MAILING STATE,MAILING ZIP,PHYSICAL ADDRESS,PHYSICAL CITY,PHYSICAL STATE,PHYSICAL ZIP,STATUS-GENDER,PHONE,ASSIGNMENT"

function parse_address() {
	local address="$*"
	local zipcode=""
	local street=""
	local city=""
	local state=$(echo $address | rev | cut -d" " -f 2 | rev )
	if [[ $state =~ ^[0-9]5* ]]; then
		#process as zip+4 
		zipcode=$(echo $address | rev | cut -d" " -f 1-2 | rev)
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
	if [[ "$line" == *"$MALEPCPINDICATOR"* ]]; then
		GENDERSTRING=$MALESTRING
	elif [[ "$line" == *"$FEMALEPCPINDICATOR"* ]]; then
		GENDERSTRING=$FEMALESTRING
	elif [[ "$line" == *"$PRECINCTINDICATOR"* ]]; then
		PRECINCT=$(echo $line | cut -d',' -f 2 | tr -d '\r');
	elif [[ "$line" =~ ^[0-9]6* ]]; then
		id_and_name=$(echo $line | cut -d"," -f 1-3);
		ma_string=$(echo $line | cut -d"," -f 4);
		ma_parsed=$(parse_address $ma_string);
		pa_string=$(echo $line | cut -d"," -f 5);
		pa_parsed=$(parse_address $pa_string);
		the_rest=$(echo $line | cut -d"," -f 6-);
		echo "$PRECINCT,$GENDERSTRING,$id_and_name,$ma_parsed,$pa_parsed,$the_rest"
	fi
done < "${1:-/dev/stdin}"

#Copyright 2018 Michael C Smith (maxomai@gmail.com), Technology Officer, Democratic Party of Multnomah County
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
