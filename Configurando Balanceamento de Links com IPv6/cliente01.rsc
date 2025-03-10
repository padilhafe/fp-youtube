#----------------------------------------------------------
# Configurações Gerais
/system/identity/set name=cliente_pppoe
/ip/dhcp-client/set 0 disabled=yes
/tool/romon/set enabled=yes

#----------------------------------------------------------
# Configuração de Interface IP
/interface ethernet set [ find default-name=ether1 ] name=ether1-BNG_01
/interface vlan add vlan-id=101 interface=ether1-BNG_01 name=VLAN101-PPPOE-LINK01
/interface vlan add vlan-id=102 interface=ether1-BNG_01 name=VLAN102-PPPOE-LINK02

/interface pppoe-client add \
    add-default-route=yes \
    disabled=no \
    interface=VLAN101-PPPOE-LINK01 \
    name=pppoe-out1 \
    use-peer-dns=yes \
    user=cliente_01 password=cliente_01

/interface pppoe-client add \
    add-default-route=no \
    disabled=no \
    interface=VLAN102-PPPOE-LINK02 \
    name=pppoe-out2 \
    use-peer-dns=no \
    user=cliente_02 password=cliente_02


/ipv6 dhcp-client add interface=pppoe-out1 pool-name=POOL-V6-01 pool-prefix-length=56 request=prefix
/ipv6 dhcp-client add interface=pppoe-out2 pool-name=POOL-V6-02 pool-prefix-length=56 request=prefix