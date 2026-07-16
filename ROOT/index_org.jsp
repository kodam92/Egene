<%--
  User: gojaehag
  Date: 12/11/2019
  Time: 10:18 AM
--%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%@ include file="/xefc/jsp/include/session.jspf" %>
<%@ include file="/xefc/jsp/common/form.jsp" %>
<%
    // 모바일 접속여부 확인
    if (getMobileCheck(request)) {
        RequestDispatcher rd = request.getRequestDispatcher("mobile.jsp");
        rd.forward(request, response);
        //response.sendRedirect("mobile.jsp");
    }

    GlobalConfig gcfg = GlobalConfig.getInstance();
    String configStr = gcfg.getValue("system");

    JSONObject configObj = (JSONObject)JSONValue.parse(configStr);
    String title = configObj.getString("title");

    if (StringUtil.invalid(title)) {
        title = "▒ 라이트닝 ▒";
    }

    ICE ice = ICE.getInstance();
    Sqls sqls = ice.sqls();
    Texts texts = Texts.getInstance();

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

    // 구축관리 사용자 여부 확인
    // 테스트 사용자는 구축관리 사용자로 설정한다.
    session.setAttribute("is_feedback", is_test);

    // 시스템 설정에서 테스터로 등록된 사용자는 구축관리 사용하도록 설정
    String tester = configObj.getString("tester");
    if (StringUtil.valid(tester)) {
        if (tester.indexOf(emp_id) != -1) {
            session.setAttribute("is_feedback", true);
        }
    }

    // 사용자 이미지 처리
    Entity userEntity = ice.map().getEntity(ICE.ENT_EMPLOYEE);
    Row userRow = userEntity.open(_user.id);

    String emp_photo = "";

    if (userRow != null) {
        emp_photo = userRow.get("emp_photo");
    }

    String photo_src = "/xefc/jsp/ui/common/file.jsp?type=profile&key=";
    if (StringUtil.valid(emp_photo)) {
        String[] arr = StringUtil.getArray(emp_photo, ';');
        if (arr.length == 5) {
            String att_id = arr[0];
            photo_src += att_id;
        }
    }
%>
<!doctype html>
<html lang="ko">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1">
    <link rel="shortcut icon" href="/favicon.ico"><!-- Chrome, Safari, IE -->
    <link rel="icon" href="/favicon.png"><!-- Chrome, Safari, IE -->
    <link rel="apple-touch-icon-precomposed" href="/favicon.ico"><!-- iphone -->
    <meta name="author" content="STEG">
    <meta http-equiv="Publisher" content="STEG"/>
    <meta name="description" content="eGene Lightning">
    <meta name="Keywords" content="egene, itsm, steg, itom"/>
    <meta name="Robots" content="noindex, nofollow"/>
    <!-- 검색엔진 제외 https://webclub.tistory.com/354 -->
    <!-- Cache 사용 하지 않도록 -->
    <%--<meta http-equiv="Cache-Control" content="no-cache" />
    <meta http-equiv="Pragma" content="no-cache" />--%>

    <title><%= title %>[<%= _user.get("emp_name") %>]</title>

    <!-- Bootstrap -->
    <link href="/xplugin/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css">
    <!-- JQuery UI -->
    <link href="/xplugin/jquery/ui/1.13.2/jquery-ui.css" rel="stylesheet" type="text/css">
    <!-- JQuery Confirm -->
    <link href="/xplugin/jquery-confirm/jquery-confirm.min.css" rel="stylesheet" type="text/css">
    <!-- jqwidget css -->
    <link href="/xplugin/jqwidgets/styles/jqx.base.css" rel="stylesheet" type="text/css"/>
    <link href="/xplugin/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css"/>

    <link href="/css/default.css" rel="stylesheet" type="text/css">
    <link href="/css/top.css" rel="stylesheet" type="text/css">
    <link href="/css/lit.css" rel="stylesheet" type="text/css">
    <link href="/css/left.css" rel="stylesheet" type="text/css">
    <link href="/css/dtree.css" rel="stylesheet" type="text/css">
    <!-- Main Style CSS -->
    <link href="/css/contents.css" rel="stylesheet" type="text/css">
    <!-- Form Style CSS -->
    <link href="/css/ui_form.css" rel="stylesheet" type="text/css">
    <!-- List Style CSS -->
    <link href="/css/ui_grid.css" rel="stylesheet" type="text/css">
    <!-- Tab Style CSS -->
    <link href="/css/ui_stab.css" rel="stylesheet" type="text/css">
    <link href="/css/stylesheet-pure-css.css" rel="stylesheet" type="text/css">
    <link href="/css/button.css" rel="stylesheet" type="text/css"/>
    <link href="/css/jqx.custom.css" rel="stylesheet" type="text/css"/>

    <link href="/css/ui_wfm.css" rel="stylesheet" type="text/css">
    <link href="/css/ui_grid.css" rel="stylesheet" type="text/css">

    <!-- Portal CSS -->
    <link href="/css/xportal/style.css" rel="stylesheet" type="text/css"/>

    <!-- Preform CSS -->
    <link href="/css/ui_preform.css" rel="stylesheet" type="text/css">


    <%@ include file="/xefc/jsp/common/script.jspf" %>

    <script type="text/javascript" src="/xefc/script/eTree.js"></script>

    <script type="text/javascript" src="/script/egene_app.js"></script>

