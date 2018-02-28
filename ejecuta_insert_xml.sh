##################################################################################
# Creado por: CLS FELIX PAZMINO					                                 #
# Lider SIS : Ernesto Idrovo			                                         #
# Lider CLS : Mariuxi Dominguez            			                         #
# Fecha     : 10/01/2016                                                         #
# Proyecto  : [10775]-DOCUMENTO ELECTRONICOS POR REIMPRESION DE SERVICIOS NO INVENTARIABLES      #
##################################################################################
#DESARROLLO
#ruta_principal=/procesos/home/siswre/xml_destino/prg
#PRODUCCION
ruta_principal=/procesos/gsioper/fact_electronica/prg 
cd $ruta_principal


#DESARROLLO
#. /home/oracle/profile_GYED
#PRODUCCION
. /home/gsioper/.profile

archivo_configuracion=$ruta_principal/archivo_configuracion.cfg

if [ ! -s $archivo_configuracion ]
then
   echo "No se encuentra el archivo de Configuracion $archivo_configuracion"
   exit 1
fi
. $archivo_configuracion

ruta=$1
file=$2
fecha=$3
RUTA_PRG=$ruta_principal
RUTA_LOGS=$LOG_PATH


#control de ejecución 
pidfile=$RUTA_LOGS"/server_insert"$file"_pidfile.lck"

if [ -s $pidfile ]; then
     cpid=`cat $pidfile`
    if [ `ps -eaf | grep -w $cpid | grep -v grep | wc -l` -gt 0 ]
    then
     echo "$0 already running"      
     echo " El proceso se encuentra ejecutándose `ls -ltr $pidfile`"             
                exit
    fi
else
    echo " El proceso se inicia"
fi
echo $$ > $pidfile



#rm -f $RUTA_LOGS/"carga_factura_"$file".log"
archivo_log=$RUTA_LOGS"/carga_factura_"$file".log"
archi_sql=$RUTA_LOGS"/resulta_insert_"$file".txt"
archi_lista_sql=$RUTA_LOGS"/resulta_select_"$file".txt"
dbuser=$USER_BASE
#DESARROLLO
#dbpass=$PASS_BASE
#PRODUCCION
dbpass=`/home/gsioper/key/pass $dbuser"`


echo "Inicia proceso.... `date`"   > $archivo_log
chmod 7777 $archivo_log
echo "Inicia consulta a tabla IN_FACTURAXML_TMP "  >> $archivo_log

cat>$RUTA_LOGS/ejecuta_select_"$file".sql<<EOF_END
set pagesize 0
set linesize 10000
set head off
SET SERVEROUTPUT ON

SELECT 'archivo:'||a.nombre_archivo FROM IN_FACTURAXML_TMP a
WHERE a.nombre_archivo like'%$file%'
and a.fecha_tabla = '$fecha';
exit;
EOF_END


echo $dbpass | sqlplus -s $dbuser @$RUTA_LOGS/ejecuta_select_"$file".sql > $archi_lista_sql


echo "\n Informacion encontrada: ">>$archivo_log
cat  $RUTA_LOGS/$archi_lista_sql >> $archivo_log


estado=`cat $archi_lista_sql| grep "ORA-"|wc -l`
ERROR=`cat $archi_lista_sql| grep "Error"|wc -l`

if [ $estado -gt 0 ]; then
	echo "Error de Ejecucion, Favor revise log -->">>$archivo_log
	date +%d/%m/%Y" "%H:%M:%S
	echo $estado
	resultado=1

else
	if [ $ERROR -gt 0 ]; then
        echo "Error de Ejecucion, Favor revise log  -->">>$archivo_log
	date +%d/%m/%Y" "%H:%M:%S
	echo $ERROR
        echo "Por favor revisar log $archivo_log"

	resultado=1
	fi
fi

 ln_existe=`cat $archi_lista_sql | grep "$2" | wc -l`;

