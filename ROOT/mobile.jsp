<%@ page import="com.steg.lit.dao.EgeneSqlDao" %><%--
  Created by IntelliJ IDEA.
  User: gojaehag
  Date: 2015. 10. 6.
  Time: 오후 3:32
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%@ include file="/xefc/jsp/include/session.jspf" %>
<%
    Box box = HttpUtility.getBox(request);
    ICE ice = ICE.getInstance();
    Sqls sqls = ice.sqls();

    // Application에 따른 모바일 구성
    // Application 정보 확인
    String app = "itsm";
    String defaultApp = "";

    // 기본 Application 정보 확인
    JSONObject cfg = (JSONObject)gc.getConfig("system");
    JSONObject appCfg = cfg.getObject("application");
    // Application Configuration 설정 확인
    if (appCfg != null) {
        defaultApp = appCfg.getString("default");
        if (StringUtil.valid(defaultApp) && StringUtil.invalid(app))
            app = defaultApp;
    } else {
        // 설정이 없는경우 app 기본값을 설정한다.
        defaultApp = app;
    }

    Data d = new Data();
    if (box.containsKey("app")) {
        app = box.get("app");
    }
    d.put("men_system", app);
    d.put("smb_type", "mobile");
    d.put("emp_id", _user.emp_id);

    // mobile type의 ssd가 없을 경우 웹화면으로 이동.
    RecordSet typRs = null;
    Result typR = sqls.getResult("SSD5.SMBoards.Mobile", d);
    typRs = typR.getRecordSet();

    // 페이지 진입시 PC 여부는 삭제하고 강제 실행
    //if (!getMobileCheck(request) || typRs.getRowCount() == 0) {
    if (typRs.getRowCount() == 0) {
        request.setAttribute("pcMode", true);
        request.setAttribute("app", app);
        RequestDispatcher rd = request.getRequestDispatcher("index.jsp");
        rd.forward(request, response);
        return;
    }
    typRs.next();

    //테스트 사용자 목록 레코드
    Result test_result = sqls.getResult("Employee.getTestUser");
    RecordSet test_rs = test_result.getRecordSet();

    //시스템 관리자 여부 레코드
    Result admin_result = sqls.getResult("Employee.getAdminUser");
    RecordSet admin_rs = admin_result.getRecordSet();

    String[] test_ids = test_rs.getValues("emp_id");
    String[] test_names = test_rs.getValues("emp_name");

    boolean is_test = test_rs.find(emp_id, "emp_id");
    boolean is_admin = admin_rs.find(emp_id, "emp_id");

    session.setAttribute("is_test", is_test);
    session.setAttribute("is_admin", is_admin);

    String typ_id = typRs.get("typ_id");
    String smbId = typRs.get("smb_id");
    String system = "";
    String theme = "";
    JSONArray toolbar = new JSONArray();
    com.steg.efc.Texts texts = com.steg.efc.Texts.getInstance();

    // 기본 애플리케이션이 아닌경우 애플리케이션 권한 확인.
    if (!app.equals(defaultApp) && StringUtil.valid(app) && _user != null) {
        EgeneSqlDao dao = EgeneSqlDao.getInstance();
        Data data = new Data();
        data.put("appId", app);
        data.put("empId", _user.getEmpId());

        RecordSet recordSet = dao.select("com.steg.egene.user.getApplicationAccessByUser", data).getRecordSet();
        if (!recordSet.next()) {
            response.sendRedirect("/error/err_403.jsp");
            return;
        }
        boolean result = StringUtil.getBoolean((String)recordSet.getRowData().get("result"), null);
        if (!result) {
            response.sendRedirect("/error/err_403.jsp");
            return;
        }
    }

    GlobalConfig gcfg = GlobalConfig.getInstance();
    String sysname = gcfg.getWebTitle();
    if (!StringUtil.valid(sysname)) {
        sysname = "라이트닝"; // ""SSD5 | Smart Strategy Dashbaord 5";
    }

    RecordSet rs = null;
    Result r = sqls.getResult("SSD.Type.Detail", typ_id);
    rs = r.getRecordSet();

    if (rs.next()) {
        system = rs.get("typ_value");
        String configStr = rs.get("typ_config");
        JSONObject appConfig = (JSONObject)JSONValue.parse(configStr);
        if (appConfig != null) {
            theme = (String)appConfig.get("theme");
            if (appConfig.containsKey("toolbar") && appConfig.get("toolbar") instanceof JSONArray) {
                toolbar = (JSONArray)appConfig.get("toolbar");
            }
        }
    }

    if (StringUtil.isEmpty(system)) {
        system = "Empty";
    }

    if (StringUtil.isEmpty(theme)) {
        theme = "mobile";
    }

    String google_js = "script/auth/googleAuth.js";
    String authScript = "";

    // Google Oauth2.0 설정
    JSONObject googleClientSecret = (JSONObject)GlobalConfig.getInstance().getConfig("google_client_secret");
    boolean googleUsed = false;

    // 인증된 상태이면 별도 인증수행 없이 로딩 수행
    try {
        if (googleClientSecret != null) {
            googleUsed = googleClientSecret.getBoolean("used");

            if (googleUsed == true) {
                authScript = google_js;
            }
        }
    } catch (BizException e) {
        Log.biz.err(e);
    } catch (Exception ex) {
        Log.biz.err(ex);
    }

    // 색상 설정 로드
    String colorConfigStr = gcfg.getValue("colortheme.config");
    JSONObject colorConfigObj = (JSONObject)JSONValue.parse(colorConfigStr);

    // 기본 색상 값
    String primaryMain = "#4E89AE";
    String primaryDark = "#30475E";
    String primaryLight = "#dfe7eb";
    String secondaryMain = "#a82f53";

    // 저장된 색상이 있으면 적용
    if (colorConfigObj != null) {
        if (colorConfigObj.containsKey("primaryMain")) {
            primaryMain = colorConfigObj.getString("primaryMain");
        }
        if (colorConfigObj.containsKey("primaryDark")) {
            primaryDark = colorConfigObj.getString("primaryDark");
        }
        if (colorConfigObj.containsKey("primaryLight")) {
            primaryLight = colorConfigObj.getString("primaryLight");
        }
        if (colorConfigObj.containsKey("secondaryMain")) {
            secondaryMain = colorConfigObj.getString("secondaryMain");
        }
    }
