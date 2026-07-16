select 
    get_dptname(d.dpt_id) as dpt_name, -- 부서 이름
    count(s.srm_id) as tot_cnt        -- 부서별 SRM 등록 건수
from ecf_dept d
left join eso_srm s
    on d.dpt_id = s.srm_reg_dpt_id
    and s.srm_tas_id not in ('TAS01632', 'TAS01776') -- 임시저장, 취소종료 제외
    and substr(s.srm_reg_dttm, 1, 6) = '202601'      -- 이번 달 데이터만 #{cond}
group by d.dpt_id