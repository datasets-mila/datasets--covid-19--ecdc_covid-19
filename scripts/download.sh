#!/bin/bash

# This script is meant to be used with the command 'datalad run'

FILES=(total_cases.csv total_deaths.csv new_cases.csv new_deaths.csv full_data.csv case_distribution.csv)

for file in *-*-*_*.csv ${FILES[*]}
do
	git mv --force $file .tmp_$file
done

for file_url in "https://covid.ourworldindata.org/data/ecdc/total_cases.csv total_cases.csv" \
	        "https://covid.ourworldindata.org/data/ecdc/total_deaths.csv total_deaths.csv" \
		"https://covid.ourworldindata.org/data/ecdc/new_cases.csv new_cases.csv" \
		"https://covid.ourworldindata.org/data/ecdc/new_deaths.csv new_deaths.csv" \
		"https://covid.ourworldindata.org/data/ecdc/full_data.csv full_data.csv" \
		"https://opendata.ecdc.europa.eu/covid19/casedistribution/csv case_distribution.csv"
do
	echo ${file_url} | git-annex addurl -c annex.largefiles=anything --raw --batch --with-files
done

for file in ${FILES[*]}
do
	if [ -e $file ]
	then
		ln -sf $(readlink $file) $(date -u +%Y-%m-%d)_$file
		if [[ $(readlink $file) != $(readlink .tmp_$file) ]]
		then
			git-annex drop --force --fast .tmp_$file
		fi
		git rm --force .tmp_*$file
	fi
done

for file in .tmp_*.csv
do
	mv $file ${file:5}
done

md5sum ${FILES[*]} > md5sums
