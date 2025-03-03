# Habilitar IPv6 e Reiniciar
/system package enable ipv6
/system reboot
yes

# Configurações Gerais
/system identity set name=link_01
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes

# Configuração de Interface e IP
/interface ethernet set [ find default-name=ether1 ] name=ether1-PROVEDOR_01
/interface ethernet set [ find default-name=ether2 ] name=ether2-PROVEDOR_02
/interface ethernet set [ find default-name=ether3 ] name=ether3-SWITCH_CORE_01

