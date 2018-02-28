
#--===================================================================================
#-- Version:    1.0.0 
#-- Descripcion:  Transferencia de los archivos txt esdinamico facturas
##====================================================================================
#-- Desarrollado por    : CIMA IT
#-- Lider proyecto      : Diego Ocampo
#-- Lider CLS           : CIM Hugo Fuentes
#-- Fecha de creacion   : 26/05/2014
#-- Proyecto            : 9574 FACTURACION ELECTRONICA INTERCONEXION
#--===================================================================================

##--------------------------------------------------------------------
##--  PRINCIPAL
##--------------------------------------------------------------------

clear

. /home/gsioper/.profile

ruta_shell="/procesos/gsioper/fact_electronica/prg"


cd $ruta_shell
echo $ruta_shell


PROG_NAME=`expr ./$0  : '.*\.\/\(.*\)'`

#NUM_SESION=`UNIX95= ps -al -fx|grep  "$PROG_NAME"|grep -v "$$"|grep -v grep|awk '{print $1}'|wc -l|awk '{print $1}'`
NUM_SESION=`UNIX95= ps -edaf|grep "$PROG_NAME"|grep -v grep|awk '{print $1}'|wc -l|awk '{print $1}'`
 
if [ $NUM_SESION -gt 2 ]

then

    echo "Saliendo, ya se encuentra $NUM_SESION levantados "

    UNIX95= ps -al -fx|grep -v "$$"|grep  "$PROG_NAME "|grep -v grep

exit

fi

resultado=0

#fecha_ingreso=$1

#if [ $fecha_ingreso == ""]
#then
 fecha_ingreso=`date +%Y%m%d`
#fi

echo "fecha ==> $fecha_ingreso"

PID=$$
#formato 20130512 -1

#if [ "$Tipo_param" = "" ] # 2 >/dev/null
#then
#   clear
#   echo "\n\n Debe ingresar valor del Tipo_param..... "
#   echo "-----------------------------------------"
#   echo "\n\nShell ->  hwcdr_SG.sh\n"
#   echo "-----------------------------------------"
#   echo "\nIngresar en 1 sola linea separada por espacio lo siguiente: \n"
#   echo " \nEjemplo:  sh hwcdr_SG.sh 1  \n\n"
#    echo "\nVerifique la tabla cg_rutas_control_hw, el campo tipo indica el hilo a ejecutar: \n"
#
#   sleep 1
#   exit;
#fi



#---------------------------------FUNCION DE VERIFICACION DE FILE SYSTEM-----------------------------------
verifica_FS_local()
{
echo "================================================================================= " >> $FILE_LOG
fecha_fs=`date`
echo "fecha ==> "$fecha_fs >> $FILE_LOG
porcentajeFSmax=$porcentajeFS
echo "file si "$FILE_SYSTEM
ruta_ini_df=$FILE_SYSTEM
porcentajeFS=`df -v /$ruta_ini_df | grep $ruta_ini_df | grep "% used blocks" | awk '{ split($4,por,"%"); print por[1]}'`

echo "Porcentaje FS max "$porcentajeFSmax 
echo "Porcentaje FS "$porcentajeFS
echo "Porcentaje FS max "$porcentajeFSmax  >> $FILE_LOG
echo "Porcentaje FS "$porcentajeFS  >> $FILE_LOG

valor_FS=0
if [ $porcentajeFS -ge $porcentajeFSmax ]
then
        mensaje="$mensaje $porcentajeFS % "
        echo "Enviando Alarma FS local "
        echo "No hay espacio suficiente para ejecutar el proceso, porcentaje acutal $porcentajeFS %, por favor depurar el filesystem /procesos " >> $FILE_LOG
        echo "Enviando Alarma FS local "  >> $FILE_LOG
        echo "Fin de Envio Alarma FS local "
        echo "Fin de Envio Alarma FS local " >> $FILE_LOG
        fecha_fs=`date`
        echo "fecha ==> "$fecha_fs >> $FILE_LOG
        valor_FS=1
fi
fecha_fs=`date`
echo "fecha ==> "$fecha_fs >> $FILE_LOG
}
## verifica_FS_local
#---------------------------------------------------------------------------------------------------------------------------------

