# ATENÇÃO - EM DESENVOLVIMENTO

# Configurando 2 Links na Mikrotik 

## Informações gerais sobre o laboratório
Este laboratório tem como objetivo guiar a configuração de uma infraestrutura de rede com redundância e alta disponibilidade. O processo é dividido em quatro partes, desde a configuração básica de um link primário até a implementação de balanceamento de carga e tolerância a falhas com múltiplos roteadores e BNGs.

Cada parte do laboratório aborda uma etapa essencial para construir uma rede robusta, que garante a continuidade do serviço mesmo em caso de falhas. Ao final, a rede estará preparada para lidar com múltiplos links, roteadores redundantes e BNGs configurados para alta disponibilidade.

---
## Parte 0 - Configurações fixas
Antes de iniciarmos o laboratório, precisamos configurar os equipamentos que terão configuração de rede fixa, bem como algumas configurações de ambiente, que são:
- Configurações fixas:
  - Provedor 01, 02 e 03
  - Cliente PPPoE 01 e 02
 
- Configurações de ambiente
  - Nomes das interfaces de redes de todos os nós
  - Ativar ROMON em todos os nós
  - Ativar pacote de IPv6 nos nós de roteamento

Para isso, bastará copiarmos a configuração presente no diretório `base_configs` para seus respectivos nós. Apenas atente-se para substituir o endereço IP da interface ether1 do provedor 01 e 02 para um endereço roteável na sua rede. Caso não saiba o que utilizar, não há problema, pois a configuração base de ambos prevê a simulação dos endereços DNS do Google em suas interfaces loopack, permitindo "ping" para o 8.8.8.8 mesmo sem rede.

## Parte 1 - Ativando o Primeiro Link
Nesta primeira etapa, vamos configurar o link principal e garantir que os serviços de rede dos nossos clientes estejam funcionando. A ideia é estabelecer a conexão inicial, ativar recursos como DHCP e PPPoE para os clientes, e testar a rede para ter certeza de que tudo está operando como esperado. Assim, você terá um ambiente estável para seguir para as próximas fases do laboratório.

Nossos objetivos serão:
- Configurar o primeiro Link;
- Configurar as regras de NAT;
- Configurar o servidor DHCP para o VPC;
- Configurar o servidor PPPoE para os 50 clientes;
- Validar o funcionamento da rede cliente;

Você acabou de adquirir um link dedicado com o *Provedor_01*, que te encaminhou as seguintes informações para configuração por email:
```
Dados para configuração do Link Dedicado
- Rede IPv4: 200.200.200.0/29
IPv4 lado Provedor 01: 200.200.200.1/29

- Rede IPv6: 2001:0db8:1::/126 e 2001:0db8:1:8::/48
IPv6 lado Provedor 01: 2001:0db8:1::1/126
A rede 2001:0db8:1:8::/48 será entregue de forma roteada.

Não é necessário configurar tagging de VLAN na interface que irá receber o link.
```

De posse destas informações, você elencou que precisa realizar as seguintes atividades:
- Configurar o endereço IPv4 na interface do link;
- Configurar o endereço IPv6 na interface do link;
- Testar conectividade local IPv4
- Testar conectividade local IPv6
- Configurar uma rota padrão para 200.200.200.1;
- Configurar uma rota padrão para 2001:0db8:1::1;
- Configurar rotas blackhole para evitar loop de roteamento
- Teste de ping para 8.8.8.8 e 8.8.4.4
- Teste de ping para 2001:4860:4860::8888 ou 2001:4860:4860::8844
- Realizar um segundo teste de conectividade adicionando temporariamente um endereço IP do bloco 2001:0db8:1:8::/48 em uma interface de loopback.

### Resolução
```
/ip address add interface=ether1 address=200.200.200.2/29
/ipv6 address add interface=ether1 address=2001:0db8:1::2/126

/ping 200.200.200.1 src-address=200.200.200.2 count=1
/ping 2001:0db8:1::1 src-address=2001:0db8:1::2 count=1

/ip route add gateway=200.200.200.1
/ipv6 route add gateway=2001:0db8:1::1
/ipv6 route add type=unreachable dst-address=2001:0db8:1:8::/48

/ping 8.8.8.8 src-address=200.200.200.2 count=1
/ping 2001:4860:4860::8888 src-address=2001:0db8:1::2 count=1

/interface bridge add name=loopback0
/ipv6 address add interface=loopback0 address=2001:0db8:1:8::ffff/48
/ping 2001:4860:4860::8888 src-address=2001:0db8:1:8::ffff count=1

/undo
/undo
```

