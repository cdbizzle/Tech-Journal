# syntax: bash findMetaModule.bash apache phpmyadmin 2018-12613
f=$1
g=$2
c=$3

lis=$(find /usr/share/metasploit-framework/modules/ "${f}" 2> /dev/null | grep "${g}")
#echo "${lis}"

for fn in ${lis}; do
res=$(cat "${fn}" | grep "${c}")
if [[ ! -z "$res" ]]; then
echo "${fn}"
fi
done
