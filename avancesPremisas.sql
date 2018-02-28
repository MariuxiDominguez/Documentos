-- Create table
create table PL_AVANCES_PREMISAS
(
  ID_SUBOBJETIVO       NUMBER not null,
  SECUENCIA_FECHA      NUMBER not null,
  ID_MES               NUMBER not null,
  META_ANUAL           NUMBER,
  META_MENSUAL         NUMBER,
  LOGRO_ANUAL          NUMBER,
  LOGRO_MENSUAL        NUMBER,
  CUMPLIMIENTO_ANUAL   NUMBER,
  CUMPLIMIENTO_MENSUAL NUMBER,
  META_ANUAL_NA        VARCHAR2(1),
  META_MENSUAL_NA      VARCHAR2(1),
  ID_ESTADO            NUMBER
)
tablespace WF_EMP_DAT
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table PL_AVANCES_PREMISAS
  is 'Control de Avances de Premisas';
-- Add comments to the columns 
comment on column PL_AVANCES_PREMISAS.ID_SUBOBJETIVO
  is 'Premisa';
comment on column PL_AVANCES_PREMISAS.SECUENCIA_FECHA
  is 'Identificador de fechas de medición - Secuencial';
comment on column PL_AVANCES_PREMISAS.ID_MES
  is 'Mes de Medición';
comment on column PL_AVANCES_PREMISAS.META_ANUAL
  is 'Meta Anual';
comment on column PL_AVANCES_PREMISAS.META_MENSUAL
  is 'Meta Mensual';
comment on column PL_AVANCES_PREMISAS.LOGRO_ANUAL
  is 'Logro Anual';
comment on column PL_AVANCES_PREMISAS.LOGRO_MENSUAL
  is 'Logro Mensual';
comment on column PL_AVANCES_PREMISAS.CUMPLIMIENTO_ANUAL
  is 'Cumplimiento Anual';
comment on column PL_AVANCES_PREMISAS.CUMPLIMIENTO_MENSUAL
  is 'Cumplimiento Mensual';
comment on column PL_AVANCES_PREMISAS.META_ANUAL_NA
  is 'Identificador No Aplica para la medición';
comment on column PL_AVANCES_PREMISAS.META_MENSUAL_NA
  is 'Identificador No Aplica para la medición';
comment on column PL_AVANCES_PREMISAS.ID_ESTADO
  is 'Estado del Objetivo - Acción';
-- Create/Recreate primary, unique and foreign key constraints 
alter table PL_AVANCES_PREMISAS
  add constraint AVANCES_PREMISAS_PK primary key (ID_SUBOBJETIVO, SECUENCIA_FECHA, ID_MES)
  using index 
  tablespace WF_EMP_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 40K
    minextents 1
    maxextents unlimited
  );
alter table PL_AVANCES_PREMISAS
  add constraint AVANCES_PRE_FK_ESTADO foreign key (ID_ESTADO)
  references PL_ESTADO (ID_ESTADO) on delete cascade;
alter table PL_AVANCES_PREMISAS
  add constraint AVANCES_PRE_FK_PREMISAS foreign key (ID_SUBOBJETIVO)
  references PL_PREMISAS (ID_SUBOBJETIVO) on delete cascade;
-- Create/Recreate check constraints 
alter table PL_AVANCES_PREMISAS
  add constraint AVANCES_PRE_CK_META_A_NA
  check (META_ANUAL_NA IN ('S','N'));
alter table PL_AVANCES_PREMISAS
  add constraint AVANCES_PRE_CK_META_M_NA
  check (META_MENSUAL_NA IN ('S','N'));
-- Grant/Revoke object privileges 
grant select, insert, update, delete, references, alter, index on PL_AVANCES_PREMISAS to PUBLIC;
