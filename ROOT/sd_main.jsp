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

    JSONObject configObj = (JSONObject) JSONValue.parse(configStr);
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
<style>
    :root {
        --primaryMain: <%= primaryMain %>;
        --primaryDark: <%= primaryDark %>;
        --primaryLight: <%= primaryLight %>;
        --secondaryMain: <%= secondaryMain %>;
    }
    
    /* .user-menu-countent .userInfo {
        width: 420px !important;
    } */
    .egene-root.pms i.left_menu_icon {
        display: none;
    }
</style>
<div style="height: 100%;">
    <script type="text/javascript" src="/script/sd_app.js"></script>

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
                            <div class="left-nav-mini">
                                <div class="nav-mini appear" onclick="switchMenu()">
                                    <div class="mmenu-trigger" >
                                        <i class="fa fa-remove visible-on-sidebar-regular"></i>
                                        <i class="fa fa-navicon visible-on-sidebar-mini"></i>
                                    </div>
                                </div>
                            </div>
                            <!--Navigation / End -->
                            <%--<div class="left-nav-mini" style="width: 45px;">
                                <div class="nav-mini appear" onclick="switchMenu()">
                                    <div class="mmenu-trigger" >
                                        <i class="fa fa-ellipsis-v visible-on-sidebar-regular"></i>
                                        <i class="fa fa-navicon visible-on-sidebar-mini"></i>
                                    </div>
                                </div>
                            </div>--%>

                            <!-- Mobile Navigation -->
                            <%--<div class="left-nav-mini-m" style="width: 45px; padding-left: 10px;">
                                <div class="nav-mini appear-m" onclick="switchMenu_m()">
                                    <div class="mmenu-trigger mmenu-trigger-m">
                                        <i class="fa fa-ellipsis-v visible-on-sidebar-regular"></i>
                                        <i class="fa fa-navicon visible-on-sidebar-mini"></i>
                                    </div>
                                </div>
                            </div>--%>
                            <!-- //Mobile  Navigation -->

                            <!-- Navigation / End -->

                            <!-- Logo -->
                            <!-- Full CI -->
                            <div id="logo">
                                <a href="#home"><span class="title"><div class="project-name"></div></span></a>
                            </div>
                            <!-- Logo / End -->

                        </div>
                        <!-- Left Side Content  / End-->

                        <!-- Right Side Content-->
                        <div class="right-side">
                            <div> 
                            <div class="app-tool">
                                    <!-- User Menu -->
                                    <div class="tool-item float-r">
                                        <div class="user-menu">
                                            <div class="user-name">
                                                <!-- <span><img src="/images/icon/user-icon.png" alt=""></span> -->
                                                <span><img src="<%=photo_src%>"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Right Side Content / End -->
                    </div>
                    <!-- Contener / End -->

                    <!--  User Info-->
                    <div class=" user-menu-countent">
                        <div class="row userInfo">
                             <div class="col-md-9" style="padding-right:0;">
                                <div class="title">
                                    <i class="sl sl-icon-docs "></i><span><%= texts.getText("나의 요청(처리) 현황", session) %></span>
                                </div>
                            <!-- userInfo_count -->
                            <div class="col-lg-4 col-md-4 group-count-all">
                                <!-- Item -->
                                <div class="row">
                                    <div class="col-md-6 group-count">
                                        <div class="dashboard-stat count active">
                                            <div class="dashboard-stat-content" target="userInfo_grid_01"
                                                 listid="MY_TODO_LIST">
                                                <span><%= texts.getText("나의할일", session) %></span><h4>0</h4></div>
                                        </div>
                                    </div>
                                    <div class="col-md-6 group-count">
                                        <div class="dashboard-stat count">
                                            <div class="dashboard-stat-content" target="userInfo_grid_02"
                                                 listid="MY_REQUEST_LIST">
                                                <span><%= texts.getText("나의요청", session) %></span><h4>0</h4></div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                <div class="col-md-6 group-count">
                                    <div class="dashboard-stat count">
                                        <div class="dashboard-stat-content" target="userInfo_grid_03"
                                             listid="MY_REQUEST_APPR_LIST">
                                            <span><%= texts.getText("승인이력", session) %></span><h4>0</h4></div>
                                    </div>
                                </div>
                                <div class="col-md-6 group-count">
                                    <div class="dashboard-stat count">
                                        <div class="dashboard-stat-content" target="userInfo_grid_04"
                                             listid="MY_TODO_APPR_LIST">
                                            <span><%= texts.getText("승인대기", session) %></span><h4>0</h4></div>
                                    </div>
                                </div>
                               </div>
                            </div>
                            <!-- userInfo_count / End-->

                            <!-- userInfo_List -->
                            <div class="col-lg-8 col-md-8 group-list">
                                <div class="userinfo-grid" style="height:330px; ">
                                    <div id="userInfo_grid_01" class="grid-content active"></div>
                                    <div id="userInfo_grid_02" class="grid-content"></div>
                                    <div id="userInfo_grid_03" class="grid-content"></div>
                                    <div id="userInfo_grid_04" class="grid-content"></div>
                                </div>
                            </div>
                            <!-- userInfo_List / End -->
                           </div>
                            <div class="col-md-3 rightUser" >
                                <div class="title user">
                                    <i class="im im-icon-Add-UserStar"></i><span><%= texts.getText("내계정", session) %></span>
                                </div>

                                    <!-- userInfo_Information -->
                                    <div class="group-user-Infomation">
                                        <div class="user-Infomation">
                                            <div class="overflow" title="<%= texts.getText("INFORMATION", session) %>">
                                                <%= texts.getText("INFORMATION", session) %>
                                            </div>
                                            <div class="img">
                                                <!-- <span><img src="/images/icon/user-icon.png" alt=""></span>-->
                                                <span><img src="<%=photo_src%>"></span>
                                                <span>관리자(admin)</span>
                                            </div>
                                        </div>
                                        <div class="user-Infomation org">
                                            <div class="overflow" title="<%= texts.getText("COMPANY", session) %>&nbsp;/&nbsp;<%= texts.getText("DEPT", session) %>">
                                                <%= texts.getText("COMPANY", session) %>&nbsp;/&nbsp;<%= texts.getText("DEPT", session) %>
                                            </div>
                                            <div class="overflow">STEG / 솔루션개발팀</div>
                                        </div>
                                        <div class="user-Infomation email">
                                            <div class="overflow" title="<%= texts.getText("MAIL", session) %>">
                                                <%= texts.getText("MAIL", session) %>
                                            </div>
                                            <div class="overflow"><%= HttpUtility.translate(_user.get("emp_email")) %>
                                            </div>
                                        </div>
                                        <div class="user-Infomation-btn">
                                            <div class="btn-style-1 overflow" onclick="doLogout()" title="<%= texts.getText("로그아웃", session) %>">
                                                <%= texts.getText("로그아웃", session) %>
                                            </div>
                                            <div class="btn-style-2 overflow" onclick="goMyInfo()" title="<%= texts.getText("개인정보수정", session) %>">
                                                <i class="sl sl-icon-lock-open"></i><%= texts.getText("개인정보수정", session) %>
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
                <div class="main-nav clearfix">
                    <div class="menu-nav">
                        <div id="menu_area" class="menu-nav-inner" style="position: relative;">
                            <div class="dtree" id="menu">
                                <div class="nav-search">
                                    <div class="keyword_wrapper">
                                        <input class="input_search" placeholder="Search for Menu.." type="text"
                                               id="search_input"
                                               autocomplete="off"/>
                                        <div class="input_clear">
                                            <i id="search_clear" class="sl sl-icon-close"></i>
                                        </div>
                                    </div>
                                </div>
                                <!-- Menu Header -->
                                <div class="menu-header">
                                <!-- 
                                    <div class="keyword_wrapper">
                                        <input class="input_search" placeholder="Search for Menu.." type="text"
                                               id="search_input"
                                               autocomplete="off">
                                        <div class="input_clear">
                                            <i id="search_clear" class="sl sl-icon-close"></i>
                                        </div>
                                    </div>
								 -->
                                    <ul class="nav nav-tabs">
                                        <li class="nav-item active">
                                            <a alt="메뉴" data-toggle="tab" href="#tab_itom">
                                                <i class="fa fa-navicon"></i><span><%= texts.getText("Menu", session) %></span></a>
                                        </li>
                                        <li class="nav-item tab_fav">
                                            <a alt="즐겨찾기" data-toggle="tab" href="#tab_fav">
                                                <i class="fa fa-star"></i><span><%= texts.getText("Fav", session) %></span></a>
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
                                <div class="menu-footer" style="display: none;">
                                    <a class="btn btn-size appear" onclick="switchMenu()"></a>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
                <!-- Left Menu / Navigation -->

                <!-- Page Contents Area -->
                <div class="main-article">

                    <!-- Popup Bg -->
                    <div class="dim-layer">
                        <div class="dimBg"></div>
                    </div>
                    <!-- Popup Bg /End -->

                    <div class="page">
                        <!-- Content Header -->
                        <div id="head" class="page-header">
                           <div class="titlebar">
                                <%--
                                <div class="title"></div>
                                --%>
                                <div class="navBar">
                                    <div class="history"></div>
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
                            <div class="content"></div>
                        </div>
                        <!-- Content / End-->
                    </div>
                </div>
                <!-- Page Contents Area / End-->

            </div>
            <!-- Application Main Conents / End  -->
        </div>
        <!-- Application Main / End -->


        <!--  FEED BACK -->
        <div class="uxm_wrap" style="display: none;">
            <%--<iframe id="uxm_frame" style='width:100%;height:530px;' marginwidth=0 marginheight=0 scrolling=yes
                    frameborder=0></iframe>--%>
            <div id="uxm_frame"></div>
        </div>


        <div id="doc_running">
            <img id="loading-image" src="/images/loading.gif" alt="Loading..."/>
        </div>

    </div>
