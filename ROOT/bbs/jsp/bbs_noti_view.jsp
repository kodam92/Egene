<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%@ include file="/xefc/jsp/include/session.jspf" %>
<%@ include file="/xefc/jsp/common/ui.jsp" %>
<%

	Box box = HttpUtility.getBox(request);
	box.restore();

	ICE ice = ICE.getInstance();
	Sqls sqls = ice.sqls();
	com.steg.efc.Texts texts = com.steg.efc.Texts.getInstance();
	GlobalConfig gcfg = GlobalConfig.getInstance();
	request.setAttribute("obox", box);

	String ent_id = box.get("ent_id");
	String key = box.get("key");
	String frm_id = box.get("frm_id");
	String ebs_ecf_id = box.get("ebs_ecf_id");

	// BBS Config
	HashMap vars = new HashMap();
	vars.put("key", key);
	vars.put("ecr_id", ebs_ecf_id);
	vars.put("ecf_id", ebs_ecf_id);

%>

<div id="bbs_form" class="grid" style="width: 100%; height :100%;">
<%
	String detail_jsp = "/xefc/jsp/ui/form/form.jsp?ent_id=" + ent_id + "&tas_id=&auth=false&frm_id=" + frm_id + "&key=" + key;
%>
    <div id="form_main" style="height:100%;display:flex;flex-direction:column;">
        <!-- Content 영역 -->
        <div style="flex:1;position: relative;height: 100%;overflow-y: hidden;">
            <jsp:include page='<%= detail_jsp %>' flush="true" />
        </div>


        <!-- Content 영역 END -->

		<div class="popup_close" style="text-align: left;">
			<label style="cursor: pointer; vertical-align: middle; font-weight: bold; padding: 5px 0px 5px 15px; " onclick="closeNotice();">
				<input type=checkbox id='chkToday'>
				<label for="chkToday"><span></span>&nbsp;</label>하루 동안 보지 않기&nbsp;&nbsp;
			</label>
		</div>
	</div>

</div>

<script type="text/javascript">
/**
 * Cookie 설정
 **/
setCookie = function(name, value, expiredays) {

	var todayDate = new Date();
	todayDate.setDate(todayDate.getDate() + expiredays);
	document.cookie = name + "=" + escape(value) + "; path=/; expires=" + todayDate.toGMTString() + ";"
}

/**
 * 창 닫기 
 **/
closeNotice = function() {

	if($jq('#chkToday').is(':checked')) {
		setCookie('NOTI_<%= key %>', 'close', 1);
	}
	window.close();
}
</script>
