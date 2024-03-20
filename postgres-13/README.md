# Образ Postgres-13

https://postgrespro.ru/docs/postgrespro/9.5/continuous-archiving

1. В pg_hba.conf было прописано разрешение на репликацию по паролю
<pre>
#TYPE   DATABASE        USER   ADDRESS           METHOD
host    replication     all    192.168.0.0/16    md5
</pre>

## Обновление серверов
Для оперативного обновления работающих образов, у которых уже есть volume, нужно вручную поместить файлы конфигурации.
На каждом сервере, где есть БД, сначала скопировать файлы конфигурации **pg_hba.conf** и **postgresql.conf** папку **/home/user/postgres**, а затем выполнить команды:
<pre>
# for pg in $(docker ps | grep postgres12 | awk '{ print $1 }') ; do docker cp /home/user/postgres/pg_hba.conf $pg:/var/lib/postgresql/data/pgdata/pg_hba.conf ; done
# for pg in $(docker ps | grep postgres12 | awk '{ print $1 }') ; do docker cp /home/user/postgres/postgresql.conf $pg:/var/lib/postgresql/data/pgdata/postgresql.conf ; done
</pre>
Затем перезапустить сервисы бд.
<pre>
# for pg in $(docker service ls | grep postgres12 | awk '{ print $2 }') ; do docker service update $pg --force -d ; done
</pre>
