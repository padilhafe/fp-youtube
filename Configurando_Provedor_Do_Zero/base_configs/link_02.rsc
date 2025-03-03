# Habilitar IPv6 e Reiniciar
/system/package/enable ipv6
/system/reboot
yes

# Configurações Gerais
/system/identity/set name=link_02
/ip/dhcp-client/set 0 disabled=yes
/tool/romon/set enabled=yes

# Configuração de Interface e IP
/interface/ethernet set [ find default-name=ether1 ] name=ether1-PROVEDOR_03
/interface/ethernet set [ find default-name=ether3 ] name=ether2-SWITCH_CORE_02