#obtiene los nombres de los archvos a transferir 

obtiene_archivos_transferir()
{
arch_tmp="arch_carga_parametros.tmp"
arch_spool="parametros_carga.sql"
archivos_directorios="arch_parametros_facturas.dat"
echo $archivos_directorios
export archivos_directorios

# armo archivo para generar spool
echo "SET PAGES     10000
SET TERMOUT   OFF
SET TRIMOUT   ON
SET TRIMSPOOL ON
SET HEADING   OFF
SET FEEDBACK  OFF
SET PAUSE     OFF
SET PAGESIZE  0
SET LINESIZE  5000
SET ECHO      OFF
SET TERM      OFF
SET VERIFY    OFF
spool $ruta_shell/$archivos_directorios
SELECT nombre_archivo||'|'||tipo_orden  from In_Orden_Electronica WHERE ESTADO_PROCESO ='G' and trunc(fecha_genera) <= trunc(to_date('$fecha_ingreso','yyyymmdd')) order by  NO_ORDEN;
spool off
exit; " >  $ruta_shell/$arch_spool

cat $ruta_shell/$arch_spool

echo $PASS_DB | sqlplus $USER_DB @$ruta_shell/$arch_spool > $ruta_shell/$arch_tmp

echo "Se realizo el spool"

# Validamos si hay errores en el spool
ERROR_ORACLE_tmp=`grep "ORA" $ruta_shell/$arch_tmp |wc -l`		 >> $FILE_LOG
ERROR_ORACLE_spool=`grep "ORA" $ruta_shell/$archivos_directorios |wc -l`	 >> $FILE_LOG

if [ $ERROR_ORACLE_tmp -gt 0 ] || [ $ERROR_ORACLE_spool -gt 0 ]
then
    echo "Surgieron errores al realizar spool "
    echo "Surgieron errores al realizar spool " >> $FILE_LOG
    cat $ruta_shell/$arch_tmp		        >> $FILE_LOG
    cat $ruta_shell/$archivos_directorios       >> $FILE_LOG
    echo "Errores de Oracle al realizar el spool de la estructura in _orden_electronica --- $ERROR_ORACLE"	 >> $FILE_ERROR

    resultado=1
    exit resultado
fi 

rm -f $ruta_shell/$arch_spool
rm -f $ruta_shell/$arch_tmp

}


