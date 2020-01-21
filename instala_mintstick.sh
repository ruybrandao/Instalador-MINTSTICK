#!/usr/bin/env bash

quadro () {
	tam=$(expr length "$1")
	((tam+=3))
	printf "\n"
	for ((i=0 ; i<=tam; i++ ))
	do
		printf "*"
	done
	printf "\n* $1 *\n"
	for ((i=0 ; i<=tam; i++ ))
	do
		printf "*"
	done
	printf "\n\n"
}

quadro "Instalação automatizada do MINTSTICK"

sudo apt update
if [ $? -ne 0 ]; then
	quadro "Senha incorreta"
	exit 1
fi

# Instala o cURL caso ele não esteja instalado
dpkg -l curl | grep '^ii' > /dev/null
#echo $?
#exit
if [ $? -ne 0 ]; then
	quadro "Instalando cURL"
	sudo apt install curl -y
fi

# Espelho de rede para baixar o pacote
REPO="http://repositorio.nti.ufal.br/mint"

# Busca versões dos pacotes DEB do MINTSTICK e armazena ordenando da versão mais velha até a mais nova
VER=($(curl -sl "${REPO}/pool/main/m/mintstick/" | grep -Po "(?<=mintstick_)[0-9]+\.[0-9]+\.[0-9]+(?=_all\.deb)" | sort -ut. -k 1,1n -k2,2n -k3,3n))

# Opção para escolha da versão
#i=0
#printf "Escolha a versão do MINTSTICK:\n\n"
#for versao in "${VER[@]}"
#do
#	if [ $i -eq $((${#VER[@]}-1)) ]
#	then
#		printf "(%2d) - " $i
#	else
#		printf "%3d  - " $i
#	fi
#	printf "%s\n" $versao
#	((i=i+1))
#done
#read -i $((${#VER[@]}-1)) -e verNum
#ARQ="mintstick_${VER[$verNum]}_all.deb"

# Baixa a versão mais nova do MINTSTICK
ARQ="mintstick_${VER[-1]}_all.deb"
quadro "Baixando arquivo de instalação \"$ARQ\""
wget "${REPO}/pool/main/m/mintstick/${ARQ}"

# Instala o MINTSTICK
quadro "Instalando \"$ARQ\""
sudo dpkg -i $ARQ
sudo apt install -f -y
#sudo dpkg -i $ARQ

# Remove pacote de instalação
quadro "Removendo pacote de instalação \"$ARQ\""
rm $ARQ
