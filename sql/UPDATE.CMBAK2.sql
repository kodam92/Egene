insert into eso_cm_bak2 (
  cmbak_id,
  cmbak_reg_dttm,
  cmbak_src_id,
  cmbak_target_name,
  cmbak_target_host,
  cmbak_target_equ,
  cmbak_type,
  cmbak_cha,
  cmbak_sort,
  cmbak_per,
  cmbak_stg_per,
  cmbak_actstart_dttm,
  cmbak_start_dttm,
  cmbak_end_dttm,
  cmbak_diss,
  cmbak_used,
  cmbak_req_emp,
  cmbak_source_name,
  cmbak_source_host,
  cmbak_source_equ
)
SELECT 
  CONCAT(?, '_', LPAD(ROW_NUMBER() OVER (ORDER BY wfc.wfc_cm_id, wfb.wfb_cmbak_target_name), 2, '0')) AS new_cmbak_id,
  ?,
  ?,
  wfb.wfb_cmbak_target_name,
  (SELECT cm_host_name FROM eso_cm WHERE cm_id = wfb.wfb_cmbak_target_name) AS target_host_name,
  (SELECT cm_equ_name FROM eso_cm WHERE cm_id = wfb.wfb_cmbak_target_name) AS target_equ_name,
  wfb.wfb_cmbak_type,
  wfb.wfb_cmbak_cha,
  wfb.wfb_cmbak_sort,
  wfb.wfb_cmbak_per,
  wfb.wfb_cmbak_stg_per,
  wfb.wfb_cmbak_actstart_dttm,
  wfb.wfb_cmbak_start_dttm,
  wfb.wfb_cmbak_end_dttm,
  wfb.wfb_cmbak_diss,
  wfb.wfb_cmbak_used,
  wfb.wfb_cmbak_req_emp,
  wfc.wfc_cm_id,
  (SELECT cm_host_name FROM eso_cm WHERE cm_id = wfc.wfc_cm_id) AS source_host_name,
  (SELECT cm_equ_name FROM eso_cm WHERE cm_id = wfc.wfc_cm_id) AS source_equ_name
FROM eso_wf_bak2 wfb INNER JOIN eso_wf_cm wfc ON wfb.wfb_src_id = wfc.wfc_src_id
WHERE wfb.wfb_status = 'CODBS_ADD' 
  AND wfb.wfb_src_id = ?

__END__

UPDATE eso_cm_bak2 bak
INNER JOIN eso_wf_bak2 wfb ON bak.cmbak_id = wfb.wfb_cmbak_id
SET 
    bak.cmbak_mod_dttm = ?,
    bak.cmbak_type = wfb.wfb_cmbak_type,
    bak.cmbak_cha = wfb.wfb_cmbak_cha,
    bak.cmbak_sort = wfb.wfb_cmbak_sort,
    bak.cmbak_per = wfb.wfb_cmbak_per,
    bak.cmbak_stg_per = wfb.wfb_cmbak_stg_per,
    bak.cmbak_actstart_dttm = wfb.wfb_cmbak_actstart_dttm,
    bak.cmbak_start_dttm = wfb.wfb_cmbak_start_dttm,
    bak.cmbak_end_dttm = wfb.wfb_cmbak_end_dttm,
    bak.cmbak_diss = wfb.wfb_cmbak_diss,
    bak.cmbak_used = wfb.wfb_cmbak_used
WHERE wfb.wfb_status = 'CODBS_CHG' 
  AND wfb.wfb_src_id = ?;

__END__

DELETE bak
FROM eso_cm_bak2 bak
INNER JOIN eso_wf_bak2 wfb ON bak.cmbak_id = wfb.wfb_cmbak_id
WHERE wfb.wfb_status = 'CODBS_DEL' 
  AND wfb.wfb_src_id = ?;


[
  {
    "cols": "id,cur_dttm,key,key",
    "vars": "id=ent_seq.CM_BAK2",
    "require": ""
  },
  {
    "cols": "cur_dttm,key",
    "vars": "",
    "require": ""
  },
  {
    "cols": "key",
    "vars": "",
    "require": ""
  }
]