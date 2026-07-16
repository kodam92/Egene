case when clm_ci_mlt_yn = 0 then ifnull(substring_index(get_sysname(clm_target_name), '/', -1), '-')
     when clm_ci_mlt_yn = 1 then ifnull((
            select group_concat(cm_name order by cm_name separator ', ')
            from eso_cm
            where cm_id in (
                select wfc_cm_id 
                from eso_wf_cm 
                where wfc_src_id = clm_id
            )
        ), '-') end as target_name