</head>


<body>
<div class="egene-app" style="height: 100%;">
    <!-- Application Header -->
    <div class="app-header header">

        <!-- Logo 영역 -->

        <div class="top-logo logo">

            <!-- CI -->
            <div class="system-ci">
                <a href="#home">
                    <img id="system_ci" src="/images/theme/default/logo.png">
                </a>
            </div>

            <!-- 시스템 이름 -->
            <div>
                <label class="h3 system-name" id="system_name">시스템 이름</label>
            </div>
        </div>

        <div class="navbar-menu nav">
            <div class="nav-item user-photo">
                <img src="<%=photo_src%>" onclick="goMyInfo()"/>
            </div>

            <!-- 테스트 사용자 목록 & 접속자 정보 -->
            <div class="nav-item user-name">
                <%
                    if (is_test) {
                        out.println(getSelect("test_emp_id", emp_id, test_ids, test_names, null, null,
                                " onChange=chgUser(this.value);"));
                    } else {
                        out.println(HttpUtility.translate(_user.get("emp_name")) + " " + texts.getText("님", session));
                    }
                %>
            </div>

            <div class="nav-item app-tools">
                <%
                    if (is_admin) {
                %>
                <!-- Entity Reload popup -->
                <div class="app-tool-item" style="display: inline;">
                    <a class="btn btn-reload" onclick="goReload()"></a>
                </div>

                <!-- System Console popup -->
                <div class="app-tool-item" style="display: inline;">
                    <a class="btn btn-system" onclick="goConsole()"></a>
                </div>
                <%
                    }
                %>

                <!-- 개인정보 -->
                <div class="app-tool-item" style="display: inline;">
                    <a class="btn btn-profile" onclick="goMyInfo()"></a>
                </div>

                <!-- 사용자 로그아웃 -->
                <div class="app-tool-item" style="display: inline;">
                    <a class="btn btn-logout" onclick="doLogout()"></a>
                </div>
            </div>

        </div>
    </div>

    <!-- Application Main -->
    <div class="app-body main">

        <!-- Application Main Conents -->
        <div class="main-contents">

            <!-- Left Menu -->
            <div class="main-nav">
                <div id="menu_area" style="position: relative; height: 100%;">
                    <div class="dtree" id="menu" style="height: 100%;">

                        <!-- Menu Header -->
                        <div class="menu-header">
                            <div class="keyword_wrapper">
                                <input class="input_search" placeholder="메뉴 검색" type="text" id="search_input"
                                       autocomplete="off" maxlength="20">
                                <img src="/images/icon/icon_filter.png" class="icon-filter"/>
                            </div>

                            <ul class="nav nav-tabs">
                                <li class="nav-item">
                                    <a class="active" data-toggle="tab" href="#tab_itom" title="메뉴">
                                        <div class="menu_icon menu_icon_list"></div>
                                    </a>
                                </li>
                                <li class="nav-item tab_fav">
                                    <a data-toggle="tab" href="#tab_fav" title="즐겨찾기">
                                        <div class="menu_icon menu_icon_fav"></div>
                                    </a>
                                </li>
                            </ul>
                        </div>

                        <!-- Menu Body -->
                        <div class="menu-body">
                            <div class="menu-body-contents" style="height: 100%;">
                                <div class="tab-content" style="height: 100%;">

                                    <div class="tab-pane fade show active" id="tab_itom" style="height: 100%;">

                                        <ul id="menu_accordion" class="navbar-nav sidebar accordion"
                                            style="height: 100%; width: 100%;">
                                            <div class="menu_items_frame" style="height: 100%;">
                                                <div id="menu_items"></div>
                                            </div>
                                        </ul>
                                    </div>

                                    <div class="tab-pane fade" id="tab_fav" style="height: 100%;">

                                        <ul id="menu_fav_accordion" class="navbar-nav sidebar accordion"
                                            style="width: 100%; height: 100%;">
                                            <div class="menu_items_frame" style="height: 100%;">
                                                <div id="menu_fav"></div>
                                            </div>
                                        </ul>
                                    </div>


                                </div>
                            </div>
                        </div>

                        <!-- Menu Footer -->
                        <div class="menu-footer">
                            <a class="btn btn-size appear" onclick="switchMenu()"></a>
                        </div>

                    </div>
                </div>

            </div>

            <!-- Page Contents Area -->
            <div class="main-article">

                <div class="page" style="height: 100%;">

                    <!-- Main 화면 Header START -->
                    <div id="head" class="page-header" style="height: 50px;">

                        <div class="titlebar" style="position: relative;">
                            <div class="title" style="padding: 12px 23px; float: left;">
                            </div>
                            <div class="history" style="position: absolute; bottom: 10px; right: 20px;">

                            </div>
                            <%
                                if ((Boolean)session.getAttribute("is_feedback")) {
                                    out.println(
                                            "<div id=\"control\" style=\"padding-top:15px;padding-right:12px;float: left;\">");
                                    out.println(
                                            "<div class=\"feedback\" onClick=\"showUXM()\" title=\"화면설명 바로가기\"></div>");
                                    out.println("</div>");

                                }
                            %>
                        </div>
                    </div>
                    <!-- Main 화면 Header END -->

                    <!-- Content 영역 -->
                    <div class="page-body"
                         style="height: 100%;padding-top:50px;margin-top:-50px;">

                        <div class="content" style="height: 100%; overflow-y: auto;">

                        </div>
                    </div>
                    <!-- Content 영역 END -->

                </div>
            </div>

        </div>

    </div>

    <!-- Applicaiton Footer -->
    <div class="app-footer footer">
        <!-- <img src="/images/icon/btn_top.png" style="width: 70%; height: 70%" onClick="moveScroll();" onMouseOver="swapImg(this);" onMouseOut="releaseImg(this)"> -->
        <span style="display: none;">
(주)에스티이지 서울특별시 서초구 반포대로 23길 14, 3층 ( 서초동 매강빌딩 )
TEL : 02-3473-3477 FAX : 02-3473-3478
Copyright ⓒ 2016 STEG , All Rights Reserved.
        </span>
    </div>

</div>
<div class="uxm_wrap" style="display: none;">
    <%--<iframe id="uxm_frame" style='width:100%;height:530px;' marginwidth=0 marginheight=0 scrolling=yes
            frameborder=0></iframe>--%>
    <div id="uxm_frame"></div>
</div>

<div id="doc_running">
    <img id="loading-image" src="/images/loading.gif" alt="Loading..."/>
</div>


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