#!/bin/bash
for filename in **/**/*.sh; do
	echo "fromdos $filename"
	fromdos "$filename"
done
for filename in **/*.sh; do
	echo "fromdos $filename"
	fromdos "$filename"
done
 