%>
<!DOCTYPE html>
<html ng-app="ssdApp" <%= !getMobileCheck(request) ? "style=\"--vh: 9.3px;\" class=\"ng-scope pcApp\"" : ""%>>

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">
    <link rel="shortcut icon" href="/favicon.ico"><!-- Chrome, Safari, IE -->
    <link rel="icon" href="/favicon.png"><!-- Chrome, Safari, IE -->
    <link rel="apple-touch-icon-precomposed" href="/favicon.ico"><!-- iphone -->
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
    <meta name="_csrf_param" content="${_csrf.parameterName}"/>

    <title><%= sysname %>
    </title>
    <%--<!-- bootstrap 5 -->--%>
    <link href="/xplugin/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css">

    <%--<!-- swiper -->--%>
    <link rel="stylesheet" href="/xplugin/swiper/swiper-bundle.min.css"/>
    <script src="/xplugin/swiper/swiper-bundle.min.js"></script>

    <link href="/xplugin/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css">
    <link href="/xplugin/jquery/ui/1.13.2/jquery-ui.css" rel="stylesheet" type="text/css">
    <link href="/xplugin/jquery-confirm/jquery-confirm.min.css" rel="stylesheet" type="text/css">
    <link href="/xplugin/jqwidgets/styles/jqx.base.css" rel="stylesheet" type="text/css"/>
    <link href="/xplugin/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css"/>

    <link rel="stylesheet" type="text/css" href="/css/stylesheet-pure-css.css">
    <link rel="stylesheet" type="text/css" href="/css/ui_preform.css">
    <link rel="stylesheet" type="text/css" href="/css/jqx.custom.css">

    <link rel="stylesheet" type="text/css" href="/css/ui_stab.css">
    <link rel="stylesheet" type="text/css" href="/css/ui_daepicker.css">
    <link rel="stylesheet" type="text/css" href="/css/style.css">
    <link rel="stylesheet" type="text/css" href="/css/ui_atom.css">
    <link rel="stylesheet" type="text/css" href="/css/dtree.css">
    <link rel="stylesheet" type="text/css" href="/css/userInfo.css">
    <link rel="stylesheet" type="text/css" href="/css/contents.css">
    <%--<link rel="stylesheet" type="text/css" href="/css/ui_form.css">--%>
    <link rel="stylesheet" type="text/css" href="/xmobile/css/ui_form.css">
    <link rel="stylesheet" type="text/css" href="/css/ui_list.css">
    <link rel="stylesheet" type="text/css" href="/css/ui_grid.css">
    <link rel="stylesheet" type="text/css" href="/css/category_list.css">
    <link rel="stylesheet" type="text/css" href="/css/button.css">
    <link rel="stylesheet" type="text/css" href="/css/ui_wfm.css">
    <link rel="stylesheet" type="text/css" href="/css/ect.css">
    <link rel="stylesheet" type="text/css" href="/css/media.css">
    <link rel="stylesheet" type="text/css" href="/xplugin/jquery-mentions-input-master/jquery.mentionsInput.css">
    <link rel="stylesheet" type="text/css" href="/xplugin/jQuery-Upload-File/4.0.11/uploadfile.css">
    <link rel="stylesheet" type="text/css" href="/css/lit.css">
    <link rel="stylesheet" type="text/css" href="/css/atom.css">
    <link rel="stylesheet" type="text/css" href="/css/ui_xview.css">

    <!-- slider 추가 -->

    <!-- SSD Style -->
    <link href="/xssd5/css/dashboard/icon.css" rel="stylesheet">
    <link href="/xssd5/css/dashboard/style.css" rel="stylesheet">
    <link href="/xssd5/css/dashboard/<%=theme%>.css" rel="stylesheet">
    <!--Mobile Custom css -->
    <link href="/xssd5/css/dashboard/mobile2.css" rel="stylesheet">

    <!-- color 재정의 -->
    <link rel="stylesheet" type="text/css" href="/css/colors/main.css" id="colors">

    <%-- 개발 시 추가되는 스타일 정의 --%>
    <link rel="stylesheet" type="text/css" href="/css/custom.css">
    <link rel="stylesheet" type="text/css" href="/xplugin/ckeditor/ckeditor.css">
    <link rel="stylesheet" href="/xplugin/highlight/styles/atom-one-dark.min.css"/>
    <%
        if (StringUtil.valid(app)) {
    %>
    <link rel="stylesheet" href="/xssd5/css/dashboard/<%=app.toLowerCase(Locale.ENGLISH)%>.css"/>
    <%
        }
    %>

    <%@ include file="/xefc/jsp/common/mobile_script.jspf" %>

    <script
            type="text/javascript"
            src="//dapi.kakao.com/v2/maps/sdk.js?appkey=fd34b77aad2b2557da22a4c744b6b9a7&autoload=false&libraries=services"
    ></script>

    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js">
    </script>

    <!-- angularjs scripts -->
    <script src="/xplugin/angularjs/angular.js"></script>
    <script src="/xplugin/angularjs/angular-route.js"></script>
    <!-- jqx scripts -->
    <script src="/xplugin/jqwidgets/jqx-all.js"></script>
    <!-- count up -->
    <script src="/xplugin/countup/countUp.js"></script>
    <!-- easypiechart -->
    <script src="/xplugin/easypiechart/easypiechart.js"></script>
    <script src="/xplugin/easypiechart/angular.easypiechart.js"></script>
    <!-- jquery sparkline -->
    <script src="/xplugin/jquery.sparkline/jquery.sparkline.js"></script>
    <!-- menu tree -->

    <!-- ssd script -->
    <script src="/xssd5/script/ssd.js"></script>

    <!-- application scripts -->
    <script src="/xmobile/script/app.js"></script>
    <script src="/xmobile/script/controllers.js"></script>
    <script src="/xssd5/script/controllers.js"></script>
    <script src="/xssd5/script/directives.js"></script>
    <script src="/xssd5/script/filters.js"></script>
    <script src="/xssd5/script/directives/filter.js"></script>
    <script src="/xssd5/script/directives/sparkline.js"></script>
    <script src="/xssd5/script/service.js"></script>

    <script src="/script/mobile_app.js"></script>
    <script src="/xmobile/script/mobile_fn.js"></script>

    <script type="text/javascript" src="<%=authScript%>"></script>
    <%--    <script type="text/javascript" src="/script/globalConfig.js"></script>--%>

    <%-- crypt-js --%>
    <script src="/xplugin/crypto-js/crypto-js.min.js"></script>
    <script>
        isMobile = true;
        $egene.app.id = 'itsm';
        $egene.app.name = 'itsm';
    </script>

    <style>
        html, body {
            height: 100%;
            width: 100%;
        }

        :root {
            --primaryMain: <%= primaryMain %>;
            --primaryDark: <%= primaryDark %>;
            --primaryLight: <%= primaryLight %>;
            --secondaryMain: <%= secondaryMain %>;
        }
    </style>

