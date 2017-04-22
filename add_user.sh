#! /bin/bash

###############################################################################
#  Variaveis
###############################################################################

groups=$(cat /etc/group | cut -d: -f1)

###############################################################################
#  Tela para obter informacoes do usuario
###############################################################################

info_user=$(zenity --forms 						\
			--width=420 --height=420 			\
			--title="Tela Principal" 			\
            		--add-entry="Nome: " 				\
          		--add-entry="Sobrenome: " 			\
			--add-entry="Usuario: "				\
           		--add-password="Senha: " 			\
           		--add-password="Confirmar Senha: " 		\
           		--separator=";"					\
			)

[ $? != 0 ] && exit 1

###############################################################################
#  Tela para escolher os grupos para o usuario
###############################################################################

info_groups=$(zenity --list	 					\
			--width=420 --height=420 			\
			--checklist 					\
			--column "" 					\
			--column "Grupos" 				\
			$(for i in ${groups}; 				\
			do echo FALSE $i ;done)				\
			)

[ $? != 0 ] && exit 1

###############################################################################
#  Validar dados
###############################################################################

_newuser=$(echo $info_user | cut -d';' -f3)
_pass=$(echo $info_user | cut -d';' -f5)
_pass_confirm=$(echo $info_user | cut -d';' -f4)
_groups=$(echo $info_groups | sed 's/|/,/g')
_password=$(echo ${_pass} | md5sum | cut -d' ' -f1)

if [ "${_pass}" != ${_pass_confirm} ]; then 
	zenity --error --text="Senha nao confere" && exit 1
fi

###############################################################################
#  Criacao do usuario
###############################################################################

echo "sudo useradd -m -G ${_groups} ${_newuser} --password=${_password}"
sudo useradd -m -G ${_groups} ${_newuser} --password=${_password}

[ $? == 0 ] && zenity --info --text="Usuario cadastradoo com sucesso!"