if  [ $ln_existe -eq 0 ]; then
cd $ruta
#contenido=`cat $ruta/$file`

echo "iniciando eliminacon de registros de clave de acceso y autorizacio" >> $archivo_log
valor=`grep -n -e "<ds:Signature xmlns" $ruta/$file | awk -F\: ' { print $1 } '`
limite=`expr $valor - 1`
if [ ! -s $limite ]; then 
   head -"$limite" $ruta/$file > $ruta/$file.new
   mv $ruta/$file.new $ruta/$file 
fi  
echo "iniciando split "  >> $archivo_log
split -b 30000 $ruta/$file $ruta/$file"_"
cont=0
chmod 777 $file"_"*
for i in `ls $ruta/*_*`
do 
cont=`expr $cont + 1`
	if [ $cont -eq 1 ]
	then
	contenido1=`cat $i`
	fi
	if [ $cont -eq 2 ]
	then
	contenido2=`cat $i`
	fi
	if [ $cont -eq 3 ]
	then
	contenido3=`cat $i`
	fi
	if [ $cont -eq 4 ]
	then
	contenido4=`cat $i`
	fi

#contenido"$cont"=`cat $i`

done 

echo "\n Inicio inserccion $file "   >> $archivo_log

cat>$RUTA_LOGS/ejecuta_insert_"$file".sql<<EOF_END

set pagesize 0
set linesize 10000
set head off
SET SERVEROUTPUT ON
set trimspool on
set feedback off


declare
lc_contenido   CLOB := '$contenido1';


contenido2 varchar2(32000):= '$contenido2';  
contenido3 varchar2(32000):= '$contenido3';  
contenido4 varchar2(32000):= '$contenido4';  
begin

  -- Call the function
  
  
  if  contenido2 is not null then 

 dbms_lob.append(lc_contenido, contenido2);
 
  end if;
  
    if  contenido3 is not null then 

 dbms_lob.append(lc_contenido, contenido3);
 
 end if;
  
   if  contenido4 is not null then 

   dbms_lob.append(lc_contenido, contenido4);
 
   end if;
insert into IN_FACTURAXML_TMP (nombre_archivo, contenido, ruta_archivo,fecha_tabla,fecha_proceso, estado, paquete) values  ('$file',lc_contenido,'$ruta','$fecha',sysdate,'C','INK_PROCESO_FACT_CF');
commit;

end;
/
exit;
EOF_END

echo $dbpass | sqlplus -s $dbuser @$RUTA_LOGS/ejecuta_insert_"$file".sql > $archi_sql

cat $archi_sql >> $archivo_log
echo "Fin insercción... " >> $archivo_log

else
 echo "El archivo $2.xml ya se encuentra cargado" >> $archivo_log
 echo "El archivo $2.xml ya se encuentra cargado"
fi


estado=`cat $archi_sql| grep "ORA-"|wc -l`
ERROR=`cat $archi_sql| grep "Error"|wc -l`

if [ $estado -gt 0 ]; then
	echo "Error de Ejecucion, Favor revise log -->">>$archivo_log
	date +%d/%m/%Y" "%H:%M:%S
	echo $estado
	resultado=1

else
	if [ $ERROR -gt 0 ]; then
        echo "Error de Ejecucion, Favor revise log  -->">>$archivo_log
	date +%d/%m/%Y" "%H:%M:%S
	echo $ERROR
        echo "Por favor revisar log $archivo_log"

	resultado=1
	fi
fi

#rm -f ejecuta_select.sql $archi_lista_sql ejecuta_insert_"$file".sql $archi_sql 
rm -f $archi_sql 
rm -f $archi_lista_sql
rm -f $RUTA_LOGS/ejecuta_select_"$file".sql
rm -f $RUTA_LOGS/ejecuta_insert_"$file".sql

rm -f $pidfile
cd $ruta
rm -f  $file"_"*

exit 0;
