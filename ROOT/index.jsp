<%@ page import="com.steg.lit.dao.EgeneSqlDao" %><%--
$(document).trigger(newCodeEvent);
  User: gojaehag
  Date: 12/11/2019 test
  Time: 10:18 AM
--%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%
    // 시스템 초기설정 확인
    String install = GlobalResource.getInstance().get("install");
    if ("none".equals(install)) {
        RequestDispatcher rd = request.getRequestDispatcher("/xmgr/jsp/install.jsp");
        rd.forward(request, response);
    }

    Texts texts = Texts.getInstance();
    Box box = HttpUtility.getBox(request);
    GlobalConfig gc = GlobalConfig.getInstance();

    // 취약점 23.2.8
    String msg = HttpUtility.translate(box.get("msg"));
    String app = "govitsm"; // 기존 itsm 에서 govitsm 으로 변경 260114
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

    if (StringUtil.valid(msg)) {
        msg = texts.getText(msg);
    }

    boolean license = GlobalResource.getInstance().license();
    if (!license) {
        response.sendRedirect("/error/err_license.jsp");
        return;
    }

    GlobalConfig gcfg = GlobalConfig.getInstance();
    String configStr = gcfg.getValue("system");
    String authConfigStr = gcfg.getValue("auth");
    JSONObject authConfigObj = (JSONObject)JSONValue.parse(authConfigStr);
    String fileConfigStr = gcfg.getValue("file");
    JSONObject fileConfigObj = (JSONObject)JSONValue.parse(fileConfigStr);
    
    // 색상 설정 로드
    String colorConfigStr = gcfg.getValue("colortheme.config");
    JSONObject colorConfigObj = (JSONObject)JSONValue.parse(colorConfigStr);
    String timeout = "1800";
    String fileMaxSize = "";
    String file_ext_disable = "";
    String chkPwNextChCycle = "";
    if (!"".equals(authConfigStr)) {
        timeout = authConfigObj.getString("timeout");
        chkPwNextChCycle = authConfigObj.getString("chkPwNextChCycle");
    }

    if (fileConfigObj != null) {
        fileMaxSize = fileConfigObj.getString("file_maxsize");
        file_ext_disable = fileConfigObj.getString("file_ext_disable");
    }

    boolean pcMode = false;
    if (null != request.getAttribute("pcMode")) {
        pcMode = (boolean)request.getAttribute("pcMode");
    }

    User _user = (User)session.getAttribute("egene.user");

    /* SSO_ID가 있고, 아직 egene.user가 없으면 ssoCallback.jsp로 이동 */
    String ssoId = (String)session.getAttribute("SSO_ID");

    if (_user == null && StringUtil.valid(ssoId)) {
%>
        <script>
            location.replace(
                "/ssoCallback.jsp?redirect_uri=" +
                encodeURIComponent(location.pathname + location.search + location.hash)
            );
        </script>
<%
        return;
    }

    // Application 정보 확인
    if (box.containsKey("app")) {
        app = box.get("app");
    } else if (null != request.getAttribute("app")) {
        app = (String)request.getAttribute("app");
    }

    // 기본 애플리케이션이 아닌경우 애플리케이션 권한 확인
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

    // Application 정보 확인
    if (StringUtil.valid(app)) {
        Entity appEntity = ICE.getInstance().map().getEntity(ICE.ENT_APPLICATION);
        Row appRow = appEntity.open(app);
        String appType = appRow.get("app_type");

        if ("mobile".equals(appType) && _user != null && !pcMode) {
            RequestDispatcher rd = request.getRequestDispatcher("mobile.jsp");
            rd.forward(request, response);
            return;
        }
    }

    // 모바일 접속여부 확인
    if (!pcMode && getMobileCheck(request)) {
        // 애플리케이션 이름 변경
        app = "mobile";

        // 인증상태 확인후 인증 정보가 없으면 로그인 화면으로 보낸다.

        if (_user != null) {
            RequestDispatcher rd = request.getRequestDispatcher("mobile.jsp");
            rd.forward(request, response);
            return;
        } else {
            //             RequestDispatcher rd = request.getRequestDispatcher("mobile_login.jsp");
            //             rd.forward(request, response);
        }
        //response.sendRedirect("mobile.jsp");

    }

    JSONObject configObj = (JSONObject)JSONValue.parse(configStr);
    String title = configObj.getString("title");

    if (StringUtil.invalid(title)) {
        title = "▒ 라이트닝 ▒";
    }

    String errorCode = box.get("error_code");
    errorCode = (errorCode == null) ? "" : HttpUtility.translate(errorCode);

    // 링크모드
    String mode = request.getParameter("mode");
    String ent_id = request.getParameter("ent_id");
    String key = request.getParameter("key");
    String api_id = request.getParameter("api_id");

    String default_js = "script/auth/default.js";
    String google_js = "script/auth/googleAuth.js";
    String apple_js = "script/auth/appleAuth.js";
    String kakao_js = "script/auth/kakaoAuth.js";
    String ldap_js = "script/auth/ldapAuth.js";
    String appleidAuth_js = "https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js";
    String authScript = default_js;
    String appleScript = "";
    String appleidAuth = "";
    String kakaoScript = "";
    String ldapScript = "";

    // Google Oauth2.0 설정
    JSONObject googleClientSecret = (JSONObject)GlobalConfig.getInstance().getConfig("google_client_secret");
    boolean googleUsed = false;

    // Apple Oauth 설정
    JSONObject appleClientSecret = (JSONObject)GlobalConfig.getInstance().getConfig("apple_client_secret");
    boolean appleUsed = false;

    // KaKao Oauth 설정
    JSONObject kakaoClientSecret = (JSONObject)GlobalConfig.getInstance().getConfig("kakao_client_secret");
    String kakaoJsKey = "";
    boolean kakaoUsed = false;

    // LDAP Oauth 설정
    JSONObject ldapClientSecret = (JSONObject)GlobalConfig.getInstance().getConfig("ldap_client_secret");
    boolean ldapUsed = false;

    // 인증된 상태이면 별도 인증수행 없이 로딩 수행
    //if (_user != null) {
    try {
        if (googleClientSecret != null) {
            googleUsed = googleClientSecret.getBoolean("used");

            if (googleUsed == true) {
                authScript = google_js;
            }
        }

        if (appleClientSecret != null) {
            appleUsed = appleClientSecret.getBoolean("used");

            if (appleUsed == true) {
                appleScript = apple_js;
                appleidAuth = appleidAuth_js;
            }
        }

        if (kakaoClientSecret != null) {
            kakaoUsed = kakaoClientSecret.getBoolean("used");

            if (kakaoUsed == true) {
                kakaoScript = kakao_js;
                kakaoJsKey = kakaoClientSecret.getString("jsKey");
            }
        }

        if (ldapClientSecret != null) {
            ldapUsed = ldapClientSecret.getBoolean("used");
            if (ldapUsed == true) {
                ldapScript = ldap_js;
            }
        }

    } catch (BizException e) {
        Log.biz.err(e);
    } catch (Exception ex) {
        Log.biz.err(ex);
    }
    //}


