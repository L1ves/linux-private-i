#!/bin/bash

noco='\033[0m'
blk='\033[0;30m'
red='\033[0;31m'
grn='\033[0;32m'
blu='\033[0;34m'
purp='\033[0;35m'
cyn='\033[0;36m'
gray='\033[00;37m'
wht='\033[01;37m'
yel='\033[01;33m'

brk=$(echo -e ${blu}"----------------------------------------------------------------------"${noco})

pi_version=$(echo -e ${cyn}"v1.0"${noco})

title=$(
	echo "$brk"
	echo -e "${blu}--------------------------${cyn}Linux Private-i${blu}-----------------------------${noco}"
	echo "$brk")

echo "$title"

###########################
####### FUNCTIONS #########
###########################

#==========
# Basic OS
#==========

f_os() { os=$(cat /etc/lsb-release |grep "DESCRIPTION" |cut -d '=' -f2 |tr -d '"'); echo "$os"; }

f_krel() { krel=$(uname -r); echo "$krel"; }

#=================
# Basic Networking
#=================

f_ifconfig() { interface=$(/sbin/ifconfig |grep -v TX |grep -v RX); echo "$interface"; }

f_netantp() { net_antp=$(netstat -antp); echo "$net_antp"; }

f_nettul() { net_tul=$(netstat -tul); echo "$net_tul"; }

#======
# More
#======

f_shadow_world() {
	perm_shadow=$(ls -la /etc/shadow |cut -c 7-10)
	case "$perm_shadow" in
		rw*)
		   echo "$yes - /etc/shadow is World R & W"
		   ;;
		*r*)
		   echo "$yes - /etc/shadow is World-Readable"
	   	   ;;
		*w*)
		   echo "$yes - /etc/shadow is World-Writable"
		   ;;
		*)
		   echo "$no - /etc/shadow is neither world readable nor writable"
		   ;;
	   	esac
}


f_pass_world() {
	perm_pass=$(ls -la /etc/passwd |cut -c 7-10)
	case "$perm_pass" in
		rw*)
		   echo "$yes - /etc/passwd is World R & W"
		   ;;
		*r*)
		   echo "$no - /etc/passwd is World-Readable"
	   	   ;;
		*w*)
		   echo "$yes - /etc/passwd is World-Writable"
		   ;;
		*)
		   echo "$no - /etc/passwd is neither world readable nor writable"
		   ;;
	   	esac
}


f_sudo_world() {
	perm_sudoers=$(ls -la /etc/sudoers |cut -c 7-10)
	case "$perm_sudoers" in
		rw*)
		   echo "$yes - /etc/sudoers is World R & W"
		   ;;
		*r*)
		   echo "$yes - /etc/sudoers is World-Readable"
	   	   ;;
		*w*)
		   echo "$yes - /etc/sudoers is World-Writable"
		   ;;
		*)
		   echo "$no - /etc/sudoers is neither world readable nor writable"
		   ;;
	   	esac
}

f_conf_world() {
	perm_conf=$(find /etc -type f \( -perm -o+w \) -exec ls -adl {} \; 2> /dev/null)

	     if [ -z "$perm_conf" ]; then
		   echo "$no - Nothing in /etc/ is World Writable"
	     else
		   echo "$yes - Found something in /etc/ that's World-Writable"
		   echo -e ${purp}"      $perm_conf"${noco}
	     fi

}

f_mail_world() {
	perm_mail=$(ls -l /var/mail/ |cut -c 7-10)
	case "$perm_mail" in
		rw*)
		   echo "$yes - Mail in /var/mail/ is World R & W"
		   ;;
		*r*)
		   echo "$yes - Mail in /var/mail/ is World-Readable"
	   	   ;;
		*w*)
		   echo "$yes - Mail in /var/mail/ is World-Writable"
		   ;;
		*)
		   echo "$no - Mail in /var/mail/ is neither world readable nor writable"
		   ;;
	   	esac
}

