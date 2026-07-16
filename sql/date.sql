date_range as (
  select 
    concat(t.week_idx, 'w') as range_id
    ,min(t.hod_dt) as start_date
    ,max(t.hod_dt) as end_date
  from (
    select 
        hod_dt,
        -- 일요일(1)을 기준으로 주차를 그룹핑하는 로직
        dense_rank() over (order by date_sub(hod_dt, interval(hod_dow_type - 1) day)
        ) as week_idx
    from ecf_holiday
    where substr(hod_dt,1,6) = '202602'
  ) as t
  group by t.week_idx
  union all 
    select 
    '1m' as range_id,
    date_format(str_to_date(concat('202602', '01'), '%Y%m%d'), '%Y%m01') as start_date,
    date_format(last_day(str_to_date(concat('202602', '01'), '%Y%m%d')), '%Y%m%d') as end_date
  union all 
    select 
    '3m' as range_id,
    date_format(date_sub(str_to_date(concat('202602', '01'), '%Y%m%d'), interval 3 month), '%Y%m01') as start_date,
    date_format(last_day(str_to_date(concat('202602', '01'), '%Y%m%d')), '%Y%m%d') as end_date
  union all 
    select 
    '6m' as range_id,
    date_format(date_sub(str_to_date(concat('202602', '01'), '%Y%m%d'), interval 6 month), '%Y%m01') as start_date,
    date_format(last_day(str_to_date(concat('202602', '01'), '%Y%m%d')), '%Y%m%d') as end_date
),