%>
<!doctype html>
<html lang="ko">
<head>
    <%-- SSL 적용시 http로 통신되는 리소스 https로 호출되도록 적용하는 태그이므로 필요시 주석 해제하여 사용하면 됩니다.
    <meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">--%>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <meta http-equiv="Cross-Origin-Opener-Policy" content="same-origin-allow-popups"/>
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">
    <link rel="shortcut icon" href="/favicon.ico"><!-- Chrome, Safari, IE -->
    <link rel="icon" href="/favicon.png"><!-- Chrome, Safari, IE -->
    <link rel="apple-touch-icon-precomposed" href="/favicon.ico"><!-- iphone -->
    <meta name="author" content="STEG">
    <meta http-equiv="Publisher" content="STEG"/>
    <meta name="description" content="eGene Lightning">
    <meta name="Keywords" content="egene, itsm, steg, itom"/>
    <meta name="Robots" content="noindex, nofollow"/>
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
    <meta name="_csrf_param" content="${_csrf.parameterName}"/>
    <meta name="referrer" content="strict-origin-when-cross-origin"/>
    <!--통합인증서버를 통한 로그인 여부 -->
    <meta name="_oauth_enabled" content="${oauth2Enabled}"/>
    <!-- 검색엔진 제외 https://webclub.tistory.com/354 -->
    <!-- Cache 사용 하지 않도록 -->
    <%--<meta http-equiv="Cache-Control" content="no-cache" />
    <meta http-equiv="Pragma" content="no-cache" />--%>

    <!-- Basic Page Needs
    ================================================== -->
    <title><%= title %>
    </title>


</head>

<body app="<%=app%>">

<div class="egene-root" style="height: 100%;">
</div>

<div id="doc_running">
    <img id="loading-image" src="/images/loading.gif" alt="Loading..."/>
