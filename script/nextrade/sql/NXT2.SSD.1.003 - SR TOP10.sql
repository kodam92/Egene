with recursive cod_layer as (
    select 
        t.cod_id, t.cod_pid, t.cod_name, 1 as level, 
        t.cod_name as full_code_name,
        cast(null as char(50)) as grp_id -- level 1은 그룹이 없으므로 null
    from ecf_code t 
    where t.cod_used = 1 
      and (t.cod_pid is null or t.cod_pid = '') 
      and t.cod_cty_id = 'srmcat' and t.cod_used = 1 -- cod_id like 'SRMNXT2CAT%'
    union all
    select 
        t.cod_id, t.cod_pid, t.cod_name, p.level+1, 
        concat(p.full_code_name, ' > ', t.cod_name),
        -- 현재 레벨이 2이면 자신의 id가 그룹 id가 되고, 2보다 크면 상위 그룹 id 유지 
        case when p.level+1 = 2 then t.cod_id 
            else p.grp_id end as grp_id
    from ecf_code t
    inner join cod_layer p on t.cod_pid = p.cod_id 
    where t.cod_used = 1
), -- 서비스요청처럼 그룹화
cod_layer_compitable as(
    select cod_id, grp_id from cod_layer
    union all
    select ec.con_sub_code as cod_id, cl.grp_id
    from ecf_ccon ec join cod_layer cl on ec.con_id = cl.cod_id
),  -- 예전버전의 cat_cd와 호환
sr_count as(
    select 
        srm_cat_cd,
        get_codename(srm_cat_cd) as cat_name,
        clc.grp_id,
        get_codename(clc.grp_id) as grp_name,
        count(1) as cnt
    from eso_srm join cod_layer_compitable clc on clc.cod_id = srm_cat_cd
    where clc.grp_id is not null 
        and srm_tas_id not in ('TAS01632','TAS01776')	/* 임시저장, 취소종료 제외 */
        and substr(srm_reg_dttm,1,6) = '202602' -- #{cond}
    group by srm_cat_cd
)
select 
    grp_id as item0_id,
    get_codename(grp_id) as name,
    sum(cnt) as cnt
from sr_count 
group by grp_id
limit 10