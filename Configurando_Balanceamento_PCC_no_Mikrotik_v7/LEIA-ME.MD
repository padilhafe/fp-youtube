# Steps do Laboratório
- Configurar links com failover
- Testar comunicação dos clientes (DHCP e PPPoE)

```
# Configurar duas WAN Separadas
/ip/firewall/nat add chain=srcnat action=masquerade out-interface=ether1
/ip/firewall/nat add chain=srcnat action=masquerade out-interface=ether2

/ip/route/add dst-address=8.8.8.8 scope=10 gateway=201.201.201.1
/ip/route/add dst-address=8.8.4.4 scope=10 gateway=202.202.202.1
/ip/route/add distance=1 gateway=8.8.8.8 target-scope=11 check-gateway=ping
/ip/route/add distance=2 gateway=8.8.4.4 target-scope=11 check-gateway=ping


/ip/route/add dst-address=208.67.222.222 gateway=201.201.201.1 scope=10
/ip/route/add dst-address=208.67.220.220 gateway=202.202.202.1 scope=10
/ip/route/add distance=1 gateway=208.67.222.222 target-scope=11 check-gateway=ping
/ip/route/add distance=2 gateway=208.67.220.220 target-scope=11 check-gateway=ping
```

# Per Connection Classifier
/routing/table/add name=PROVEDOR_01 fib disabled=no
/routing/table/add name=PROVEDOR_02 fib disabled=no

/ip/route/add gateway=201.201.201.1 check-gateway=ping routing-table=PROVEDOR_01
/ip/route/add gateway=202.202.202.1 check-gateway=ping routing-table=PROVEDOR_02

/ip/route/add gateway=201.201.201.1 check-gateway=ping routing-table=main distance=1
/ip/route/add gateway=202.202.202.1 check-gateway=ping routing-table=main distance=2

/ip/firewall/mangle add chain=prerouting in-interface=ether1-PROVEDOR_01 connection-state=new connection-mark=no-mark action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_01
/ip/firewall/mangle add chain=prerouting in-interface=ether2-PROVEDOR_02 connection-state=new connection-mark=no-mark action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_02
/ip/firewall/mangle add chain=output connection-mark=CONEXAO_PROVEDOR_01 action=mark-routing new-routing-mark=PROVEDOR_01
/ip/firewall/mangle add chain=output connection-mark=CONEXAO_PROVEDOR_01 action=mark-routing new-routing-mark=PROVEDOR_02

/ip/firewall/mangle add chain=prerouting in-interface=ether3 connection-state=new connection-mark=no-mark dst-address-type=!local per-connection-classifier=src-address-and-port:2/0 action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_01
/ip/firewall/mangle add chain=prerouting in-interface=ether3 connection-state=new connection-mark=no-mark dst-address-type=!local per-connection-classifier=src-address-and-port:2/1 action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_01
/ip/firewall/mangle add chain=prerouting in-interface=ether3 connection-state=new connection-mark=no-mark dst-address-type=!local per-connection-classifier=src-address-and-port:2/2 action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_01
/ip/firewall/mangle add chain=prerouting in-interface=ether3 connection-state=new connection-mark=no-mark dst-address-type=!local per-connection-classifier=src-address-and-port:2/3 action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_01
/ip/firewall/mangle add chain=prerouting in-interface=ether3 connection-state=new connection-mark=no-mark dst-address-type=!local per-connection-classifier=src-address-and-port:2/4 action=mark-connection new-connection-mark=CONEXAO_PROVEDOR_02  


# R1
/ip address add address=192.168.1.10/24 interface=ether1
/interface vrrp add interface=ether1 vrid=49 priority=254
/ip address add address=192.168.1.1/32 interface=vrrp1

# R2
/ip address add address=192.168.1.20/24 interface=ether1
/interface vrrp add interface=ether1 vrid=49
/ip address add address=192.168.1.1/32 interface=vrrp1
```