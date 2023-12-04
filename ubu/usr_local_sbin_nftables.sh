#!/bin/bash

WAN0="wlx90e6ba6abfb8"
LAN0="enp4s0"
AP0="wlx90e6ba6abf05"

cat << EOF > /etc/nftables.conf
#!/usr/sbin/nft -f

# CREATED BY /usr/local/sbin/nftables.sh
# Don't edit directly, edit that script and systemctl restart nftables

flush ruleset

table ip nat {
    chain prerouting {
        type nat hook prerouting priority 0; policy accept;
    }
    chain input {
        type nat hook input priority 0; policy accept;
    }
    chain output {
        type nat hook output priority 0; policy accept;
    }
    chain postrouting {
        type nat hook postrouting priority 0; policy accept;
        oifname "$LAN0" masquerade
        oifname "$AP0" masquerade
        oifname "$WAN0" masquerade
    }
}

table ip filter {
    chain input {
        type filter hook input priority 0; policy accept;
    }
    chain forward {
        type filter hook forward priority 0; policy accept;
        iifname "$LAN0" oifname "$AP0" ct state new accept
        iifname "$AP0" oifname "$LAN0" ct state related,established accept
        iifname "$WAN0" oifname "$LAN0" ct state related,established accept
        iifname "$LAN0" oifname "$AP0" accept
        iifname "$LAN0" oifname "$WAN0" accept
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF

/usr/sbin/nft -f /etc/nftables.conf

