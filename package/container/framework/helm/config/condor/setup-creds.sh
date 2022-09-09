if [[ ! -s /etc/condor/passwords.d/POOL ]]; then
    ( flock -n 200 || exit 0;
    echo "POOL is empty";
    condor_store_cred add -c -p `/etc/condor/passwords.d/passgen.py`;
    chmod 600 /etc/condor/passwords.d/POOL;
    condor_token_create -id condor@$SERVICE_FQDN -token condor.idtoken;
    ) 200>/etc/condor/passwords.d/POOL;
else
    echo "POOL is not empty";
fi;

grid-proxy-init -cert /etc/grid-security/hostcert.pem -key /etc/grid-security/hostkey.pem -valid 999:0;

until [[ -s /etc/condor/tokens.d/condor.idtoken ]]; do
    sleep 1;
done;