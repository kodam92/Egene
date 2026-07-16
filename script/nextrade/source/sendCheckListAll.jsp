<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=utf-8" %>

<%@ include file="/xefc/jsp/common/import.jspf" %>

<%
    Box box = HttpUtility.getBox(request);
    Log.act.info("---START CheckList--");

    try {
        ICE ice = ICE.getInstance();
        Sqls sqls = ice.sqls();
        Users users = ice.users();

        String sql_id = "";
        String sql_id_rel = "";
        User user = null;
        TrxContext trx = null;
        Connection con = null;

        user = users.getUser("admin");
        session.setAttribute("egene.user", user);

        Calendar today = Calendar.getInstance();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
        String dateStr = dateFormat.format(today.getTime());

        sql_id = "Holiday.select";
        box.put("date", dateStr);

        Result holidayResult = sqls.getResult(sql_id, box);
        RecordSet holidayRS = holidayResult.getRecordSet();

        if (holidayRS.next()) {
            String hodId = holidayRS.get("hod_id");
            String hodDowType = holidayRS.get("hod_dow_type");
            String hodType = holidayRS.get("hod_type");
            String day = hodId.substring(hodId.length() - 2);
            boolean daily = "HODTYP01".equals(hodType);
            boolean week = "2".equals(hodDowType);
            boolean month = "01".equals(hodId.substring(hodId.length() - 2));

            if (week && month && daily) {
                box.put("daily", "CHKCYL01000");
                box.put("week", "CHKCYL02000");
                box.put("month", "CHKCYL03000");
            } else if (week && daily) {
                box.put("daily", "CHKCYL01000");
                box.put("week", "CHKCYL02000");
            } else if (month && daily) {
                box.put("daily", "CHKCYL01000");
                box.put("month", "CHKCYL03000");
            } else if (week && month) {
                box.put("week", "CHKCYL02000");
                box.put("month", "CHKCYL03000");
            } else if (!week && !month && daily) {
                box.put("daily", "CHKCYL01000");
            } else if (week) {
                box.put("week", "CHKCYL02000");
            } else if (month) {
                box.put("month", "CHKCYL03000");
            }
            if (box.get("daily") == "") box.put("daily", "empty");
            if (box.get("week") == "") box.put("week", "empty");
            if (box.get("month") == "") box.put("month", "empty");

            sql_id = "CLM.CheckList.All";
            Result clmResult = sqls.getResult(sql_id, box);
            RecordSet clmRS = clmResult.getRecordSet();

            if (clmRS.getRowCount() > 0) {
                EntityMap entityMap = ice.map();
                Entity chkmEntity = entityMap.getEntity("CHKM");
                Row chkmRow = null;
                Entity chkEntity = entityMap.getEntity("CHK");
                Row chkRow = null;
                Entity chrEntity = entityMap.getEntity("CHR");
                Row chrRow = null;

                String chkmCtlId = "CTL03164";
                String chkCtlId = "CTL02697";
                
                SimpleDateFormat date = new SimpleDateFormat("yyyy/MM/dd");
                String today1 = date.format(today.getTime());

                Wfms wfms = Wfms.getInstance();
                Control chkmCtl = wfms.getControl(chkmCtlId);

                box.put("var/ent_id", "CHKM");
                box.put("var/frm_id", "");
                box.put("var/tas_id", "TAS02204");
                box.put("var/act", "1");
  
                Result clmResultchkm = sqls.getResult(sql_id, box);
                RecordSet clmRSchkm = clmResultchkm.getRecordSet();

                // CHKM 박스 설정
                if (clmRSchkm.next()) {
                    String claCdChkm = clmRSchkm.get("cla_cd"); 
                    chkmRow = chkmEntity.openNew();
                    
                    if ("CLMCLA010".equals(claCdChkm)) {
                        box.put("chkm_req_title", today1 + "_감사일지");
                        box.put("chkm_cla_cd", "CLMCLA010");
                        box.put("chkm_tas_id", "TAS02200");
                    } else if ("CLMCLA020".equals(claCdChkm)) {
                        box.put("chkm_req_title", today1 + "_점검일지");
                        box.put("chkm_cla_cd", "CLMCLA020");
                        box.put("chkm_tas_id", "TAS02200");
                    } else if ("CLMCLA030".equals(claCdChkm)) {
                        box.put("chkm_req_title", today1 + "_정보보안_점검일지");
                        box.put("chkm_cla_cd", "CLMCLA030");
                        box.put("chkm_tas_id", "TAS02200");
                    }
                    chkmEntity.save(chkmRow, chkmCtl, box, session, request);
                }
                
                Control chkCtl = wfms.getControl(chkCtlId);

                box.put("var/ent_id", "CHK");
                box.put("var/frm_id", "");
                box.put("var/tas_id", "TAS01750");
                box.put("var/act", "1");

                while (clmRS.next()) {
                    if (validCheckList(clmRS.get("clm_cyl_cfg"), daily, hodDowType, hodId)) {
                        String clmId = clmRS.get("clm_id");
                        String catCd = clmRS.get("cat_cd");
                        String reqDttm = clmRS.get("req_dttm");
                        String actStartDttm = clmRS.get("actstart_dttm");
                        String actFinishDttm = clmRS.get("actfinish_dttm");
                        String regEmpId = clmRS.get("reg_emp_id");
                        String orgId = clmRS.get("reg_org_id");
                        String dptId = clmRS.get("reg_dpt_id");
                        String acpEmpId = clmRS.get("acp_emp_id");
                        String wogId = clmRS.get("acp_wog_id");
                        String actEmpId = clmRS.get("act_emp_id");
                        String reqTitle = clmRS.get("req_title");
                        String cylCd = clmRS.get("cyl_cd");
                        String acpCd = clmRS.get("acp_cd");
                        String targetName = clmRS.get("target_name");
                        String claCd = clmRS.get("cla_cd"); 

                        chkRow = chkEntity.openNew();

                        if ("CLMCLA010".equals(claCd)) {
                            box.put("chk_tas_id", "CHKTAS03111");
                        } else if ("CLMCLA020".equals(claCd)) {
                            box.put("chk_tas_id", "CHKTAS01670");
                        } else if ("CLMCLA030".equals(claCd)) {
                            box.put("chk_tas_id", "CHKTAS03116");
                        }

                        box.put("chk_src_id", chkmRow.key);
                        box.put("chk_cat_cd", catCd);
                        box.put("chk_reg_dttm", reqDttm);
                        box.put("chk_req_dttm", reqDttm);
                        box.put("chk_actstart_dttm", actStartDttm);
                        box.put("chk_actfinish_dttm", actFinishDttm);
                        box.put("chk_reg_emp_id", regEmpId);
                        box.put("chk_req_emp_id", regEmpId);
                        box.put("chk_reg_org_id", orgId);
                        box.put("chk_req_org_id", orgId);
                        box.put("chk_reg_dpt_id", dptId);
                        box.put("chk_req_dpt_id", dptId);
                        box.put("chk_acp_emp_id", acpEmpId);
                        box.put("chk_ass_emp_id", acpEmpId);
                        box.put("chk_acp_wog_id", wogId);
                        box.put("chk_ass_wog_id", wogId);
                        box.put("chk_act_emp_id", actEmpId);
                        box.put("chk_req_title", reqTitle);
                        box.put("chk_cyl_cd", cylCd);
                        box.put("chk_acp_cd", acpCd);
                        box.put("chk_acp_req_dttm", dateStr);
                        box.put("chk_target_name", targetName);
                        box.put("chk_clm_id", clmId);
                        box.put("chk_cla_cd", claCd);

                        chkEntity.save(chkRow, chkCtl, box, session, request);

                        sql_id_rel = "CLM.CheckList.Relation";
                        box.put("clm_id", clmId);
                        Result clmRelResult = sqls.getResult(sql_id_rel, box);
                        RecordSet clmRelRS = clmRelResult.getRecordSet();

                        while (clmRelRS.next()) {
                            String clrRegDttm = clmRelRS.get("reg_dttm");
                            String empId = clmRelRS.get("emp_id");
                            String chkId = chkRow.key;
                            String clrClmId = clmRelRS.get("clm_id");
                            String chdId = clmRelRS.get("chd_id");
                            //TODO : 감사항목의 주기를 가져와서 비교후 해당하는 것만 아래 코드롤 사용해 추가 

                            chrRow = chrEntity.openNew();
                            box.put("chr_req_dttm", reqDttm);
                            box.put("chr_reg_emp_id", empId);
                            box.put("chr_chk_id", chkId);
                            box.put("chr_clm_id", clrClmId);
                            box.put("chr_chd_id", chdId);
                            box.put("chr_rslt_yn", 1);
                            chrEntity.save(chrRow, null, box, session, request);
                        }
                    }
                }
            }
        }
    } catch (BizError ex) {
        Log.biz.err(ex);
    } catch (Exception ex) {
        Log.biz.err(ex);
    } finally {
        //try {if (con != null) con.close();} catch (Exception ex) {}
    }

    Log.act.info("--END CheckList--");
