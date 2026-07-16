-- egene66_nextrade.eso_srm_wf definition

CREATE TABLE `eso_srm_wf` (
  `WFF_SRC_ID` varchar(20) DEFAULT NULL,
  `WFF_REG_DTTM` varchar(14) DEFAULT NULL,
  `WFF_TAS_ID` varchar(20) DEFAULT NULL,
  `WFF_NEXT_TAS_ID` varchar(20) DEFAULT NULL,
  `WFF_ORG_ID` varchar(20) DEFAULT NULL,
  `WFF_DPT_ID` varchar(20) DEFAULT NULL,
  `WFF_WOG_ID` varchar(20) DEFAULT NULL,
  `WFF_EMP_ID` varchar(20) DEFAULT NULL,
  `WFF_CURRENT` varchar(1) DEFAULT NULL,
  `wff_id` varchar(100) DEFAULT NULL,
  `WFF_GRADE_CD` varchar(100) DEFAULT NULL,
  `WFF_TITLE_CD` varchar(100) DEFAULT NULL,
  `WFF_DUTY_CD` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;