<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>
<%@ include file="/xefc/jsp/include/session.jspf" %>
<%
    Box box = HttpUtility.getBox(request);
%>


<%@ include file="/xefc/jsp/common/html_begin.jspf" %>


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
<link rel="stylesheet" type="text/css" href="/css/egenedoc.css">
<link rel="stylesheet" href="/xplugin/highlight/styles/atom-one-dark.min.css"/>


<script type="text/javascript" src="/xplugin/jquery/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="/xplugin/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/xplugin/bootstrap/js/bootstrap.bundle.min.js"></script>
<script type="text/javascript" src="/xplugin/jquery/ui/1.13.2/jquery-ui.js"></script>
<script type="text/javascript" src="/xplugin/jquery-confirm/jquery-confirm.min.js"></script>

<script type="text/javascript" src="/script/egene/egene_autoSearch.js"></script>

<script>
    var $jq = $;
</script>
<%-- crypt-js --%>
<script type="text/javascript" src="/xplugin/crypto-js/crypto-js.min.js"></script>

<script type="text/javascript" src="/script/egene_popup.js"></script>

<script src="/xplugin/highlight/highlight.min.js"></script>

<script src="/script/dist/common-all.min.js"></script>
<script src="/script/dist/egene-all.min.js"></script>

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

</head>
<body>
<script>

    (function () {

        let version = '<%=box.get("version")%>';
        downloadDoc(version);

        /**
         * 클릭시 특정 엘리먼트에 전체 페이지에 대한 html content 붙이고 첨부파일 과정 로직
         * */
        function downloadDoc(version) {

            $('body').append('<div class="downloadHtml" style="display: none;"></div>')

            // 스크립트가 호출이 다 되고 , html 전체를 붙어야해서 별도의 페이지에서 스크립트 전체 호출하여 화면 그리는 행위
            $('.downloadHtml').load('/xefc/jsp/ui/manual/egenedoc_download_content.jsp', function (a, b, c) {

                var CardViewControl = {

                    fnGeneralCategory: function (result) {

                        let html = '';
                        let subHtml = '';
                        let tabTitle = '';
                        let newHtml = '';

                        $.each(result, function (idx, obj) {

                            tabTitle = obj.name;
                            obj['p_name'] = tabTitle;

                            // new module
                            if (obj['hlp_top'] == '1') {
                                $('.new-list').show();
                                newHtml += CardViewControl.fnCreateCard(obj);
                            }
                            //module 대상
                            if (obj['lev'] == '1') {
                                //module
                                if (obj['hlp_cat_cd'] == 'HLPTYPE070') {
                                    html += CardViewControl.fnCreateCard(obj);
                                    // api/function
                                } else if (obj['hlp_cat_cd'] == 'HLPTYPE080') {
                                    subHtml += CardViewControl.fnCreateCard(obj);
                                }
                            }
                        });

                        $('.downloadHtml .main-list ul').append(html);
                        $('.downloadHtml .new-list ul').append(newHtml);
                        $('.downloadHtml .sub-list ul').append(subHtml);
                    },

                    //module
                    fnCreateCard: function (item) {
                        let temp = '';
                        temp = '<li data-sid="' + getText(item.sid) + '"   data-name="' + getText(item.cat_name) + '" data-id="' + item.id + '">' +
                            '<h5>' + getText(item.cat_name) + '</h5>' +
                            '<div class = "sub-title-group">' + getText(item.hlp_descr) + '</div></li>';
                        return temp;
                    }
                };


                /**
                 * nav 2레벨 하위
                 * @param item
                 * @param subtitle h2의 타이틀
                 * @param subTmpId 현재 temp Id
                 * @param bsubTmpId 이전 temp Id
                 * @param i 현재 loop 수
                 */
                function fnCreateSubAppendView(item, subtitle, subTmpId, bsubTmpId, i) {

                    if (item.root_id) {
                        var sub_li =
                            '<li data-name="' + getText(subtitle) + '" data-id="' + getText(subTmpId) + '"> \
				<span class = "sub_li_name sub_level3">\
				<a href="#' + subTmpId + '">\
					' + getText(subtitle) + '\
				</a></span>\
		 </li>';
                        if (i == 0) {
                            $(sub_li).insertAfter($('#nav_' + item.root_id + ' li[data-id=' + item.id + ']'));
                        } else {
                            $(sub_li).insertAfter($('#nav_' + item.root_id + ' li[data-id=' + bsubTmpId + ']'));
                        }
                    }
                }


                //카테고리  표시
                let CardContentViewControl = {

                    fnGeneralCategory: function (result) {

                        let html = '';
                        var rootHtml = '';
                        let contentHtml = '';
                        let isStart = false;
                        let tabTitle = '';

                        var topArr = [];
                        var subArr = [];

                        $.each(result, function (idx, obj) {

                            if (obj.pid == '') {
                                topArr.push(obj);

                                if (isStart) {
                                    isStart = !isStart;
                                    html += CardContentViewControl.fnCreateCard(obj, isStart);
                                }

                                isStart = true;
                                tabTitle = obj.name;
                                obj['p_name'] = tabTitle;

                                html += CardContentViewControl.fnCreateCard(obj, isStart);
                            } else {
                                subArr.push(obj);
                            }
                        });

                        // 왼쪽 최상위 카테고리 화면 구성
                        $('.downloadHtml .nav-tree').html(html);

                        for (var i = 0; i < topArr.length; i++) {
                            rootHtml += CardContentViewControl.fnCreateRootView(topArr[i]);
                        }

                        $('.downloadHtml #mnl-container').html(rootHtml);

                        for (var i = 0; i < subArr.length; i++) {
                            CardContentViewControl.fnCreateRootSubView(subArr[i]);
                        }

                        for (var i = 0; i < result.length; i++) {

                            if (result[i].pid == '') {
                                contentHtml += CardContentViewControl.fnCreateMainView(result[i]);
                            } else {
                                CardContentViewControl.fnCreateSubView(result[i]);
                            }

                            $('.downloadHtml .mnl-area#' + result[i].id).append(contentHtml);
                            contentHtml = '';
                        }
                    },

                    //대제목
                    fnCreateCard: function (item, isStart) {
                        let temp = '';
                        if (isStart) {
                            temp =
                                '<li data-cat2="' + getText(item.id) + '" data-name="' + getText(item.name) + '" data-id="' + item.id + '"> \
			 <a href="#' + item.id + '">' + getText(item.name) + '</a></li>';
                        } else {
                            temp += '';
                        }
                        return temp;
                    },

                    /**
                     *  1레벨 root 기준으로 하위 nav 리스트 틀 생성 html
                     * @param itemegene
                     */
                    fnCreateRootView: function (item) {
                        let temp = '';
                        temp = '<div class="mnl-area" data-cat2="' + getText(item.id) + '" id="' + item.id + '">' +
                            '<nav class ="area-nav" id="area_nav_' + item.id + '"> ' +
                            '<ul class="nav-brch" id="nav_' + item.id + '">' +
                            '</ul>' +
                            '</nav>' +
                            ' </div>';
                        return temp;
                    },

                    /**
                     *  sid root 기준으로 하위 nav 리스트 데이터 생성 html
                     * @param item
                     */
                    fnCreateRootSubView: function (item) {
                        var sid = item.root_id;
                        var lev = item.lev;
                        var lpadding = 0
                        if (lev >= 3) {
                            lpadding = (lev * 2)
                        }
                        if (sid) {
                            var sub_li =
                                '<li  data-cat="' + getText(item.pid) + '" data-name="' + getText(item.name) + '" data-id="' + item.id + '"> \
				<span class = "sub_li_name" style= "padding-left: ' + lpadding + 'px;">\
				<a href="#' + item.id + '">\
					' + getText(item.name) + '\
				</a></span>\
		 </li>';
                            $('.downloadHtml #nav_' + sid).append(sub_li)
                        }
                    },

                    /**
                     *  1레벨 content html
                     * @param item
                     * @returns {string}
                     */
                    fnCreateMainView: function (item) {
                        let temp = '';
                        temp = '<article class="mnl-article">' +
                            '<div class="mnl-article-box">' +
                            '<h2 id=' + item.id + ' class="atc-title">' + item.name + '</h2><div class ="article-editor" id=' + item.id + '>'
                            + item.content + '</div></div></article>';
                        return temp;
                    },

                    /**
                     *  2레벨이후의  content html , 3레벨 이상일 경우 css 클래스 추가
                     * @param item
                     * @returns {string}
                     */
                    fnCreateSubView: function (item) {

                        let temp = '';
                        if (item.lev > 2) {
                            temp = '<article class="mnl-article level3"'
                        } else {
                            temp = '<article class="mnl-article"'
                        }

                        temp += ' id=' + item.id + '>' +
                            '<div class="mnl-article-box">' +
                            '<h2 id=' + item.id + ' class="atc-title">' + item.name + '</h2><div class ="article-editor" id=' + item.id + '>'
                            + item.content + '</div></div></article>'

                        $('.mnl-area#' + item.root_id).append(temp);

                        // h2 속성일 경우 우측 네비게이션에 나타날수있도록
                        $($('h2', '.article-editor[id=' + item.id + ']')).each(function (i, item2) {
                            let subtitle = $(this)[0].innerText;
                            $(this).attr('id', item.id + '_' + i + '_tmp');
                            // 임의로 만들어진 ID로 nav append
                            fnCreateSubAppendView(item, subtitle, $(this).attr('id'), item.id + '_' + (i - 1) + '_tmp', i);
                        });
                    }
                }

                //카테고리 목록조회
                let manualList;
                $service.ajax({
                    url: '/api/egene/sql/manual_Catagory',
                    async: false,
                    data: {'doc_version': version}
                }, function (result) {
                    manualList = result;
                    CardViewControl.fnGeneralCategory(manualList);
                    $service.ajax({
                        url: '/api/egene/sql/ED_Catagory',
                        async: false,
                        data: {'doc_version': version}
                    }, function (result) {
                        //카테고리 목록조회
                        categoryList = result;
                        CardContentViewControl.fnGeneralCategory(categoryList);
                        const loadHtml = $('.downloadHtml').html();
                        // file 로직
                        var ajaxUrl = '/api/egene/document/createDocument';
                        var ajaxData = {html: loadHtml};
                        var filePrefix = getText("DOCUMENT");
                        var fileSuffix = "zip";
                        downloadAjax(ajaxUrl, ajaxData, function () {
                            parent.hideRunning();
                            $('.downloadHtml').remove();
                        });
                    });
                });
            });
        }


    })();
</script>
</body>
</html>

