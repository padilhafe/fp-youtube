# Habilitar IPv6 e Reiniciar
/system package enable ipv6
/system reboot
yes
#----------------------------------------------------------
# Configurações Gerais
/system identity set name=provedor_02
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes
#----------------------------------------------------------
# Configuração de Interface IP
## Ether1
/interface ethernet set [ find default-name=ether1] name=ether1-NET
/ip address add interface=ether1-NET address=172.16.0.12/24
/ip route add gateway=172.16.0.2
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1-NET

## Ether2
/interface ethernet set [ find default-name=ether2] name=ether2-CLIENTE_DEDICADO
/ip address add address=202.202.202.1/30 interface=ether2-CLIENTE_DEDICADO
/ipv6 address add address=2001:2::1/126 interface=ether2-CLIENTE_DEDICADO
/ipv6 route add dst-address=2001:2:b700::/40 gateway=2001:2::2
#----------------------------------------------------------
# Configuração de IPv6 para simular ping ao Google
/interface bridge add name=lo0
/interface bridge add name=lo1
/ip address add address=8.8.8.8 interface=lo0
/ip address add address=8.8.4.4 interface=lo1
/ipv6 address add address=2001:4860:4860::8888 interface=lo0
/ipv6 address add address=2001:4860:4860::8844 interface=lo1
