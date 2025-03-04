# Habilitar IPv6 e Reiniciar
/system package enable ipv6
/system reboot
yes
#----------------------------------------------------------
# Configurações Gerais
/system identity set name=roteador_02
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes
#----------------------------------------------------------
# Configuração de Interface IP
## Ether1
/interface ethernet set [ find default-name=ether1] name=ether1-PROVEDOR_03
/ip address add address=203.203.203.2/30 interface=ether1-PROVEDOR_03

## Ether2
/interface ethernet set [ find default-name=ether2] name=ether2-PROVEDOR_04
/ip address add address=204.204.204.2/30 interface=ether2-PROVEDOR_04

## Ether3
/interface ethernet set [ find default-name=ether3] name=ether3-SWITCH_01
/ip address add address=10.33.33.12/24 interface=ether3-SWITCH_01
