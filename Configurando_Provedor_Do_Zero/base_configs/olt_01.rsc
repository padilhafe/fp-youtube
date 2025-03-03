# Configurações Gerais
/system identity set name=olt_01
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes

# Configuração de Interface e IP
/interface ethernet set [ find default-name=ether1 ] name=ether1-SWITCH_CORE_01
/interface ethernet set [ find default-name=ether2 ] name=ether2-CLIENTE_PPPOE_01
