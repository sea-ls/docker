#!/bin/sh

touch  ~/.profile
for i in $(ls -1 /run/secrets)
do
  echo ${i}
  echo cat /run/secrets/${i}
  echo "export ${i}=$(cat /run/secrets/${i})" >> ~/.profile
	export ${i}=$(cat /run/secrets/${i})
done

source ~/.profile
exec "$@"