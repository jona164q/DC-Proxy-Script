#!/bin/bash
clear
MYSQLDB="squiddb"
MYSQLUSER="squid"
PASSWDMASTER="/etc/squid/squid.passwd"
PS3="Please enter your choice: "
options=("Create User" "Attach ip to user" "Show Proxies" "Delete proxy" "Block site" "unblock domain" "change proxy expiration" "Show users" "Delete user" "Made By Hollando#3086")
select opt in "${options[@]}"
do
    case $opt in
        "Create User")
            read -p "Enter Username: " username
            read -p "Enter Password: " password
            if [ -z "$username" ];then
                echo "Missing Input details"
            fi
            if [ -z "$password" ];then
                echo "Missing Input details"
            fi
            word3=$username
                cmd=$(grep -ci "$word3" /etc/squid/squid.passwd)
                if [ "$cmd" = "0" ]; then
            /usr/bin/htpasswd -b $PASSWDMASTER $username $password
                else
                    echo "Username already exist"
                    break
                fi
                echo $username >> "users.txt"
                echo $password > "${username}"
            ;;
        "Attach ip to user")
           read -p "Enter start ip: " IPADD
           read -p "Enter end ip: " IPADD2
           read -p "enter Port: " PORT
           FILE=/etc/squid/conf.d/${PORT}.conf
            if test -f "$FILE";then
                echo "port already exists"
                break
            else
                echo "port available"
            fi
           read -p "which user: " USERNAME
           PASSWORD=$(awk 'NR==1' $USERNAME)
           if [ -z "${IPADD}" ];then
                echo "Missing input"
                break
           if [ -z "${IPADD2}" ];then
                echo "Missing input"
                break
            fi
            if [ -z "${PORT}" ];then
                echo "Missing input"
                break
            fi
            if [ -z "${USERNAME}" ];then
                echo "Missing input"
                break
            fi

            else
                 st=$( echo $IPADD  | cut -d '.' -f4 )
                 en=$( echo $IPADD2 | cut -d '.' -f4 )
                 pre=$(echo $IPADD  | cut -d '.' -f1-3)

                for ((i=$st;i<=$en;i++))
                    do
                     ip=${pre}.${i}
                     echo "http_port $PORT name=${USERNAME}${PORT}
acl ${USERNAME}_${PORT} myportname ${USERNAME}${PORT}
acl $USERNAME proxy_auth $USERNAME
acl ${ip}_${PORT} myip $ip
tcp_outgoing_address $ip ${ip}_${PORT}
http_access allow $USERNAME ${ip}_${PORT} ${USERNAME}_${PORT}" >> "/etc/squid/conf.d/${PORT}.conf"

                       echo "${ip}:${PORT}:${USERNAME}:${PASSWORD}"

                       echo "${ip}:${PORT}:${USERNAME}:${PASSWORD}" >> proxies.txt
                 done
                fi
                systemctl restart squid
              ;;
        "Show Proxies")
            cat proxies.txt
        ;;
        "Delete proxy")
            read -p "Enter port of proxies you want to delete: " DELPORT
            if [ -z "${DELPORT}" ];then
                echo "Missing input"
                break
            fi
                sed -i '/'${DELPORT}'/d' proxies.txt
                rm -r /etc/squid/conf.d/${DELPORT}.conf
                systemctl restart squid
        ;;
        "Block site")
            read -p "Enter url: fx google.com: " URL
                echo "${URL}" >> '/etc/squid/blacklist.txt'
                systemctl restart squid
                echo "Site blocked"
        ;;
        "unblock domain")
            read -p "Enter url of domain: " domain
                sed -i '/'${domain}'/d' /etc/squid/blacklist.txt
                systemctl restart squid
                echo "Domain unblocked"
        ;;
        "change proxy expiration")
            read -p "Enter port of proxies: " EXPPORT
            if [ -z "${EXPPORT}" ];then
                echo "Missing input"
                break
            fi
            read -p "How many days should the proxy be live: " DAYS
            if [ -z "${DAYS}" ];then
                echo "Missing input"
                break
            fi
                at now +${DAYS} days <<< "sed -i '/'{EXPPORT}'/d' proxies.txt"
                at now +${DAYS} days <<< "rm -rf /etc/squid/conf.d/${EXPPORT}.conf"
                at now +${DAYS} days <<< "systemctl restart squid"
                at now +${DAYS} days <<< "sed -i '/^$/d' proxies.txt"
                at now +${DAYS} days <<< "echo 'Proxies expired'"
        ;;
        "Show users")
        cat users.txt
        ;;
        "Delete user")
        read -p "Enter username: " DELETEUSER
        if [ -z "${DELETEUSER}" ];then
                echo "Missing input"
                break
            fi
        read -p "Enter port: " PORT
        if [ -z "${PORT}" ];then
                echo "Missing input"
                break
            fi
        rm -r ${DELETEUSER}
        sed -i '/'${DELETEUSER}'/d' /etc/squid/squid.passwd
        sed -i '/'${DELETEUSER}'/d' users.txt
        sed -i '/'${DELETEUSER}'/d' proxies.txt
        rm -r /etc/squid/conf.d/${PORT}.conf
        systemctl restart squid
        ;;
        "Made By Hollando#3086")
        ;;
        *) echo "invalid option $REPLY";;
    esac
done
