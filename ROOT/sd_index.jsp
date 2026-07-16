<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="/xefc/jsp/common/import.jspf" %>

<script>
    // viewWorkSpaceSd();
    function createTransLocationForm() {
        // 화면 이동 폼 객체 찾기
        var $locForm = $(document.body).find('form.sd-location');
        // 없으면 폼 객체 생성
        if ($locForm.length == 0 || $locForm.length == undefined) {
            $locForm = $('<form class="sd-location" method="POST" action="/sd.jsp" target=""></form>');
            $(document.body).append($locForm);
        }
        // 값 초기화
        $locForm.attr('target', '');
        // csrf 토큰 설정
        $locForm.append('<input type="hidden" name="'+$egene.csrf.param+'" value="'+$egene.csrf.token+'">');
        return $locForm;
    }

    var f = 'servicedesk'
    var win = window.open('', f);

    if (win) {
        var $form = createTransLocationForm();
        $form.attr('target', f);
        $form.submit();
        win.focus();
    }
    $('#menu_items > .active').removeClass('active');
    document.location.href = '/#home'
</script>
