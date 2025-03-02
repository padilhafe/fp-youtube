# Configurações Gerais
/system identity set name=provedor01

# Configuração de Interface IP
/ip address add address=200.200.200.1/29 interface=ether2

/ipv6 address add address=2001:0db8::1/126 interface=ether2
/ipv6 route add dst-adress=gateway=2001:0db8:1:8::/48 gateway=2001:0db8::2

# Configurações de NAT para o laboratório funcionar
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1

# Configuração de IPv6 para simular ping ao Google
/interface bridge add name=lo0
/interface bridge add name=lo1

/ipv6 address add address=2001:4860:4860::8888 interface=lo0
/ipv6 address add address=2001:4860:4860::8844 interface=lo1
