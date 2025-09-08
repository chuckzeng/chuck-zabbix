#!/bin/bash

# 配置参数
ES_HOST="xxxx:9200"    # ES 地址
INDEX="filebeat-*"      # 日志索引名
IP_FIELD="ip.keyword" # IP 字段名（需为 keyword 类型）
TIME_FIELD="@timestamp"       # 时间字段
IP=$2

ip.discovery(){
ip=($(cat /etc/zabbix/scripts/log_ip.txt))
printf '{\n'
printf '\t"data":[\n'
 for ((i=0;i<${#ip[@]};++i))
 {
    num=$(echo $((${#ip[@]}-1)))
    if [ "$i" != ${num} ];
    then
       printf "\t\t{ \n"
       printf "\t\t\t\"{#IP}\":\"${ip[$i]}\"},\n"
    else
       printf "\t\t{ \n"
       printf "\t\t\t\"{#IP}\":\"${ip[$num]}\"}]}\n"
    fi
}
}

get_log_count(){
# 构建查询请求
REQUEST_JSON=$(cat <<EOF
{
  "size": 0,
  "track_total_hits": false,
  "query": {
    "bool": {
      "must": [
        {"term": {"${IP_FIELD}": "${IP}"}},
        {"range": {
          "${TIME_FIELD}": {
            "gte": "now-1h",
            "lte": "now"
          }
        }}
      ]
    }
  },
  "aggs": {
    "ip_count": {"value_count": {"field": "${IP_FIELD}"}}
  }
}
EOF
)

# 发送请求并提取结果,记得修改用户名和密码
RESPONSE=$(curl -u "user:passwd" -s -X POST "${ES_HOST}/${INDEX}/_search" \
          	-H 'Content-Type: application/json' \
            	-d "${REQUEST_JSON}")

# 解析聚合结果
COUNT=$(echo "${RESPONSE}" | jq -r '.aggregations.ip_count.value')

# 输出统计
#echo "IP ${IP} 在最近 1 小时的日志数量: ${COUNT:-0}"
echo $COUNT
}

case $1 in
        ip.discovery)
                ip.discovery
                ;;
        get_log_count)
                get_log_count
                ;;
        *)
                echo "bash $0 {ip.discovery,get_log_count}"
                ;;
esac
