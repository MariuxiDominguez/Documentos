#############################
## Autor: CLS Gloria Suarez Acnchundia
## Proyecto: Facturación Electronica
## Lider: SIS Tanya Merchan
## Lider CLS : CLS Mariuxi Dominguez
## Objetivo : Realizacion de transferencias de archivos al servidor esdinamico
#############################


# => En algunos servidores el expect se encuentra en la ruta /usr/bin/ en otros no,
#    para saber donde esta instalado el comando expect, ejecutar lo siguiente en consola:
#    type expect

#!/usr/local/bin/expect -f
# => la linea anterior [ #!/usr/bin/expect -f ] no es un comentario

###ruta_shell=/procesos/gsioper/event_handler/consumidor/sftp

ruta_shell=/procesos/gsioper/fact_electronica/prg
cd $ruta_shell

############################# parametros #############################
ruta_archivo=$1
# => ruta donde se encuentra el archivo a transferir (put) o ruta donde quiero que se deposite un archivo(get)
ruta_remota=$2
# => ruta donde se encuentra el archivo en el servidor remoto
username=$3
# => usuario remoto
password=$4
# => password del usuario remoto
hostname=$5
# => ip del servidor al que se desea acceder
comando="$6"
# => put o get mas el archivo; ejemplo put prueba.txt o get prueba.dat
############################# parametros #############################

############################# variables #############################
log_ftp_exp="$ruta_shell/$$_sftp.log"
# => log para realizar QC de tamaños de archivos transferidos
############################# variables #############################

cd $ruta_archivo

 

/usr/local/bin/expect $ruta_shell/sftp.exp "$ruta_remota" "$username" "$password" "$hostname" "$comando" "$log_ftp_exp"
# => ejecuto expect que realiza el ftp

##sh sftp.sh /procesos/home/sisjla/esdinamico/factura /procesos/home/sisjla/facturas/ sisjla Isani0612 192.168.37.34 "put CLARO_001034*."
# echo  /procesos/home/sisjla/facturas/ sisjla Isani0612 192.168.37.34 "put CLARO_001034*."
#echo echo  /procesos/home/sisjla/esdinamico/factura /home/gsioper/pruebas_sifi gsioper Y4ZZm28T5$ 192.168.37.141 "put CLARO_001034*.txt"
# echo  /procesos/home/sisjla/esdinamico/factura /home/gsioper/pruebas_sifi CAJAS 12345678 130.11.0.33 "put CLARO_001034*.txt"

cd $ruta_shell