WITH ass_rslt AS (
    /* 1. tas_type이 3이 아닌 경우 (AutoAssign) */
    SELECT 
        'AutoAssign' AS rslt_type, -- 결과 구분용
        aas.aas_id as rslt_pid,
        CONCAT(get_wogname(aas.aas_wog_id), ' / ', 
            IFNULL(
                (SELECT GROUP_CONCAT(e.emp_name SEPARATOR ', ')  
                FROM ecf_member m 
                JOIN ecf_employee e ON m.mem_emp_id = e.emp_id 
                WHERE m.mem_wog_id = aas.aas_wog_id), 
                '인원 없음'
            )
        ) AS rslt_name,
        -- aas.aas_wog_id AS rslt_wog_id,
        frm.frm_id as rslt_frm_id
    FROM 
        ecf_autoassign aas
        JOIN ewf_task tas ON aas.aas_tas_id = tas.tas_id
        JOIN ecr_form frm ON tas.tas_id = frm.frm_tas_id
        JOIN ecr_frm_ui fru ON frm.frm_id = fru.fru_frm_id
    WHERE 
        aas.aas_ent_id = 'srm'
        AND tas.tas_used = '1'
        AND tas.tas_type != '9' AND tas.tas_type != '3' -- 종료 / 승인이 아닌 경우
        AND aas.aas_config LIKE CONCAT('%', frm.frm_tag, '%')
    UNION ALL
    /* 2. tas_type이 3인 경우 (결재자지정) */
    SELECT 
        '결재자지정' AS rslt_type, -- 결과 구분용
        apl.apl_id AS rslt_pid, 
        get_codename(apla.apla_cat_cd) AS rslt_name,
        frm.frm_id as rslt_frm_id
    FROM 
        eso_aprl apl
        JOIN ewf_task tas ON apl.apl_base_tas_id = tas.tas_id
        JOIN ecr_form frm ON tas.tas_id = frm.frm_tas_id
        JOIN ecr_frm_ui fru ON frm.frm_id = fru.fru_frm_id
        JOIN eso_aprl_attrib apla ON apla.apla_src_id = apl.apl_id
    WHERE 
        apl.apl_base_ent_id = 'srm'
        AND tas.tas_used = 1
        AND tas.tas_type = '3' -- 승인일 때만 실행
        AND apl.apl_base_cat_cd = frm.frm_tag
)
SELECT 
  act.act_order,
  tas.tas_order,
  frm.frm_id,
  frm.frm_name,
  frm.frm_tag,
  getcode_fullpath_name(frm.frm_tag) AS cat_name,
  frm.frm_tas_id,
  get_tasname(frm.frm_tas_id) AS tas_name,
  fru.fru_frm_id,
  fru.fru_frm_view,
  fru.fru_view_emp,
  rslt.rslt_id,
  rslt.rslt_name  
FROM ewf_activity act
    JOIN ewf_task tas ON act.act_id = tas.tas_act_id 
    JOIN ecr_form frm ON tas.tas_id = frm.frm_tas_id
    JOIN ecr_frm_ui fru ON frm.frm_id = fru.fru_frm_id
    LEFT JOIN ass_rslt rslt ON rslt.rslt_frm_id = frm.frm_id
WHERE act.act_wof_id = 'WOF00214' --  서비스요청관리 
    AND frm.frm_tag like 'SRMNXT2CAT%'
    -- 요청등록 및 승인, 종료 제외
    AND tas.tas_id IN ('TAS01635', 'TAS01766', 'TAS03090', 'TAS02187', 'TAS02188', 'TAS02189', 'TAS02190', 'TAS02191', 'TAS03098', 'TAS03099', 'TAS02192', 'TAS01638')
    #{cond}
ORDER BY #{orderby}








IFNULL(IFNULL(get_empname(fru.fru_view_emp),
      (SELECT GROUP_CONCAT(emp_name SEPARATOR ', ')  
       FROM ecf_member m JOIN ecf_employee e ON m.mem_emp_id = e.emp_id AND m.mem_wog_id = fru.fru_view_emp)),
       fru.fru_view_emp) AS ass_emp,

SELECT GROUP_CONCAT(emp_name SEPARATOR ', ')  
       FROM ecf_member m JOIN ecf_employee e ON m.mem_emp_id = e.emp_id AND m.mem_wog_id = fru.fru_view_emp)),
       fru.fru_view_emp)


(SELECT GROUP_CONCAT(emp_name SEPARATOR ', ')  
       FROM ecf_member m JOIN ecf_employee e ON m.mem_emp_id = e.emp_id AND m.mem_wog_id = aas.aas_wog_id) 