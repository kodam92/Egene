/* 1. 히스토리맵 wff_current Update*/
update eso_chm_wf
set wff_current = '0' 
where wff_current = '1'
  and wff_src_id in (
    select chm_id 
    from eso_chm   
    where chm_tas_id = 'TAS03116' -- 배포대기중
      and chm_dep_hold_yn = 1
      and chm_dep_srm_id = ?
  )

{
  "cols":"key"
},

 __END__

 /* 2. 배포 항목 - 배포 히스토리맵 생성*/
 insert into eso_chm_wf ( 
  wff_id
  ,wff_src_id
  ,wff_reg_dttm
  ,wff_tas_id
  ,wff_next_tas_id
  ,wff_org_id
  ,wff_dpt_id
  ,wff_emp_id
  ,wff_current
)
select 
  ?           -- wff_id
  ,chm_id     -- wff_src_id
  ,?          -- wff_reg_dttm
  ,'TAS03116' -- wff_tas_id (배포대기중)
  ,'TAS02205' -- wff_next_tas_id (배포)
  ,org_id -- wff_org_id
  ,dpt_id -- wff_dpt_id
  ,?      -- wff_emp_id
  ,'1'            -- wff_current
from eso_chm 
  join ecf_employee on emp_id = ?
  join ecf_dept on dpt_id = emp_dpt_id 
	join ecf_org on org_id = emp_org_id
where chm_tas_id = 'TAS03116' -- 배포대기중
  and chm_dep_hold_yn = 1 and chm_dep_yn = 1
  and chm_dep_srm_id  = ?

{
  "cols":"s_id,cur_dttm,emp_id,emp_id,key",
  "vars":"s_id=ukey"
},

 __END__

/* 3. 배포 항목 - ISSUE Tas ID 배포로 갱신*/
update eso_issue
set iss_tas_id = 'TAS02205', -- 배포
  iss_mod_dttm = ?
  -- issue_tas_type = '4'
where iss_sr_id in (
    select chm_id 
    from eso_chm   
    where chm_tas_id = 'TAS03116' -- 배포대기중
      and chm_dep_hold_yn = 1 and chm_dep_yn = 1
      and chm_dep_srm_id = ?
  )


{
  "cols":"cur_dttm,key"
},

/* 4. 배포 항목 - CHM Tas ID 배포로 갱신*/
update eso_chm
set chm_tas_id = 'TAS02205' -- 배포
where chm_tas_id = 'TAS03116' -- 배포대기중
  and chm_dep_hold_yn = 1 and chm_dep_yn = 1
  and chm_dep_srm_id = ?

{
  "cols":"key"
},

__END__ 



 /* 5. 미배포 항목 - 기각종료 히스토리맵 생성*/
 insert into eso_chm_wf ( 
  wff_id
  ,wff_src_id
  ,wff_reg_dttm
  ,wff_tas_id
  ,wff_next_tas_id
  ,wff_org_id
  ,wff_dpt_id
  ,wff_emp_id
  ,wff_current
)
select 
  ?           -- wff_id
  ,chm_id     -- wff_src_id
  ,?          -- wff_reg_dttm
  ,'TAS03116' -- wff_tas_id (배포대기중)
  ,'TAS01704' -- wff_next_tas_id (종료)
  ,org_id -- wff_org_id
  ,dpt_id -- wff_dpt_id
  ,?      -- wff_emp_id
  ,'1'            -- wff_current
from eso_chm 
  join ecf_employee on emp_id = ?
  join ecf_dept on dpt_id = emp_dpt_id 
	join ecf_org on org_id = emp_org_id
where chm_tas_id = 'TAS03116' -- 배포대기중
  and chm_dep_hold_yn = 1 and chm_dep_yn = 0
  and chm_dep_srm_id  = ?

{
  "cols":"s_id,cur_dttm,emp_id,emp_id,key",
  "vars":"s_id=ukey"
},

 __END__

/* 6. 미배포 항목 - ISSUE Tas ID 기각종료로 갱신*/
update eso_issue
set iss_tas_id = 'TAS01704', -- 종료
  iss_mod_dttm = ?,
  iss_tas_type = '9'
where iss_sr_id in (
    select chm_id 
    from eso_chm   
    where chm_tas_id = 'TAS03116' -- 배포대기중
      and chm_dep_hold_yn = 1 and chm_dep_yn = 0
      and chm_dep_srm_id = ?
  )

{
  "cols":"cur_dttm,key"
},

/* 7. 미배포 항목 - CHM Tas ID 기각종료로 갱신*/
update eso_chm
set chm_tas_id = 'TAS01704' -- 종료
where chm_tas_id = 'TAS03116' -- 배포대기중
  and chm_dep_hold_yn = 1 and chm_dep_yn = 0
  and chm_dep_srm_id = ?

{
  "cols":"key"
},

__END__ 

