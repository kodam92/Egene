select emp_id, emp_name, emp_email, emp_hphone, count(1) as cnt from
(
select mem_emp_id as emp_id, emp_name, emp_email, emp_hphone, iss_sr_id
from eso_issue, ecf_employee, ecf_member
where mem_wog_id = iss_ass_wog_id
  and emp_id = mem_emp_id
  and ifnull(emp_used,0) = 1
  and iss_ent_id in ('SRM','CHM','ICM','PBM','CHK') -- 서비스요청, (APP/INF)변경관리, 장애관리, 이슈관리, 점검관리
  and (iss_ass_wog_id is not null and iss_ass_wog_id != '')
  and iss_tas_type in ('2','4','0') -- 단계유형이 접수, 처리, 진행인 단계들만 조회

union all

select emp_id, emp_name, emp_email, emp_hphone, iss_sr_idd
from eso_issue, ecf_employee 
where emp_id = iss_ass_emp_id 
and ifnull(emp_used,0) = 1
and iss_ent_id in ('SRM','CHM','ICM','PBM', 'CHK') 
and (iss_ass_emp_id is not null and iss_ass_emp_id != '') -- 서비스요청, (APP/INF)변경관리, 장애관리, 이슈관리
and iss_tas_type in ('2','4','0') -- 단계유형이 접수, 처리, 진행인 단계들만 조회
) t
group by emp_id