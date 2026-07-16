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
    if (!getMobileCheck(request)) {
        response.sendRedirect("index.jsp");
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
    <meta name="viewport" content="width=device-width, initial-scale=1">
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

    <link rel="shortcut icon" href="/favicon.ico"><!-- Chrome, Safari, IE -->
    <link rel="icon" href="/favicon.png"><!-- Chrome, Safari, IE -->

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

</head>


<body>

<div class="mobile-app">
    <div class="app-header">

    </div>
    <div class="app-body">

    </div>

    <div class="app-footer">

    </div>

</div>

<script>
    $(document).ready(function () {
        $('.app-body').load('/xssd5/?typ_id=158331117100001#/board/46320110-1b93-4c75-9832-0cedcecc3b5c');
    });
</script>

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