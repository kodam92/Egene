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
    GlobalConfig gcfg = GlobalConfig.getInstance();
    String configStr = gcfg.getValue("system");

    JSONObject configObj = (JSONObject)JSONValue.parse(configStr);
    String title = configObj.getString("title");

    if (StringUtil.invalid(title)) {
        title = "▒ 라이트닝 ▒";
    }

    boolean isSearch = StringUtil.parseBoolean(gcfg.getValue("SEARCH_MODULE"), false);

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

    if (is_admin == true) {
        is_test = true;
    }

    session.setAttribute("is_test", is_test);
    session.setAttribute("is_admin", is_admin);

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

    boolean commentYn = "1".equals(configObj.getString("commentused"));

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

    // TODO 접속한 사용자가 프로젝트 멤버인지 확인하고 인증키를 생성한다.
    Box box = HttpUtility.getBox(request);
    box.put("emp_id", _user.emp_id);

%>

<script defer>
    async function setProfile() {
        const profile = await getProfileByUserId("<%=_user.id%>");
        $(".photo").attr("src", profile);
    }

    setProfile();
</script>

<div style="height: 100%;">
    <%--메뉴 호출되는 쿼리 확인 필요--%>
    <script type="text/javascript" src="/script/pms_app.js"></script>

    <div id="egene-root" class="egene-app" style="height: 100%">
        <!-- Application Header -->
        <div class="app-header header">
            <!-- Header -->
            <header id="header-container" class="fixed fullwidth dashboard">
                <div id="header" class="not-sticky">
                    <div class="contain">
                        <!-- Left Side Content -->
                        <div class="left-side">
                            <!--Navigation / End -->
                            <!-- Mobile Navigation -->
                            <div class="left-nav-mini">
                                <div class="nav-mini">
                                    <div class="mmenu-trigger">
                                        <i class="fa fa-remove visible-on-sidebar-regular"></i>
                                        <i class="fa fa-navicon visible-on-sidebar-mini"></i>
                                    </div>
                                </div>
                            </div>
                            <!-- //Mobile  Navigation -->
                            <!-- Navigation / End -->

                            <!-- Logo -->
                            <!-- Full CI -->
                            <div id="logo">
                                <a href="#home" style="padding-top: 5px;"><img id="system_ci" src="egene_pms_logo.png"></a>
                            </div>

                        </div>
                        <!-- Left Side Content  / End-->

                        <!-- header 통합검색 -->
                        <div class="center-side">
                            <div class="pms-search">
                                <i class="fa fa-search"></i>
                                <input class="input-search ui-autocomplete-input"
                                       placeholder="<%= texts.getText("검색하기", session) %>" type="text"
                                       autocomplete="off">
                                <div class="pms-search-box">
                                    <div class="srch-cate">
                                        <div class="cate-list"></div>
                                        <div class="btn-group">
                                            <button type="button" class="srch-detail"><i
                                                    class="fa-solid fa-pencil"></i> <%= texts.getText("상세조회",
                                                    session) %>
                                            </button>
                                        </div>
                                    </div>
                                    <div class="srch-result-box"></div>
                                </div>
                            </div>
                        </div>
                        <!-- Right Side Content-->
                        <div class="right-side">
                            <div>
                                <div class="app-tool">
                                    <!-- User Menu -->
                                    <div class="tool-item float-r">
                                        <div class=" user-menu">
                                            <div class="user-name">
                                                <span><img class="photo"></span>
                                            </div>
                                        </div>
                                    </div>


                                    <!-- 신규 메시지 알림 -->
                                    <div class="tool-item float-r noti-message"
                                         style="position: relative; cursor: pointer;">
                                        <div class="style-l">
                                            <ul style="list-style: none; margin-top: 10px; margin-bottom: 0px;">
                                                <li><i class="list-box-icon fa fa-bell"></i></li>
                                            </ul>
                                        </div>
                                        <span class="comment-new-count">0</span>
                                        <div class="alert-wrap comment-new-list">
                                            <h4 class="alert-title"><%= texts.getText("알림", session) %>
                                            </h4>
                                            <div class="alert-box">
                                                <ul class="alert-tab"></ul>
                                                <div class="alert-tabContent active"></div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- 신규 메시지 알림 -->
                                    <div class="tool-item float-r manual">
                                        <div style="display: inline; float: left">
                                            <div class="nav-item app-tools">
                                                <button type="button" class="manual-btn" title="매뉴얼"><i
                                                        class="fa fa-book" aria-hidden="true"></i></button>
                                                <div class="app-tool-item">
                                                    <ul>
                                                        <li class="fst">
                                                            <a class="btn-doc-manual" onclick="goPMSDocManual()">pdf</a>
                                                        </li>
                                                        <li>
                                                            <a class="btn-vdo-manual"
                                                               onclick="goVdoManual(this)">video</a>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <button type="button" id="app-tool-btn"><i class="fa fa-ellipsis-v" aria-hidden="true"></i>
                        </button>

                    </div>
                    <!-- Contener / End -->

                    <!--  User Info-->
                    <div class="user-menu-countent pms-info">
                        <div class="row userInfo">
                            <div class="rightUser">
                                <div class="title user">
                                    <i class="im im-icon-Add-UserStar"></i><span><%= texts.getText("내계정",
                                        session) %></span>
                                </div>

                                <!-- userInfo_Information -->
                                <div class="group-user-Infomation">
                                    <div class="user-Infomation">
                                        <div class="overflow" title="INFORMATION">
                                            <%= texts.getText("INFORMATION", session) %>
                                        </div>
                                        <div class="img">
                                            <!-- <span><img src="/images/icon/user-icon.png" alt=""></span>-->
                                            <span><img class="photo" src=""></span>
                                            <span>관리자(admin)</span>
                                        </div>
                                    </div>
                                    <div class="user-Infomation org">
                                        <div class="overflow" title="COMPANY&nbsp;/&nbsp;DEPT">
                                            <%= texts.getText("COMPANY", session) %>&nbsp;/&nbsp;<%= texts.getText(
                                                "DEPT", session) %>
                                        </div>
                                        <div class="overflow"></div>
                                    </div>
                                    <div class="user-Infomation email">
                                        <div class="overflow" title="MAIL">
                                            <%= texts.getText("MAIL", session) %>
                                        </div>
                                        <div class="overflow"><%= HttpUtility.translate(_user.get("emp_email")) %>
                                        </div>
                                    </div>
                                    <div class="user-Infomation-btn">
                                        <div class="btn-style-1 overflow" onclick="doLogout()"
                                             title="<%= texts.getText("로그아웃", session) %>">
                                            <%= texts.getText("로그아웃", session) %>
                                        </div>
                                        <div class="btn-style-2 overflow" onclick="goMyInfo()"
                                             title="<%= texts.getText("개인정보수정", session) %>">
                                            <i class="sl sl-icon-lock-open"></i><%= texts.getText("개인정보수정", session) %>
                                        </div>
                                        <div class="btn-style-2 overflow pmsEdit" onclick="" title="pms 환경설정">
                                            <i class="fa-solid fa-gear"></i>
                                        </div>
                                    </div>
                                </div>
                                <!-- userInfo_Information  / End -->
                            </div>
                        </div>
                    </div>
                    <!-- User Info  / End -->
                </div>
            </header>
            <!-- Header / End -->
        </div>
        <!-- Application Header / End-->

        <!-- Application Main -->
        <div class="app-body">
            <!-- Application Main Conents -->
            <div class="main-contents">
                <!-- Left Menu / Navigation -->
                <div class="main-nav clearfix fav-menu fixing">
                    <div class="menu-nav">
                        <div id="menu_area" class="menu-nav-inner" style="position: relative;">
                            <div class="dtree" id="menu">
                                <button type="button" class="menu-fix-btn active"><i class="sl sl-icon-pin"></i>
                                </button>
                                <div class="nav-search">
                                    <div class="keyword_wrapper">
                                        <button type="button" class="new-project" onclick="goNewProject('top')"><i
                                                class="fa fa-file-circle-plus"></i><%= texts.getText("새 프로젝트 만들기",
                                                session) %>
                                        </button>
                                    </div>
                                </div>
                                <!-- Recent Update -->
                                <div class="recent-menu">
                                    <div class="rmTitleWrap">
                                        <h3 class="rm-title">Recent Update</h3>
                                        <button class="rm-btn"></button>
                                        <div id="recentMenuPopup">
                                            <ul class="rm-list" id="rm-list-all">
                                            </ul>
                                        </div>
                                    </div>
                                    <ul class="rm-list" id="rm-list"></ul>
                                </div>
                                <!-- Recent Update end -->


                                <!-- Menu Header -->
                                <div class="menu-header">
                                    <ul class="nav nav-tabs">
                                        <li class="nav-item active">
                                            <a alt="메뉴" href="#tab_itom">
                                                <i class="fa fa-navicon"></i><span><%= texts.getText("Menu",
                                                    session) %></span></a>
                                        </li>
                                        <li class="nav-item tab_fav">
                                            <a alt="즐겨찾기" href="#tab_fav">
                                                <i class="fa fa-star"></i><span><%= texts.getText("Fav",
                                                    session) %></span></a>
                                        </li>
                                    </ul>
                                </div>

                                <!-- Menu Body -->
                                <div class="menu-body">
                                    <div class="menu-body-contents">
                                        <div class="tab-content" style="height: 100%; padding:0px;">

                                            <div class="tab-pane fade show active" id="tab_itom" style="height: 100%;">
                                                <ul id="menu_accordion" class="navbar-nav sidebar accordion"
                                                    style="height: 100%; width: 100%;">
                                                    <div class="menu_items_frame" style="height: 100%;">
                                                        <div id="menu_items">
                                                        </div>
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
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Page Contents Area -->
                <div class="main-article">
                    <%--컨텐츠 로드위치--%>

                    <!-- Popup Bg -->
                    <div class="dim-layer">
                        <div class="dimBg"></div>
                    </div>
                    <!-- Popup Bg /End -->
                    <div class="page">
                        <!-- Content Header -->
                        <!-- Content Header -->
                        <div id="head" class="page-header" style="display: none;">
                            <div class="titlebar">
                                <div class="navBar">
                                    <div class="history">
                                    </div>
                                    <div class="top-btn" style="flex: 1; text-align: right;"></div>
                                    <div class="top-context-menu">
                                        <div class="btn-group">
                                            <button type="button" class="btn button-lst-action pop_list_menu">
                                                <i class="sl sl-icon-options"></i>
                                                <span></span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Content Header / End -->
                        <!-- Content  -->
                        <div class="page-body">
                            <div class="content">
                            </div>
                        </div>
                        <!-- Page Contents Area / End-->
                    </div>

                </div>
                <!-- Page Contents Area / End-->

            </div>
            <!-- Application Main Conents / End  -->
        </div>
        <!-- Application Main / End -->


        <!--  FEED BACK -->
        <div class="uxm_wrap" style="display: none;">

            <div id="uxm_frame"></div>
        </div>

    </div>