</div>


<input type="hidden" class="csrf-field" name="${_csrf.parameterName}" value="${_csrf.token}"/>



<script>
(function () {
    var lastSelectedMenuId = getMenuIdFromHash();

    /*
     * URL hash에서 메뉴 ID 추출
     * 예: /#MEN_GOV_04020/_93c3429f → MEN_GOV_04020
     */
    function getMenuIdFromHash() {
        var hash = location.hash || '';
        if (!hash) {
            return null;
        }

        hash = hash.replace(/^#/, '');

        if (hash.indexOf('/') > -1) {
            hash = hash.split('/')[0];
        }

        return hash || null;
    }

    /*
     * 최하위 메뉴가 포함된 최상위 메뉴에 포커스를 부여한다.
     */
    function restoreMenuFocus() {
        document.querySelectorAll('#menu_items li.nav-item.real-selected-parent')
            .forEach(function (li) {
                li.classList.remove('real-selected-parent');
            });

        if (!lastSelectedMenuId) {
            return false;
        }

        var selected = document.querySelector(
            '#menu_items a[data-men_id="' + lastSelectedMenuId + '"]'
        );

        if (!selected) {
            return false;
        }

        var parent = selected.closest('li.nav-item');

        while (parent && parent.parentElement && parent.parentElement.id !== 'menu_items') {
            parent = parent.parentElement.closest('li.nav-item');
        }

        if (parent) {
            parent.classList.add('real-selected-parent');
            return true;
        }

        return false;
    }

    function restoreMenuFocusRetry(count) {
        if (restoreMenuFocus()) {
            return;
        }

        if (count <= 0) {
            return;
        }

        setTimeout(function () {
            restoreMenuFocusRetry(count - 1);
        }, 500);
    }

    document.addEventListener('click', function (e) {
        var el = e.target.closest('#menu_items a[data-men_id]');
        if (!el) {
            return;
        }

        if (!el.getAttribute('data-target')) {
            lastSelectedMenuId = el.getAttribute('data-men_id');
        }

        setTimeout(restoreMenuFocus, 100);
    }, true);

    window.addEventListener('hashchange', function () {
        lastSelectedMenuId = getMenuIdFromHash();
        restoreMenuFocusRetry(10);
    });

    /*
     * 최초 로딩 시 메뉴 DOM 생성이 늦을 수 있으므로 재시도
     */
    restoreMenuFocusRetry(10);
})();
</script>

</body>

<!-- CSS
================================================== -->
<!--
<link href="https://fonts.googleapis.com/css?family=Noto+Sans+KR:100,300,400,500,700,900|Noto+Sans:400,400i,700,700i" rel="stylesheet">
-->
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
<link rel="stylesheet" type="text/css" href="/css/ui_form.css">
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
<link rel="stylesheet" type="text/css" href="/css/colors/main.css">
<!-- Portal css -->
<link href="/css/xportal/style.css" rel="stylesheet" type="text/css"/>

<!-- Login css -->
<link href="/css/login.css" rel="stylesheet" type="text/css">

<!-- dhxGantt -->
<%--<link rel="stylesheet" href="/xplugin/dhtmlxGantt/dhtmlxgantt.css">--%>
<link rel="stylesheet" href="/xplugin/dhtmlxGantt/skins/dhtmlxgantt_material.css">
<link rel="stylesheet" href="/css/gantt/gantt_custom.css">

<!-- color 재정의 -->
<link rel="stylesheet" type="text/css" href="/css/colors/main.css" id="colors">

<!-- 동적 색상 테마 적용 -->
<style>
<%
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
:root {
    --primaryMain: <%= primaryMain %>;
    --primaryDark: <%= primaryDark %>;
    --primaryLight: <%= primaryLight %>;
    --secondaryMain: <%= secondaryMain %>;
}
</style>

<!-- colorCode css -->
<link rel="stylesheet" type="text/css" href="/css/colorcode.css">

<%-- 개발 시 추가되는 스타일 정의 --%>
<link rel="stylesheet" type="text/css" href="/css/custom.css">
<link rel="stylesheet" type="text/css" href="/xplugin/ckeditor/ckeditor.css">
<link rel="stylesheet" href="/xplugin/highlight/styles/atom-one-dark.min.css"/>

<!-- PMS -->
<link rel="stylesheet" type="text/css" href="/css/pms.css">

<!-- TIMESHEET  -->
<link rel="stylesheet" type="text/css" href="/css/timesheet.css">

<%@ include file="/xefc/jsp/common/script.jspf" %>

<script>

    $egene.app.id = '<%=app%>';
    $egene.app.name = '<%=app%>';
    $egene.app.title = '<%=HttpUtility.translate(title)%>';
    $egene.app.commentSQL = 'Mention.Lookup';

    $egene.maxLogOutTime = '<%=timeout%>';
    $egene.currLogoutTime = '<%=timeout%>';
    $egene.file.file_maxsize = '<%=fileMaxSize%>';
    $egene.file.file_ext_disable = '<%=file_ext_disable%>';
    $egene.chkPwNextChCycle = '<%=chkPwNextChCycle%>';


    // msg 파라미터 값이 있다면 메시지 표시
    var msg = '<%=msg%>';
    if (msg) {
        $egene.alert(msg);
    }

    $egene.setSessionId('<%= Utils.getSessionSecureKey(session) %>');

</script>

<script type="text/javascript" src="<%=authScript%>"></script>
<script type="text/javascript" src="<%=appleScript%>"></script>
<script type="text/javascript" src="<%=appleidAuth%>"></script>
<script type="text/javascript" src="<%=kakaoScript%>"></script>
<script type="text/javascript" src="<%=ldapScript%>"></script>


<%
    if (kakaoUsed) {
%>

<script type="text/javascript"
        src="//dapi.kakao.com/v2/maps/sdk.js?appkey=fd34b77aad2b2557da22a4c744b6b9a7&autoload=false&libraries=services"></script>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src="https://t1.kakaocdn.net/kakao_js_sdk/2.1.0/kakao.min.js"
        integrity="sha384-dpu02ieKC6NUeKFoGMOKz6102CLEWi9+5RQjWSV0ikYSFFd8M3Wp2reIcquJOemx"
        crossorigin="anonymous"></script>

<script src="https://developers.kakao.com/sdk/js/kakao.js"></script>
<script>
    if (!Kakao.isInitialized()) {
        Kakao.init('<%= kakaoJsKey %>'); // 사용하려는 앱의 JavaScript 키 입력
    }
</script>

<%
    }
%>

<%--
<script type="text/javascript">


</script>

<script async defer src="https://apis.google.com/js/api.js"
        onload="this.onload=function(){};handleClientLoad()"
        onreadystatechange="if (this.readyState === 'complete') this.onload()">
</script>
--%>

</html>

<%!
    /**
     * User-Agent 없는 경우 처리 Null Point
     *
     * 모바일 확인.
     * @param req
     * @return
     */
    boolean getMobileCheck(HttpServletRequest req) {

        String ua = req.getHeader("User-Agent");

        if (ua == null)
            return false;

        ua = ua.toLowerCase(Locale.ENGLISH);
        if (ua.matches(
                ".*(android|avantgo|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\\/|plucker|pocket|psp|symbian|treo|up\\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino).*")
                || ua.substring(0, 4)
                .matches(
                        "1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\\-(n|u)|c55\\/|capi|ccwa|cdm\\-|cell|chtm|cldc|cmd\\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\\-s|devi|dica|dmob|do(c|p)o|ds(12|\\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\\-|_)|g1 u|g560|gene|gf\\-5|g\\-mo|go(\\.w|od)|gr(ad|un)|haie|hcit|hd\\-(m|p|t)|hei\\-|hi(pt|ta)|hp( i|ip)|hs\\-c|ht(c(\\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\\-(20|go|ma)|i230|iac( |\\-|\\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\\/)|klon|kpt |kwc\\-|kyo(c|k)|le(no|xi)|lg( g|\\/(k|l|u)|50|54|e\\-|e\\/|\\-[a-w])|libw|lynx|m1\\-w|m3ga|m50\\/|ma(te|ui|xo)|mc(01|21|ca)|m\\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\\-2|po(ck|rt|se)|prox|psio|pt\\-g|qa\\-a|qc(07|12|21|32|60|\\-[2-7]|i\\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\\-|oo|p\\-)|sdk\\/|se(c(\\-|0|1)|47|mc|nd|ri)|sgh\\-|shar|sie(\\-|m)|sk\\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\\-|v\\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\\-|tdg\\-|tel(i|m)|tim\\-|t\\-mo|to(pl|sh)|ts(70|m\\-|m3|m5)|tx\\-9|up(\\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|xda(\\-|2|g)|yas\\-|your|zeto|zte\\-")) {
            return true;
        }

        return false;
    }
%>
