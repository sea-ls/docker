# docker

Для скачивания Docker образов с нашего репозитория нужно залогинется в нем:

1) Необходимо создать свой personal access token (classic) с такими scopes
![image](https://github.com/PoTerPimRus/docker/assets/52749469/418da2fa-8ca4-4073-b14a-3f1a9fc7a1ab)
2) Ввести следующие команды по отдельности, вместо \<TOKEN\> вставить ваш токен.
<br/>
```export CR_PAT=<TOKEN>```
```echo $CR_PAT | docker login ghcr.io -u sea-ls --password-stdin```
