/* NXT2.SSD.1.001 - 서비스 요청현황 */
SELECT 
    TYPE
    ,ENT_NAME
    ,CAT_LABEL1
    ,CASE TYPE WHEN 'REQ' THEN IFNULL(REQ_CNT,0) 
               WHEN 'RECP' THEN IFNULL(ACP_CNT,0)
               WHEN 'PROC' THEN IFNULL(PROC_CNT,0)
               WHEN 'DELAY' THEN IFNULL(DELAY_CNT,0) 
               WHEN 'COMP' THEN IFNULL(CLO_CNT,0)
               ELSE 0 END AS CNT
    ,'SRM' AS ENT_ID
FROM (
    SELECT * 
    FROM (
        SELECT 
            COUNT(*) AS REQ_CNT
            ,SUM(CASE WHEN TAS_ACT_ID IN ('ACT00725', 'ACT00726') THEN 1 ELSE 0 END) AS ACP_CNT				/* 접수대기 */
            ,SUM(CASE WHEN TAS_ACT_ID NOT IN ('ACT00725', 'ACT00726') AND SRM_CLO_CD IS NULL THEN 1 ELSE 0 END) AS PROC_CNT /* 처리중 */
            ,SUM(CASE WHEN DATEDIFF(STR_TO_DATE(SUBSTR(GET_SYSDATE(), 1, 8), '%Y%m%d'),
                                  STR_TO_DATE(SUBSTR(SRM_REG_DTTM, 1, 8), '%Y%m%d')) >=3 /* 등록 이후 3일 이상이면 지연 */
                                  AND SRM_CLO_CD IS NULL THEN 1
                        ELSE 0 END) AS DELAY_CNT	/* 지연 */
            ,SUM(CASE WHEN SRM_CLO_CD IS NOT NULL THEN 1 ELSE 0 END) AS CLO_CNT /* 당월 종료 */
        FROM ESO_SRM S JOIN EWF_TASK T ON S.SRM_TAS_ID = T.TAS_ID
        WHERE SRM_TAS_ID NOT IN ('TAS01632','TAS01776')	/* 임시저장, 취소종료 제외 */
          #{cond}
        ) AS AA
    ) AS STAT_VAL,
    (
    SELECT 'REQ' TYPE, '당월요청' ENT_NAME, '전월요청' CAT_LABEL1
    UNION ALL
    SELECT 'RECP' TYPE, '접수대기' ENT_NAME, '' CAT_LABEL1
    UNION ALL
    SELECT 'PROC' TYPE, '처리중' ENT_NAME, '' CAT_LABEL1
    UNION ALL
    SELECT 'DELAY' TYPE, '지연' ENT_NAME, '' CAT_LABEL1
    UNION ALL
    SELECT 'COMP' TYPE, '당월종료' ENT_NAME, '' CAT_LABEL1
    ) AS TEMPLATE
WHERE TYPE = 'REQ'

