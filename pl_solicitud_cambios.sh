#==============================================================================
#                       PROCESO DESPACHADOR OPERACIONES
#                  ESTE PROCESO SE DEBE EJECUTAR EN AXIS
#==============================================================================

if [ $# -gt 0 ] && [ $1 = "-version" ]
then
   echo "\n\tfms_genera.sh: V <1.0> Ult.Act.:29/Diciembre/2004 EID\n"
   exit
fi

PROG_NAME=`expr ./$0  : '.*\.\/\(.*\)'`
PROG_PARAM=""
if [ $# -gt 0  ]
then
PROG_PARAM=" $@"
fi

#NUM_SESION=`UNIX95= ps -edaf|grep -v grep|grep -v "sh -c"|grep -c "$PROG_NAME$PROG_PARAM"`
#echo "Procesos pl_solicitud_cambios.sh levantados -> $NUM_SESION"


#if [ $NUM_SESION -gt 1 ]
#then
   #echo "Saliendo, ya se encuentra" $NUM_SESION levantados " >> $LOG
#   UNIX95= ps -edaf|grep -v grep|grep  "$PROG_NAME$PROG_PARAM"
#   exit
#fi

#==============================================================================
#                       VARIABLES DE AMBIENTE DE ORACLE
#==============================================================================

#. /home/oracle/.profile
. /home/sisrna/.profile

#==============================================================================
#                       VARIABLES DE AMBIENTE DEL PROGRAMA
#==============================================================================

#SHELL_PATH=/ora1/gsioper/procesos
SHELL_PATH=/home/sisrna/negocios/scripts
DB_LOGIN=wfemp
DB_PASS=wfemp
ORACLE_SID=GYE
export ORACLE_SID

cd $SHELL_PATH


#==============================================================================
#      EJECUCION DEL PROCEDURE QUE GENERA LOS ARCHIVOS CON LA INFORMACION DE AXIS
#==============================================================================

cat>$SHELL_PATH/plan_negocios_solicitud_cambios.sql<<END
set heading off
begin
   gck_trx_plan_negocios_jobs.GCP_PROCESA_CAMBIOS;
end;
/
exit;
END
sqlplus -s $DB_LOGIN/$DB_PASS@$ORACLE_SID @$SHELL_PATH/plan_negocios_timeout_medicion.sql

rm -f $SHELL_PATH/plan_negocios_solicitud_cambios.sql

echo "Proceso Terminado."

