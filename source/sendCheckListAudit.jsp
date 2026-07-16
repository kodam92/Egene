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

        // 해당 월의 말일 계산 (2월 28일 등 대응)
        int lastDayOfMonth = today.getActualMaximum(Calendar.DAY_OF_MONTH);

        sql_id = "CLM.CheckList.Audit";
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
                String title = clmRSchkm.get("req_title");
                int baseDay = clmRSchkm.get("base_day");
                int baseMonth = clmRSchkm.get("base_month");

                String cycle = getHighestCycle(baseDay, baseMonth, dateStr, lastDayOfMonth);
                Log.act.info("cycle : " + cycle);
                //TODO : 감사 주기 코드 명으로 리턴하도록 
                if (!"".equals(cycle)) {
                    chkmRow = chkmEntity.openNew();
                    
                    if ("CLMCLA010".equals(claCdChkm)) {
                        if ("CHKDCYC040".equals(cycle)) {
                          box.put("chkm_req_title", title + "_연점검_현황");
                        } else if ("CHKDCYC030".equals(cycle)) {
                          box.put("chkm_req_title", title + "_분기점검_현황");
                        } else if ("CHKDCYC020".equals(cycle)) {
                          box.put("chkm_req_title", title + "_월점검_현황");
                        } else if ("CHKDCYC010".equals(cycle)) {
                          box.put("chkm_req_title", title + "_주점검_현황");
                        }
                        box.put("chkm_cla_cd", "CLMCLA010");
                        box.put("chkm_tas_id", "TAS02200");
                    }
                    chkmEntity.save(chkmRow, chkmCtl, box, session, request);
                }
            }
            
            Control chkCtl = wfms.getControl(chkCtlId);

            box.put("var/ent_id", "CHK");
            box.put("var/frm_id", "");
            box.put("var/tas_id", "TAS01750");
            box.put("var/act", "1");

            while (clmRS.next()) {
                int baseDay = clmRS.get("base_day");
                int baseMonth = clmRS.get("base_month");
                String cycle = getHighestCycle(baseDay, baseMonth, dateStr, lastDayOfMonth);

                //TODO
                if (!"".equals(cycle)) {
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
                    // box.put("chk_req_title", reqTitle);
                    box.put("chk_cyl_cd", cylCd);
                    box.put("chk_acp_cd", acpCd);
                    box.put("chk_acp_req_dttm", dateStr);
                    box.put("chk_target_name", targetName);
                    box.put("chk_clm_id", clmId);
                    box.put("chk_cla_cd", claCd);
                    //Todo : box.put("chk_점검주기", claCd);

                    if ("CHKDCYC040".equals(cycle)) {
                      box.put("chk_req_title", reqTitle + "_연점검");
                    } else if ("CHKDCYC030".equals(cycle)) {
                      box.put("chk_req_title", reqTitle + "_분기점검");
                    } else if ("CHKDCYC020".equals(cycle)) {
                      box.put("chk_req_title", reqTitle + "_월점검");
                    } else if ("CHKDCYC010".equals(cycle)) {
                      box.put("chk_req_title", reqTitle + "_주점검");
                    }

                    chkEntity.save(chkRow, chkCtl, box, session, request);

                    sql_id_rel = "CLM.CheckList.Relation.Audit";
                    box.put("clm_id", clmId);
                    Result clmRelResult = sqls.getResult(sql_id_rel, box);
                    RecordSet clmRelRS = clmRelResult.getRecordSet();

                    //eso_clr에 추가된 점검 항목 중 현재 주기에 해당하는 항목만 chr에 추가 
                    while (clmRelRS.next()) {
                        String clrRegDttm = clmRelRS.get("reg_dttm");
                        String empId = clmRelRS.get("emp_id");
                        String chkId = chkRow.key;
                        String clrClmId = clmRelRS.get("clm_id");
                        String chdId = clmRelRS.get("chd_id");
                        String chdCycle = clmRelRS.get("chd_cycle");

                        if (checkValidCycle(cycle, chdCycle)) {
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
    * 오늘 날짜가 만족하는 주기 중 가장 큰 주기를 반환 (YEAR > HALF > QUARTER > MONTH)
    * @param baseDay    기준일 (1~31)
    * @param baseMonth  기준월 (0~11)
    * @param date       오늘 날짜 (yyyyMMdd)
    */
    private String getHighestCycle(int baseDay, int baseMonth, String date, int lastDayOfMonth) {
        
        // 1. 날짜 데이터 파싱
        int year = Integer.parseInt(date.substring(0, 4));
        int month = Integer.parseInt(date.substring(4, 6));
        int day = Integer.parseInt(date.substring(6, 8));

        // 3. 오늘이 실행 기준일인지 확인 (기준일이 오늘이거나, 말일인 경우)
        boolean isTargetDay = (day == baseDay) || (baseDay > lastDayOfMonth && day == lastDayOfMonth);

        if (!isTargetDay) return ""; // 기준일이 아니면 아무것도 반환 안 함

        // 4. 기준월과의 차이 계산
        int diff = month - baseMonth;

        // 5. 큰 주기부터 역순으로 체크 (가장 먼저 걸리는 것이 가장 큰 주기)
        if (diff > 0 && diff % 12 == 0) {
            return "CHKDCYC040";    // 매년
        } 
        else if (diff > 0 && diff % 6 == 0) {
            return "CHKDCYC030";    // 반기
        } 
        else if (diff > 0 && diff % 3 == 0) {
            return "CHKDCYC020"; // 분기
        } 
        
        // 위 조건에 해당하지 않지만 실행일인 경우
        return "CHKDCYC010";       // 매월
    }

    private boolean checkValidCycle(String clmCycle, String chkdCycle) {
        if ("CHKDCYC010".equals(clmCycle)) { // 매월
          if ("CHKDCYC010".equals(chkdCycle)) {
              return true;
          } else {
              return false;
          }
        }

        if ("CHKDCYC020".equals(clmCycle)) { // 분기
          if ("CHKDCYC010".equals(chkdCycle) || "CHKDCYC020".equals(chkdCycle)) {
              return true;
          } else {
              return false;
          }
        }

        if ("CHKDCYC030".equals(clmCycle)) { // 반기
          if ("CHKDCYC010".equals(chkdCycle) || "CHKDCYC020".equals(chkdCycle) ||
              "CHKDCYC030".equals(chkdCycle)) {
              return true;
          } else {
              return false;
          }
        }

        if ("CHKDCYC040".equals(clmCycle)) { // 연
          if ("CHKDCYC010".equals(chkdCycle) || "CHKDCYC020".equals(chkdCycle) ||
              "CHKDCYC030".equals(chkdCycle) || "CHKDCYC040".equals(chkdCycle)) {
              return true;
          } else {
              return false;
          }
        }

        return false;
    }
%>