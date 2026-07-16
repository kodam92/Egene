<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%@ include file="/xefc/jsp/include/session.jspf" %>
<%

    Box box = HttpUtility.getBox(request);
    box.restore();

    Texts texts = Texts.getInstance();
    String uri = box.get("uri");
    String params = box.get("uri_params");

    GlobalConfig gcfg = GlobalConfig.getInstance();
    String configStr = gcfg.getValue("system");

    JSONObject configObj = (JSONObject)JSONValue.parse(configStr);
    String title = configObj.getString("title");

    if (StringUtil.invalid(title)) {
        title = "▒ 라이트닝 ▒";
    }

    if (uri.indexOf("WEB-INF") > -1 || uri.indexOf("META-INF") > -1) {
        String auth_msg = "<script>$egene.alert('" + texts.getText("잘못된 접근입니다.", session) + "');self.close();</script>";
        out.println(auth_msg);
        return;
    }

    //로딩 시 Main - Content영역의 높이(고정)
    //TOP Title : 64px
    //FOOTER : 37px
    //Contents 상단 Margin : 10px
    int scrollHeight = 74;

    //URL정보에 Form 유무
    String display = "none";

    uri += box.getURLParameters();

    if (StringUtil.valid(uri)) {
        if (uri.indexOf("?") > 0) {
            uri += "&async=false";
        } else {
            uri += "?async=false";
        }
    }


%>

<%@ include file="/xefc/jsp/common/html_begin.jspf" %>
<title><%= title %>[<%= HttpUtility.translate(_user.get("emp_name")) %>]</title>


<!-- CSS
================================================== -->
<link href="/xplugin/jquery-confirm/jquery-confirm.min.css" rel="stylesheet" type="text/css">
<link href="/xplugin/jqwidgets/styles/jqx.base.css" rel="stylesheet" type="text/css"/>


<link rel="stylesheet" type="text/css" href="/css/jqx.custom.css">
<link rel="stylesheet" type="text/css" href="/css/ui_daepicker.css">
<link rel="stylesheet" type="text/css" href="/css/style.css">
<link rel="stylesheet" type="text/css" href="/css/ui_atom.css">
<link rel="stylesheet" type="text/css" href="/css/ui_list.css">
<link rel="stylesheet" type="text/css" href="/css/contents.css">
<link rel="stylesheet" type="text/css" href="/css/ui_form.css">
<link rel="stylesheet" type="text/css" href="/css/button.css">
<link rel="stylesheet" type="text/css" href="/css/ect.css">
<link rel="stylesheet" type="text/css" href="/xplugin/ckeditor/ckeditor.css">
<link rel="stylesheet" type="text/css" href="/css/egenedoc.css">
<link rel="stylesheet" href="/xplugin/highlight/styles/atom-one-dark.min.css"/>


<script type="text/javascript" src="/xplugin/jquery/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="/xplugin/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/xplugin/bootstrap/js/bootstrap.bundle.min.js"></script>
<script type="text/javascript" src="/xplugin/jquery/ui/1.13.2/jquery-ui.js"></script>
<script type="text/javascript" src="/xplugin/jquery-confirm/jquery-confirm.min.js"></script>
<script type="text/javascript" src="/xplugin/jquery-mentions-input-master/lib/jquery.events.input.js"></script>

<script type="text/javascript" src="/xefc/script/core.js"></script>
<script type="text/javascript" src="/xefc/script/util.js"></script>
<script type="text/javascript" src="/xefc/script/ui_form.js"></script>
<script type="text/javascript" src="/xplugin/s9soft/s9soft.js"></script>

<script>
    var $jq = $;
</script>


<%-- crypt-js --%>
<script type="text/javascript" src="/xplugin/crypto-js/crypto-js.min.js"></script>
<script type="text/javascript" src="/script/egene_popup.js"></script>


<script src="/xplugin/highlight/highlight.min.js"></script>

<script type="text/javascript" src="/xplugin/chosen_v1.8.7/chosen.jquery.min.js"></script>
<script type="text/javascript" src="/xplugin/ckeditor5/ckeditor.js"></script>
<script type="text/javascript" src="/script/dist/common-all.min.js"></script>
<script type="text/javascript" src="/script/dist/egene-all.min.js"></script>


<!-- Popup Layout Page Script -->
<script type="text/javascript">

    moveScroll = function () {
        $jq("#content").animate({scrollTop: 0}, 0);
    };

    function closeWin() {
        window.close();
    }

</script>
<!-- // Popup Layout Page Script -->

<body>
<%@ include file="/xefc/jsp/common/running_b.jspf" %>

<!-- main -->
<div id="main_wrapper" class="popup-layout egene-root">
    <%
        String header_uri = "/xefc/jsp/ui/popup_header.jsp";

    %>
    <!-- Popup Header -->
    <div class="popup_header">
        <%
            try {
        %>
        <jsp:include page="<%= getUrl(header_uri, params) %>" flush="true"/>
        <%
            } catch (BizError e) {
                Log.biz.err("popup_layout.jsp[" + uri + "] " + e);
                Log.biz.err(e.getMessage());
            } catch (Exception e) {
                Log.biz.err("popup_layout.jsp[" + uri + "] " + e);
                Log.biz.err(e.getMessage());
            }
        %>
    </div>
    <!-- //Popup Header  -->

    <!-- Control Button -->
    <div class="popup-top-btn" style="text-align: right;"></div>

    <!-- Content -->
    <div class="content popup-content">

        <%
            // 팝업 컨텐츠 로딩방식 변경됨
            // 팝업 파라미터를 hidden 필드로 등록함
            String[] keys = box.getKeys();
            for (int i = 0; i < keys.length; i++) {
                // check key name
                String key = HttpUtility.translate(keys[i]);
                // || key.charAt(0) == '_'  2021.04.14 _로 시작하는 KEY 예외 처리 제외 -> 타이틀 유지
                if (key.length() == 0
                        || key.startsWith("req.")
                        || key.startsWith("current."))
                    continue;

                String value = HttpUtility.translate(box.get(key));
                out.println("<input type=hidden name='" + key + "' value=\"" + value + "\">");
            }

            if (!StringUtil.valid(uri)) {
        %>
        <div id=info class=border2 style='width: 500px;'>
            <div class=title>
                <%= texts.getText("정보", session) %>
            </div>
            <div class=content style='height:200px;'>
                <%= texts.getText("서비스 준비중입니다.", session) %>
            </div>
        </div>
        <%
                Log.biz.info("popup_layout url[" + uri + "] invalid.");
            }
        %>
    </div>
    <!-- // Content -->

    <!-- Footer -->
    <%
        if (!box.getBoolean("no_resize")) {
    %>
    <!-- Top으로 위치 이동 이미지 상주 영역 -->
    <div id="footer_div">
        <!-- <img src="/images/icon/btn_top.png" style="width: 70%; height: 70%;" onClick="moveScroll();" onMouseOver="swapImg(this);" onMouseOut="releaseImg(this)"> -->
    </div>
    <%
        }
    %>
    <!-- //Footer -->

</div>
<!-- // Main-->

</body>
</html>

<%!
    String getUrl(String uri, String params) {

        int idx = uri.indexOf('?');
        if (idx > 0) {
            return uri + "&" + params;
        }
        if (params == null || params.equals("")) {
            return uri;
        }
        return uri + "?" + params;
    }
%>
