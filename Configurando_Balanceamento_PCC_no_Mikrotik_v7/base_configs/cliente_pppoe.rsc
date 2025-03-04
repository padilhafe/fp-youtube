# Habilitar IPv6 e Reiniciar
/system/package/enable ipv6
/system/reboot
yes
#----------------------------------------------------------
# Configurações Gerais
/system identity/set name=cliente_pppoe
/ip/dhcp-client/set 0 disabled=yes
/tool/romon/set enabled=yes

#----------------------------------------------------------
# Configuração de Interface IP
/interface ethernet set [ find default-name=ether1 ] name=ether1-BNG_01
/interface pppoe-client add \
    add-default-route=yes \
    disabled=no \
    interface=ether1-BNG_01 \
    name=pppoe-out1 \
    use-peer-dns=yes \
    user=cliente_01 password=cliente_01