valida_errores_log()
{
nombre2=$1
rutaenviados=$2
rutaorigen=$3

######[INI]Verifico si efectivamente se realizo la transfrencia o si ocurrio un error
conteoListado=`cat $RUTA_LOG/sftp.log|grep "txt" |wc -l|awk '{print $1}'`
conteoErrores=`egrep -c "Login incorrect|Login failed|Please login with USER and PASS|Disk full|Passive mode refused.  Turning off passive mode"  $RUTA_LOG/sftp.log`
if [ "$conteoListado" -le 0 -o "$conteoErrores" -gt 0 ]; then
 error="Ocurrio un error al transferir los archivos desde el  servidor $ip_remota "
 echo "Ocurrio un error al transferir  los archivos desde el  servidor $ip_remota" >> $FILE_ERROR
 echo $error
 cat $RUTA_LOG/sftp.log >> $FILE_ERROR
 cat $RUTA_LOG/sftp.log
 ESTADO="G"
else

echo "valida error" 

cat $RUTA_LOG/sftp.log 
cat $RUTA_LOG/sftp.log |grep 100% | awk ' { print substr($1,1,32) } '> $RUTA_LOG/transferok.dat

cat $RUTA_LOG/transferok.dat

cat $RUTA_LOG/transferok.dat | cut -c 2-100 > $RUTA_LOG/transferok1.dat

sort $nombre2 > $nombre2".ord" 
sort $RUTA_LOG/transferok1.dat > $RUTA_LOG/transferok.dat.ord


cat $nombre2".ord" | awk '{ print substr($1,1,31)"|"$1 }' > $nombre2".ord1"
sort  $nombre2".ord1" > $nombre2".ord2"

join -t\| -v1 -j1 1 -j2 1 $nombre2".ord2" $RUTA_LOG/transferok.dat.ord |awk -F\| ' { print $2 } ' > $RUTA_LOG/control_error.dat
join -t\|  -j1 1 -j2 1 $nombre2".ord2" $RUTA_LOG/transferok.dat.ord | awk -F\| ' { print $2 } ' > $RUTA_LOG/transferok.dat.ord1

#join -v1 $nombre2".ord1" $RUTA_LOG/transferok.dat.ord >  $RUTA_LOG/control_error.dat 

echo $nombre2".ord2" 
echo $RUTA_LOG/transferok.dat.ord1
cat $RUTA_LOG/control_error.dat 

if [ -s $RUTA_LOG/control_error.dat  ]; then
echo "Archivos de facturas no transferidos:" >> $FILE_ERROR
cat $RUTA_LOG/control_error.dat >> $FILE_ERROR
echo "Debera regresarlos a la ruta original" 

 cat $RUTA_LOG/control_error.dat | awk ' { print "mv "$1" ../" } ' > $ruta_shell/mover.sh
 cd $rutaorigen
 sh $ruta_shell/mover.sh

fi

cat $RUTA_LOG/transferok.dat.ord1

if [ -s $RUTA_LOG/transferok.dat.ord1 ]; then
 ESTADO="T"
 cat $RUTA_LOG/transferok.dat.ord1
 echo "Actualiza todos los ok a la base de datos y debe mover los archivos"
 actualiza_in_orden_ele $RUTA_LOG/transferok.dat.ord1 $ESTADO
 cat $RUTA_LOG/transferok.dat.ord1 | awk -v arch=$rutaenviados ' { print "mv "$1" "arch } ' > $ruta_shell/mover.sh
 cd $rutaorigen
 sh $ruta_shell/mover.sh
 cd $ruta_shell
fi


fi 




}

actualiza_in_orden_ele() {

archivo44=$1
ESTADO="'"$2"'"
echo $archivo44
resultado2=0
cat $archivo44 | awk -v estado=$ESTADO -v a="'" '{ print "update in_orden_electronica set ESTADO_PROCESO="estado" , fecha_envio = sysdate where NOMBRE_ARCHIVO="a$1a";"; } ' > $RUTA_LOG/datos2.dat

echo "set heading off" >$ruta_shell/script.dat
cat $RUTA_LOG/datos2.dat >> $ruta_shell/script.dat
echo "commit; "  >> $ruta_shell/script.dat
echo "exit; "  >> $ruta_shell/script.dat


echo $PASS_DB | sqlplus $USER_DB @$ruta_shell/script.dat > $FILE_SQL

cat  $FILE_SQL 

ERROR_ORACLE=`grep "ORA" $FILE_SQL |wc -l` >>  $FILE_LOG

if [ $ERROR_ORACLE -gt 0 ] 
then
     echo "Errores encontrados al conectarse a la base de datos  "
     echo "Errores encontrados al conectarse a la base de datos al realizar el update en la in_orden_electronica $ERROR_ORACLE ">>$FILE_ERROR
     echo "Errores encontrados al conectarse a la base de datos al realizar el update en la in_orden_electronica $ERROR_ORACLE" >>  $FILE_LOG
     resultado2=1
else
resultado2=0
fi 

}

echo "\n****************************************************************************"
echo "                      INICIO DE EJECUCION			 " 
date
echo "Nombre del programa  sh_transfer_fact_electronica.sh -"

echo "****************************************************************************"
date
###############################################################################################################

archivo_configuracion="configuracion.cfg"

if [ ! -s $archivo_configuracion ]
then
   echo "No se encuentra el archivo de Configuracion $archivo_configuracion=\n"
   sleep 1
   exit;
fi
. $archivo_configuracion

echo "*********************** INCICIO DEL PROGRAMA**************************" >> $FILE_LOG

##--------------------------------------------------------------------##--##--
##-- Recuperando Informacion de la base a cargar 
##--

