# Configurações Gerais
/system identity set name=switch_01
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes
#----------------------------------------------------------
# Configuração da Bridge
/interface bridge add name=bridge01 protocol-mode=rstp
/interface bridge port add interface=all bridge=bridge01
#----------------------------------------------------------
# Configuração de Interface e IP
/interface ethernet set [ find default-name=ether1] name=ether1-ROTEADOR_01
/interface ethernet set [ find default-name=ether2] name=ether2-ROTEADOR_02
/interface ethernet set [ find default-name=ether3] name=ether3-BNG_01
/ip address add interface=bridge01 address=10.33.33.21/24
/ip route add gateway=10.33.33.254