</div>

<script type="x/template" id="total_search_result_title_template">
    <li data-ent_id="{{ent_id}}" data-key="{{id}}" data-id="{{_id}}" data-link="{{link}}" class="fa-icon search_link"
        data-idx="{{idx}}">
        <i class="fa {{icon}}"></i><span class="search_content">[{{ent_name}}] {{highlight_title}}</span>
    </li>
</script>
<script language=javascript>
    $(document).ready(function () {
        $('.rm-btn').click(function () {
            $(this).toggleClass('_active');
        });

        // 메뉴 고정핀 function
        $('.menu-fix-btn').click(function () {
            $(this).toggleClass('active');
            if ($(this).hasClass('active')) {
                $("body").removeClass("sidebar-toggled");
                $(".sidebar").removeClass("toggled");
                $('.menu-nav-inner').removeClass('folding');
                $('.main-article').removeClass('folding');
                $('.main-nav').removeClass('folding');

                $('.main-nav').addClass('fixing');
                $('.dim-layer').removeClass('pop-layer2');

                // 상단 메뉴 오픈 버튼 click 해제
                $('.nav-mini').removeAttr('onclick');

            } else {
                $("body").addClass("sidebar-toggled");
                $(".sidebar").addClass("toggled");
                $('.menu-nav-inner').addClass('folding');
                $('.main-article').addClass('folding');
                $('.main-nav').addClass('folding');

                $('.main-nav').removeClass('fixing');
                $('.dim-layer').addClass('pop-layer2');
                // 상단 메뉴 오픈 버튼 click 살리기
                $('.nav-mini').attr('onClick', 'switchMenu()');
            }
        });

        // Recent Menu - 본인이 속한 업무 업데이트 최신순의 프로젝트명 표기
        $service.ajax({
            url: '/api/egene/sql/Recent_pms_menu',
            data: {'emp_id': '<%= _user.emp_id %>'}
        }, function (result) {
            $(result).each(function (index, item) {

                // 메뉴 사용여부 0이 아닐 경우 최근 메뉴 전체 표시
                if ($egene.app.app_menu_used != '0') {
                    if (item.pms_req_title) {
                        $("#rm-list-all").append("<li><a id=gomenu data-id =" + item.pms_id + ">" + item.pms_req_title + "</a></li>");
                    } else {
                        $("#rm-list-all").append("<li><a id=gomenu> </a></li>");
                    }
                }

                if (index < 4) {
                    if (item.pms_req_title) {
                        $("#rm-list").append("<li><a id=gomenu data-id =" + item.pms_id + ">" + item.pms_req_title + "</a></li>");
                    } else {
                        $("#rm-list").append("<li><a id=gomenu> </a></li>");
                    }
                }
            })
            // 최근 프로젝트 없는 경우
            if (!result.length > 0) {
                $('#recentMenuPopup').find('ul').hide();
                $('#recentMenuPopup').append('<p2>' + $egene.getText("최근 업데이트 프로젝트가 없습니다.") + '</p2>');
            }
        })

        let pmsIt = false;
        let pmsCodes = "";
        // pms 사용여부 조회
        $service.ajax({
            contentType: 'application/json',
            dataType: 'json',
            async: false,
            url: '/api/egene/codes/PMSCAT'
        }, function (result) {
            const filtered = result.filter((el) => el.id !== 'PMSCAT020');
            pmsCodes = filtered.map(code => code.id).join('|');
            /*if (!(filtered.length === 1 && filtered[0].id === 'PMSCAT000')) {
                $('.tool-item.float-r.noti-message').show();
            } else {
                pmsIt = true;
            }*/
            if (filtered.length === 1 && result.some(code => code.id === 'PMSCAT000')) {
                pmsIt = true; //IT PMS 만 사용
            }
        });

        //알림 Tab 구성
        let alertObject = {};
        $service.ajax({
            url: '/pms/config/portal_pms_alert.json',
            dataType: 'json'
        }, function (result) {
            //console.log(result);
            if (typeof (result.alertAll) != 'undefined') {
                let alertConfig = result.alertAll;
                let $alertBox = $('.alert-wrap').find('.alert-box');
                let $alertTab = $alertBox.find('.alert-tab');
                //console.log(result.alertAll);

                $alertTab.empty();
                $alertBox.find('.alert-tabContent').remove();
                alertConfig.forEach(function (data) {
                    let html = '';
                    html = '<li id="' + data.id + '"><a>' + $egene.getText(data.label) + '</a></li>';

                    if (pmsIt) {
                        //IT PMS 일 경우 공지사항 Tab만 사용
                        if (data.id === 'noti') {
                            $alertTab.append($(html));
                            $alertBox.append($('<div class="alert-tabContent">' + $egene.getText(data.label) + '</div>'));
                            alertObject[data.id] = data;
                        }
                        return false;
                    }

                    $alertTab.append($(html));
                    $alertBox.append($('<div class="alert-tabContent">' + $egene.getText(data.label) + '</div>'));
                    alertObject[data.id] = data;
                });

                //Tab 선택 이벤트
                $alertBox.find('li').on('click', function () {
                    var index = $(this).index();
                    if ($(this).hasClass('active')) {
                        $('.alert-tab li').removeClass('active');
                        $('.alert-tabContent').eq(index).removeClass('active');
                        $('.alert-tabContent').removeClass('active');
                    } else {
                        $('.alert-tab li').removeClass('active');
                        $(this).addClass('active');
                        $('.alert-tabContent').removeClass('active');
                        $('.alert-tabContent').eq(index).addClass('active');
                    }
                    let alarmType = $(this).attr('id');
                    searchPmsCommentNotiList(alarmType, alertObject[alarmType].portal_hide);
                });

                //상단 알림 아이콘 선택 시 선택된 tab이 없을 경우 수행
                if ($('.comment-new-list').find('.alert-box').find('li.active').length == 0) {
                    $('.comment-new-list').find('.alert-box').find('li:eq(0)').addClass('active');
                    $('.comment-new-list').find('.alert-tabContent:eq(0)').addClass('active');
                }
            }
        });

        /**
         * 최신 업데이트 프로젝트 클릭시 워크스페이스 이동
         */
        $("#rm-list").on('click', 'li', function () {
            let pmsInfoObj = {
                pms_id: $(this).children().attr('data-id'),
                pms_app_id: $egene.app.id
            }
            viewWorkSpace(pmsInfoObj, 'location');
        })

        $("#rm-list-all").on('click', 'li', function () {
            let pmsInfoObj = {
                pms_id: $(this).children().attr('data-id'),
                pms_app_id: $egene.app.id
            }
            viewWorkSpace(pmsInfoObj, 'location');
        })

        // 메뉴 클릭시 이동
        function go_menu(id) {
            goMenu(id);
        }

        //pms 개인정보 수정
        $('.pmsEdit').on('click', function () {
            showWin('/xefc/jsp/ui/popup_layout.jsp', 'uri=' +
                '/xefc/jsp/ui/form/form.jsp&ent_id=025&frm_id=FRMF025011&_title=PMS 환경설정', '', '', '');
        });

        $('.user-menu').on('click', function () {
            userMenu($egene._user.emp_id, $egene._user.emp_name, $egene._user.org_name, $egene._user.dpt_name, $egene._user.emp_email);
        });

        //   $('.content').load('/pms/jsp/my_project_list.jsp');

        /* ------------ User Menu View 요소 밖 영역 클릭시 창 닫히도록 하는 이벤트 --------- */
        $(document).mouseup(function (e) {
            var container = $('.rightUser');
            var userMenu = $('.user-menu.active');

            if (!container.is(e.target) && container.has(e.target).length === 0) { /*내가 클릭한 요소(target)를 기준으로 상위요소에 없으면 */
                if (e.target.className == "user-name") {
                    return false
                }
                /* 계정버튼 클릭시에는 동작 안하도록 (위에서 처리중)*/
                $('.dim-layer').removeClass('pop-layer'); // bg
                $('.user-menu').removeClass('active');
                $('.user-menu-countent.active').removeClass('active');
            }
        });
        /* ----------Search ------- */

        // 프로젝트 그룹 옵션 버튼에 해당되는 마우스 영역 이동시 닫기 처리
        $(document).mouseout(function (e) {
            if ($('.menu-nav ul li ul li.on').has(e.target).length === 0) {
                $('.menu-nav .hide-menu-btn').removeClass('on');
                $('.menu-nav li').removeClass('on');
                $('.menu-nav .hide-menu-box').hide();
            }
        });

        var searched = "";
        var totalCount = 0;
        var oldQuery = "";
        var query;
        var sequence = 0;
        var tooltip = true;
        //var short_sido = false; //짧은검색
        var exact_search = false; //정밀검색
        var $pmsSearch = $('.pms-search');
        var $pmsSearchInput = $pmsSearch.find('.input-search'), $pmsSearchBox = $pmsSearch.find('.pms-search-box');
        var searchObject = {};

        // top 통합검색 search box
        $('.pms-search .input-search').click(function () {
            $(this).parent('.pms-search').addClass('show');
        });
        $(document).click(function (e) {
            if ($(e.target).parents('.pms-search').length == 0) {
                $pmsSearch.removeClass('show');
            } else if (e.target.className == 'srch-detail' || $(e.target).closest('button').attr('class') == 'srch-detail') {
                //console.log('document click!!');
                let keyword = $('.input-search').val(),
                    gubun = $('input[name=srch-radio]:checked').closest('.chk-cate').attr('gubun');
                if ($('.input-search').val() != '') {
                    keyword = $pmsSearchBox.find('.srch-result:eq(0)').find('em:eq(0)').text();
                }

                //상세조회 버튼 클릭
                let pageParam = {
                    'gubun': 'ALL',
                    'keyword': ''
                };
                $('.content').loadPage('/pms/portal/jsp/portal_pms_search.jsp', pageParam, function () {
                    //console.log('loadPage!');
                    $pmsSearch.removeClass('show');
                    $('.input-search').val('');
                    $('input[name=srch-radio]:eq(0)').prop('checked', true);
                });
            }
        });

        //통합검색 Tab 영역 추가
        $service.ajax({
            url: '/pms/config/portal_pms_search.json',
            dataType: 'json'
        }, function (result) {
            //console.log(result);
            if (typeof (result.searchAll) != 'undefined') {
                let searchConfig = result.searchAll;
                searchConfig.forEach(function (data) {
                    let html = '';
                    html = '<span class="chk-cate" gubun="' + data.gubun + '">' +
                        '<input type="radio" name="srch-radio" id="' + data.id + '" value="' + data.value + '">' +
                        '<label for="' + data.id + '"><i class="' + data.cls + '"></i>' + $egene.getText(data.label) + '</label>' +
                        '</span>';
                    if (!(pmsIt === true && (data.gubun === 'PMSWBS' || data.gubun === 'PEM'))) {   //it pms만 사용할때 '업무'와 '멤버' 검색 제외
                        $pmsSearch.find('.cate-list').append($(html));
                        searchObject[data.gubun] = data;
                    }
                });

                //통합검색 tab 선택 시 autocomplete 이벤트 강제 발생
                $pmsSearchBox.find('.cate-list').find('input[name=srch-radio]').on('change', function () {
                    $pmsSearchInput.trigger('select');
                });

                $('input[name=srch-radio]:eq(0)').prop('checked', true);
            }
        });

        // top 통합검색
        $pmsSearchInput.on('focus', function (e) {
            //console.log("focus");
            if ($(this).val() == "") {
                $pmsSearchBox.find('.srch-result').remove(); //조회 영역 삭제
                $pmsSearchBox.find('.srch-result-none').remove();
                return false;
            }
            S9QC.reset();
            $(this).autocomplete("search");
        }).on('click', function (event) {
            //console.log("click");
            searched = false;
            $(this).focus();
        }).on('keyup', function (event) {
            //console.log('keyup');
        }).on('change', function (event) {
            //console.log('change');
        }).on('select', function (event, ui) {
            //console.log("select");
            searched = true;
        }).autocomplete({
            source: function (request, response) {
                var filter_or = true; //필터or사용
                var filter_str = pmsCodes;//$egene._user.emp_id;  //검색필터
                var dic = $('input[name=srch-radio]:checked').val();

                if (typeof (dic) == 'undefined' || dic == '') {
                    dic = '';
                    $('input[name=srch-radio]').each(function () {
                        if ($(this).val() != '' && $(this).val() != 'undefined') {
                            dic += $(this).val() + ',';
                        }
                    });
                    dic = dic.slice(0, -1);
                }

                query = S9QC.clean(request.term);
                if (query == "") {
                    if (S9QC.isEmpty) {
                    }
                    return;
                }

                //데이터 조회
                $service.ajaxHidden({
                    url: "/api/egene/search",
                    dataType: "json",
                    cache: false,
                    data: {
                        //q: encodeURI(query),
                        q: query,
                        count: 100,
                        e: exact_search, // 정밀검색 여부 true, false
                        dic: dic, // dictionary 설정
                        n: ++sequence,
                        filter_or: filter_or,
                        filters: filter_str,
                    },
                }, function (result) {
                    var data = result.data;
                    searched = data.query; //조회 키워드
                    totalCount = data.totalcount; //조회 건수
                    //console.log('result data:', data);

                    //s9s 에서 조회 되지 않아 DB 조회 된 경우
                    if (typeof (totalCount) == 'undefined' && result.data.values) {
                        totalCount = result.data.values.length;
                    }

                    $pmsSearchBox.find('.srch-result').remove(); //조회 영역 삭제
                    $pmsSearchBox.find('.srch-result-none').remove();

                    //조회 템플릿 생성
                    if (data.values && totalCount > 0) { //조회 건수가 있을 경우
                        let dataArray = data.values, dataObjArray = [], dataGroups = [];
                        dataArray.forEach(function (val) {
                            let valArray = val.split('|'), dataObj = {};

                            if (valArray[0] == 'PMSBLG') {
                                valArray[0] = 'PMSWBS';
                            }
                            //config에 설정된 데이터 기준으로 dataObj에 할당
                            if (searchObject[valArray[0]] != undefined) {
                                searchObject[valArray[0]].dataObj.forEach(function (column, i) {
                                    if (column.indexOf(':') != -1) {
                                        let columnArray = column.split(':'), colValArray = valArray[i].split(':');
                                        columnArray.forEach(function (colVal, j) {
                                            dataObj[colVal] = colValArray[j];
                                        });
                                    } else {
                                        dataObj[column] = valArray[i];
                                    }
                                });
                            }
                            dataObjArray.push(dataObj);
                        });

                        dataGroups = groupItems(dataObjArray, 'gubun'); //조회 결과 gubun 기준으로 그룹화
                        let dataGroupsArray = Object.keys(dataGroups);

                        //조회결과 Tab 구성
                        $pmsSearchBox.find('.cate-list').find('.chk-cate').each(function () {
                            for (let value of dataGroupsArray) {
                                if ($(this).attr('gubun') == value) {
                                    let item = {'gubun': value, 'count': dataGroups[value].length}, $html = '';
                                    item['title'] = $('.chk-cate[gubun=' + value + ']').find('label').text();
                                    item['icon'] = searchObject[value].cls;

                                    $html = $(searchResultTemplate(item));

                                    $pmsSearchBox.find('.srch-result-box').append($html);
                                    $html.find('.moreBtn').on('click', function (e) {
                                        //console.log('click!!');
                                        let $target_srch = $(e.target).closest('.srch-result');
                                        let keyword = $('.input-search').val();
                                        if ($('.input-search').val() != '') {
                                            keyword = $target_srch.find('em:eq(0)').text();
                                        }

                                        let pageParam = {
                                            'gubun': $target_srch.attr('gubun'),
                                            'keyword': keyword
                                        };
                                        $('.content').loadPage('/pms/portal/jsp/portal_pms_search.jsp', pageParam, function () {
                                            //console.log('loadPage!');
                                            $pmsSearch.removeClass('show');
                                            $('.input-search').val('');
                                            $('input[name=srch-radio]:eq(0)').prop('checked', true);
                                        });
                                    });
                                    break;
                                }
                            }
                        });
                        response(dataObjArray); //autocomplete 에서 사용할 데이터
                    } else { //데이터가 없을 경우
                        $pmsSearchBox.append($('<div class="srch-result-none"><span>' + $egene.getText('검색 결과가 없습니다.') + '</span></div>'));
                    }
                }, true);
            },
            minLength: 1, //최소글자수
            delay: 300,
            select: function (event, ui) { /* 선택 이벤트: autocomplete _renderItem에서 수행 */
                return false; // false: leave input value, true: resert input value
            },
            focus: function (event, ui) {
                return false;  // false: leave input value, true: resert input value
            },
            open: function (event, ui) {
            }
        }).autocomplete("instance")._renderItem = function (ul, item) {
            //jquery-ui $.widget( "ui.autocomplete" 중 _renderItemData return 되어 해당 영역이 생기는 현상
            $('.ui-autocomplete[id=ui-id-1]').remove();

            let $table = $pmsSearchBox.find('.srch-result[gubun=' + item.gubun + ']').find('table > tbody'), html = '';
            let $searchRow = $(searchResultRowTemplate(item));
            $table.append($searchRow);

            //조회 결과 선택 시 이벤트 실행
            $searchRow.on('click', function (e) {
                let gubun = $(this).attr('gubun'), key = $(this).attr('key'), status = $(this).attr('status'),
                    mtn_id = $(this).attr('mtn_id');
                if (gubun == 'PMS') {
                    let pmsInfo = {'pms_id': key, 'pms_app_id': 'pms'};
                    if (status == '1') {
                        viewWorkSpace(pmsInfo, 'location');
                    } else {
                        $egene.alert($egene.getText('프로젝트의 멤버가 아닙니다.'));
                    }
                } else if (gubun == 'PMSWBS') {
                    var entId = 'PMSWBS';
                    if (key.indexOf("PBG") > -1) {
                        entId = 'PMSBLG';
                    }
                    viewFormPopup(key, '', entId, '', '', '', '', 0, {'mtn_id': mtn_id});
                } else if (gubun == 'PEM') {
                    viewFormPopup(key, '', '025', '', 'FRMF025012', '', '', 0, {'mtn_id': mtn_id});
                } else if (gubun == 'CMT') {
                    var entId = 'PMSWBS';
                    if (key.indexOf("PBG") > -1) {
                        entId = 'PMSBLG';
                    }
                    viewFormPopup(key, '', entId, '', '', '', '', 0, {'mtn_id': mtn_id});
                } else if (gubun == 'ATT') {
                    let $target = $(e.target);
                    if ((typeof ($(e.target).attr('class')) == 'undefined' && $(e.target).closest('span').attr('class') == 'dw')
                        || $target.attr('class') == 'dw' || $target.attr('class').indexOf('fa-download') != -1) {
                        //파일 다운로드
                        let $targetTR = $target.closest('tr');
                        let params = [];
                        params.push("direct=true");
                        params.push('ent_id=' + $targetTR.attr('file_gubun'));
                        params.push('src_id=' + $targetTR.attr('src_id'));
                        params.push('att_id=' + $targetTR.attr('key'));
                        params.push('tab_name=' + encodeURIComponent(searchObject[$targetTR.attr('gubun')].tables[$targetTR.attr('file_gubun')]));

                        var url = "/servlet/com.steg.servlet.DownloadServlet";
                        downloadAjax(url, params.join('&'));
                    } else {
                        if ($(this).attr('ent_id') == 'PMSCAL') {
                            viewFormPopup($(this).attr('src_id'), '', $(this).attr('ent_id'), '', 'PMSCF009873', '', '', 0, {'mtn_id': mtn_id});
                        } else {
                            viewFormPopup($(this).attr('src_id'), '', $(this).attr('ent_id'), '', '', '', '', 0, {'mtn_id': mtn_id});
                        }
                    }
                }
            });
            return $(html);
        };

        //통합검색 template
        function searchResultTemplate(item) {
            let html = '';

            html = '<div class="srch-result" gubun="' + item.gubun + '">' +
                '  <div class="titleFlex">' +
                '    <h5 class="result"><i class="' + item.icon + '"></i>' + item.title + '<span class="count">' + item.count + '</span></h5>' +
                '    <button type="button" class="moreBtn">+ ' + $egene.getText('더보기') + '</button>' +
                '  </div>' +
                '  <div class="result-box">' +
                '    <table>';

            if (item.gubun == 'PEM') {
                html += '      <colgroup><col style="width: auto;"><col style="width: 0px;"></colgroup><tbody></tbody>';
            } else {
                html += '      <colgroup><col style="width: auto;"></colgroup><tbody></tbody>';
            }
            html += ' </table></div></div>';
            return html;
        }

        //조회 데이터 template
        function searchResultRowTemplate(item) {
            let html = '';

            if (item.gubun == 'PMS') {
                let pem_emp = item.pem_emp, status = 0, status_val = '';
                if (pem_emp.indexOf($egene._user.emp_id) != -1) {
                    status = 1;
                    status_val = $egene.getText('참여중');
                }
                html = '<tr gubun="' + item.gubun + '" key="' + item.key + '" status="' + status + '"><td><span class="result">' + S9HL.highlightTag(item.title, searched, "<em>", "</em>") + '</span></td>' +
                    '<td class="t_right"><span class="status _done">' + status_val + '</span></td></tr>';
            } else if (item.gubun == 'PMSWBS') {
                var statusSpan = '';
                if (item.status_name_color != '' && item.status_name_color != undefined) {
                    let textColor = getTextColor(item.status_name_color);
                    statusSpan = '<span class="status" style="color: ' + textColor + '; background-color:' + item.status_name_color + '">' + item.status + '</span>';
                } else {
                    statusSpan = '<span class="status _' + item.status_val + '">' + item.status + '</span>';
                }
                html = '<tr gubun="' + item.gubun + '" key="' + item.key + '" mtn_id="' + item.mtn_id + '"><td><span class="result">' + item.project_name + ' > ' + S9HL.highlightTag(item.title, searched, "<em>", "</em>") + '</span></td>' +
                    '<td class="t_right">' + statusSpan + '</td></tr>';
            } else if (item.gubun == 'PEM') {
                html = '<tr gubun="' + item.gubun + '" key="' + item.key + '"><td><span class="result">' +
                    '    <span class="pf-item">' +
                    '      <span class="pf-img"><img src="/xefc/jsp/ui/common/file.jsp?type=profile&key=' + (item.emp_photo ? item.emp_photo : '') + '" alt=""></span>' +
                    '      <span class="pf-title">' + S9HL.highlightTag(item.title, searched, "<em>", "</em>") + '</span>' +
                    '    </span>' + S9HL.highlightTag(item.project_name, searched, "<em>", "</em>") +
                    '</span></td>' +
                    '</tr>';
            } else if (item.gubun == 'CMT') {
                html = '<tr gubun="' + item.gubun + '" key="' + item.key + '" mtn_id="' + item.mtn_id + '">' +
                    '<td><div class="reply-list">' +
                    '    <span class="titleArea">' +
                    '      <span class="loc">' + item.project_name + ' > <span class="w-t">' + item.req_title + '</span></span>' +
                    '      <span class="title ck-editor-readonly">' + S9HL.highlightTag(item.title, searched, "<em>", "</em>") + '</span>' +
                    '    </span>' +
                    '    <div class="userArea">' +
                    '      <span class="profile"><img src="/xefc/jsp/ui/common/file.jsp?type=profile&key=' + (item.emp_photo ? item.emp_photo : '') + '" alt=""></span>' +
                    '      <div class="user-info">' +
                    '        <span class="name">' + item.reg_emp_name + '</span><span class="date">' + item.reg_dttm + '</span>' +
                    '      </div>' +
                    '    </div>' +
                    '</div></td>' +
                    '</tr>';
            } else if (item.gubun == 'ATT') {
                html = '<tr gubun="' + item.gubun + '" key="' + item.key + '" file_gubun="' + item.file_gubun + '" ent_id="' + item.ent_id + '" src_id="' + item.src_id + '" mtn_id="' + item.mtn_id + '">' +
                    '<td><div class="reply-list">' +
                    '    <span class="titleArea">' +
                    '      <span class="loc">' + item.project_name + ' > <span class="w-t">' + item.req_title + '</span></span>' +
                    '      <span class="title"><span class="dw"><i class="fa-solid fa-download"></i>' + S9HL.highlightTag(item.title, searched, "<em>", "</em>") + '</span></span>' +
                    '    </span>' +
                    '    <div class="userArea">' +
                    '      <span class="profile"><img src="/xefc/jsp/ui/common/file.jsp?type=profile&key=' + (item.emp_photo ? item.emp_photo : '') + '" alt=""></span>' +
                    '      <div class="user-info">' +
                    '        <span class="name">' + item.reg_emp_name + '</span><span class="date">' + item.reg_dttm + '</span>' +
                    '      </div>' +
                    '    </div>' +
                    '</div></td>' +
                    '</tr>';
            }
            return html;
        }

        //조회 데이터 grouping
        function groupItems(array, property) {
            var reducer = function (groups, item) {
                var name = item[property]
                var group = groups[name] || (groups[name] = []);
                group.push(item);
                return groups;
            };
            return array.reduce(reducer, {});
        }


        async function getProfileByUserId(userId) {
            let photoSrc = "";
            // ecf_employee에 해당 유저의 emp_photo에 저장된 img_id를 통해 통해서 ecf_image 테이블에 이미지 조회
            const result = await $.ajax({
                url: '/api/egene/sql/SQL01204',
                type: 'get',
                cache: false,
                async: false,
                data: {
                    user_id: userId
                }
            });
            // result 성공 및 데이터 존재할 때, 이미지 데이터 삽입
            if (result.length) {
                photoSrc = result[0].img_url;
            }
            // result가 존재하지 않을 때 Google 이미지 조회 및 삽입
            else {
                //google 로그인 Image를 가져오기 위한 api
                $service.ajax({
                    url: '/api/egene/google/userinfo',
                    method: 'get',
                    async: false
                }, function (result) {
                    //google 로그인을 한 경우
                    if (result !== null) {
                        photoSrc = result.picture;
                    }
                }, true);
            }
            // GOOGLE 이미지 조회 후에도 값이 없을 때 anonymous 이미지 반환
            if (!photoSrc) photoSrc = "data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD//gA7Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2NjIpLCBxdWFsaXR5ID0gOTAK/9sAQwADAgIDAgIDAwMDBAMDBAUIBQUEBAUKBwcGCAwKDAwLCgsLDQ4SEA0OEQ4LCxAWEBETFBUVFQwPFxgWFBgSFBUU/9sAQwEDBAQFBAUJBQUJFA0LDRQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQU/8AAEQgARgBGAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/aAAwDAQACEQMRAD8A+t8Ck4ozRmgBeKOKM1taF4P1XxEN9pbHyc486Q7U/Pv+GaAMXg0YFdxJ8INZSPcs9m7f3A7A/qtcrq+h3+hXHk31s8DnoTyrfQjg0AUeKOKTNGaADiijNFAC4owKKKAOl8BeF18Ta0EmB+xwDzJsfxei/j/IGvc4oY4IkjiRY40G1UUYAHoBXnnwaCCw1JhjzDKgP0wcfzNei7vagBcVR1nRbXXtPks7uMPG44PdD2I9DV7PtSbvagD5x1jS5NF1S5spuZIXK5Hcdj+Iwap4rsfiuqDxa5XG5oULfXp/LFcdQAYFFFFABiiiigDr/hp4lj0DWmiuXCWt2AjOeisPuk+3JH417Z1rwHwx4OvvFMxFuoitlOHuHHyr7D1Pt/KvatA0Y6Fpsdp9rmuwnR5iOPYeg9uaANTFQXt5BptpLc3MgihjXczN2FS1zHjXwfL4qt1Ed/JA0fKwtzEx9SBzn35+lAHj/iLWH1/Wru+YFRK/yqf4VHCj8gKzauato93od69reQmGVeeejD1B7iqVAC4ooooAMVseFfDsvibWYrNCUj+/LIP4UHU/Xt+NY9ex/CXR1s9Ae+Zf3t25wf8AYU4A/PcaAOwsNPg0yzitbaMRQRDaqj/PWrGKWigBMUmKdRQBheLfC0HijTGgcBLhAWhm7o3+B714Jc2slncSwTIY5YmKOp6gg819L968g+LujrZ61BfRrhbtPmx/fXAJ/Ij8qAODxRRRQAYr6F8KwLb+GtLRegtoyfqVBP6miigDWxSEUUUAAGRQBRRQAYrhPjBbq/h21l/iS5AB9irZ/kKKKAPIKKKKAP/Z";
            return photoSrc;
        }

    });
</script>

<!-- css -->
<link rel="stylesheet" type="text/css" href="/css/colorcode.css">