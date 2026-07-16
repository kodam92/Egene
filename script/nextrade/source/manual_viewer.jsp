<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%@ include file="/xefc/jsp/include/session.jspf" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%

	Box box = HttpUtility.getBox(request);
	Texts texts = Texts.getInstance();

%>
<!-- CSS -->
<link rel="stylesheet" type="text/css" href="/css/manual.css">

<div class="btn-group manual-btn">
	<button type="button" class="btn button-lst-action" title="메뉴얼 목록" >
		<i class="fa fa-long-arrow-left"></i>
		<span>메뉴얼 목록</span>
	</button>
</div>

<div class="list-main manual-list">
	<div class="list-main-contents" style="height: 100%;">

		<!-- 사용자 매뉴얼 -->
		<div class="manual-wrap">
			<div class="dashboard-list-box invoices with-icons">
				<h4><%= texts.getText("사용자 매뉴얼", session) %></h4>
				<ul>
        <!--
                    <li class="manualView-content"
                        data-url="/xefc/jsp/ui/manual/doc_viewer.jsp" data-title="행정안전부 표준 가이드" data-id="GovItsmManual"
                        data-param ="src=/xefc/jsp/ui/manual/doc/GovItsmManual.pdf">
                        <i class="list-box-icon sl sl-icon-doc"></i>
                        <span><%= texts.getText("행정안전부 표준 가이드", session) %></span>
                        <div class="sub-title-group">
                            <p class="sub-title">행정안전부 정보시스템 표준운영절차에 대한 가이드를 담고 있으며, 본 가이드를 통해 각 프로세스의 주요 특징과 준수 포인트를 숙지 할 수 있습니다.</p>
                        </div>
                    </li>
        -->
          <li class="manualView-content hide"
						data-url="/xefc/jsp/ui/manual/doc_viewer.jsp" data-title="ITSM 요청자" data-id="ITSMReqManual"
						data-param ="src=/xefc/jsp/ui/manual/doc/ITSMuserGuide.pdf">
						<i class="list-box-icon sl sl-icon-doc"></i>
						<span><%= texts.getText("ITSM 요청자", session) %></span>
						<div class="sub-title-group">
							<p class="sub-title">Lightning E-GENE 사용을 위한 시스템의 주요기능과 사용절차에 대한 가이드를 담고 있으며, 본 가이드를 통해 Lightning 시스템의 빠른 이해와 사용법을 숙지 할 수 있습니다.</p>
						</div>
						<!--
							<div class="buttons-to-right download">
								<a href="/xefc/jsp/ui/manual/doc/ITSMuserGuide.pdf" class="button gray"  download='ITSM사용자매뉴얼.pdf'><%= texts.getText("다운로드", session) %></a>
							</div>
							-->
					</li>

          <li class="manualView-content hide"
						data-url="/xefc/jsp/ui/manual/doc_viewer.jsp" data-title="ITSM 처리자" data-id="ITSMAssManual"
						data-param ="src=/xefc/jsp/ui/manual/doc/ITSMuserGuide.pdf">
						<i class="list-box-icon sl sl-icon-doc"></i>
						<span><%= texts.getText("ITSM 처리자", session) %></span>
						<div class="sub-title-group">
							<p class="sub-title">Lightning E-GENE 사용을 위한 시스템의 주요기능과 사용절차에 대한 가이드를 담고 있으며, 본 가이드를 통해 Lightning 시스템의 빠른 이해와 사용법을 숙지 할 수 있습니다.</p>
						</div>
						<!--
							<div class="buttons-to-right download">
								<a href="/xefc/jsp/ui/manual/doc/ITSMuserGuide.pdf" class="button gray"  download='ITSM사용자매뉴얼.pdf'><%= texts.getText("다운로드", session) %></a>
							</div>
							-->
					</li>
        <!--
					<li class="manualView-content"
						data-url="/xefc/jsp/ui/manual/video_viewer.jsp" data-title="사용자 동영상" data-id="LightningReqVideo"
						data-param ="src=/manual/video/STEG_ITSM_E-GENE_Lightning_Guide_REQ.mp4">
						<i class="list-box-icon sl sl-icon-doc"></i>
						<span><%= texts.getText("사용자 동영상 매뉴얼", session) %></span>
						<div class="sub-title-group">
							<p class="sub-title">ITSM 서비스요청  하는 방법에 대한  사용방법 및 사용절차에 대한 가이드를 영상으로 담고 있으며, 본 영상를 통해 서비스요청관리에 빠른 이해와 사용법을 숙지 할 수 있습니다.</p>
						</div>
					</li>

					<li class="manualView-content"
						data-url="/xefc/jsp/ui/manual/video_viewer.jsp" data-title="처리자 동영상" data-id="LightningAssVideo"
						data-param ="src=/manual/video/STEG_ITSM_E-GENE_Lightning_Guide_ASS.mp4">
						<i class="list-box-icon sl sl-icon-doc"></i>
						<span><%= texts.getText("처리자 동영상 매뉴얼", session) %></span>
						<div class="sub-title-group">
							<p class="sub-title">ITSM 처리자 측면에서 사용하는 방법에 대한 사용방법 및 사용절차에 대한 가이드를 영상으로 담고 있으며, 본 영상를 통해  쉽고 빠르게 효율적인 업무처리를 숙지 할 수 있습니다.</p>
						</div>
					</li>

					<li class="manualView-content"
						data-url="/xefc/jsp/ui/manual/doc_viewer.jsp"data-title="PMS"  data-id="pmsGuide"
						data-param ="src=/xefc/jsp/ui/manual/doc/pmsGuide.pdf">
						<i class="list-box-icon sl sl-icon-doc"></i>
						<span><%= texts.getText("PMS 기능 매뉴얼", session) %></span>
						<div class="sub-title-group">
							<p class="sub-title">PMS 기능매뉴얼 입니다.</p>
						</div>
					</li>
        -->
				</ul>
			</div>
		</div>

		<!-- 개발자 매뉴얼 -->
		<%--<div class="manual-wrap">
			<div class="dashboard-list-box invoices with-icons">
				<h4><%= texts.getText("개발자 매뉴얼", session) %></h4>
				<ul>

					<li class="manualView-content"
						data-url="/xefc/jsp/ui/manual/help_viewer.jsp" data-title="아톰" data-id="atomGuide"
						data-param ="cat_cd=HLPTYPE010">
						<i class="list-box-icon sl sl-icon-doc"></i>
						<span><%= texts.getText("아톰", session) %></span>
						<div class="sub-title-group">
							<p class="sub-title">Entity 필드 유형 별로 사용할 수 있는 UI형태의 아톰 유형 및 사용방법에 대한 가이드를 담고 있으며, 본 가이드를 통해  데이터 필드 유형에 따라 Form Designer에서  아톰을 쉽게 사용할 수 있는 방법을 숙지 할 수 있습니다.</p>
						</div>
						<!--
							<div class="buttons-to-right download">
								<a href="/xefc/jsp/ui/manual/doc/EGENE_6.1_Atom.docx" class="button gray" download="EGENE_6.1_Atom.docx"><%= texts.getText("다운로드", session) %></a>
							</div>
							 -->
					</li>

					<li class="manualView-content"
						data-url="/xefc/jsp/ui/manual/doc_viewer.jsp" data-title="릴레이션" data-id="relationGuide"
						data-param ="src=/xefc/jsp/ui/manual/doc/relationGuide.pdf">
						<i class="list-box-icon sl sl-icon-doc"></i>
						<span><%= texts.getText("릴레이션", session) %></span>
						<div class="sub-title-group">
							<p class="sub-title">엔티티와 엔티티간의 관계를 정의하는 릴레이션에 대한 정의 및 사용방법에 대한 가이드를 담고 있으며, 본 가이드를 통해  다양한 업무 환경에서 데이터간 관계를 쉽게 사용할 수 있는 방법을 숙지 할 수 있습니다.</p>
						</div>
						<!--
							<div class="buttons-to-right download">
								<a href="/xefc/jsp/ui/manual/doc/EGENE_6.1_Relation.docx" class="button gray"  download="EGENE_6.1_Relation.docx"><%= texts.getText("다운로드", session) %></a>
							</div>
							-->
					</li>


					<li class="manualView-content"
						data-url="/xefc/jsp/ui/manual/doc_viewer.jsp"data-title="E-GENE 자동완성"  data-id="s9sGuide"
						data-param ="src=/xefc/jsp/ui/manual/doc/s9sGuide.pdf">
						<i class="list-box-icon sl sl-icon-doc"></i>
						<span><%= texts.getText("E-GENE 자동완성", session) %></span>
						<div class="sub-title-group">
							<p class="sub-title">사용자 검색의 편의성을 높이기 위해 에스나인에스 회사의 자동완성 솔루션을 E-GENE 패키지에 내재화 되어있으며, 본 가이드를 통해 설치정보와 구성정보를 관리하고 쉽게 사용할 수 있는 방법을 숙지 할 수 있습니다.</p>
						</div>
						<!--
							<div class="buttons-to-right download">
								<a href="/xefc/jsp/ui/manual/doc/E-GENE자동완성가이드.docx" class="button gray" download="E-GENE자동완성가이드.docx"><%= texts.getText("다운로드", session) %></a>
							</div>
							-->
					</li>

					<li class="manualView-content"
						data-url="/xefc/jsp/ui/manual/doc_viewer.jsp"data-title="AutoAssign"  data-id="AutoAssignGuide"
						data-param ="src=/xefc/jsp/ui/manual/doc/AutoAssignGuide.pdf">
						<i class="list-box-icon sl sl-icon-doc"></i>
						<span><%= texts.getText("AutoAssign", session) %></span>
						<div class="sub-title-group">
							<p class="sub-title">다양한 서비스와 프로세스의 담당자를 자동 할당되도록 지원하는 모듈이며, 본 가이드를 통해  담당자 할당 규칙 설정으로 쉽게 프로세스를 구성하고, 담당자를  쉽게 지정하여 사용 할 수 있는 방법을 숙지 할 수 있습니다.</p>
						</div>
						<!--
							<div class="buttons-to-right download">
								<a href="/xefc/jsp/ui/manual/doc/AutoAssign가이드.docx" class="button gray" download="AutoAssign가이드.docx""><%= texts.getText("다운로드", session) %></a>
							</div>
							-->
					</li>


                </ul>
			</div>
		</div>--%>

	</div>
