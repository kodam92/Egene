function showSubInput() {
  showFormField('srm_sub_button');  //추가요청 버튼
  showFormField('srm_sub_info'); // 추가요청 접수정보
  hideFormField('srm_sub_parent'); // 상위요청 정보
  hideFormField('srm_sub_child'); // 추가요청 처리정보  
}

function showSubParent() {
  hideFormField('srm_sub_button');  //추가요청 버튼
  hideFormField('srm_sub_info'); // 추가요청 접수정보
  showFormField('srm_sub_parent'); // 상위요청 정보
  hideFormField('srm_sub_child'); // 추가요청 처리정보  
}

function showSubChild() {
  hideFormField('srm_sub_button');  //추가요청 버튼
  hideFormField('srm_sub_info'); // 추가요청 접수정보
  hideFormField('srm_sub_parent'); // 상위요청 정보
  showFormField('srm_sub_child'); // 추가요청 처리정보  
}

function hideSubAll() {
  hideFormField('srm_sub_button');  //추가요청 버튼
  hideFormField('srm_sub_info'); // 추가요청 접수정보
  hideFormField('srm_sub_parent'); // 상위요청 정보
  hideFormField('srm_sub_child'); // 추가요청 처리정보  
}

function controlSubSRForm(srm_id) {
  var srm = getBizData('Get.SRM.Info','key='+ srm_id);

  var tas_id = srm.srm_tas_id;
  var sr_trs_yn = srm.srm_sr_trs_yn;
  var add_sr_cat = srm.srm_add_sr_cat;
  var all_done = srm.srm_sub_sr_alldone_yn;

  console.log("controlSubSRForm - srm_id : " + srm_id);
  console.log("controlSubSRForm - tas_id : " + tas_id);
  console.log("controlSubSRForm - sr_trs_yn : " + sr_trs_yn);
  console.log("controlSubSRForm - add_sr_cat : " + add_sr_cat);
  console.log("controlSubSRForm - all_done : " + all_done);

  if (tas_id == 'TAS01635') { //요청접수 Task
    if (sr_trs_yn == '1') { // 자티켓이 요청 접수 들어왔을 때
      hideButton('CTL05103');
      hideFormField('srm_add_sr_cat'); // 요청 추가접수 여부

      // 자티켓에서 취소종료할 수 있도록 기존 반려버튼 대신 취소버튼 추가
      showButton('CTL05127'); // 취소버튼
      hideButton('CTL02531'); // 반려 -> 재등록

      showFormGroup('srm_sub_group');
      showSubParent();
    } else if (all_done == '1') { // All done, 자티켓 완료되어 요청접수로 돌아왔을 때
      hideButton('CTL05103');
      changeFieldEditable('srm_add_sr_cat', false); // 요청 추가접수 여부

      // 자티켓에서 취소종료할 수 있도록 추가한 취소버튼 대신 기존 반려버튼
      hideButton('CTL05127'); // 취소버튼
      showButton('CTL02531'); // 반려 -> 재등록

      showFormGroup('srm_sub_group');
      showSubChild();
    } else { // 최초 요청 접수 진입했을 때 
      // 자티켓에서 취소종료할 수 있도록 추가한 취소버튼 대신 기존 반려버튼
      hideButton('CTL05127'); // 취소버튼
      showButton('CTL02531'); // 반려 -> 재등록

      showFormField('srm_add_sr_cat'); // 요청 추가접수 여부
      if (add_sr_cat == 'NXTADDSRCAT00100') { //예
        showFormGroup('srm_sub_group');
        showSubInput();
      } else { // 아니오
        hideFormGroup('srm_sub_group');
        hideSubAll();
      }
    }
  } else {
    if (all_done == '1') { // All done
      showFormGroup('srm_sub_group');
      showSubChild();
    } else {
      hideFormField('srm_add_sr_cat'); // 요청 추가접수 여부
      if (sr_trs_yn == '1') { // 자티켓
        showFormGroup('srm_sub_group');
        showSubParent();
      } else {
        if (add_sr_cat == 'NXTADDSRCAT00100') { //예
          showFormGroup('srm_sub_group');
          showSubChild();
        } else { // 아니오
          hideFormGroup('srm_sub_group');
          hideSubAll();
        }
      }
    }
  }
}

/// 테스트 1:N 추가 등록
function showRegSRForm(srm_id)
{
  //var srm_id = '#{row.srm_id}';
  console.log("showRegSRForm : srm_id : " + srm_id);
  var sub_json = getBizData('Get.SRM.SubReq','key='+srm_id);
  console.log("showRegSRForm : sub_json.row_cnt : " + sub_json.row_cnt);
  
  if (sub_json.row_cnt >= 5) {
    alert("추가요청접수는 5개까지 가능합니다.");
  } else {
    showWin('/xefc/jsp/ui/popup_layout.jsp','uri=/xefc/jsp/ui/form/form.jsp&ent_id=SRM&frm_id=FRM012040&auth=true&act=1', '',1200, 800,'');
  }
};

function onPopupClose() {
  console.log("onPopupClose()");
  e$relation.refresh('RefS4F354');
}