%>

<%!

    /**
     *
     * @param _configValue  점검주기 설정 정보
     * @param businessDay   업무일 여부
     * @param dayOfWeek     요일
     * @param date          오늘 날짜
     * @return
     */
    private boolean validCheckList(String _configValue, boolean businessDay, String dayOfWeek, String date) {

        String day = date.substring(date.length() - 2);

        if (StringUtil.valid(_configValue)) {
            JSONObject cycleConfig = (JSONObject) JSONValue.parse(_configValue);
            String cycleType = (String) cycleConfig.get("cycleType");

            if (cycleType.equals("01")) {
                // 매일
                // 공휴일 미포함일경우 공유일 여부 체크 (cycleInfo=0,daily=true)
                String cycleInfo = (String) cycleConfig.get("cycleType");
                if (cycleInfo.equals("0")) {
                    // 업무일인인지 확인
                    if (businessDay == true) {
                        // 업무일
                        return true;
                    } else {
                        // 공휴일
                        return false;
                    }
                } else {
                    return true;
                }

            } else if (cycleType.equals("02")) {
                // 매주
                List dayOfWeeks = (List) cycleConfig.get("cycleInfo");

                for(int i = 0; i < dayOfWeeks.size(); i++) {
                    String _d = (String)dayOfWeeks.get(i);
                    if (StringUtil.valid(_d) && StringUtil.valid(dayOfWeek)) {
                        if (Integer.parseInt(_d) == Integer.parseInt(dayOfWeek)) {
                            return true;
                        }
                    }
                }

            } else if (cycleType.equals("03")) {
                // 매월
                List dayOfMonths = (List) cycleConfig.get("cycleInfo");

                for(int i = 0; i < dayOfMonths.size(); i++) {
                    String _d = (String)dayOfMonths.get(i);
                    if (StringUtil.valid(_d) && StringUtil.valid(day)) {
                        if (Integer.parseInt(_d) == Integer.parseInt(day)) {
                            return true;
                        }
                    }
                }
            } else if (cycleType.equals("04")) {
                // 매년
                List dates = (List) cycleConfig.get("cycleInfo");

                for(int i = 0; i < dates.size(); i++) {
                    String _date = (String)dates.get(i);
                    // 설정된 날짜가 오늘이라면 점검 등록
                    if (date.equals(_date)) {
                        return true;
                    }
                }
            }
        }

        return false;
    }
%>