## Parte 2 - Configurando o Switch Core e Interconexões
Agora vamos configurar a interconexão entre a nossa OLT, nosso equipamento de autenticação PPPoE, nossa rede interna e o nosso roteador de link.
Bem, não é uma OLT de verdade já que não podemos emular uma. Será apenas um Mikrotik, configurado com switch, fazendo qinq das VLANS das "portas PON".

Depois de muito estudar a melhor forma de configurar as VLANs na sua rede, você decidiu fazer as seguintes configurações:
- Vlan 100: vlan para sub-rede interna;
  - Rede IPv4: 10.100.100.0/24
  - Rede IPv6: 2001:0db8:1:8:ffff::/64
  
- Vlan 110: vlan do /24 de gerencia das OLTs;
  - Rede IPv4: 10.110.100.0/24

- Vlan 120: vlan do /24 de gerencia dos Switch Core;
  - Rede IPv4: 10.120.100.0/24

- Vlan 140: comunicação IPv4 entre link_01 e bng's;
  - Rede IPv4: 10.140.100.0/24
  
- Vlan 160: comunicação IPv6 entre link_01 e bng's;
  - Rede IPv6: 2001:0db8:1:9:ffff::/64
  
- Testar a conectividade de todos os nós com o 8.8.8.8 e no bng_01 e rede_interna adicionalmente com o 2001:4860:4860::8888

### Resolução
**link_01**
```
/interface vlan add name=VLAN100-REDE_INTERNA interface=ether3 vlan-id=100
/interface vlan add name=VLAN110-GERENCIA_OLT interface=ether3 vlan-id=110
/interface vlan add name=VLAN120-GERENCIA_SWITCH_CORE interface=ether3 vlan-id=120
/interface vlan add name=VLAN140-BNG_IPV4 interface=ether3 vlan-id=140
/interface vlan add name=VLAN160-BNG_IPV6 interface=ether3 vlan-id=160

/ip address add interface=VLAN100-REDE_INTERNA address=10.100.100.1/24
/ip address add interface=VLAN110-GERENCIA_OLT address=10.110.100.1/24
/ip address add interface=VLAN120-GERENCIA_SWITCH_CORE address=10.120.100.1/24
/ip address add interface=VLAN140-BNG_IPV4 address=10.140.100.1/24

/ipv6 settings set accept-redirects=no accept-router-advertisements=no
/ipv6 nd set [ find default=yes ] managed-address-configuration=yes other-configuration=yes
/ipv6 address add interface=VLAN100-REDE_INTERNA address=2001:0db8:1:8:ffff::1/64
/ipv6 address add interface=VLAN160-BNG_IPV6 address=2001:0db8:1:9:ffff::1/64 advertise=no

/ip pool add name=pool-rede_interna ranges=10.100.100.100-10.100.100.200
/ip dhcp-server add address-pool=pool-rede_interna disabled=no interface=VLAN100-REDE_INTERNA name=dhcp-rede_interna
/ip dhcp-server network add address=10.100.100.0/24 gateway=10.100.100.1 netmask=24
/ip firewall nat add chain=srcnat src-address=10.100.100.0/24 out-interface=ether1 action=src-nat to-addresses=200.200.200.2
/ip firewall nat add chain=srcnat src-address=10.110.100.0/24 out-interface=ether1 action=src-nat to-addresses=200.200.200.2
/ip firewall nat add chain=srcnat src-address=10.120.100.0/24 out-interface=ether1 action=src-nat to-addresses=200.200.200.2
/ip firewall nat add chain=srcnat src-address=10.140.100.0/24 out-interface=ether1 action=src-nat to-addresses=200.200.200.2
```

