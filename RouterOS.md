HQ-RTR
Базовые настройки, VLAN и IP-адресация

#

# 1. Имя устройства (Полное доменное имя)
/system identity set name=hq-rtr.au-team.irpo

# 2. Создание локального администратора
/user add name=net_admin password="P@\$\$word" group=full

# 3. Настройка VLAN на внутреннем интерфейсе (ether2)
/interface vlan add name=vlan100 vlan-id=100 interface=ether2
/interface vlan add name=vlan200 vlan-id=200 interface=ether2
/interface vlan add name=vlan999 vlan-id=999 interface=ether2

# 4. Назначение IP-адресов
/ip address add address=172.16.4.2/28 interface=ether1 comment="Link to ISP"
/ip address add address=192.168.100.1/25 interface=vlan100 comment="HQ-SRV"
/ip address add address=192.168.200.1/27 interface=vlan200 comment="HQ-CLI"
/ip address add address=192.168.99.1/28 interface=vlan999 comment="Management"

# 5. Маршрут по умолчанию в сторону ISP
/ip route add gateway=172.16.4.1 comment="Default route to Internet"

#

Настройка DHCP-сервера для HQ-CLI (VLAN 200)

# Пуле адресов (исключаем адрес роутера 192.168.200.1)
/ip pool add name=pool-cli ranges=192.168.200.2-192.168.200.30

# Создание DHCP-сервера
/ip dhcp-server add name=dhcp-cli interface=vlan200 pool=pool-cli disabled=no

# Параметры сети DHCP (Шлюз, DNS, доменный суффикс)
/ip dhcp-server network add address=192.168.200.0/27 gateway=192.168.200.1 dns-server=192.168.100.2 domain=au-team.irpo

NAT (Маскарадинг для выхода в интернет)

/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment="Internet Access"

Проброс портов (DST-NAT)

# Проброс HTTP (80 -> 80) на HQ-SRV (192.168.100.2)
/ip firewall nat add chain=dstnat dst-address=172.16.4.2 protocol=tcp dst-port=80 action=dst-nat to-addresses=192.168.100.2 to-ports=80 comment="Moodle"

# Проброс SSH (2024 -> 2024) на HQ-SRV
/ip firewall nat add chain=dstnat dst-address=172.16.4.2 protocol=tcp dst-port=2024 action=dst-nat to-addresses=192.168.100.2 to-ports=2024 comment="Secure SSH"

#

Настройка NTP-сервера (Chrony аналог)

/system ntp server set enabled=yes manycast=no
# Настройка часового пояса (укажите ваш согласно региону, например Europe/Moscow)
/system clock set time-zone-name=Europe/Moscow

#

Настройка маршрутизатора BR-RTR
Базовые настройки и IP-адресация

# 1. Имя устройства
/system identity set name=br-rtr.au-team.irpo

# 2. Создание локального администратора
/user add name=net_admin password="P@\textdollar\textdollar word" group=full

# 3. Назначение IP-адресов
/ip address add address=172.16.5.2/28 interface=ether1 comment="Link to ISP"
/ip address add address=192.168.50.1/26 interface=ether2 comment="BR-SRV Network"

# 4. Маршрут по умолчанию
/ip route add gateway=172.16.5.1 comment="Default route to Internet"

#

NAT и проброс портов

# Маскарадинг
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade

# Проброс HTTP (80 -> 8080) на BR-SRV (допустим, его IP 192.168.50.2)
/ip firewall nat add chain=dstnat dst-address=172.16.5.2 protocol=tcp dst-port=80 action=dst-nat to-addresses=192.168.50.2 to-ports=8080 comment="Wiki"

# Проброс SSH (2024 -> 2024) на BR-SRV
/ip firewall nat add chain=dstnat dst-address=172.16.5.2 protocol=tcp dst-port=2024 action=dst-nat to-addresses=192.168.50.2 to-ports=2024 comment="Secure SSH"

#

/system ntp client set enabled=yes primary-ntp=192.168.100.1
/system clock set time-zone-name=Europe/Moscow

#

Объединение офисов (GRE-туннель и OSPF)
На HQ-RTR:

/interface gre add name=gre-to-br remote-address=172.16.5.2 local-address=172.16.4.2 dscp=inherit clamp-tcp-mss=yes
/ip address add address=10.0.0.1/30 interface=gre-to-br

На BR-RTR:

/interface gre add name=gre-to-hq remote-address=172.16.4.2 local-address=172.16.5.2 dscp=inherit clamp-tcp-mss=yes
/ip address add address=10.0.0.2/30 interface=gre-to-hq

#

Динамическая маршрутизация OSPF с авторизацией
На HQ-RTR

# Создание области OSPF
/routing ospf instance add name=ospf-inst version=2 router-id=1.1.1.1
/routing ospf area add name=ospf-area instance=ospf-inst area-id=0.0.0.0

# Настройка интерфейсного шаблона только на туннель с MD5-авторизацией
/routing ospf interface-template add instance=ospf-inst interfaces=gre-to-br area=ospf-area auth=md5 auth-key="OSPF@P@ss" type=ptp

# Объявление локальных сетей через перераспределение (redistribute) или добавлением в шаблоны как passive
/routing ospf interface-template add instance=ospf-inst interfaces=vlan100,vlan200,vlan999 area=ospf-area passive=yes

На BR-RTR

# Создание области OSPF
/routing ospf instance add name=ospf-inst version=2 router-id=2.2.2.2
/routing ospf area add name=ospf-area instance=ospf-inst area-id=0.0.0.0

# Настройка туннельного стыка
/routing ospf interface-template add instance=ospf-inst interfaces=gre-to-hq area=ospf-area auth=md5 auth-key="OSPF@P@ss" type=ptp

# Объявление сети офиса BR
/routing ospf interface-template add instance=ospf-inst interfaces=ether2 area=ospf-area passive=yes