</div>

<div class="manual-content">
	<div class="manual-view"></div>
</div>

<script type="text/javascript">

	var $manual = $('.manual-list'),
			$manualBtn = $('.manual-btn'),
			$content = $('.manual-view'),
			userAgent = '';

	$(document).ready(function(){

		//컨텐츠 숨김
		$content.addClass('hide');
		//메뉴목록 버튼 숨김
		$manualBtn.addClass('hide');

		//버전확인
		var agent = navigator.userAgent.toLowerCase();

		if ( (navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1) ) {
			// 익스플로러
			userAgent = 'ie'
		}else{
			userAgent = 'ext'
		}

		// 권한 조회: ASS 사용자면 관리자 섹션 보이기
		try {
				$.ajax({
					url: '/api/egene/sql/Employee.Req.Role',
					contentType: 'application/json',
					dataType: 'json',
					data: { emp_id: $egene.emp_id },
					success: function(result) {
						var isAss = false;
						if (Array.isArray(result) && result.length>0) {
							for (var i=0;i<result.length;i++){
								var r = result[i] || {};
								if (r.rol_ass_type === 'ROLASSTYPE_ASS') {
									isAss = true; break;
								}
							}
						}
						// Show only the relevant manual item based on role (use hide class to avoid inline styles)
						if (isAss) {
							$('.manualView-content').addClass('hide');
							$('.manualView-content[data-id="ITSMAssManual"]').removeClass('hide');
						} else {
							$('.manualView-content').addClass('hide');
							$('.manualView-content[data-id="ITSMReqManual"]').removeClass('hide');
						}
					},
					error: function(xhr, status, err){
						console.error('Role lookup failed', status, err);
					}
				});
		} catch(e) {
			console.error(e);
			}
	});

	//메뉴 클릭할때
	$(document).on("click", ".manual-wrap .manualView-content span, .sub-title-group", function(e){

		$manual.addClass('hide');
		$manualBtn.removeClass('hide');
		$content.removeClass('hide');

		var url = $(this).parent().attr('data-url'),
				param =  $(this).parent().attr('data-param') ?  $(this).parent().attr('data-param') : '',
				id = $(this).parent().attr('data-id'),
				title = $(this).parent().attr('data-title');

		param = param + '&id=' + id;

		$content.load(url+'?'+param);

		//메뉴명 변경
		$('.form-title-text span').text(title);

	});

	//메뉴 목록
	$(document).on("click", ".manual-btn", function(e){

		//메뉴명 변경
		$('.form-title-text span').text('MANUAL');

		//동영상 멈춤
		var video = '';
		var id = $('video').attr('id');
		var videoTarget = $('#'+id).get(0);

		if($('#'+id).length > 0){
			if(!videoTarget.paused){
				videoTarget.pause();
			}
		}

		$content.html('');
		//컨텐츠 숨김
		$content.addClass('hide');
		$manualBtn.addClass('hide');
		$manual.removeClass('hide');

	});

	//다운로드 객체 생성
	let atags = document.querySelectorAll('a');

	for (let i = 0; i < atags.length; i++) {
		const element = atags[i];
		MS_bindDownload(element);
	}

	//다운로드
	function MS_bindDownload(el) {

		if (el === undefined) {
			throw Error('I need element parameter.');
		}
		if (el.href === '') {
			throw Error('The element has no href value.');
		}
		var filename = el.getAttribute('download');

		if (filename === '') {
			var tmp = el.href.split('/');
			filename = tmp[tmp.length - 1];
		}

		el.addEventListener('click', function (evt) {

			var href = $(this).attr('href');
			if($(this).attr('href') == ''){
				$egene.alert('준비중입니다.');
				evt.preventDefault();

				return false;
			}

			//ie11
			if(userAgent == 'ie'){

				evt.preventDefault();

				var xhr = new XMLHttpRequest();

				xhr.onloadstart = function () {
					xhr.responseType = 'blob';
				};
				xhr.onload = function () {
					navigator.msSaveOrOpenBlob(xhr.response, filename);
				};
				xhr.open("GET", el.href, true);
				xhr.send();
			}

		})
	}


</script>

