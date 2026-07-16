select  
       ifnull(cm_id, '-') as his_src_id,
       ifnull(cm_id, '-') as btn_id,
       ifnull(cm_name, '-') as cm_name,
       ifnull(his_emp_nm, '-') as his_emp_nm,
       ifnull(fm_ldt(his_reg_dttm), '-') as his_reg_dttm,
       ifnull(group_concat(cm_col_nm), '-') as cm_col_nm,
       ''  as detail
from (
  select
      get_empname(his_usr_id) as his_emp_nm,
      his_reg_dttm,
      his_fld_name as cm_col_nm,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_oval),his_fld_oval) cm_before,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_nval),his_fld_nval) cm_after,
      his_src_id as cm_id,
      replace(his_src_id, '-', '_') nkey,
      (select cm_name from eso_cm where cm_id = his_src_id) cm_name
  from eso_cm_history
  union all
    -- 2. 서버 정보 변경 이력 (eso_cm_svr_history)
  select  
      get_empname(his_usr_id) as his_emp_nm,
      his_reg_dttm,
      his_fld_name AS cm_col_nm,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_oval),his_fld_oval) cm_before,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_nval),his_fld_nval) cm_after,
      (select cmsvr_src_id from eso_cm_svr where cmsvr_id = his_src_id) as cm_id, -- 원본 cm_id 추출
      replace(his_src_id, '-', '_') nkey,
      (select cm_name from eso_cm_svr join eso_cm c on cmsvr_src_id = cm_id where cmsvr_id = his_src_id) cm_name
  from eso_cm_svr_history
  union all
    -- 3. 스토리지/백업 정보 변경 이력 (eso_cm_sto_history)
  select  
      get_empname(his_usr_id) as his_emp_nm,
      his_reg_dttm,
      his_fld_name AS cm_col_nm,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_oval),his_fld_oval) cm_before,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_nval),his_fld_nval) cm_after,
      (select cmsto_src_id from eso_cm_sto where cmsto_id = his_src_id) as cm_id, -- 원본 cm_id 추출
      replace(his_src_id, '-', '_') nkey,
      (select cm_name from eso_cm_sto join eso_cm c on cmsto_src_id = cm_id where cmsto_id = his_src_id) cm_name
  from eso_cm_sto_history
  union all
    -- 4. 정보보호 정보 변경 이력 (eso_cm_se_history)
  select  
      get_empname(his_usr_id) as his_emp_nm,
      his_reg_dttm,
      his_fld_name AS cm_col_nm,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_oval),his_fld_oval) cm_before,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_nval),his_fld_nval) cm_after,
      (select cmse_src_id from eso_cm_se where cmse_id = his_src_id) as cm_id, -- 원본 cm_id 추출
      replace(his_src_id, '-', '_') nkey,
      (select cm_name from eso_cm_se join eso_cm c on cmse_src_id = cm_id where cmse_id = his_src_id) cm_name
  from eso_cm_se_history
  union all
    -- 5. PCOA 정보 변경 이력 (eso_cm_pcoa_history)
  select  
      get_empname(his_usr_id) as his_emp_nm,
      his_reg_dttm,
      his_fld_name AS cm_col_nm,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_oval),his_fld_oval) cm_before,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_nval),his_fld_nval) cm_after,
      (select cmpcoa_src_id from eso_cm_pcoa where cmpcoa_id = his_src_id) as cm_id, -- 원본 cm_id 추출
      replace(his_src_id, '-', '_') nkey,
      (select cm_name from eso_cm_pcoa join eso_cm c on cmpcoa_src_id = cm_id where cmpcoa_id = his_src_id) cm_name
  from eso_cm_pcoa_history
  union all
    -- 6. SW 정보 변경 이력 (eso_cm_sw_history)
  select  
      get_empname(his_usr_id) as his_emp_nm,
      his_reg_dttm,
      his_fld_name AS cm_col_nm,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_oval),his_fld_oval) cm_before,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_nval),his_fld_nval) cm_after,
      (select cmsw_src_id from eso_cm_sw where cmsw_id = his_src_id) as cm_id, -- 원본 cm_id 추출
      replace(his_src_id, '-', '_') nkey,
      (select cm_name from eso_cm_sw join eso_cm c on cmsw_src_id = cm_id where cmsw_id = his_src_id) cm_name
  from eso_cm_sw_history
  union all
     -- 7. 응용시스템 정보 변경 이력 (eso_cm_sys_history)
  select  
      get_empname(his_usr_id) as his_emp_nm,
      his_reg_dttm,
      his_fld_name AS cm_col_nm,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_oval),his_fld_oval) cm_before,
      ifnull((select cod_name from ecf_code where cod_id = his_fld_nval),his_fld_nval) cm_after,
      (select cmsys_src_id from eso_cm_sys where cmsys_id = his_src_id) as cm_id, -- 원본 cm_id 추출
      replace(his_src_id, '-', '_') nkey,
      (select cm_name from eso_cm_sys join eso_cm c on cmsys_src_id = cm_id where cmsys_id = his_src_id) cm_name
  from eso_cm_sys_history
) t1 
#{cond}
 group by ifnull(his_src_id, '-'), ifnull(cm_name, '-'), ifnull(his_emp_nm, '-'), ifnull(fm_ldt(his_reg_dttm), '-')
 order by #{orderby}










 SELECT 
    GET_EMPNAME(t.his_emp_id) AS his_emp_nm,      -- 변경자
    FM_LDT(t.his_reg_dttm) AS his_reg_dttm,        -- 변경일시
    t.cm_id AS his_src_id,                         -- 최종 표시될 원본 자산 ID (cm_id)
    t.cm_name,                                     -- CI명
    t.his_fld_name,                                -- 변경한속성
    t.his_fld_oval,                                -- 변경전내용
    t.his_fld_nval                                 -- 변경후내용
FROM (
    -- 1. 공통 정보 변경 이력
    SELECT 
        h.his_emp_id,
        h.his_reg_dttm,
        h.his_src_id AS cm_id,                     -- 공통 이력의 his_src_id는 바로 cm_id
        c.cm_name,
        h.his_fld_name,
        h.his_fld_oval,
        h.his_fld_nval
    FROM eso_cm_history h
    LEFT JOIN eso_cm c ON c.cm_id = h.his_src_id

    UNION ALL

    -- 2. 서버 정보 변경 이력
    SELECT 
        h.his_emp_id,
        h.his_reg_dttm,
        s.cmsvr_src_id AS cm_id,                   -- 서버 맵핑 테이블을 통해 원본 cm_id 추출
        c.cm_name,
        h.his_fld_name,
        h.his_fld_oval,
        h.his_fld_nval
    FROM eso_cm_svr_history h
    LEFT JOIN eso_cm_svr s ON s.cmsvr_id = h.his_src_id
    LEFT JOIN eso_cm c ON c.cm_id = s.cmsvr_src_id

    UNION ALL

    -- 3. 네트워크 정보 변경 이력
    SELECT 
        h.his_emp_id,
        h.his_reg_dttm,
        n.cmnet_src_id AS cm_id,                   -- 네트워크 맵핑 테이블을 통해 원본 cm_id 추출
        c.cm_name,
        h.his_fld_name,
        h.his_fld_oval,
        h.his_fld_nval
    FROM eso_cm_net_history h
    LEFT JOIN eso_cm_net n ON n.cmnet_id = h.his_src_id
    LEFT JOIN eso_cm c ON c.cm_id = n.cmnet_src_id
) t
ORDER BY t.his_reg_dttm DESC;                      -- 최근 변경 항목부터 정렬 (필요에 따라 수정 가능)