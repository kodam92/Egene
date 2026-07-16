/* 1. tas_type이 3이 아닌 경우 (A쿼리 로직) */
SELECT 
    'ASSIGN' AS result_type, -- 결과 구분용
    ea.aas_id as result_id,
    ea.aas_wog_id AS result_name  
FROM 
    ecf_autoassign ea
    JOIN ewf_task t ON ea.aas_tas_id = t.tas_id
    JOIN ecr_form f ON t.tas_id = f.frm_tas_id
    JOIN ecr_frm_ui fui ON f.frm_id = fui.fru_frm_id
WHERE 
    ea.aas_ent_id = 'SRM'
    AND t.tas_used = '1'
    AND t.tas_type != '9' AND t.tas_type != '3' -- 종료 / 승인이 아닌 경우
    AND ea.aas_config LIKE CONCAT('%', f.frm_tag, '%')
    #{cond}

UNION ALL

/* 2. tas_type이 3인 경우 (B쿼리 로직) */
SELECT 
    'APPROVAL' AS result_type, -- 결과 구분용
    ea.apl_id AS result_id, 
    get_codename(eaa.apla_cat_cd) AS result_name
FROM 
    eso_aprl ea
    JOIN ewf_task t ON ea.apl_base_tas_id = t.tas_id
    JOIN ecr_form f ON t.tas_id = f.frm_tas_id
    JOIN ecr_frm_ui fui ON f.frm_id = fui.fru_frm_id
    JOIN eso_aprl_attrib eaa ON eaa.apla_src_id = ea.apl_id
WHERE 
    ea.apl_base_ent_id = 'SRM'
    AND t.tas_used = 1
    AND t.tas_type = '3' -- 승인일 때만 실행
    AND ea.apl_base_cat_cd = f.frm_tag
    #{cond}