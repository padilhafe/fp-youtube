# Habilitar IPv6 e Reiniciar
/system/package/enable ipv6
/system/reboot
yes
#----------------------------------------------------------
# Configurações Gerais
/system identity/set name=bng_01
/ip/dhcp-client/set 0 disabled=yes
/tool/romon/set enabled=yes

#----------------------------------------------------------
# Configuração de Interface IP
## Ether1
/interface/ethernet/set [ find default-name=ether1] name=ether1-SWITCH_01
/ip/address/add address=10.33.33.31/24 interface=ether1-SWITCH_01
/ip/route/add gateway=10.33.33.254

## Ether2
/interface ethernet set [ find default-name=ether2] name=ether2-CLIENTE_PPPOE

## Ether3
/interface ethernet set [ find default-name=ether3] name=ether3-CLIENTE_DHCP
/ip address add address=100.65.0.1/24 interface=ether3-CLIENTE_DHCP

#----------------------------------------------------------
# PPPoE Server
/ip/pool/add name=pool_pppoe ranges=100.64.0.100-100.64.0.200

/ppp/profile/set 0 local-address=10.33.33.31 remote-address=pool_pppoe
/ppp/secret/add name=cliente_01 password=cliente_01 profile=default service=pppoe

/interface/pppoe-server/server add \
    authentication=chap \
    default-profile=default \
    disabled=no \
    interface=ether2-CLIENTE_PPPOE \
    one-session-per-host=yes \
    service-name=pppoe

#----------------------------------------------------------
# DHCP Server
/ip/pool/add name=pool_dhcp ranges=100.65.0.100-100.65.0.200
/ip/dhcp-server/add address-pool=pool_dhcp disabled=no interface=ether3-CLIENTE_DHCP name=dhcp-ether3
/ip/dhcp-server/network add address=100.65.0.0/24 gateway=100.65.0.1 netmask=24