#USER_DB=$USER_DB
#PASS_DB=`/home/gsioper/key/pass $USER_DB`
#SID_BD_GYE=""
PASS_DB=`/home/gsioper/key/pass $USER_DB"_g"`


mes=`date +%m`
dia=`date +%d`
anio=`date +%Y`
fecha=$anio$mes$dia



numero_proceso=`date +'%Y%m%d%H%M%S'`
numero_pid=0
echo "Inicia ejecucion $numero_proceso" 

echo "\nNumero de proceso del programa sh_transfer_fact_electronica.sh --> $numero_proceso " 


FILE_LOG=$RUTA_LOG/"transfer_factura_"$fecha"_"$PID.log
FILE_ERROR=$RUTA_LOG/"Transfer_Error_factura_"$fecha"_"$PID.log
FILE_SQL=$RUTA_LOG/"Update_factura_"$fecha"_"$PID.log
############################################################################
############### VALIDACION DE FILE SYSTEM  #################################
############################################################################
verifica_FS_local
if  [ $valor_FS -eq 1 ]
         then
          resultado=1
          echo "   Verificacion FS Local terminada - NO hay espacio suficiente para continuar con el proceso "
          echo "   Verificacion FS Local terminada - NO hay espacio suficiente para continuar con el proceso " >> $FILE_LOG
          echo "   Error_FS|$resultado " >> $FILE_LOG 
          exit $resultado
fi


obtiene_archivos_transferir

if [ ! -s $archivos_directorios ]; then 
 echo "2000| El archivo no contiene los nombres para realizar el proceso de transferencia " $FILE_LOG
 exit 0
else
 COMANDO=dir 
fi


cont=0

echo "Empezando a realizar el split para transferencia en lotes " 
echo "empezando a realizar el split para transferencia en lotes " >> $FILE_LOG

rm -f $RUTA_LOG/new*

#cat $archivos_directorios | split -100 > $RUTA_LOG/new

split -100 $archivos_directorios $RUTA_LOG/new

ls $RUTA_LOG/new* > $ruta_shell/"archivos_split.dat"

cat $ruta_shell/"archivos_split.dat"  >> $FILE_LOG


for nombre in `cat $ruta_shell/"archivos_split.dat"`
do

echo $nombre
cat $nombre | awk -v ruta_dev=$ruta_archivo_nc"not_crl" -v ruta_fac=$ruta_archivo_fact"fact1" -v archivo=facturas.dat -v archivo2=devoluciones.dat -F\| '{ if ( $2 == "08" || $2 == "18" ) { print "mv "$1" "ruta_fac > archivo} else{  print "mv "$1" "ruta_dev  > archivo2 } } '

if [ -s $ruta_shell/facturas.dat ]; then 

ruta_archivo_fact_nc="$ruta_archivo_fact"fact1

cd $ruta_archivo_fact

echo "Empezando a mover los archivos facturas " >> $FILE_LOG
sh $ruta_shell/facturas.dat 

cd $ruta_archivo_fact_nc
ls INTX_* > $ruta_shell/existentes.dat
cd  $ruta_shell

cat $nombre | awk -F\| ' { print $1 } ' |  sort -u > $nombre"_ve.ord" 

sort $ruta_shell/existentes.dat > $RUTA_LOG/existentes.dat.ord

join -v1 $nombre"_ve.ord" $RUTA_LOG/existentes.dat.ord > $ruta_shell/faltantes.dat

if [ -s $ruta_shell/faltantes.dat ]; then 

 echo "Archivos no existen en el directorio de facturas" 
 cat  $ruta_shell/faltantes.dat >> $FILE_LOG

 echo "Actualiza los registros de facturas a estado Pendiente " >> $FILE_LOG

  actualiza_in_orden_ele $ruta_shell/faltantes.dat "P"

  #MOFIFICAR CUANDO ESTE P no deberia actualizar la fecha de envio 
fi


cd $ruta_shell

comando="mput INTX*"
echo $UserRemoto

 echo "Transfiriendo las facturas a es_dinamico " >> $FILE_LOG

