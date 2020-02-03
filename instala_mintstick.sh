#!/usr/bin/env bash

quadro () {
	tam=$(expr length "$1")
	((tam+=2))
	printf "\n+"
	for ((i=0 ; i<tam; i++ ))
	do
		printf "-"
	done
	printf "+\n| $1 |\n+"
	for ((i=0 ; i<tam; i++ ))
	do
		printf "-"
	done
	printf "+\n\n"
}

quadro "Instalação automatizada do MINTSTICK"

sudo apt update
if [ $? -ne 0 ]; then
	quadro "Senha incorreta"
	exit 1
fi

# Instala o cURL caso ele não esteja instalado
dpkg -l curl | grep '^ii' > /dev/null
if [ $? -ne 0 ]; then
	quadro "Instalando cURL"
	sudo apt install curl -y
fi

# Instala o Wget caso ele não esteja instalado
dpkg -l wget | grep '^ii' > /dev/null
if [ $? -ne 0 ]; then
	quadro "Instalando Wget"
	sudo apt install wget -y
fi

# Espelho de rede para baixar o pacote
REPO="http://repositorio.nti.ufal.br/mint"

# Busca versões dos pacotes DEB do MINTSTICK e armazena ordenando da versão mais nova até a mais velha
VER=($(curl -sl "${REPO}/pool/main/m/mintstick/" | grep -Po "(?<=mintstick_)\d+\.\d+\.\d+(?=_all\.deb)" | sort -ut. -k 1,1n -k2,2n -k3,3n | tac))

if [ "$1" == "-l" ]; then
	# Opção para escolha da versão
	i=0
	for versao in "${VER[@]}"
	do
		if [ $i -eq 0 ]
		then
			printf "(%2d) - " $i
		else
			printf "%3d  - " $i
		fi
		printf "%s\n" $versao
		((i=i+1))
	done
	echo ""
	read -p "Entre com o índice para versão que deseja instalar [0]: " verNum
	verNum=${verNum:-0}
	ARQ="mintstick_${VER[$verNum]}_all.deb"
else
	ARQ="mintstick_${VER[0]}_all.deb"
fi

# Baixa o MINTSTICK
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
