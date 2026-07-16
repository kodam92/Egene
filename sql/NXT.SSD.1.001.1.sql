SELECT 
        TYPE
      , ENT_NAME
      , CAT_LABEL1
	  ,	CASE TYPE WHEN 'REQ' THEN IFNULL(REQ_CNT,0) 
                  WHEN 'RECP' THEN IFNULL(ACP_CNT,0) 
                  WHEN 'PROC' THEN IFNULL(PROC_CNT,0) 
                  WHEN 'DELAY' THEN IFNULL(DELAY_CNT,0) 
                  WHEN 'COMP' THEN IFNULL(CLO_CNT,0)
                  ELSE 0 END AS CNT
      , CASE TYPE WHEN 'REQ' THEN LAST_MONTH_REQ_CNT 
      		      ELSE 0 END AS SAT1
      , CASE TYPE WHEN 'COMP' THEN DELAY_ACT_CNT
                  ELSE 0 END AS DELAY
      , 'SRM' AS ENT_ID
  FROM 	(
		SELECT * 
		  FROM (
		  		SELECT 
		  				SUM(CASE WHEN SRM_TAS_ID IN ('TAS01635', 'TAS01766') THEN 1 ELSE 0 END) AS ACP_CNT				/* 접수대기 */
		  			  , SUM(CASE WHEN TAS_ACT_ID IN ('ACT00727', 'ACT01057', 'ACT01058') THEN 1 ELSE 0 END) AS PROC_CNT /* 처리중 */
		  			  , SUM(CASE WHEN SRM_TAS_ID IN ('TAS01773', 'TAS01637', 'TAS01636', 'TAS01668')
		  			                             AND SRM_ACT_DTTM IS NULL
		  			                             AND SUBSTR(IFNULL(SRM_AGREE_DTTM, SRM_DEAD_DTTM),1, 8) < DATE_FORMAT(NOW(), '%Y%m%d') THEN 1 
		  			             ELSE 0 END) AS DELAY_CNT	/* 지연 */
		          FROM ESO_SRM S JOIN EWF_TASK T ON S.SRM_TAS_ID = T.TAS_ID
		         WHERE 1=1
		          #{cond}
		        ) AS AA,
		       /* 당월 현황 */
		       (
		       	SELECT 
		       			COUNT(*) AS REQ_CNT											/* 당월요청 */
		              , SUM((IFNULL(SRM_SAT1, 0) + IFNULL(SRM_SAT1, 0)) / 2) AS STF_SUM
		              , SUM(CASE WHEN SRM_SAT1 IS NOT NULL THEN 1 ELSE 0 END) AS STF_CNT
		              , SUM(CASE SRM_MED_CD WHEN 'SRMMED010' THEN 0 ELSE 1 END) AS CALL_CNT
				  FROM ESO_SRM
		         WHERE SUBSTR(IFNULL(SRM_REG_DTTM,SRM_REQ_DTTM), 1, 6) = DATE_FORMAT(NOW(), '%Y%m')
		            AND SRM_TAS_ID NOT IN ('TAS01632','TAS01776')	/* 임시저장, 취소종료 제외 */
		            #{cond}
		       ) AS BB,
		       /* 당월 처리 */
		       (
		        SELECT 
		       			COUNT(*) AS CLO_CNT /* 당월 종료 */
		       		  , SUM(CASE WHEN SUBSTR(IFNULL(SRM_AGREE_DTTM, SRM_DEAD_DTTM),1, 8) < SRM_ACT_DTTM THEN 1 ELSE 0 END) AS DELAY_ACT_CNT /* 비적기 처리 */
		          FROM ESO_SRM
		         WHERE substr(SRM_CLO_DTTM, 1, 6) = DATE_FORMAT(NOW(), '%Y%m')
		           AND srm_tas_id not in ('TAS01632','TAS01776')
		           #{cond}
		       ) AS CC,
		       (
		        SELECT 
		                COUNT(*) AS LAST_MONTH_REQ_CNT
		              , SUM((IFNULL(SRM_SAT1, 0) + IFNULL(SRM_SAT1, 0)) / 2) LAST_MONTH_STF_SUM
		              , SUM(CASE WHEN SRM_SAT1 IS NOT NULL THEN 1 ELSE 0 END) LAST_MONTH_STF_CNT
		              , SUM(CASE SRM_MED_CD WHEN 'SRMMED010' THEN 0 ELSE 1 END) LAST_MONTH_CALL_CNT
				  FROM eso_srm
		         WHERE SUBSTR(IFNULL(SRM_REG_DTTM,SRM_REQ_DTTM), 1, 6) = DATE_FORMAT(DATE_ADD(NOW(), INTERVAL -1 MONTH), '%Y%m')
		            AND SRM_TAS_ID NOT IN ('TAS01632','TAS01776')	/* 임시저장, 취소종료 제외 */
		            #{cond}
		       ) AS DD
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
		WHERE TYPE = 'RECP'