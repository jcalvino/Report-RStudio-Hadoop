set +x

echo --------------------------------------------------------------------------
echo Inicio do processamento - `date`
echo --------------------------------------------------------------------------

#  PARAMENTRO PASSADO DURANTE A CHAMADO DA ROTINA  EX: rotina.sh 20200701 (ano mes dia)
echo "arg1: $1"

#  OPCIONAL - PARAMENTRO PASSADO PARA FORÇAR O INICIO DO PROCESSO EM ALGUM STEP ESPECIFICO  EX: rotina.sh 20200701 step03
echo "step: $2"

#  ALOCA A INFORMAÇÃO DO STEP PASSADO PARA UMA VARIAVEL
export step=$2

#  DEFINE O NOME DO ARQUIVO DE LOG - CONCATENANDO A DATA DE MOVIMENTO PASSADO E A DATA DE PROCESSAMENTO DO SISTEMA REDHAT
LOGFILE="rotina_"$1"_"`date +"%H-%M-%S"`


#  LOGICA PARA DEFINIR EM QUAL STEP IRÁ INICIAR O PROCESSO DE ACORDO COM OS PARAMENTROS PASSADOS
if [ "$step" == "" ]; then
  echo "Iniciando script $0 - MOVTO $1 a partir do inicio"
else
  echo "Iniciando script $0 - MOVTO $1 a partir do $step"
fi

case $step in
"")
    echo ------------------------------------------------------------------------------
	echo Inicio do step01  - `date`
	echo ------------------------------------------------------------------------------
;&

"step01"){
#------------------------------------------------------------------------------
# case step01 #EXECUÇÃO DO SCRIPT EM R 
#------------------------------------------------------------------------------

echo Inicio do Step01 - `date`

#  EXECUTANDO SCRIPT NO COMPILADOR DO R
/usr/bin/Rscript /home/user/exec_extrac_report_git.r $1 


# ALOCA O STATUS DO RESULTADO DO PROCESSAMENTO EM UMA VARIAVEL
var_return_tws=$?

# EXPORTA O RESULTADO NO ARQUIVO DE LOG
} >> ${LOGFILE}.log 


# IDENTIFICA O STATUS SE O PROCESSO EXECUTOU OU NÃO COM SUCESSO
if [ ${var_return_tws} -ne 0 ]; then

    echo Final do step01 com erro - verificar /home/user/exec_extrac_report_git.r  - `date`
    echo "------------------------------------------------------------------------------------------------------------------"
    echo "Log da execucao:"
    echo "------------------------------------------------------------------------------------------------------------------"
    tail ${LOGFILE}.log
    exit 10
  else
    echo Final do step01 com sucesso - `date`
    echo --------------------------------------------------------------------------
  fi   
    ;;

*)

  echo ------ step $step nao existe --------
  exit 10
  ;;

esac