**bng_01**
```
/interface vlan add name=VLAN140-BNG_IPV4 interface=ether1 vlan-id=140
/interface vlan add name=VLAN160-BNG_IPV6 interface=ether1 vlan-id=160

/ip address add interface=VLAN140-BNG_IPV4 address=10.140.100.2/24
/ip route add gateway=10.140.100.1

/ipv6 settings set accept-redirects=no accept-router-advertisements=no
/ipv6 nd set [ find default=yes ] managed-address-configuration=yes other-configuration=yes
/ipv6 address add interface=VLAN160-BNG_IPV6 address=2001:0db8:1:9:ffff::2/64 advertise=no
/ipv6 route add gateway=2001:0db8:1:9:ffff::1
```

**olt_01**
```
/interface bridge add name=bridge01 frame-types=admit-only-vlan-tagged ingress-filtering=yes pvid=666 vlan-filtering=yes protocol-mode=rstp

/interface vlan add name=VLAN110-GERENCIA_OLT interface=bridge01 vlan-id=110
/ip address add interface=VLAN110-GERENCIA_OLT address=10.110.100.2/24
/ip route add gateway=10.110.100.1

/interface bridge port add interface=ether1-SWITCH_CORE_01 bridge=bridge01 frame-types=admit-only-vlan-tagged hw=yes ingress-filtering=yes pvid=666
/interface bridge vlan add vlan-ids=110 bridge=bridge01 disabled=no \
    tagged=ether1-SWITCH_CORE_01,bridge01

```

**switch_core_01**
```
/interface bridge add name=bridge01 frame-types=admit-only-vlan-tagged ingress-filtering=yes pvid=666 vlan-filtering=yes protocol-mode=rstp

/interface vlan add name=VLAN120-GERENCIA_SWITCH_CORE interface=bridge01 vlan-id=120
/ip address add interface=VLAN120-GERENCIA_SWITCH_CORE address=10.120.100.2/24
/ip route add gateway=10.120.100.1

/interface bridge port add interface=ether1-LINK_01 bridge=bridge01 frame-types=admit-only-vlan-tagged hw=yes ingress-filtering=yes pvid=666
/interface bridge port add interface=ether2-OLT_01 bridge=bridge01 frame-types=admit-only-vlan-tagged hw=yes ingress-filtering=yes pvid=666
/interface bridge port add interface=ether11-BNG_01 bridge=bridge01 frame-types=admit-only-vlan-tagged hw=yes ingress-filtering=yes pvid=666
/interface bridge port add interface=ether16-REDE_INTERNA bridge=bridge01 frame-types=admit-only-untagged-and-priority-tagged hw=yes pvid=100 edge=yes

/interface bridge vlan add vlan-ids=100 bridge=bridge01 disabled=no \
    tagged=ether1-LINK_01 untagged=ether16-REDE_INTERNA

/interface bridge vlan add vlan-ids=110 bridge=bridge01 disabled=no \
    tagged=ether1-LINK_01,ether2-OLT_01

/interface bridge vlan add vlan-ids=120 bridge=bridge01 disabled=no \
    tagged=ether1-LINK_01,bridge01

/interface bridge vlan add vlan-ids=140 bridge=bridge01 disabled=no \
    tagged=ether1-LINK_01,ether11-BNG_01

/interface bridge vlan add vlan-ids=160 bridge=bridge01 disabled=no \
    tagged=ether1-LINK_01,ether11-BNG_01
```



- Vlan 3001: vlan externa para a olt_01;
- Vlan 1101 - 1300: Range para vlan interna das portas PON.

**Configurar as regras de NAT**
```
/ip firewall nat add chain=srcnat src-address=100.64.0.0/26 out-interface=ether2 action=src-nat to-addresses=200.200.200.3
/ip firewall nat add chain=srcnat src-address=100.64.0.64/26 out-interface=ether2  action=src-nat to-addresses=200.200.200.4
/ip firewall nat add chain=srcnat src-address=100.64.0.128/26 out-interface=ether2  action=src-nat to-addresses=200.200.200.5
/ip firewall nat add chain=srcnat src-address=100.64.0.192/26 out-interface=ether2  action=src-nat to-addresses=200.200.200.6
```

**Configurar o servidor DHCP para o VPC**
