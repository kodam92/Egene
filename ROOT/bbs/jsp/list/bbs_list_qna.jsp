<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%@ include file="/xefc/jsp/common/form.jsp" %>
<%@ include file="/xefc/jsp/common/page.jsp" %>
<%@ include file="/xefc/jsp/ui/list/include/format.jsp" %>
<%

	Box box = (Box)request.getAttribute("box");

	ICE ice = ICE.getInstance();
	Sqls sqls = ice.sqls();
	Texts texts = Texts.getInstance();

	// BBS ADMIN
	String bbsAdminSqlId = "Employee.Role";
	String arrParams[] = new String[1];
	arrParams[0] = box.get("current.emp_id");
	Result bbsResutl = sqls.getResult(bbsAdminSqlId, arrParams);
	RecordSet bbsRs = bbsResutl.getRecordSet();
	String FINAL_BBS_ADMIN = "R999";	// BBS Admin Role ID
	String bbsadmin = "";
	while(bbsRs.next()) {
		if(FINAL_BBS_ADMIN.equals(bbsRs.get("rol_id"))) {
			bbsadmin = "1";
		}
	}
	box.put("bbsadmin", bbsadmin);

	boolean isPagemode = true;    // page Mode.
	int curpage = box.getInt("curpage");
	int pagesize = box.getInt("pagesize");
	int act = box.getInt("act");

	UIList2 ul = (UIList2)request.getAttribute("uilist");
	if(ul == null || ul.isError) {
		Log.biz.err("list_01.jsp[" + ul + "] ", ul.getThrowable());
%>
<%= ul.getThrowable() %>
<%
		return;
	}

	String cls = "grid_1";
	if(StringUtil.valid(ul.layout.cls)) {
		cls = ul.layout.cls;
	}

	String conds_style = "";
	if(!ul.conds.visible) { 
		conds_style = "display: none;";
	}

	if(pagesize==0) {
		curpage = 1;
		pagesize = ul.grid.pagesize;
		if (pagesize == 0) {
			//pagesize = 15;
			isPagemode = false;
		}
	}
	
	String lst_id = box.get("lst_id");
%>
<div class="list-body">
    <div id="<%=ul.id%>" class="svc_content list-content" style="width:100%;">
        <div class="<%= cls %> jqx-grid-frame" style="display: flex; flex-direction: column; width: 100%;">

				<form name=conds method=post action='/xefc/jsp/ui/list/list_main.jsp?lst_id=<%= lst_id %>' onsubmit="return false;">
					<input type=hidden name=curpage value=''>
					<input type=hidden name=pagesize value=''>
					<input type=hidden name=act value='1'>
					<!-- UIITEM Entity.ListSearch uiitem_fid-->
					<input type=hidden name=uiitem_fid value="<%= box.get("uiitem_fid") %>">

<%
	String[] uri_params = StringUtil.getArray(ul.uri_params, ',');
	for(int i = 0; i < uri_params.length; i++) {
		out.println("<input type=hidden name='" + uri_params[i] + "' value='" + box.get(uri_params[i]) + "'>");
	}

	if(ul.conds.visible) { 
%>
			<%@ include file="/xefc/jsp/ui/list/include/bbs_conds_jqxgrid.jsp" %>
<%
	} else {
%>
			<%@ include file="/xefc/jsp/ui/list/include/conds_hidden.jsp" %>
<%
	}
%>
			</form>


<%
	Result result = ul.getResult(box);
	if(result.isError) {
		Log.biz.err("list_01.jsp[" + ul.id + "] ", result.getException());
%>
		<%@ include file="/error/error.jsp" %>
<%
	} else {
%>
		<%@ include file="/bbs/jsp/list/bbs_grid_qna.jsp" %>
<%
	}
%>
		</div>
	</div>
</div>

<script type="text/javascript">
<%
	for(int i = 0; i < ul.scripts.size(); i++) {
%>
<%= Utils.transVars((String)ul.scripts.get(i), box, session) %>
<%
	}
%>

/*
* qna 선택시 action
 */
showContent = function(el_id) {

	var el = $jq('#' + el_id);
	var dis = el.css('display');

	$jq('div.bbs_qna_content').hide();
	if(dis == 'block') {
		el.hide();
	} else {
		el.show();
	}
}

function searchBbsQna() {
    // 컨트롤버튼 초기화
    resetPageButton();
    $('.list-body').searchForm(false);
 	// 기본 조회버튼 추가
	addPageButton('', getText("조 회"), searchBbsQna, null, 'search');	
}

function searchEnter() {
	$(document).on('keydown', 'input', function(event) {
		if (event.key === 'Enter') {
			event.preventDefault();
			$('.list-body').searchForm(true);
		}
	});
}

$(document).ready(function(){
	// 컨트롤버튼 초기화
	resetPageButton();
	// Enter 키 눌렀을 때 폼 전송
	searchEnter();
	// 기본 조회버튼 추가
	addPageButton('', getText("조 회"), searchBbsQna, null, 'search');
});
</script>