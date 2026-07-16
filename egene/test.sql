select distinct
cm_id,
    t2.cmbak_srm_cit_id2
	,t2.cmbak_src_id
	,(select cm_name from eso_cm where cm_id = cmbak_target_name) as ci_tgt_name /*백업대상*/
	-- ,ifnull(get_codename(t2.cmbak_target_name),'-') as cmbak_target_name /*cm 타켓네임*/
	,ifnull(get_codename(t2.cmbak_type),'-') as cmbak_type /*백업타입*/
	,ifnull((t2.cmbak_cha),'-') as cha/*백업경로*/
	,ifnull(get_codename(t2.cmbak_sort),'-') as cmbak_sort /*백업종류*/
	,ifnull(get_codename(t2.cmbak_stg_per),'-') as cmbak_stg_per/*백업보관기간*/
	,CASE WHEN t2.cmbak_diss = 1 THEN '예'
          WHEN t2.cmbak_diss = 0 THEN '아니오'
          ELSE '-'
    END AS cmbak_diss /*백업소산*/
, t1.srm_id
from eso_cm t, eso_srm t1, eso_cm_bak2 t2
where 1=1
and cm_id = 'CM-MIG-HW-01150'
and t1.srm_id = t2.cmbak_src_id
-- and t1.srm_id = (select cmbak_id from ESO_CM_BAK2 where 1=1 and CMBAK_TARGET_NAME = 'CM-MIG-HW-01150');
-- and CM_ID = SRM_CIT_ID2
-- and t1.srm_tas_id = 'TAS01639' -- srm에서 종료된 티켓에 대해서만 보이도록 설정


(select cmbak_id from ESO_CM_BAK2 where 1=1 and CMBAK_TARGET_NAME = 'CM-MIG-HW-01150')
