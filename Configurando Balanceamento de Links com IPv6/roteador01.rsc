# Configurações Gerais
/system identity set name=roteador01
/ip dhcp-client set 0 disabled=yes
/tool romon set enabled=yes

#----------------------------------------------------------
# Configuração de Interface IP
/interface ethernet set [ find default-name=ether4] name=ether4-PROVEDOR_01
/ipv6 address add address=2001:0db8::11/126 interface=ether4-PROVEDOR_01
/ipv6/route/add gateway=2001:0db8::10 dst-address=::/0 distance=10

/interface ethernet set [ find default-name=ether3] name=ether3-PROVEDOR_02

/interface ethernet set [ find default-name=ether1] name=ether1-CLIENTE_PPPOE
/interface vlan add vlan-id=101 interface=ether1-CLIENTE_PPPOE name=VLAN101-PPPOE
/interface vlan add vlan-id=102 interface=ether1-CLIENTE_PPPOE name=VLAN102-PPPOE

#----------------------------------------------------------
# PPPoE Server
/ip/pool/add name=pool_pppoe_provedor01 ranges=100.64.0.100-100.64.0.200
/ipv6/pool/add name=pool_pd_provedor01 prefix=2001:db8:b720::/45 prefix-length=56
/ipv6/pool/add name=pool_prefix_provedor01 prefix=2001:db8:b72f:f000::/52 prefix-length=64



/ipv6/nd set [ find default=yes ] managed-address-configuration=yes other-configuration=yes

/ppp/profile/add name=LINK01 only-one=no local-address=10.33.33.31 \
    remote-address=pool_pppoe_provedor01 \
    use-ipv6=yes \
    dhcpv6-pd-pool=pool_pd_provedor01 \
    remote-ipv6-prefix-pool=pool_prefix_provedor01


/ppp/secret/add name=cliente_01 password=cliente_01 service=pppoe
/ppp/secret/add name=cliente_02 password=cliente_02 service=pppoe

/interface/pppoe-server/server add \
    authentication=chap \
    default-profile=LINK01 \
    disabled=no \
    interface=VLAN101-PPPOE \
    one-session-per-host=no \
    service-name=VLAN101-LINK01
    
/interface/pppoe-server/server add \
    authentication=chap \
    default-profile=LINK01 \
    pado-delay=1000 \
    disabled=no \
    interface=VLAN102-PPPOE \
    one-session-per-host=no \
    service-name=VLAN102-LINK01



# Video comeca aqui
/ipv6 address add address=2001:0db9::11/126 interface=ether3-PROVEDOR_02
/ipv6/route/add gateway=2001:0db9::10 dst-address=::/0 distance=20


/ip/pool/add name=pool_pppoe_provedor02 ranges=100.65.0.100-100.65.0.200
/ipv6/pool/add name=pool_pd_provedor02 prefix=2001:db9:b720::/45 prefix-length=56
/ipv6/pool/add name=pool_prefix_provedor02 prefix=2001:db9:b72f:f000::/52 prefix-length=64

/ppp/profile/add name=LINK02 only-one=no local-address=10.33.33.31 \
    remote-address=pool_pppoe_provedor02 \
    use-ipv6=yes \
    dhcpv6-pd-pool=pool_pd_provedor02 \
    remote-ipv6-prefix-pool=pool_prefix_provedor02

/interface/pppoe-server/server add \
    authentication=chap \
    default-profile=LINK02 \
    pado-delay=1000 \
    disabled=no \
    interface=VLAN101-PPPOE \
    one-session-per-host=no \
    service-name=VLAN101-LINK02

/interface/pppoe-server/server add \
    authentication=chap \
    default-profile=LINK02 \
    disabled=no \
    interface=VLAN102-PPPOE \
    one-session-per-host=no \
    service-name=VLAN102-LINK02


# Criar as tabelas de roteamento de cada provedor
/routing/table/add name=PROVEDOR_01 fib disabled=no
/routing/table/add name=PROVEDOR_02 fib disabled=no

# Criar as rotas default
/ipv6/route/add gateway=2001:0db8:1::10 check-gateway=ping routing-table=PROVEDOR_01
/ipv6/route/add gateway=2001:0db9:1::10 check-gateway=ping routing-table=PROVEDOR_02
/ipv6/route/add gateway=2001:0db8:1::10 check-gateway=ping routing-table=main distance=1
/ipv6/route/add gateway=2001:0db9:1::10 check-gateway=ping routing-table=main distance=2

/ipv6/firewall/mangle add chain=output src-address=2001:db8:b720::/45 action=mark-routing new-routing-mark=PROVEDOR_01
/ipv6/firewall/mangle add chain=output src-address=2001:db9:b720::/45 action=mark-routing new-routing-mark=PROVEDOR_01


/tool netwatch add disabled=no down-script="/interface/pppoe-server/server/set 0,3 disabled=yes" host=2001:db8:1::10 http-codes="" interval=10s name=VERIFICA-LINK01 src-address=2001:db8:1::11 test-script="" type=icmp up-script="/interface/pppoe-server/server/set 0,3 disabled=no"
/tool netwatch add disabled=no down-script="/interface/pppoe-server/server/set 1,2 disabled=yes" host=2001:db9:1::10 http-codes="" interval=10s name=VERIFICA-LINK01 src-address=2001:db9:1::11 test-script="" type=icmp up-script="/interface/pppoe-server/server/set 1,2 disabled=no"

## - PCC

# Configurar o NAT das interfaces WAN
/ipv6/firewall/nat add chain=srcnat src-address=fd01::/45 action=netmap to-address=2001:db8:b720::/45 out-interface=ether4
/ipv6/firewall/nat add chain=srcnat src-address=fd01::/45 action=netmap to-address=2001:db9:b720::/45 out-interface=ether3

# Adicionar as regras de marcação na entrada
/ipv6/firewall/mangle add chain=prerouting in-interface=ether4-PROVEDOR_01 connection-state=new connection-mark=no-mark action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_01
/ipv6/firewall/mangle add chain=prerouting in-interface=ether3-PROVEDOR_02 connection-state=new connection-mark=no-mark action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_02

# Adicionar as regras para forçar lookup na tabela de roteamento de cada provedor
/ipv6/firewall/mangle add chain=output connection-mark=CONEXAO_PROVEDOR_01 action=mark-routing new-routing-mark=PROVEDOR_01
/ipv6/firewall/mangle add chain=output connection-mark=CONEXAO_PROVEDOR_01 action=mark-routing new-routing-mark=PROVEDOR_02

# Adicionar as regras de marcação e balancemento da rede LAN
/ipv6/firewall/mangle add chain=prerouting in-interface=ether4 connection-state=new connection-mark=no-mark dst-address-type=!local per-connection-classifier=src-address-and-port:2/0 action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_01
/ipv6/firewall/mangle add chain=prerouting in-interface=ether3 connection-state=new connection-mark=no-mark dst-address-type=!local per-connection-classifier=src-address-and-port:2/1 action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_02