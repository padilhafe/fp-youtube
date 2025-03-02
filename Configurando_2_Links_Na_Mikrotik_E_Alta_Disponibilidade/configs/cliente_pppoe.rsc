:for i from=1 to=50 do={
    :local username ("cliente" . $i)
    :local password ("password")
    
    /interface pppoe-client
    add name=("pppoe-out-" . $username) interface=ether1 \
        user=$username password=$password \
        disabled=no add-default-route=no use-peer-dns=no
        
    :log info ("Cliente PPPoE configurado: " . $username)
}
