# Configurações Gerais
/system identity set name=google
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes

# Configuração de Interface IP
/interface ethernet set [ find default-name=ether1] name=ether1-PROVEDOR_01
/ipv6 address add address=2001:0db8::2/126 interface=ether1-PROVEDOR_01
/ipv6 route add dst-address=2001:0db8::/32  gateway=2001:0db8::1 distance=10

/interface ethernet set [ find default-name=ether2] name=ether2-PROVEDOR_02
/ipv6 address add address=2001:0db9::2/126 interface=ether2-PROVEDOR_02
/ipv6 route add dst-address=2001:0db9::/32 gateway=2001:0db9::1 distance=20

# Configuração de IPv6 para simular ping ao Google
/interface bridge add name=lo0
/interface bridge add name=lo1
/ipv6 address add address=2001:4860:4860::8888 interface=lo0
/ipv6 address add address=2001:4860:4860::8844 interface=lo1
