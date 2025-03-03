# ATENÇÃO - EM DESENVOLVIMENTO

# Configurando 2 Links na Mikrotik 

## Informações gerais sobre o laboratório
Este laboratório tem como objetivo guiar a configuração de uma infraestrutura de rede com redundância e alta disponibilidade. O processo é dividido em quatro partes, desde a configuração básica de um link primário até a implementação de balanceamento de carga e tolerância a falhas com múltiplos roteadores e BNGs.

Cada parte do laboratório aborda uma etapa essencial para construir uma rede robusta, que garante a continuidade do serviço mesmo em caso de falhas. Ao final, a rede estará preparada para lidar com múltiplos links, roteadores redundantes e BNGs configurados para alta disponibilidade.

As configurações gerais do nosso ambiente serão:
- Rede PPPoE: 100.64.0.0/24
- Rede DHCP: 172.16.0.0/24

---
## Parte 0 - Configurações fixas
Antes de iniciarmos o laboratório, precisamos configurar os equipamentos que terão configuração de rede fixa, que são:
- Provedor 01, 02 e 03
- SwitchCore 01 e 02
- OLT 01 e 02
- Cliente PPPoE 01 e 02
- Nomes das interfaces de redes de todos os nós

Para isso, bastará copiarmos a configuração presente no diretório `base_configs` para seus respectivos nós. Apenas atente-se para substituir o endereço IP da interface ether1 do provedor 01 e 02 para um endereço roteável na sua rede. Caso não saiba o que utilizar, não há problema, pois a configuração base de ambos prevê a simulação dos endereços DNS do Google em suas interfaces loopack, permitindo "ping" para o 8.8.8.8 mesmo sem rede.

## Parte 1 - Ativando o Primeiro Link e Cliente
Nesta primeira etapa, vamos configurar o link principal e garantir que os serviços de rede dos nossos clientes estejam funcionando. A ideia é estabelecer a conexão inicial, ativar recursos como DHCP e PPPoE para os clientes, e testar a rede para ter certeza de que tudo está operando como esperado. Assim, você terá um ambiente estável para seguir para as próximas fases do laboratório.

Nossos objetivos serão:
- Configurar o primeiro Link;
- Configurar as regras de NAT;
- Configurar o servidor DHCP para o VPC;
- Configurar o servidor PPPoE para os 50 clientes;
- Validar o funcionamento da rede cliente;

**Configurando o primeiro Link**
```
/ip address add interface=ether1 address=200.200.200.2/29
/ipv6 address add interface=ether1 address=2001:0db8:1::2/126

/ip route add gateway=200.200.200.1
/ip route add type=blackhole dst-address=200.200.200.0/29

/ipv6 route add gateway=2001:0db8:1::2/126
/ipv6 route add type=unreacheable dst-address=2001:0db8:1:8::2/48
```

**Configurar as regras de NAT**
```
/ip firewall nat add chain=srcnat src-address=100.64.0.0/26 out-interface=ether2 action=src-nat to-addresses=200.200.200.3
/ip firewall nat add chain=srcnat src-address=100.64.0.64/26 out-interface=ether2  action=src-nat to-addresses=200.200.200.4
/ip firewall nat add chain=srcnat src-address=100.64.0.128/26 out-interface=ether2  action=src-nat to-addresses=200.200.200.5
/ip firewall nat add chain=srcnat src-address=100.64.0.192/26 out-interface=ether2  action=src-nat to-addresses=200.200.200.6
```

**Configurar o servidor DHCP para o VPC**