f_log_world(){
                la=$(ls -l /var/log |awk '/syslog$/')
                lb=$(ls -l /var/log |awk '/auth.log$/')
		lc=$(ls -l /var/log |awk '/messages$/')
		ld=$(ls -l /var/log |awk '/secure$/')
		le=$(ls -l /var/log |awk '/mail.log$/')
		lf=$(ls -l /var/log |awk '/maillog$/')

                test=("$la" "$lb" "$lc" "$ld" "$le" "$lf")
                for i in "${test[@]}"; do
                   if [ -z "$i" ]; then
                        :
                   else
                    iy=$(echo "$i" |rev |cut -d ' ' -f1 |rev)
                    iz=$(echo "$i" |cut -c 7-10)
                        case "$iz" in
                        rw*)
                           echo "$yes - $iy is World R and W"
                           ;;
                        *r*)
                           echo "$yes - $iy is World-Readable"
                           ;;
                        *w*)
                           echo "$yes - $iy is World-Writable"
                           ;;
                        *)
                           echo "$no - $iy is neither world readable nor writable"
                           ;;
                        esac

                   fi
                done

}


f_ssh_world(){
                sa=$(ls -l /etc |awk '/ssh$/')
		if [ -z "$sa" ]; then
			:
		else
                  sb=$(ls -l /etc/ssh |awk '/ssh_host_rsa_key$/')
		  sc=$(ls -l /etc/ssh |awk '/ssh_host_ed25519_key$/')
		  sd=$(ls -l /etc/ssh |awk '/ssh_host_ecdsa_key$/')
		  se=$(ls -l /etc/ssh |awk '/ssh_host_dsa_key$/')

                  test=("$sb" "$sc" "$sd" "$se")
                  for i in "${test[@]}"; do
                     if [ -z "$i" ]; then
                        :
                     else
                     	  iy=$(echo "$i" |rev |cut -d ' ' -f1 |rev)
                          iz=$(echo "$i" |cut -c 7-10)
                          case "$iz" in
                          rw*)
                             echo "$yes - $iy is World R and W"
                             ;;
                          *r*)
                             echo "$yes - $iy is World-Readable"
                             ;;
                          *w*)
                             echo "$yes - $iy is World-Writable"
                             ;;
                          *)
                             echo "$no - $iy is neither world readable nor writable"
                             ;;
                          esac

                     fi
                  done
		fi
	
		sz=$(ls -la ~/ |awk '/.ssh$/')
		if [ -z "$sz" ]; then
			echo "$no - No .ssh directory found in home"
		else
			sx=$(echo "$sz" |cut -c 7-10)
			case "$sx" in
                        rw*)
                           echo "$yes - ~/.ssh is World R and W"
                           ;;
                        *r*)
                           echo "$yes - ~/.ssh is World-Readable"
                           ;;
                        *w*)
                           echo "$yes - ~/.ssh is World-Writable"
                           ;;
                        *)
                           echo "$no - ~./ssh is neither world readable nor writable"
                           ;;
                        esac

		fi
}


f_passwd_search(){
	passwd_search=("/var/www/" "/var/apache2/" "/var/log/" "/home/" "/opt")
    	  for i in "${passwd_search[@]}"; do
	    iv=$(grep -iRl "password" "${i}" 2>/dev/null)
	     if [ -z "$iv" ]; then
		   echo "$no - No passwords observed in: "$i" "
	     
	     else
		   echo "$yes - Found 'password' string in "$i" "
	     	   echo -e ${purp}"$iv"${noco}
	     fi
	  done

}


##############
#### Apps ####
##############


f_wp_perm(){

	ipres=$(ls -l $wp_p |cut -c 7-10 2>/dev/null)
              	case "$ipres" in
               	   rw*)
                        echo "      $yes wp-config.php is World R and W"
		        f_wp_pass;;
                   *w*)
                	echo "      $yes wp-config.php is World-Writable"
			f_wp_pass;;
		   *r*)
			echo "      $yes wp-config.php is World-Readable"
			f_wp_pass;;
              	   *)
              		echo "      $no wp-config.php is neither world readable nor writable";;
                     	esac
}

