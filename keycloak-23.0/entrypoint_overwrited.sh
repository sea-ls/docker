#!/bin/sh

for i in $(ls -1 /run/secrets)
do
	export ${i}=$(cat /run/secrets/${i})
done

"$@"