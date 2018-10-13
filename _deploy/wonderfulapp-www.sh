#!/bin/bash
set -euo pipefail
set -x

# -- configuration -------------------------------------------------------------
username=andreyvit

# -- parse options -------------------------------------------------------------
deploy=false
reconfigure=false
while test "$#" -gt 0; do
    case "$1" in
        --deploy)      deploy=true;      shift;;
        --reconfigure) reconfigure=true; shift;;
        *) echo "** invalid option '$1'"; exit 1;;
    esac
done

# -- directories ---------------------------------------------------------------
sudo install -d -m755 -g$username -o$username /srv/wonderfulapp-www/versions

# -- deploy code ---------------------------------------------------------------
if $deploy; then
    now="$(date "+%Y%m%d_%H%M%S")"
    sudo cp -r ~/wonderfulapp-www "/srv/wonderfulapp-www/versions/$now"
    sudo chown -R $username:$username "/srv/wonderfulapp-www/versions/$now"
    sudo rm -f "/srv/wonderfulapp-www/upcoming"
    sudo ln -s "/srv/wonderfulapp-www/versions/$now" "/srv/wonderfulapp-www/upcoming"
    sudo mv -T "/srv/wonderfulapp-www/upcoming" "/srv/wonderfulapp-www/current"
fi

if $reconfigure; then

# -- configure Caddy -----------------------------------------------------------
sudo install -m644 -groot -oroot /dev/stdin /srv/wonderfulapp-www/Caddyfile <<EOF
thewonderfulapp.com {
    root /srv/wonderfulapp-www/current
    tls andrey@tarantsov.com
}
EOF

sudo systemctl restart caddy

fi

# -- start ---------------------------------------------------------------------
# nop