f_wp_pass(){
	
	wp_db=$(find $wp_p -exec grep 'DB_PASSWORD' {} \; 2>/dev/null)
	if [ -z "$wp_db" ]; then echo "          $no Unable to find a DB_PASSWORD entry in wp-config.php";else
	   echo "          $yes Found DB_PASSWORD entry in wp-config.php"
	   echo -e ${yel}"              $wp_db"
   	fi

	wp_ftp=$(find $wp_p -exec grep 'FTP_PASS' {} \; 2>/dev/null)
	if [ -z "$wp_ftp" ];then echo "          $no Unable to find a FTP_PASSWORD entry in wp-config.php";else
	   echo "          $yes Found FTP_PASSWORD entry in wp-config.php"
	   echo -e ${yel}"              $wp_ftp"
   	fi

}


f_wp(){
	c_wp=$(find /var/www/ -name 'wp-config.php' 2>/dev/null)
	if [ -z $c_wp ];then
		c_wpa=$(find /usr/share/nginx/ -name 'wp-config.php' 2>/dev/null)
	   	if [ -z $c_wpa ];then
			c_wpb=$(find /opt/ -name 'wp-config.php' 2>/dev/null)
			if [ -z $c_wpb ];then 
			   echo "$no - Unable to confirm if WordPress is installed";else
			   wp_p=$(echo "$c_wpb")
			   echo "$yes - WordPress is installed"
			   f_wp_perm
			fi
		else
			wp_p=$(echo "$c_wpa")
			echo "$yes - WordPress is installed"
			f_wp_perm
		fi
	else
		wp_p=$(echo "$c_wp")
		echo "$yes - WordPress is installed"
		f_wp_perm
	fi

}



f_tc_pass(){
	tx=$(find /etc/tomcat*/tomcat*-users.xml -exec grep "password=" {} \; 2>/dev/null)
	tf=$(echo "$tx" |grep -v "must-be") 
	if [ -z "$tf" ]; then echo "          $no Unable to find a unique 'password' in tomcat-users.xml";else
	   echo "          $yes Found unique 'password' string in tomcat-users.xml"
	   echo -e ${yel}"              $tf"
   	fi
}

f_smb(){
	smb_ck=$(ls /etc |grep -wi samba)
	if [ -z "$iv" ]; then
	  echo "$no - Unable to confirm if Samba is installed";else
	  echo "$yes - Samba is installed"
	  smb_v=$(samba -V 2>/dev/null)
	  echo "      $yes $smb_v"

	fi

}


f_basic_apps(){
	basic_apps=("Samba" "Perl" "Ruby" "Python" "Netcat")
    	  for i in "${basic_apps[@]}"; do
	    iv=$(
	    ls /bin |grep -wi "$i"
	    ls /usr/bin |grep -wi "$i"
	    ls /usr/sbin |grep -wi "$i"
	    ls /sbin |grep -wi "$i"
	    ls /etc |grep -wi "$i"
	    )
	     if [ -z "$iv" ]; then
		   echo "$no - Unable to confirm if "$i" is installed"
	     else
		   echo "$yes - "$i" is installed"
	     fi
	  done

}

f_adv_apps(){
	
	tomcat=$(ls /etc/ |grep '\<tomcat.*\>' 2</dev/null)
	#test this
	apache=$(ls /etc/ |grep '\<apache.*\>' 2</dev/null)
	adv_apps=("Apache" "HTTPD" "$tomcat" "Netcat" "Perl" "Ruby" "Python" "Netcat")
    	  for i in "${adv_apps[@]}"; do
	    iv=$(
	    ls /bin |grep -wi "$i"
	    ls /usr/bin |grep -wi "$i"
	    ls /usr/sbin |grep -wi "$i"
	    ls /sbin |grep -wi "$i"
	    ls /etc |grep -wi "$i"
	    )
	     if [ -z "$iv" ]; then
		   echo "$no - Unable to confirm if "$i" is installed"
	     else
		   echo "$yes - "$i" is installed"
		   case "$i" in
			Apache)
				a2=$(ls -l /etc/apache2 2>/dev/null)
				a1=$(ls -l /etc/apache 2>/dev/null)

				if [ -z $a1 ];then echo "      $no Unable to find 'Apache'";else
					echo "      $yes Found 'Apache'"
				fi
				if [ -z "$a2" ];then echo "      $no Unable to find 'Apache2'";else
					echo "      $yes Found 'Apache2'"
				fi

			;;

			HTTPD)
				hd=$(ls -l /etc/httpd 2>/dev/null)


			;;
			tomcat*)
				icat=$(ls -l /etc/tomcat*/tomcat*-users.xml |cut -c 7-10 2>/dev/null)
                          	case "$icat" in
                          	   rw*)
                             	   	echo "      $yes - tomcat-users.xml is World R and W"
					f_tc_pass;;
                          	   *w*)
                             		echo "      $yes - tomcat-users.xml is World-Writable"
					f_tc_pass;;
				   *r*)
					echo "      $yes - tomcat-users.xml is World-Readable"
					f_tc_pass;;
                          	   *)
                             		echo "      $no - tomcat-users.xml is neither world readable nor writable";;
                          	   esac
			;;

			


		   esac
	     fi
	   done
	   f_wp
	   f_smb
}

