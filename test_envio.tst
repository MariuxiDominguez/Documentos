PL/SQL Developer Test script 3.0
11
begin
  -- Call the procedure
  ink_proceso_fact_cf.inp_envio_archivo_xml(pv_ruta_servidor => :pv_ruta_servidor,
                                            pv_ruta_local => :pv_ruta_local,
                                            pv_ruta_shell => :pv_ruta_shell,
                                            pv_fecha_tabla => :pv_fecha_tabla,
                                            pv_billcycle => :pv_billcycle,
                                            pv_cuenta => :pv_cuenta,
                                            pv_fact_bscs => :pv_fact_bscs,
                                            pv_error => :pv_error);
end;
8
pv_ruta_servidor
1
/doc1/ebilling/xml_publicacion/
5
pv_ruta_local
1
/procesos/home/siswre/xml_destino/xml_publicacion/
5
pv_ruta_shell
1
/procesos/home/siswre/xml_destino/prg/
5
pv_fecha_tabla
1
20160602
5
pv_billcycle
1
14
5
pv_cuenta
1
6.598931
5
pv_fact_bscs
1
001-064-006751173
5
pv_error
0
5
0
