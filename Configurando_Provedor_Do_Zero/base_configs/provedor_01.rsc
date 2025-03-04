# Habilitar IPv6 e Reiniciar
/system package enable ipv6
/system reboot
yes

# Configurações Gerais
/system identity set name=provedor_01
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes

# Configuração de Interface IP
/interface ethernet set [ find default-name=ether1] name=ether1-NET
/ip address add interface=ether1-NET address=172.16.0.11/24
/ip route add gateway=172.16.0.2
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1-NET

/interface ethernet set [ find default-name=ether2] name=ether2-CLIENTE_DEDICADO
/ip address add address=200.200.200.1/29 interface=ether2-CLIENTE_DEDICADO
/ipv6 address add address=2001:0db8:1::1/126 interface=ether2-CLIENTE_DEDICADO
/ipv6 route add dst-address=2001:0db8:1:8::/48 gateway=2001:0db8:1::2

# Configuração do Cliente Externo
/interface ethernet set [ find default-name=ether4] name=ether4-CLIENTE_EXTERNO
/ip address add interface=ether4-CLIENTE_EXTERNO address=172.30.250.1/24
/ip pool add name=pool-cliente_externo ranges=172.30.250.100-172.30.250.200
/ip dhcp-server add address-pool=pool-cliente_externo disabled=no interface=ether4-CLIENTE_EXTERNO name=dhcp-cliente_externo
/ip dhcp-server network add address=172.30.250.0/24 gateway=172.30.250.1 netmask=24

# Configuração de IPv6 para simular ping ao Google
/interface bridge add name=lo0
/interface bridge add name=lo1

/ip address add address=8.8.8.8 interface=lo0
/ip address add address=8.8.4.4 interface=lo1

/ipv6 address add address=2001:4860:4860::8888 interface=lo0
/ipv6 address add address=2001:4860:4860::8844 interface=lo1