##################
#### DATABASE ####
##################
#defining IFS is not portable.
f_co_pass(){
	cx=$(find /etc/couchdb/local.ini -exec grep pbkdf2 {} \; 2>/dev/null)
	IFS=$'\n'

	if [ -z "$cx" ]; then echo "          $no Unable to find user or hashed password in local.ini";else
	  for f in $cx;do
   	     echo "          $yes Found user & hashed password in local.ini"
	     echo -e ${yel}"              $f"
	  done
   	fi
}


f_re_pass(){
	rx=$(find /etc/redis/redis.conf -exec grep "requirepass" {} \; 2>/dev/null)
	rf=$(echo "$rx" |grep -v "#")
        IFS=$'\n'	
	if [ -z "$rf" ]; then echo "          $no Unable to find a unique 'password' in tomcat-users.xml";else
	  for f in $rf;do
	    echo "          $yes Found in-use 'requirepass' string in redis.conf"
	    echo -e ${yel}"              $f"
	  done
   	fi
}

f_mon_auth(){
	mx=$(find /etc/mongodb.conf -exec grep "auth = true" {} \; 2>/dev/null)
	mf=$(echo "$mx" |grep -v "#")
        IFS=$'\n'	
	if [ -z "$mf" ]; then echo "          $yes It seems Auth is NOT Enabled in mongodb.conf";else
	  for f in $mf;do
	    echo "          $no It seems Auth is Enabled in mongodb.conf"
	    echo -e ${yel}"              $f"
	  done
   	fi
}


