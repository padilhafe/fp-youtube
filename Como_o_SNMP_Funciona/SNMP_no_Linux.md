# **SNMP no Linux**

O SNMP (*Simple Network Management Protocol*) é amplamente utilizado para monitorar e gerenciar dispositivos em redes. No Linux, utilizamos o pacote `snmpd` (ou `net-snmp` em algumas distribuições) e suas ferramentas para configurar e operar o protocolo SNMP. Ele é composto de dois componentes principais:

- **snmpd**: Fornece o daemon necessário para habilitar o suporte SNMP no sistema, permitindo que ele seja monitorado por um manager SNMP.
- **snmp**: Um conjunto de ferramentas que permite interagir com o protocolo SNMP, seja para consultas, configurações ou simulações.

---

## **Instalação do SNMP no Ubuntu**
Primeiro, atualize os repositórios e instale os pacotes necessários:

```bash
sudo apt update -y
sudo apt install snmp snmpd -y
```

Esses pacotes incluem o daemon (`snmpd`) e as ferramentas de linha de comando (`snmp`).

---

## **Configurando o SNMP v1 ou v2c no Linux**

O SNMPv1 e SNMPv2c utilizam *community strings* para controle de acesso. Para configurá-los:

1. Edite o arquivo de configuração:
   ```bash
   sudo nano /etc/snmp/snmpd.conf
   ```

2. Altere os seguintes parâmetros:
   - **`syslocation`**: Define a localização do dispositivo.  
     Exemplo: `syslocation "Data Center"`
   - **`syscontact`**: Define o contato responsável pelo dispositivo.  
     Exemplo: `syscontact "admin@exemplo.com"`
   - **`rocommunity`**: Define a *community string* de leitura.  
     Exemplo: `rocommunity snmp default 1.3`
`

1. Reinicie o daemon para aplicar as mudanças:
   ```bash
   sudo systemctl restart snmpd
   ```

2. Teste a configuração:
   ```bash
   snmpget -v2c -c public IP_MAQUINA 1.3.6.1.2.1.1.5.0
   ```

---

## **Ferramentas disponíveis no pacote `snmp`**

As ferramentas do pacote `snmp` fornecem diversas funcionalidades, sendo úteis tanto para operações simples quanto para testes avançados:

- **`snmptranslate`**: Traduz um OID para seu nome na MIB ou vice-versa.  
  Exemplo: `snmptranslate -IR sysName.0`
- **`snmpget`**: Realiza uma consulta GET em algum agent SNMP para obter o valor de uma variável.  
  Exemplo: `snmpget -v2c -c public 127.0.0.1 sysName.0`
- **`snmpgetnext`**: Realiza uma consulta GETNEXT para obter o próximo OID na MIB.  
  Exemplo: `snmpgetnext -v2c -c public 127.0.0.1 sysUpTime`
- **`snmpwalk`**: Realiza consultas GETNEXT de forma iterativa, percorrendo os OIDs.  
  Exemplo: `snmpwalk -v2c -c public 127.0.0.1`
- **`snmptable`**: Retorna o conteúdo de uma tabela MIB de um agent.  
  Exemplo: `snmptable -v2c -c public 127.0.0.1 ifTable`
- **`snmpset`**: Realiza ações de SET para alterar valores em um agent.  
  Exemplo: `snmpset -v2c -c private 127.0.0.1 sysLocation.0 s "Data Center"`
- **`snmpbulkget`**: Realiza consultas GETBULK (suportado pelo SNMPv2c e SNMPv3).  
  Exemplo: `snmpbulkget -v2c -c public 127.0.0.1 system`
- **`snmptrap`**: Gera uma TRAP SNMP para ser enviada a um manager.  
  Exemplo: `snmptrap -v2c -c public 127.0.0.1 "" .1.3.6.1.4.1`

---

## **Configurando o SNMPv3**

O SNMPv3 oferece maior segurança ao utilizar autenticação e criptografia. Para ativá-lo:

1. Após configurar o SNMPv2, crie um usuário para SNMPv3 utilizando o utilitário `net-snmp-create-v3-user`:

   ```bash
   sudo systemctl stop snmpd
   sudo net-snmp-create-v3-user -a SHA-256 -A autenticacao -x AES -X encriptacao usuario
   ```

2. Durante a execução do comando, você será solicitado a fornecer:
   - **-A**: referente a senha de autenticação.
   - **-X**: referente a senha de criptografia.
   - **Nome do usuário**: Escolha um nome, como `usuario`.

3. Reinicie o daemon para que as mudanças entrem em vigor:
   ```bash
   sudo systemctl restart snmpd
   ```

4. Teste a configuração SNMPv3 com:
   ```bash
   snmpget -v3 -u usuario \
    -l authPriv \
    -a SHA-256 -A autenticacao \
    -x AES -X encriptacao \
    192.168.10.28 1.3.6.1.2.1.1.5.0
   ```
