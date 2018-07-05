#/bin/bash
# V=0.1 RubaOliva

# Lists
list[0]="bad.psky.me"
list[1]="bl.mailspike.net"
list[2]="b.barracudacentral.org"
list[3]="dnsrbl.org"
list[4]="dnsbl.sorbs.net"
list[5]="zen.spamhaus.org"
list[6]="ips.backscatterer.org"
list[7]="bl.blocklist.de"
list[8]="psbl.surriel.com"
list[9]="bl.spamcop.net"
list[10]="ubl.unsubscore.com"
list[11]="dnsbl.cobion.com"
list[12]="spam.dnsbl.sorbs.net"
list[13]="dnsbl-1.uceprotect.net"
list[14]="dnsbl-2.uceprotect.net"
list[15]="dnsbl-3.uceprotect.net"
list[16]="blacklist.rbl.interhost.com"

# Description Lists
listdesc[0]="<<Protected_Sky>> Go to http://bad.psky.me/check/?ip=$1"
listdesc[1]="<<Mailspike>> Go to http://mailspike.org/"
listdesc[2]="<<Barracuda>> Go to http://www.barracudanetworks.com/reputation/?r=1&ip=$1"
listdesc[3]="<<DNSRBL>> Go to http://dnsrbl.org/"
listdesc[4]="<<SORBS-BL>> Go to http://www.sorbs.net/lookup.shtml?$1"
listdesc[5]="<<Zen_Spamhaus>> Go to https://www.spamhaus.org/query/ip/$1"
listdesc[6]="<<Backscatterer>> Go to http://www.backscatterer.org/"
listdesc[7]="<<Blocklist.de>> Go to http://www.blocklist.de"
listdesc[8]="<<PSBL_Passive_Spam_Block>> Go to http://psbl.org/listing?ip="$1"&list=PSBL+list+query"
listdesc[9]="<<SPAMCOP>> Go to http://www.spamcop.net/bl.shtml?$1"
listdesc[10]="<<LASHBACK>> Go to http://blacklist.lashback.com/"
listdesc[11]="<<IBM>> Go to http://filterdb.iss.net/dnsblinfo/"
listdesc[12]="<<SORBS-SPAM>> Go to http://www.sorbs.net/lookup.shtml?$1"
listdesc[13]="<<UCEPROTECT Level 1>> Go to http://www.uceprotect.net/en/rblcheck.php?ipr=$1"
listdesc[14]="<<UCEPROTECT Level 2>> Go to http://www.uceprotect.net/en/rblcheck.php?ipr=$1"
listdesc[15]="<<UCEPROTECT Level 3>> Go to http://www.uceprotect.net/en/rblcheck.php?ipr=$1"
listdesc[16]="<<Interhost>> Go to http://sac.interhost.com"

function usage(){
echo -e '\nchkblacklist (c) RubaOliva \n\nUsage: ./chkblacklist <ip>\n'
exit 1
}
function log(){
# The first parameter is the error type (critical, warning or info) the second parameter is the error text
type=$1

if [ "$type" = "critical" ]
then
	printf "$(tput setaf 1)[CRITICAL] $2 $(tput setaf 7)"
elif [ "$type" = "warning" ]
then
	printf "$(tput setaf 3)[WARNING] $2 $(tput setaf 7)"
elif [ "$type" = "ok" ]
then
        printf "$(tput setaf 2)[OK] $2 $(tput setaf 7)"
elif [ "$type" = "info" ]
then
	printf "$(tput setaf 4)[INFO] $2 $(tput setaf 7)"
fi
}
function store_delist_advice(){
delist_advice[$2]=$1
}
function show_delist_advices(){
if ! [ -n "${delist_advice[*]}" ]
then
	printf  "\n\n$(log ok "Nice that IP is clean")"
else	
	for (( i = 0 ; i < ${#delist_advice[@]} ; i++))
	do
		if ! [ -n "${delist_advice[$i]}" ]
		then
			r="r"
		else	
			printf "\n$(log info "${delist_advice[$i]}")"
		fi
	done
fi
}

function check(){
listed=0
if [ -n "$1" ]
then
	ip=$1
	ipreverse=$(echo ${ip[i]} | awk 'BEGIN{FS="."};{print $4"."$3"."$2"."$1}')
	for (( i = 0 ; i < ${#list[@]} ; i++))
        do
        	out=$(dig $ipreverse.${list[$i]} +short)
		if ! [ -n "$out" ]
		then
			anwser=$(echo -e "${list[$i]}")
			log=$(log ok "NoT_Listed")
			printf "\n%-30s %50s" "$anwser" "$log"
			store_delist_advice "" "$i"
		else
			anwser=$(echo $(tput setaf 1)"${list[$i]}")
			log=$(log critical "Listed")
			printf  "\n%-30s %55s" "$anwser" "$log"
			store_delist_advice "${listdesc[$i]}" "$i"
			listed=1
		fi
	done
else
	echo -e "\n"
	log info "\t\t\t\tNeed it an ip for working"
	echo -e "\n"
	usage
fi
}

tput bold
tput setaf 7
check $1
if [ $listed = 1 ]
then
	printf "\n\n$(log critical "Your IP is blacklisted")"
	printf "\n\n$(log info "Follow the next URL for delist your IP")"
	show_delist_advices
	echo -e "\n"
else
	printf  "\n\n$(log ok "Nice that IP is clean")"
	echo -e "\n"
fi