f_db_apps(){
	sqlite_v=$(ls /usr/bin/ |grep '\<sqlite.*\>' 2</dev/null)
	if [ -z "$sqlite_v" ];then echo "$no - Unable to confirm if "$i" is installed";else
		echo "$yes - SQLite version(s) are installed"
		for i in $sqlite_v;do
		   if [ "$i" = "sqlite" ];then
			   lite_v=$(sqlite -version 2>/dev/null)
			   echo "      $yes SQLite is installed"
			   echo "            $yes Version:$lite_v"
		   elif [ "$i" = "sqlite3" ];then
			   lite_v=$(sqlite3 --version 2>/dev/null)
			   echo "      $yes SQLite3 is installed"
			   echo "            $yes Version: $lite_v"
		   elif [ "$i" = "sqlitebrowser" ];then
			   echo "      $yes SQLiteBrowser is installed"
		   else
			   "$no - Unable to confirm what SQLite versions are installed"
			   echo ${purp}"      $sqlite_v"${noco}
		   fi
		done
	fi
			


	db_apps=("PostgreSQL" "MySQL" "MariaDB" "MongoDB" "Oracle" "Redis" "CouchDB")
          for i in "${db_apps[@]}"; do
	    iv=$(
	    ls /bin |grep -wi "$i"
	    ls /usr/bin |grep -wi "$i"
	    ls /usr/sbin |grep -wi "$i"
	    ls /sbin |grep -wi "$i"
	    ls /etc |grep -wi "$i"
	    )
	     if [ -z "$iv" ]; then
		   echo "$no - Unable to confirm if "$i" is installed"
	     else
		   echo "$yes - "$i" is installed"
		   case "$i" in
			PostgreSQL)
				   pver=$(psql -V 2>/dev/null |cut -d ' ' -f3)
				   if [ -z $pver ];then echo "      $no - Unable to find PostgreSQL version";else
				        echo "      $yes Postgres Version: $pver"
				   fi
				   igres=$(ls -l /etc/postgresql/*/*/pg_hba.conf |cut -c 7-10 2>/dev/null)
                          	   case "$igres" in
                          	   rw*)
                             	   	echo "      $yes Postgres pg_hba.conf is World R and W";;
                          	   *w*)
                             		echo "      $yes Postgres pg_hba.conf is World-Writable";;
                          	   *)
                             		echo "      $no Postgres pg_hba.conf is not World-Writable";;
                          	   esac
			;;

			MySQL)
				   imy=$(ls -l /etc/mysql/my.cnf |cut -c 7-10 2>/dev/null)
                         	   case "$imy" in
                          	   rw*)
                             	   	echo "      $yes /etc/mysql/my.cnf is World R and W";;
                          	   *r*)
                             		echo "      $yes /etc/mysql/my.cnf is World-Readable";;
                          	   *w*)
                             		echo "      $yes /etc/mysql/my.cnf is World-Writable";;
                          	   *)
                             		echo "      $no /etc/mysql/my.cnf is neither world readable nor writable";;
                          	   esac
				
				   echo -e ${cyn}"      Searching for other my.cnf file versions"${noco}
				   fmy=$(find /home -name 'my.cnf' -exec ls -l {} \; 2>/dev/null)
				   fmy2=$(find ~/ -name 'my.cnf' -exec ls -l {} \; 2>/dev/null)
				   if [ -z "$fmy" ];then echo "      $no Unable to find/read file 'my.cnf' in /home";else
					   nmy=$(echo "$fmy" |rev |cut -d ' ' -f1 |rev)
					   echo "      $yes Found my.cnf in /home"
					   for f in $nmy;do
					   	echo -e ${purp}"          $f"${noco}
					   	fmy_pa=$(find $f -exec grep password {} \; 2>/dev/null)
					   	if [ -z $fmy_pa ]; then echo "          $no Unable to find/read 'password' in above my.cnf file";else
						   echo "          $yes Found string 'password' in above my.cnf file"
						   echo -e ${yel}"              $fmy_pa"
					   	fi
					   done
				   fi
				   
				   if [ -z "$fmy2" ];then echo "      $no Unable to find/read file 'my.cnf' in ~/";else
					   nmy2=$(echo "$fmy2" |rev |cut -d ' ' -f1 |rev)
					   echo "      $yes Found my.cnf in ~/"
					   for f in $nmy2;do
					   	echo -e ${purp}"          $f"${noco}
						fmy2_pa=$(find $f -exec grep password {} \; 2>/dev/null)
						if [ -z $fmy2_pa ]; then echo "           $no Unable to find/read 'password' in above my.cnf file";else
							echo "          $yes Found string 'password' in above my.cnf file"
							echo -e ${yel}"              $fmy2_pa"
						fi
					   done
				   fi
			;;
			
			CouchDB)

				   ico=$(ls -l /etc/couchdb/local.ini |cut -c 7-10 2>/dev/null)
                         	   case "$ico" in
                          	   rw*)
                             	   	echo "      $yes /etc/couchdb/local.ini is World R and W"
					f_co_pass;;
                          	   *r*)
                             		echo "      $yes /etc/couchdb/local.ini is World-Readable"
					f_co_pass;;
                          	   *w*)
                             		echo "      $yes /etc/couchdb/local.ini is World-Writable";;
                          	   *)
                             		echo "      $no /etc/couchdb/local.ini is neither world readable nor writable";;
                          	   esac
			;;	

			Redis)

				   ire=$(ls -l /etc/redis/redis.conf |cut -c 7-10 2>/dev/null)
                         	   case "$ire" in
                          	   rw*)
                             	   	echo "      $yes /etc/redis/redis.conf is World R and W"
					f_re_pass;;
                          	   *r*)
                             		echo "      $yes /etc/redis/redis.conf is World-Readable"
					f_re_pass;;
                          	   *w*)
                             		echo "      $yes /etc/redis/redis.conf is World-Writable";;
                          	   *)
                             		echo "      $no /etc/redis/redis.conf is neither world readable nor writable";;
                          	   esac
			;;

			MongoDB)

				   imo=$(ls -l /etc/mongodb.conf |cut -c 7-10 2>/dev/null)
                         	   case "$imo" in
                          	   rw*)
                             	   	echo "      $yes /etc/mongo.conf is World R and W"
					f_mon_auth;;
                          	   *r*)
                             		echo "      $yes /etc/mongo.conf is World-Readable"
					f_mon_auth;;
                          	   *w*)
                             		echo "      $yes /etc/mongo.conf is World-Writable";;
                          	   *)
                             		echo "      $no /etc/mongo.conf is neither world readable nor writable";;
                          	   esac
			;;
		   esac
	     fi
	   done

}

