# Habilitar IPv6 e Reiniciar
/system package enable ipv6
/system reboot
yes

#----------------------------------------------------------
# Configurações Gerais
/system identity set name=rotedor_01
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes

#----------------------------------------------------------
# Configuração de Interface IP
## Ether1
/interface ethernet set [ find default-name=ether1] name=ether1-PROVEDOR_01
/ip address add address=201.201.201.2/30 interface=ether1-PROVEDOR_01

## Ether2
/interface ethernet set [ find default-name=ether2] name=ether2-PROVEDOR_02
/ip address add address=202.202.202.2/30 interface=ether2-PROVEDOR_02

## Ether3
/interface ethernet set [ find default-name=ether3] name=ether3-SWITCH_01
/ip address add address=10.33.33.254/24 interface=ether3-SWITCH_01

#----------------------------------------------------------
# Rota estática para os clientes
/ip/route/add dst-address=100.64.0.0/24 gateway=10.33.33.31
/ip/route/add dst-address=100.65.0.0/24 gateway=10.33.33.31