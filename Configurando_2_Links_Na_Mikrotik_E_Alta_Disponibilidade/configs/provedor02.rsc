# Configurações Gerais
/system identity set name=provedor02

# Configuração de Interface e IP
/interface vlan add interface=ether2 name=VLAN524-CLIENTE_65524 vlan-id=524
/ip address add address=192.168.5.25/30 interface=VLAN524-CLIENTE_65524
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1

/interface vlan add interface=ether2 name=VLAN524-CLIENTE_65524_IPV6 vlan-id=524
/ip address add address=2001:0db8:2::1/126 interface=VLAN524-CLIENTE_65524_IPV6

# Configurar os filtros de entrada e saída
/routing filter add chain=RF-OUT-CLIENTE_65524 action=accept prefix=0.0.0.0/0
/routing filter add chain=RF-OUT-CLIENTE_65524 action=discard

/routing filter add chain=RF-IN-CLIENTE_65524 action=accept prefix=250.200.200.0/29
/routing filter add chain=RF-IN-CLIENTE_65524 action=discard

/routing filter add chain=RF-OUT-CLIENTE_65524_IPV6 action=accept prefix=::/0
/routing filter add chain=RF-OUT-CLIENTE_65524_IPV6 action=discard

/routing filter add chain=RF-IN-CLIENTE_65524_IPV6 action=accept prefix=2001:0db8:2:8::/48
/routing filter add chain=RF-IN-CLIENTE_65524_IPV6 action=discard

# Configuração do BGP
/routing bgp instance add name=INSTANCIA-CLIENTE_65524 as=65524 router-id=192.168.5.25
/routing bgp peer add name=iBGP-CLIENTE_65524 \
	address-families=ip default-originate=always \
	in-filter=RF-IN-CLIENTE_65524 out-filter=RF-OUT-CLIENTE_65524 \
	remote-address=192.168.5.26 remote-as=65524 \
    instance=INSTANCIA-CLIENTE_65524 update-source=VLAN524-CLIENTE_65524

/routing bgp peer add name=iBGP-CLIENTE_65524_IPV6 \
	address-families=ip6 default-originate=always \
	in-filter=RF-IN-CLIENTE_65524_IPV6 out-filter=RF-OUT-CLIENTE_65524_IPV6 \
	remote-address=2001:0db8:2::2 remote-as=65524 \
	instance=INSTANCIA-CLIENTE_65524 update-source=VLAN524-CLIENTE_65524_IPV6
