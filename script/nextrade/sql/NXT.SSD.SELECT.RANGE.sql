select
  id,
  name
from (
  select
    '1w' as id,
    '1주차' as name
  from dual
  union all
  select
    '2w' as id,
    '2주차' as name
  from dual
  union all
  select
    '3w' as id,
    '3주차' as name
  from dual
  union all
  select
    '4w' as id,
    '4주차' as name
  from dual
  union all
  select
    '5w' as id,
    '5주차' as name
  from dual
) range