</div>

<script type="x/template" id="total_search_result_title_template">
    <li data-ent_id="{{ent_id}}" data-key="{{id}}" data-id="{{_id}}" data-link="{{link}}" class="fa-icon search_link" data-idx="{{idx}}">
        <i class="fa {{icon}}"></i><span class="search_content">[{{ent_name}}] {{highlight_title}}</span>
    </li>
</script>
<script language=javascript>
    $(document).ready(function () {

        $('.user-menu').on('click', function () {
            userMenu($egene._user.emp_id, $egene._user.emp_name, $egene._user.org_name, $egene._user.dpt_name, $egene._user.emp_email);
        });

        /* ------------ User Menu View 요소 밖 영역 클릭시 창 닫히도록 하는 이벤트 --------- */
        $(document).mouseup(function (e) {
            var container = $('.user-menu-countent.active');
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
    var root = $('#total_search');

    var $html = {
        template_title_html : $('#total_search_result_title_template').html()
    };

    var $el = {
        search_body: $('div.atom-group', root),
        search_title_result: $('#total_search_title_result'),
        searchKeyword: $('#total_search_keyword'),
        result_body: $('div.search_result div.list_info', root),
        formsize: $('#total_search_pageindex', root),
        keyword : $('#total_search_keyword', root),
        bekeyword: $('#total_search_bekeyword', root),
    };
    var searchTimer;
    var oldKeyword;

    var searchTitleInfo = {
        moveCursor: false, // 커서 움직임.
        selected: -1,
        resultCnt:-1   // max 값
    };

    var DEF = {
        RESULT_TITLE_CLEAR : 'clear',
        RESULT_TITLE_DOWN: 'down',
        RESULT_TITLE_UP: 'up',
    };

    {
        /**
         * KeyInput 검색
         * **/
        $el.searchKeyword.on('keyup', function (e) {
            var keyCode = e.keyCode;
            var data = fnGetParam();
            var keyword = data['keyword'];

            if (keyCode == 13) {
                if(searchTitleInfo.moveCursor) {

                    var el = $('li.selected', $el.search_title_result);

                    var key = el.attr('data-key');
                    var ent_id = el.attr('data-ent_id');

                    fnLinkEvent(el, ent_id, key);

                    $el.keyword.val('');
                    $el.search_title_result.hide();

                } else {
                    clearTimeout(searchTimer);
                    $el.formsize.val(0);
                    fnSearch();

                }

                fnResultTitleKeyDown(DEF.RESULT_TITLE_CLEAR);

            } else if(keyCode == 38){ // up

                fnResultTitleKeyDown(DEF.RESULT_TITLE_UP);
                return false;


            } else if(keyCode == 40){ // down

                fnResultTitleKeyDown(DEF.RESULT_TITLE_DOWN);
                return false;
            }else {

                if(oldKeyword == keyword) {
                    return;
                }

                clearTimeout(searchTimer);
                if(keyword.length >= 2) {
                    searchTimer = setTimeout(fnTitleSearch, 300);
                } else {
                    if($el.search_title_result.attr('display') == 'none') {
                        return;
                    }
                    $el.search_title_result.hide();
                }
                oldKeyword = keyword;
            }
        });

        $el.search_title_result.width($($el.keyword.parent()).width());

        $el.search_title_result.on('click', 'li.search_link', function(e){
            e.stopPropagation();

            var el = $(this);

            var key = el.attr('data-key');
            var ent_id = el.attr('data-ent_id');

            fnLinkEvent(el, ent_id, key);

            $el.keyword.val('');
            $el.search_title_result.hide();


        });


        $el.keyword.focusout(function(e){
            e.stopPropagation();

            setTimeout(function() {
                $el.search_title_result.hide();
            }, 300);

        });
    }

    /**
     * 조회
     * */
    var fnTitleSearch = function(){
        var data = fnGetParam();
        var keyword = data.keyword || '';

        // keyword 백업
        $el.bekeyword.val(keyword);

        $service.ajaxHidden({
            url: '/api/egene/searchtitle',
            method:'GET',
            data: data
        }, function(result){
            var resultData = result.data;
            var resultInfo = JSON.parse(resultData);

            fnTitleResultShow(resultInfo);
        }, true)
    }

    var fnTitleResultShow = function(result){

        var html = '';
        var hits = result.hits;
        var arrHits = hits.hits;
        var len = arrHits.length;

        if(len === 0) {
            $el.search_title_result.hide();
        } else {
            var idx =0;

            for (var i = 0; i < len; i++) {
                var hit = arrHits[i];
                var map = hit._source;
                var highlight = hit['highlight'];
                var title = map.title;
                var ent = map['ent_id'];
                var id = map['id'];


                // 메뉴의 경우 사용여부가 존재하는지
                if(ent == '' +
                    'MEN' && !$egene.menus[id]) {
                    continue;
                }

                if(highlight) {
                    title = hit.highlight['title'] || map.title;
                }
                map['highlight_title'] = title;
                map['idx'] = idx++; //메뉴가 상단에서 필터링 되므로 아래에서 처리 해야 함


                html += $.fn.fnRenderTemplate($html.template_title_html, map);
            }
            searchTitleInfo.resultCnt = idx;
        }

        $('ul', $el.search_title_result).empty().append(html);
        $el.search_title_result.show();

    }

    var fnLinkEvent = function(el, ent_id, key){

        var url = '/xefc/jsp/ui/form/form.jsp';

        if(ent_id == 'EMM') {
            url = '/xefc/jsp/ui/manual/tui_viewer.jsp'

            showWin('/xefc/jsp/ui/popup_layout.jsp',
                'uri='+url+'&ent_id='+ent_id
                +'&key=' + key + '&_title=', '', null, null, '_search' + key);
            return false;

        }else if(ent_id == 'MEN') {

            var href = location.href
            if (href.indexOf('#') > 0) {
                href = href.substring(0, href.indexOf('#'));
            }
            document.location = href + '#' + key;

            return false;
        }else if(ent_id == 'CATEGORY') {
            var href = location.href
            var link = el.attr('data-link');

            if (href.indexOf('#') > 0) {
                href = href.substring(0, href.indexOf('#'));
            }
            document.location = href + '#form' +  link + '&_title=' + encodeURIComponent('반출증');
            // http://localhost:8080/#form/FRM003696/ent_id=SRM/cat_cd=SRMCAT01010

            return false;
        } else if(ent_id == 'FAQ' || ent_id == 'QNA') {
            viewForm(key, '', 'BBSBBS', '', 'FRMBBSQA002');

            return false;
        }else {
            showWin('/xefc/jsp/ui/popup_layout.jsp',
                'uri='+url+'&ent_id='+ent_id
                +'&key=' + key + '&_title=', '', null, null, '_search' + key);

            return false;

        }

    }

    var fnResultTitleKeyDown = function(code) {

        if(code == DEF.RESULT_TITLE_CLEAR) {
            $el.search_title_result.hide();
            searchTitleInfo.selected = -1;
            searchTitleInfo.moveCursor=false;
            searchTitleInfo.resultCnt=-1;
            $('li.selected', $el.search_title_result).removeClass('selected');
        } else if(code == DEF.RESULT_TITLE_UP) {

            if(searchTitleInfo.selected > -1) {
                searchTitleInfo.selected--;
                searchTitleInfo.moveCursor = (searchTitleInfo.selected === -1)? false: true;

                $('li.selected', $el.search_title_result).removeClass('selected');
                $('li[data-idx=' + searchTitleInfo.selected + ']', $el.search_title_result).addClass('selected');

                return false;
            }

        } else if(code == DEF.RESULT_TITLE_DOWN) {

            if(searchTitleInfo.selected < (searchTitleInfo.resultCnt-1)) {
                searchTitleInfo.selected++;
                searchTitleInfo.moveCursor = true;
                $('li.selected', $el.search_title_result).removeClass('selected');
                $('li[data-idx=' + searchTitleInfo.selected + ']', $el.search_title_result).addClass('selected');

                return false;
            }
        }
    }


        /**
     * 조회
     * */
    var fnSearch = function(){

        var href = location.href
        if (href.indexOf('#') > 0) {
            href = href.substring(0, href.indexOf('#'));
        }
        var data = fnGetParam();


        document.location = href + '#MENSEARCH' + '/keyword=' + encodeURIComponent(data.keyword);
        $el.keyword.val('');
        $el.search_title_result.hide();
    }



    /**
     * 조회 조건 파라메터
     */
    var fnGetParam = function(){

        var data = {
            'formsize': ($el.formsize.val() || 0) * 10,
            'keyword' : $el.keyword.val(),
            'bekeyword': $el.bekeyword.val()
        };

        return data;
    }
    
  //recent menu Fix Icon
    var togglePinButton = function (elem) {
        elem.toggleClass('active');
        if(elem.hasClass('active')) {
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
            $('.nav-mini').attr('onClick','switchMenu()');
        }
    }
    $('.dtree').prepend('<button type="button" class="menu-fix-btn"><i class="sl sl-icon-pin"></i></button>');
    $('.menu-fix-btn').click(function(){
        togglePinButton($(this));
    });
    //togglePinButton($('.menu-fix-btn'));
});


    doReload = function (act) {
        var json = callAjaxJSON("/xif/jsp/common/ent_reset_ajax.jsp", "act=" + act);
        $egene.alert(json.msg.replace(/<br>/gi, '\n'));
    };
	
    // Recent Menu 설정
    var json = getBizData('Recent_menu_sd', 'emp_id=<%= _user.emp_id %>');
    const id = json.id.split(',');
    const pid = json.pid.split(',');
    
    for(let i=0; i<4; i++){
        var id_name = getBizData('Recent_menu_name', 'id=' + id[i]);
        var pid_name = getBizData('Recent_menu_name', 'id=' + pid[i]);
        if(id_name.name){
            $("#rm-list").append("<li><a id=gomenu name="+ id[i] +" style='cursor:pointer' onclick=go_menu('"+id[i]+"')>" + pid_name.name + " > " + id_name.name + "</a></li>");
        }else{
            $("#rm-list").append("<li><a id=gomenu> </a></li>");
        }
    }
    
    function go_menu(id){
    	goMenu(id);
    }

</script>