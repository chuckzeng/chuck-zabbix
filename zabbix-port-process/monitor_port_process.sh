#!/bin/bash
#function:monitor linux port status from zabbix
#mail:zck91@163.com
#version date:2024-03-06

linux.proc.discovery(){
proc=($(cat /etc/zabbix/scripts/proc.txt | grep -v "^#" | awk '{print $1}'))
proc_num=($(cat /etc/zabbix/scripts/proc.txt | grep -v "^#" | awk '{print $2}'))

printf '{\n'
printf '\t"data":[\n'
 for ((i=0;i<${#proc[@]};++i))
 {
    num=$(echo $((${#proc[@]}-1)))
    if [ "$i" != ${num} ];
    then
       printf "\t\t{ \n"
       printf "\t\t\t\"{#PROCNAME}\":\"${proc[$i]}\",\n"
       printf "\t\t\t\"{#PROC_NUM}\":\"${proc_num[$i]}\"},\n"
    else
       printf "\t\t{ \n"
       printf "\t\t\t\"{#PROCNAME}\":\"${proc[$num]}\",\n"
       printf "\t\t\t\"{#PROC_NUM}\":\"${proc_num[$num]}\"}]}\n"
    fi
}
}

linux.port.discovery(){
host=($(cat /etc/zabbix/scripts/port.txt | grep -v "^#" | awk '{print $1}'))
port=($(cat /etc/zabbix/scripts/port.txt | grep -v "^#" | awk '{print $2}'))

printf '{\n'
printf '\t"data":[\n'
 for ((i=0;i<${#host[@]};++i))
 {
    num=$(echo $((${#host[@]}-1)))
    if [ "$i" != ${num} ];
    then
       printf "\t\t{ \n"
       printf "\t\t\t\"{#HOST}\":\"${host[$i]}\",\n"
       printf "\t\t\t\"{#PORT}\":\"${port[$i]}\"},\n"
    else
       printf "\t\t{ \n"
       printf "\t\t\t\"{#HOST}\":\"${host[$num]}\",\n"
       printf "\t\t\t\"{#PORT}\":\"${port[$num]}\"}]}\n"
    fi
}
}

case $1 in
	port_discovery)
		linux.port.discovery
		;;
	proc_discovery)
		linux.proc.discovery
		;;
	tcp_connect_total)
		netstat -tunlpa | awk '{print $4}' | grep ":$2$" | wc -l	
		;;
	tcp_connect_established)
		netstat -tunlpa | grep ESTABLISHED | awk '{print $4}' | grep ":$2$" | wc -l
		;;
	tcp_connect_close_wait)
		netstat -tunlpa | grep CLOSE_WAIT | awk '{print $4}' | grep ":$2$" | wc -l
		;;
	tcp_connect_time_wait)
		netstat -tunlpa | grep TIME_WAIT | awk '{print $4}' | grep ":$2$" | wc -l
		;;
	proc_num)
		ps aux | grep $2 | grep -v grep  | grep -v $0 | wc -l
		;;
	proc_mem_util)
		ps aux | grep $2 | grep -v grep | awk '{sum+=$4};END{print sum}'
		;;
	proc_cpu_util)
		ps aux | grep $2 | grep -v grep | awk '{sum+=$3};END{print sum}'
		;;
	*)
		echo "bash $1 {port_discovery,tcp_connect_total,proc_discovery,tcp_connect_established,tcp_connect_close_wait,proc_num,proc_cpu_util,proc_mem_util}"
		;;
esac