##################
###  Mail Apps  ##
##################

when_doves_cry(){
	dopas=$(grep -r "PLAIN" /etc/dovecot 2>/dev/null)
	if [ -z "$dopas" ];then echo "      $no Unable to find/read any plain text creds within /etc/dovecot";else
	   for d in $dopas;do
		df=$(echo $d |cut -d ':' -f1)
		dp=$(echo $d |cut -d ':' -f2-)
		echo "      $yes Found possible PLAIN text creds in $df"
		echo -e ${yel}"          $dp"
	   done
	fi	
}


f_mail_apps(){
	mail_apps=("Postfix" "Dovecot" "Exim" "SquirrelMail" "Cyrus" "Sendmail" "Courier")

          for i in "${mail_apps[@]}"; do
	    iv=$(
	    ls /bin |grep -wi "$i"
	    ls /usr/bin |grep -wi "$i"
	    ls /usr/sbin |grep -wi "$i"
	    ls /sbin |grep -wi "$i"
	    ls /etc |grep -wi "$i"
	    )
	    if [ -z "$iv" ]; then
		   echo "$no - Unable to confirm if "$i" is installed"
	     else
		   echo "$yes - "$i" is installed"
		   case "$i" in
			Exim)
				exver=$(exim -bV |sed -n '1p' 2>/dev/null)
				if [ -z "$exver" ];then echo "    $no Unable to confirm Exim version";else
					echo "      $yes $exver"
				fi
			;;
			
			Postfix)
				pover=$(postconf -d mail_version)
				if [ -z "$pover" ];then echo "    $no Unable to confirm Postfix version";else
					echo "      $yes $pover"
				fi
			
			;;

			Dovecot)
				dover=$(dovecot --version 2>/dev/null)
				if [ -z "$dover" ];then echo "    $no Unable to confirm Dovecot version";else
					echo "      $yes Version: $dover"
					when_doves_cry
				fi
			;;

		   esac
	    fi
	 done
}

pea=$(echo -e "${cyn}Full Scope${noco}		- Non-Targeted approach with verbose results")
peb=$(echo -e "${cyn}Quick Canvas${noco}		- Brief System Investigation")
pec=$(echo -e "${cyn}Sleuths Special${noco}	- Search for unique perms, sensitive files, passwords, etc")  
ped=$(echo -e "${cyn}Kernel Tip-off${noco}	- Lists possible Kernel exploits")

priv=("$pea" "$peb" "$pec" "$ped")

no=$(echo -e "${red}[-]${noco}")
yes=$(echo -e "${grn}[+]${noco}")

prompt="Selection: "
PS3="$prompt"

