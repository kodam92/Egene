select 
    ifnull(joined_table.tot_cnt, '0') as tot_cnt,
    ifnull(joined_table.tot_cnt, '0') as delay_percent,
    ifnull(joined_table.tot_cnt, '0') as ing_cnt
from (
    -- 모든 카테고리 코드를 먼저 추가
    select cod_id, cod_name 
    from ecf_code 
    where cod_cty_id = 'srmcat' 
      and cod_used = '1'
) all_cd
left join (
    -- 2. 실제 SRM data를 LEFT JOIN.
    select 
        cat_cd
        ,cod_name
        ,srm_reg_dttm
        ,tot_cnt
        ,concat(round(delay_cnt * 100.0 / nullif(tot_cnt, 0), 0),'%') as delay_percent
        ,ing_cnt
        ,dangerous_stat
    from total, status, ecf_code
    where srm_cat_cd = cat_cd
      and cod_id = srm_cat_cd 
      and cod_cty_id = 'srmcat' 
      and cod_used = '1'
) joined_table on all_cd.cod_id = joined_table.cod_id
order by all_cd.cod_id;