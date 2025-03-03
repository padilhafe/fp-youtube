# Configurações Gerais
/system identity set name=switch_core_01
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes

# Configuração de Interface e IP
/interface ethernet set [ find default-name=ether1] name=ether1-LINK_01
/interface ethernet set [ find default-name=ether2] name=ether2-OLT_01
/interface ethernet set [ find default-name=ether8] name=ether8-SWITCH_CORE_02
/interface ethernet set [ find default-name=ether11] name=ether11-BNG_01
/interface ethernet set [ find default-name=ether16] name=ether16-REDE_INTERNA
