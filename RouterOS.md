### 1. Настройка маршрутизатора HQ-RTR

**Базовые настройки и системный администратор**

Задаем полное доменное имя устройства согласно топологии и создаем администратора с максимальными привилегиями.
```routeros
/system identity set name=hq-rtr.au-team.irpo
/user add name=net_admin password="P@\$\$word" group=full
```

#

**Разделение на VLAN на внутреннем интерфейсе (Пункт 2 и 4)**

Создаем виртуальные интерфейсы (VLAN) на порту `ether2`, который смотрит в локальную сеть офиса HQ.
```routeros
/interface vlan add name=vlan100 vlan-id=100 interface=ether2
/interface vlan add name=vlan200 vlan-id=200 interface=ether2
/interface vlan add name=vlan999 vlan-id=999 interface=ether2
```

#

**Конфигурация IPv4-адресации**

Назначаем статические IP-адреса из приватных диапазонов согласно требованиям вместимости масок хостов.
```routeros
/ip address add address=172.16.4.2/28 interface=ether1 comment="Link to ISP"
/ip address add address=192.168.100.1/25 interface=vlan100 comment="HQ-SRV Network"
/ip address add address=192.168.200.1/27 interface=vlan200 comment="HQ-CLI Network"
/ip address add address=192.168.99.1/28 interface=vlan999 comment="Management"
```

#

**Маршрут по умолчанию**

Добавляем основной статический маршрут для пересылки интернет-трафика на шлюз магистрального провайдера.
```routeros
/ip route add gateway=172.16.4.1 comment="Default route to Internet"
```

#

**Настройка DHCP-сервера для HQ-CLI (Пункт 9)**

Создаем пул адресов (исключая адрес самого роутера) и запускаем службу DHCP на `vlan200` с передачей параметров DNS (`HQ-SRV`), шлюза и суффикса.
```routeros
/ip pool add name=pool-cli ranges=192.168.200.2-192.168.200.30
/ip dhcp-server add name=dhcp-cli interface=vlan200 pool=pool-cli disabled=no
/ip dhcp-server network add address=192.168.200.0/27 gateway=192.168.200.1 dns-server=192.168.100.2 domain=au-team.irpo
```

#

**Динамическая трансляция адресов NAT (Пункт 8)**

Обеспечиваем всем локальным устройствам офиса HQ автоматический доступ к сети Интернет через технологию Masquerade.
```routeros
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment="Internet Access"
```

#

**Статическая трансляция портов Port Forwarding (Пункт 6)**

Пробрасываем входящие внешние соединения для доступа к веб-сервису Moodle (порт 80) и защищенному SSH (порт 2024) на внутренний сервер `HQ-SRV`.
```routeros
/ip firewall nat add chain=dstnat dst-address=172.16.4.2 protocol=tcp dst-port=80 action=dst-nat to-addresses=192.168.100.2 to-ports=80 comment="Moodle"
/ip firewall nat add chain=dstnat dst-address=172.16.4.2 protocol=tcp dst-port=2024 action=dst-nat to-addresses=192.168.100.2 to-ports=2024 comment="Secure SSH HQ"
```

#

**Служба сетевого времени NTP (Пункт 3)**

Включаем встроенный NTP-сервер на роутере для синхронизации остальных узлов инфраструктуры (роутер выступает как Stratum-сервер).
```routeros
/system ntp server set enabled=yes manycast=no
/system clock set time-zone-name=Europe/Moscow
```

---

### 2. Настройка маршрутизатора BR-RTR

**Базовые настройки и системный администратор**

Задаем имя филиала в доменном формате и создаем привилегированного администратора.
```routeros
/system identity set name=br-rtr.au-team.irpo
/user add name=net_admin password="P@\$\$word" group=full
```

#

**Конфигурация IPv4-адресации**

Настраиваем адреса на внешнем интерфейсе `ether1` (к провайдеру) и внутреннем `ether2` в сторону `BR-SRV`.
```routeros
/ip address add address=172.16.5.2/28 interface=ether1 comment="Link to ISP"
/ip address add address=192.168.50.1/26 interface=ether2 comment="BR-SRV Network"
```

#

**Маршрут по умолчанию**

Организуем выход в внешнюю сеть через вышестоящий шлюз провайдера.
```routeros
/ip route add gateway=172.16.5.1 comment="Default route to Internet"
```

#

**Динамический NAT**

Разрешаем маскарадинг для выхода хостов филиала в глобальную сеть.
```routeros
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade
```

#

**Проброс портов на BR-SRV**

Пробрасываем порт HTTP 80 во внутренний порт 8080 для веб-приложения MediaWiki и порт 2024 для безопасного управления по SSH.
```routeros
/ip firewall nat add chain=dstnat dst-address=172.16.5.2 protocol=tcp dst-port=80 action=dst-nat to-addresses=192.168.50.2 to-ports=8080 comment="Wiki"
/ip firewall nat add chain=dstnat dst-address=172.16.5.2 protocol=tcp dst-port=2024 action=dst-nat to-addresses=192.168.50.2 to-ports=2024 comment="Secure SSH BR"
```

#

**NTP-клиент**

Настраиваем синхронизацию времени с головным устройством `HQ-RTR`.
```routeros
/system ntp client set enabled=yes primary-ntp=192.168.100.1
/system clock set time-zone-name=Europe/Moscow
```

---

### 3. Межсетевое взаимодействие (HQ \leftrightarrow BR)

**Настройка GRE-туннеля (Пункт 6)**

Создаем виртуальный защищенный туннель между внешними адресами роутеров и выделяем для стыка подсеть `10.0.0.0/30`.

*Команды на HQ-RTR:*
```routeros
/interface gre add name=gre-to-br remote-address=172.16.5.2 local-address=172.16.4.2 dscp=inherit clamp-tcp-mss=yes
/ip address add address=10.0.0.1/30 interface=gre-to-br
```

*Команды на BR-RTR:*
```routeros
/interface gre add name=gre-to-hq remote-address=172.16.4.2 local-address=172.16.5.2 dscp=inherit clamp-tcp-mss=yes
/ip address add address=10.0.0.2/30 interface=gre-to-hq
```

#

**Динамическая маршрутизация OSPF с авторизацией (Пункт 7)**

Настраиваем протокол OSPF v2 для динамического обмена внутренними маршрутами между офисами. Защита реализуется через проверку хэшей MD5, а OSPF-пакеты изолируются только внутри туннеля.

*Команды на HQ-RTR:*
```routeros
/routing ospf instance add name=ospf-inst version=2 router-id=1.1.1.1
/routing ospf area add name=ospf-area instance=ospf-inst area-id=0.0.0.0
/routing ospf interface-template add instance=ospf-inst interfaces=gre-to-br area=ospf-area auth=md5 auth-key="OSPF@P@ss" type=ptp
/routing ospf interface-template add instance=ospf-inst interfaces=vlan100,vlan200,vlan999 area=ospf-area passive=yes
```

*Команды на BR-RTR:*
```routeros
/routing ospf instance add name=ospf-inst version=2 router-id=2.2.2.2
/routing ospf area add name=ospf-area instance=ospf-inst area-id=0.0.0.0
/routing ospf interface-template add instance=ospf-inst interfaces=gre-to-hq area=ospf-area auth=md5 auth-key="OSPF@P@ss" type=ptp
/routing ospf interface-template add instance=ospf-inst interfaces=ether2 area=ospf-area passive=yes
```