</head>

<body app="<%=app%>" ng-controller="appController" ssd-system="<%=app%>" class="<%=app%>">

<%@ include file="/xefc/jsp/common/running_b.jspf" %>
<div class="article ssd-app mobile-portal egene-root" smb-id="<%= smbId %>">
    <div class="container header">

        <div class="page-header container">
            <div style="display: flex; align-items: center; height: 100%;">
                <div class="before-page-header hide">
                    <div class="header-icon btn-back" onclick="backWin()">
                        <i class="fa fa-angle-left"></i>
                    </div>
                </div>
                <div class="main-page-header">
                    <div class="header-ci">
                        <img id="system_ci" src="/egene_logo_black.png"/>
                    </div>
                    <div class="header-title"></div>
                    <button type="button" class="btn button-lst-action btn-mobile-favorite hide" title="">
                          <i class="fa fa-star list-icon"></i>
                          <span></span>
                    </button>
                </div>
                <div class="after-page-header">
                    <div class="header-icon btn-logout" onclick="mobileLogout('<%=app%>')">
                        <i class="fa fa-power-off"></i>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- ssd console 설정 // -->
    <div class="settings-container" adminYn="<%=_user.getBoolean("emp_admin_yn") ? true : false %>"
         style="display: none;">

        <div class="btn btn-app btn-xs btn-warning settings-btn" onclick="toogleSettings()">
            <i class="ace-icon fa fa-cog bigger-130"></i>
        </div>

        <div class="settings-box clearfix">
            <div>
                <!-- #section:settings.skins -->
                <div class="settings-item">
                    <div class="ace-settings-item">
                        <ul class="list-group">
                            <li class="list-group-item active"><%= texts.getText("대시보드 관리", session)%>
                            </li>
                            <li class="list-group-item">
                                <label style="margin-right: 15px;">&nbsp;&nbsp;Designer</label>
                                <button type="button" class="btn btn-default btn-xs pull-right"
                                        onclick="doMgr()" style="padding-top: 0;"><%= texts.getText("시작", session)%>
                                </button>
                            </li>
                        </ul>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <div class="container section">
        <div ng-view="" class="page-section" style="height: 100%; position: relative;"></div>
    </div>

    <div class="container footer">
        <%
            if (toolbar.size() > 0) {
                for (int i = 0; i < toolbar.size(); i++) {
                    JSONObject toolbarItem = (JSONObject)toolbar.get(i);
        %>
        <div mp_btn_id="<%= toolbarItem.getString("btnId") %>" class="footer-icon"
             onclick="<%= toolbarItem.getString("handler") %>">
            <i class="<%= toolbarItem.getString("icon") %>"></i>
            <div class="title"><%= toolbarItem.getString("title") %>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <div class="footer-icon" onclick="loadPortal()">
            <i class="fa fa-home"></i>
            <div class="title"><%= texts.getText("홈", session)%>
            </div>
        </div>
        <%
            }
        %>
    </div>

</div>
<!--로딩화면 스플래쉬 이미지-->
<%
    if (StringUtil.valid(app)) {

%>
<script type="text/javascript">

    setTimeout(function () {
        $(".<%=app.toLowerCase(Locale.ENGLISH)%>_splash").hide();
    }, 1500);
</script>
<div class="<%=app.toLowerCase(Locale.ENGLISH)%>_splash"></div>
<%
    }
%>
</body>
</html>

<%!
    /**
     * 모바일 확인.
     * @param req
     * @return
     */
    boolean getMobileCheck(HttpServletRequest req) {

        String ua = req.getHeader("User-Agent").toLowerCase(Locale.ENGLISH);
        if (ua.matches(
                ".*(ipad|android|avantgo|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\\/|plucker|pocket|psp|symbian|treo|up\\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino).*")
                || ua.substring(0, 4)
                .matches(
                        "1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\\-(n|u)|c55\\/|capi|ccwa|cdm\\-|cell|chtm|cldc|cmd\\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\\-s|devi|dica|dmob|do(c|p)o|ds(12|\\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\\-|_)|g1 u|g560|gene|gf\\-5|g\\-mo|go(\\.w|od)|gr(ad|un)|haie|hcit|hd\\-(m|p|t)|hei\\-|hi(pt|ta)|hp( i|ip)|hs\\-c|ht(c(\\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\\-(20|go|ma)|i230|iac( |\\-|\\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\\/)|klon|kpt |kwc\\-|kyo(c|k)|le(no|xi)|lg( g|\\/(k|l|u)|50|54|e\\-|e\\/|\\-[a-w])|libw|lynx|m1\\-w|m3ga|m50\\/|ma(te|ui|xo)|mc(01|21|ca)|m\\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\\-2|po(ck|rt|se)|prox|psio|pt\\-g|qa\\-a|qc(07|12|21|32|60|\\-[2-7]|i\\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\\-|oo|p\\-)|sdk\\/|se(c(\\-|0|1)|47|mc|nd|ri)|sgh\\-|shar|sie(\\-|m)|sk\\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\\-|v\\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\\-|tdg\\-|tel(i|m)|tim\\-|t\\-mo|to(pl|sh)|ts(70|m\\-|m3|m5)|tx\\-9|up(\\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|xda(\\-|2|g)|yas\\-|your|zeto|zte\\-")) {
            return true;
        }

        return false;
    }
%>

<script src="script/egene/slick.js" defer="defer"></script>