select opt in "${priv[@]}" "Exit"; do
	case "$REPLY" in	

	1) 
	   echo "$brk"
	   echo -e "${gray}   ,--..${red}Y   ${noco}"
	   echo -e "${gray}   \   /'.  ${noco}   Running ${cyn}Full Scope ${noco}Investigation" 
	   echo -e "${gray}    \.    \ ${noco}"
	   echo -e "${gray}     '''--' ${noco}							$pi_version"
	   echo "$brk"
	   echo -e "${blu}-----------------------------${cyn}OS info${blu}----------------------------------${noco}"
	   f_os
	   f_krel
	   whoami
	   id
	   echo -e "${cyn}\nSuper users${noco}"
	   awk -F: '($3 == "0") {print}' /etc/passwd
	   echo -e ${blu}-------------------------${cyn}Vital Quick Checks${blu}---------------------------${noco}
	   f_pass_world
	   f_shadow_world
	   f_sudo_world
	   f_mail_world
	   f_conf_world
	   echo -e ${cyn}/var/log/ Detection${noco}
	   f_log_world
	   echo -e ${blu}-------------------------${cyn}Application Research${blu}--------------------------${noco}
	   f_adv_apps
	   echo -e "${blu}\n----------------------------${cyn}SSH Info${blu}----------------------------------${noco}"
	   f_ssh_world
	   echo -e "${blu}\n----------------------------${cyn}Database${blu}----------------------------------${noco}"
	   f_db_apps
	   echo -e "${blu}\n----------------------------${cyn}Mail${blu}----------------------------------${noco}"
	   f_mail_apps
	   echo -e "${blu}---------------------------${cyn}Networking${blu}---------------------------------${noco}"
	   echo -e ${cyn}ifconfig${noco}
	   f_ifconfig
	   echo "$brk"
	   echo -e ${cyn}TCP and UDP${noco}
	   f_netantp
	   f_nettul
	   echo -e "${blu}-----------------------------${cyn}Misc.${blu}-----------------------------------${noco}"
	   echo -e ${cyn}Bash history - tail${noco}
	   tail ~/.bash_history
	   echo -e "${blu}\n-----------------------------${cyn}Crontab${blu}-----------------------------------${noco}"
	   cat /etc/crontab |grep -v '#'
	   echo -e "${blu}\n---------------------------${cyn}Mount Info${blu}---------------------------------${noco}"
	   df -h
	   echo -e "${cyn}\nfstab${noco}"
	   cat /etc/fstab |grep -v '#'	   
	   echo -e "${blu}---------------------${cyn}Do Your Due Diligence${blu}----------------------------${noco}"
	   exit;;

	2) 
	   echo "$brk"
	   echo -e "${red}         ____   _____${noco}"
	   echo -e "${red}   _..-'     'Y'      '-.${noco}"
	   echo -e "${red}    \ ${gray}Dossier:${red} | ~~ ~ ~  /${noco}    Running ${cyn}Quick Canvas${noco}"
	   echo -e "${red}    \\  ${wht}LINUX${red}   | ~ ~ ~~ //${noco}"
	   echo -e "${red}     \\ _..---. |.--.._ //					$pi_version"
	   echo "$brk"

	   echo -e "${blu}---------------------------${cyn}Basic OS info${blu}------------------------------${noco}"
	   f_os
	   f_krel
	   whoami
	   id
	   echo -e "${blu}-----------------------------${cyn}Networking${blu}-------------------------------${noco}"
	   echo -e ${cyn}ifconfig${noco}
	   f_ifconfig
	   echo "$brk"
	   echo -e ${cyn}TCP and UDP....${noco}
	   f_netantp
	   f_nettul
	   echo -e ${blu}-----------------${cyn}File, Directory and App Quick Checks${blu}------------------${noco}
	   echo -e ${cyn}Vital checks${noco}
	   f_pass_world
	   f_shadow_world
	   f_sudo_world
	   f_mail_world
	   f_conf_world
	   echo -e ${cyn}Log Detection${noco}
	   f_log_world
	   echo -e ${cyn}Quick App Research${noco}
	   f_basic_apps
	   echo -e "${blu}---------------------${cyn}Do Your Due Diligence${blu}----------------------------${noco}"
	   exit;;

	3) 
           echo "$brk"   
	   echo -e "  _________" 
	   echo -e " ||${red}  TOP ${noco} ||      ('^-'-/^).___..---'-'-._"
	   echo -e " ||${red} SECRET${noco}||      '${grn}6${noco}_ ${grn}6${noco}  )   '-.  (     ).'-.__.')" 
	   echo -e " ||_______||      (_${purp}Y${noco}_.)'  ._   )  '._ '. '--..-'" 
	   echo -e " |${gray}  _____${noco}  |    _..${wht}'${noco}--${wht}'${noco}_..-_/  /--'_.' ,' "
	   echo -e " | ${gray}|  |_||${noco} |  (il),-''  (li),'  ((!.-'   Running the ${cyn}Sleuths Special${noco}"
	   echo -e " '-${gray}|_____|${noco}-'                                                    $pi_version"
	   echo "$brk"
	   echo -e ${blu}--------------------------${cyn}Detecting R or W Logs${blu}-----------------------${noco}
	   f_log_worl
	   echo -e ${blu}-------------------------------${cyn}Vital Checks${blu}----------------------------${noco}
	   f_pass_world
	   f_shadow_world
	   f_sudo_world
	   f_mail_world

	   echo -e "${blu}--------------------${cyn}World-Writable Directories${blu}------------------------${noco}"
	   echo -e "${cyn}PLEASE STAND BY ...${noco}"
	   find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print 2> /dev/null |grep -v vmware

	   echo -e "${blu}----------------------${cyn}World-Writable Files${blu}----------------------------${noco}"
	   find / -xdev -type f \( -perm -0002 -a ! -perm -1000 \) -print 2> /dev/null |grep -v vmware

	   
	   echo -e "${blu}----------${cyn}Searching string 'password' in common areas${blu}-----------------${noco}"
	   f_passwd_search
	   echo -e "${blu}---------------------${cyn}Do Your Due Diligence${blu}----------------------------${noco}"
	   exit;;

	4)
	   echo "$brk"
	   echo -e "${gray}         ,--.${yel}!,"${noco}
	   echo -e "${gray}       __/   ${yel}-*-"${noco}
	   echo -e "${gray}     ,d08b.  ${yel}'|'${noco}    Running ${cyn}Kernel Tip-off${noco} "
	   echo -e "${gray}     0088MM     "${noco}
	   echo -e "${gray}     '9MMP'     						$pi_version"
	   echo "$brk"
	   
	   kern=$(uname -r |cut -d '.' -f1-2) 
	   sploits=(	   
	   "PE -- Linux Kernel < 4.10 4.10.6 -- AF_PACKET CVE-2017-7308"
	   "PE -- Linux Kernel 4.3.3 Ubuntu 14.04 15.10 -- overlayfs CVE-2015-8660"
	   "PE -- Linux Kernel 2.6.22 < 3.9 -- Dirty Cow CVE-2016-5195"
	   "PE -- Linux Kernel 2.4/5.3 CentOS RHEL 4.8/5.3 -- ldso_hwcap CVE-2017-1000370"
	   "PE -- Linux Kernel 2.6 2.4 Ubuntu 8.10 -- sock_sendpage() CVE-2009-2692"
	   "PE -- Linux Kernel 2.6 3.2 Ubuntu  -- mempodipper"
	   "PE -- Linux Kernel 2.6 Debian 4.0 -- Ubuntu UDEV < 1.4.1"
	   "PE -- Linux Kernel 3.13 3.16 3.19 Ubuntu 12.04 14.04 14.10 15.04 -- overlayfs CVE-2015-1328"
 	   "PE -- Linux Kernel < 3.15.4 -- ptrace CVE-2014-4699"
	   "PE -- Linux Kernel < = 2.6.37 2.6 RHEL / Ubuntu 10.04 -- Full-Nelson CVE-2010-3849"
	   "PE -- Linux Kernel 2.6.0 < 2.6.36 2.6 RHEL -- compat CVE-2010-3081"
	   "PE -- Linux Kernel 2.6.8 < 2.6.16 2.6 -- h00lyshit CVE-2006-3626"
	   "PE -- Linux Kernel 2.44 < 2.4.37 & 2.6.15 < 2.6.13 2.4 2.6 -- pipe.c CVE-2009-3547"
	   "PE -- Linux Kernel 2.6.0 < 2.6.36 2.6 Ubuntu 9.10 10.04 -- half-nelson CVE-2010-4073"
	   "PE -- Linux Ubunutu 9.04 Debian 4.0-- pulseaudio CVE-2009-1894"
   	   )

	   echo -e "${blu}-----------------${cyn}Listing ${kern} Kernel Exploits${blu}-------------------------${noco}"
	   echo -e "${blu}---------------------${cyn}Do Your Due Diligence${blu}----------------------------${noco}"
	   for i in "${sploits[@]}"; do
             if [[ "$i" != *"$kern"* ]]; then
		:
	     else
		echo "$i"
             fi
	   done

	   
	   exit;;



   $(( ${#priv[@]}+1 )) ) echo "...."; exit;;
   *) echo "Invalid"; continue;;

   esac
done
