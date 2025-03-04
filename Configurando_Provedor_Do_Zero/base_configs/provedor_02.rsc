# Habilitar IPv6 e Reiniciar
/system package enable ipv6
/system reboot
yes

# Configurações Gerais
/system identity set name=provedor_02
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes

# Configuração de Interface e IP
/interface ethernet set [ find default-name=ether1] name=ether1-NET
/ip address add interface=ether1 address=172.16.0.12/24
/ip route add gateway=172.16.0.2
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1

/interface ethernet set [ find default-name=ether2] name=ether2-CLIENTE_65524
/interface vlan add interface=ether2-CLIENTE_65524 name=VLAN524-CLIENTE_65524 vlan-id=524
/ip address add address=192.168.2.25/30 interface=VLAN524-CLIENTE_65524
/ipv6 address add address=2001:0db9:2::1/126 interface=VLAN524-CLIENTE_65524

# Configurar os filtros de entrada e saída
/routing filter add chain=RF-OUT-CLIENTE_65524 action=accept prefix=0.0.0.0/0
/routing filter add chain=RF-OUT-CLIENTE_65524 action=discard

/routing filter add chain=RF-IN-CLIENTE_65524 action=accept prefix=220.200.200.0/29
/routing filter add chain=RF-IN-CLIENTE_65524 action=discard

/routing filter add chain=RF-OUT-CLIENTE_65524_IPV6 action=accept prefix=::/0
/routing filter add chain=RF-OUT-CLIENTE_65524_IPV6 action=discard

/routing filter add chain=RF-IN-CLIENTE_65524_IPV6 action=accept prefix=2001:0db9:b700::/48
/routing filter add chain=RF-IN-CLIENTE_65524_IPV6 action=discard

# Configuração do BGP
/routing bgp instance add name=INSTANCIA-CLIENTE_65524 as=65524 router-id=192.168.2.25
/routing bgp peer add name=iBGP-CLIENTE_65524 \
	address-families=ip default-originate=always \
	in-filter=RF-IN-CLIENTE_65524 out-filter=RF-OUT-CLIENTE_65524 \
	remote-address=192.168.2.26 remote-as=65524 \
    instance=INSTANCIA-CLIENTE_65524 update-source=VLAN524-CLIENTE_65524

/routing bgp peer add name=iBGP-CLIENTE_65524_IPV6 \
	address-families=ipv6 default-originate=always \
	in-filter=RF-IN-CLIENTE_65524_IPV6 out-filter=RF-OUT-CLIENTE_65524_IPV6 \
	remote-address=2001:0db9:2::2 remote-as=65524 \
	instance=INSTANCIA-CLIENTE_65524 update-source=VLAN524-CLIENTE_65524

# Configuração de IPv6 para simular ping ao Google
/interface bridge add name=lo0
/interface bridge add name=lo1

/ip address add address=8.8.8.8 interface=lo0
/ip address add address=8.8.4.4 interface=lo1

/ipv6 address add address=2001:4860:4860::8888 interface=lo0
/ipv6 address add address=2001:4860:4860::8844 interface=lo1
