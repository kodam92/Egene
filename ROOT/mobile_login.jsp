<%--
  Created by IntelliJ IDEA.
  User: gojaehag
  Date: 2015. 10. 6.
  Time: 오후 3:32
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%
    Box box = HttpUtility.getBox(request);
    ICE ice = ICE.getInstance();
    Sqls sqls = ice.sqls();

    // mobile type의 ssd가 없을 경우 웹화면으로 이동
    RecordSet typRs = null;
    Data d = new Data();
    d.put("smb_type", "mobile");
    Result typR = sqls.getResult("SSD5.SMBoards.Mobile", d);
    typRs = typR.getRecordSet();

    if (!getMobileCheck(request) || typRs.getRowCount() == 0) {
        request.setAttribute("pcMode", true);
        RequestDispatcher rd = request.getRequestDispatcher("index.jsp");
        rd.forward(request, response);
    }
    typRs.next();

    String system = "";
    com.steg.efc.Texts texts = com.steg.efc.Texts.getInstance();

    GlobalConfig gcfg = GlobalConfig.getInstance();
    String sysname = gcfg.getWebTitle();
    if (!StringUtil.valid(sysname)) {
        sysname = "라이트닝";
    }

    String errorCode = box.get("error_code");
    errorCode = (errorCode == null) ? "" : HttpUtility.translate(errorCode);

%>
<!DOCTYPE html>
<html>
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

    <meta http-equiv="Cache-Control" content="no-cache"/>
    <meta http-equiv="Pragma" content="no-cache"/>

    <title><%= sysname %>
    </title>

    <!-- bootstrap  -->
    <link href="/xplugin/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <!-- font -->
    <link href="/xplugin/font-awesome/css/font-awesome.min.css" rel="stylesheet">
    <!-- jqx -->
    <link href="/xplugin/jqwidgets/styles/jqx.base.css" rel="stylesheet">

    <!-- Login CSS -->
    <link href="/css/login.css" rel="stylesheet" type="text/css">

    <script type="text/javascript" src="/xplugin/jquery/jquery-3.7.1.min.js"></script>
    <script type="text/javascript" src="/xplugin/jquery/ui/1.13.2/jquery-ui.min.js"></script>
    <!-- angularjs scripts -->

    <script type="text/javascript" src="/xplugin/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/xplugin/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script>
        var $jq = $;
    </script>

    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>

    <script type="text/javascript" src="/script/dist/egene-all.min.js"></script>
    <script type="text/javascript" src="/script/dist/common-all.min.js"></script>

    <script type="text/javascript">

        $(document).ready(function () {
            $service.ajax({
                url: '/api/egene/user'
            }, function (result) {
                if (result.status == '999') {
                    $('.mobile-login').load('/xefc/egene/login.jsp');
                    $('.mobile-login').show();

                    // 에러코드 있는경우 메시지 표시
                    var errorCode = '<%=HttpUtility.translate(errorCode)%>';
                    if (errorCode == 'LIT006') {
                        $egene.alert('사용자 정보가 없습니다.');
                    } else if (errorCode == 'LIT009') {
                        $egene.alert('허용되지 않은 접근입니다');
                    }

                } else {
                    // 로그인 되어 있는 경우
                }
            }, true);

        });
    </script>
</head>

<body>

<%@ include file="/xefc/jsp/common/running_b.jspf" %>

<div class="mobile-login" style="width:100%; height:100%; overflow: hidden; display: none;"></div>

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