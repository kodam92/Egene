select  
  es.srm_id as "key"
  ,es.srm_id as srm_id
  ,get_codename(es.srm_cat_cd) as cat_name
  ,es.srm_tas_id as tas_id
  ,et.tas_name as tas_name
  ,es.srm_req_title as req_title
  ,ifnull(get_empname(es.srm_ass_emp_id), get_wogname(es.srm_ass_wog_id)) as ass_info
from eso_srm es
  join ewf_task et on es.srm_tas_id = et.tas_id
  join eso_chm ec on es.srm_id = ec.chm_dep_srm_id
where 1=1
  and srm_tas_is is not null
  #{cond}