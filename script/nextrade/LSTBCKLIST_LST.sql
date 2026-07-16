with recursive cod_tmp as (
	  select t.*, t.cod_id root_id, 1 lev, concat(t.cod_name) as full_code_name
        from ecf_code t where t.cod_used = 1 and cod_cty_id = 'CMCAT' #{cond}
        
  union all
  
  select t.*, p.root_id, p.lev+1 lev, left(concat(p.full_code_name ,'>' , t.cod_name),100) as full_code_name  
    from ecf_code t, cod_tmp p where t.cod_used = 1 and t.cod_pid = p.cod_id  and t.cod_mtn_id = p.cod_mtn_id
 
 )
select distinct 
  t2.srm_id
  ,t1.cmbak_src_id                                         /*접수번호*/
  ,t3.cm_id                                                /*백업할 대상ID*/
  ,t3.cm_name                                              /*백업할 대상(자산명칭) - 미사용*/
  ,t3.cm_host_name                                         /*백업할 대상(호스트명)*/
  ,CASE WHEN t3.cm_used = 1 THEN '예'
          WHEN t3.cm_used = 0 THEN '아니오'
          ELSE '-'
   END AS cm_used_str                                      /*백업할 대상(사용여부) - 미사용*/
  ,get_codename(t3.cm_cat_cd) as cm_cat_cd_str             /*백업할 대상(자산분류)*/
  -- ,ifnull(t4.full_code_name, '-') as locale_cat_name    /*백업할 대상(전체자산분류) - 리스트 중복 방지*/
  ,t1.cmbak_target_name as bak_id                          /*백업장소ID*/
  ,(select cm_name from eso_cm where cm_id = t1.cmbak_target_name) as bak_name /*백업장소(자산명칭) - 미사용*/ 
  ,(select cm_host_name from eso_cm where cm_id = t1.cmbak_target_name) as bak_host_name /*백업장소(호스트명)*/ 
  ,CASE WHEN cmbak_used = 1 THEN '예'
        WHEN cmbak_used = 0 THEN '아니오'
        ELSE '-'
   END AS bak_used                                         /*백업사용여부*/
  ,ifnull(get_codename(cmbak_type),'-') as bak_type        /*백업타입*/
  ,ifnull((cmbak_cha),'-') as bak_cha                      /*백업경로*/
  ,ifnull(get_codename(cmbak_sort),'-') as bak_sort        /*백업방법*/
  ,ifnull(get_codename(cmbak_per),'-') as bak_per          /*백업주기*/
  ,ifnull(get_codename(cmbak_stg_per),'-') as bak_stg_per  /*백업보관기간*/
  ,ifnull(cmbak_actstart_dttm,'-') as bak_actstart_dttm    /*백업수행시점*/
  ,CASE WHEN cmbak_diss = 1 THEN '예'
        WHEN cmbak_diss = 0 THEN '아니오'
        ELSE '-'
   END AS bak_diss                                         /*소산여부*/
  ,ifnull(fm_ldt(cmbak_start_dttm),'-') as bak_start_dttm  /*백업시작일시*/
  ,ifnull(fm_ldt(cmbak_end_dttm),'-') as bak_end_dttm      /*백업종료일시*/
  ,ifnull(get_empname(cmbak_req_emp),'-') as bak_req_emp   /*백업요청자*/
from eso_wf_cm t
     ,eso_cm_bak2 t1
     ,eso_srm  t2
     ,eso_cm t3
     ,cod_tmp t4
where 1=1
and t.wfc_src_id = t1.cmbak_src_id
and t1.cmbak_src_id = t2.srm_id 
and  upper(t3.cm_id) = upper(t.wfc_cm_id)
and t4.cod_id = t3.cm_cat_cd 
and (t2.srm_tas_id = 'TAS01639'  or t2.srm_tas_id='TAS02213')-- SRM종료된 건만 보이도록
#{cond1}