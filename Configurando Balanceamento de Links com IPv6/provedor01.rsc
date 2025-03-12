# Configurações Gerais
/system identity set name=provedor01
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes

# Configuração de Interface IP
/interface ethernet set [ find default-name=ether1] name=ether1-CLIENTE_01
/ipv6 address add address=2001:0db8::10/126 interface=ether1-CLIENTE_01
/ipv6 route add dst-address=2001:db8:b700::/40 gateway=2001:0db8::11

/interface ethernet set [ find default-name=ether2] name=ether2-GOOGLE
/ipv6 address add address=2001:0db8::1/126 interface=ether2-GOOGLE
/ipv6 route add dst-address=2001:4860::/32 gateway=2001:0db8::2
/ipv6 firewall filter add action=drop chain=forward in-interface=ether1-CLIENTE_01 src-address=!2001:db8::/32