sh -x $ruta_shell/sftp.sh $ruta_archivo_fact_nc $ruta_remota $UserRemoto $PasswordRemoto $ip_remota "$comando" > $RUTA_LOG/sftp.log

valida_errores_log $RUTA_LOG/existentes.dat.ord $ruta_archivo_fact_env $ruta_archivo_fact_nc

if [ $resultado2 -eq 0 ]; then 

echo "Actualizacion fue exitosa de facturas"
echo "Actualiza los registros de facturas a estado finalizado " >> $FILE_LOG
else 
echo "No se acturlizaron todo los registros del archivo $nombre "

fi 

fi 

if [ -s $ruta_shell/devoluciones.dat ]; then 


ruta_archivo_fact_nc="$ruta_archivo_nc"not_crl

cd  $ruta_archivo_nc

echo "Empezando a mover los archivos devoluciones " >> $FILE_LOG
sh $ruta_shell/devoluciones.dat 

cd $ruta_archivo_fact_nc

ls INTX_* > $ruta_shell/existentes.dat
cd  $ruta_shell

cat $nombre | awk -F\| ' { print $1 } ' | sort -u > $nombre"_ve.ord" 
sort $ruta_shell/existentes.dat > $RUTA_LOG/existentes.dat.ord

join -v1 $nombre"_ve.ord" $RUTA_LOG/existentes.dat.ord > $ruta_shell/faltantes.dat

echo "Empezando a mover los archivos devoluciones " >> $FILE_LOG


if [ -s $ruta_shell/faltantes.dat ]; then 

echo "Archivos no existen en el directorio de devolucion" 
cat  $ruta_shell/faltantes.dat >> $FILE_LOG
echo "Actualiza los registros de devoluciones a estado Pendiente " >> $FILE_LOG

actualiza_in_orden_ele $ruta_shell/faltantes.dat P

fi


cd $ruta_shell
comando="mput INTX*"
echo $UserRemoto

 echo "Transfiriendo las devoluciones a es_dinamico " >> $FILE_LOG

sh -x $ruta_shell/sftp.sh $ruta_archivo_fact_nc $ruta_remota $UserRemoto $PasswordRemoto $ip_remota "$comando" > $RUTA_LOG/sftp.log

valida_errores_log $RUTA_LOG/existentes.dat.ord $ruta_archivo_nc_env $ruta_archivo_fact_nc


if [ $resultado2 -eq 0 ]; then 

echo "Actualizacion fue exitosa de devoluciones"
echo "Actualiza los registros de devoluciones a estado finalizado " >> $FILE_LOG
else 
echo "No se actualizaron todo los registros del archivo $nombre "

fi 



fi 

done 



# Eliminacion de los archivos temporales
# ======================================
 rm -f  $RUTA_LOG/sftp.log
 rm -f $RUTA_LOG/new*
 rm -f  *.log
 rm -f  *.sql
 rm -f  *.dat


echo "Fin del proceso " `date` >> $FILE_LOG

echo "Verificando si existen errores en el proceso "
echo "Verificando si existen errores en el proceso ">> $FILE_LOG

if [ -s $FILE_ERROR ]; then 

echo "Se encontro errores $FILE_ERROR" >>$FILE_LOG

mens_mail=$Servidor" "$IP_Servidor" "$ruta_shell/"sh_transfer_fact_electronica.sh "$MENSAJE

echo "Se envia correo $PARA $COPIA $ASUNTO $MENSAJE $FILE_ERROR" >> $FILE_LOG
sh -x $FILE_MAIL "$PARA" "$COPIA" "$ASUNTO" "$mens_mail" "$FILE_ERROR" parametros_trans.dat

date  >> $FILE_LOG

echo "Finalizo con errores  ... "

else
echo "No existen errores " >>$FILE_LOG

date  >> $FILE_LOG

echo "****************** FIN DEL PROGRAMA****************" >> $FILE_LOG 
echo "Finaliza de la transferencias exitosas   ... " >> $FILE_LOG
fi 

numero_proceso=`date +'%Y%m%d%H%M%S'`
rm -f *sftp.log
echo "Finaliza ejecucion $numero_proceso" 
