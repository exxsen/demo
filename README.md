Для скрытия истории 
```bash
export HISTCONTROL=ignorespace
```
И все команды на скачивание и на запуск надо начить с ПРОБЕЛА 
Чтобы удалить команду export HISTCONTROL надо ввести 
```bash
 history -d 1
```
где 1 это номер в history 

#

Для запуска скриптов 
```bash
source ./название.sh
```
или

```bash
. ./название.sh
```

Для скачивания 

```bash
wget https://raw.githubusercontent.com/exxsen/demo/main/название
```
