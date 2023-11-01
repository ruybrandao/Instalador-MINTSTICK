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

quadro "Instalação automatizada do MintStick"

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
REPO="http://packages.linuxmint.com"

# Busca versões dos pacotes DEB do MintStick e armazena ordenando da versão mais nova até a mais velha
VER=($(curl -sl "${REPO}/pool/main/m/mintstick/" | grep -Po "(?<=mintstick_)\d+\.\d+\.\d+(?=_all\.deb)" | sort -ut. -k 1,1n -k2,2n -k3,3n | tac))

# Busca pacotes DEB de traduções do Mint
VER_TRAD=($(curl -sl "${REPO}/pool/main/m/mint-translations/" | grep -Po "(?<=mint-translations_)\d+\.\d+\.\d+(?=_all\.deb)" | sort -ut. -k 1,1n -k2,2n -k3,3n | tac))

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
	ARQ="mint-translations${VER[$verNum]}_all.deb"
else
	# Última versão
	ARQ="mintstick_${VER[0]}_all.deb"
	ARQ="mint-translations${VER[0]}_all.deb"
fi

# Baixa o MintStick
quadro "Baixando pacote de instalação e traduções"
wget "${REPO}/pool/main/m/mintstick/${ARQ}"
wget "${REPO}/pool/main/m/mint-translations/${ARQ_TRAD}"

# Instala o MintStick
quadro "Instalando MintStick e traduções"
sudo dpkg -i ${ARQ} ${ARQ_TRAD}
sudo apt install -f -y

# Remove pacote de instalação
quadro "Removendo pacotes de instalação"
rm ${ARQ} ${ARQ_TRAD}

quadro "MintStick instalado"
