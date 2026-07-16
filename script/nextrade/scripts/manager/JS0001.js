const BASIC = 0;	// ‘등록>접수>처리>확인>종료’ 
const APPR = 1;		// ‘등록>승인>접수>처리>확인>종료’
const PROCAPPR = 2;	// ‘등록>승인>접수>처리 전 승인>처리>확인>종료’
const ICM = 4;		// ‘등록>접수>처리>장애이관>처리>확인>종료’
const CHM = 5;		// ‘등록>승인>접수>처리>변경이관>처리>확인>종료’
const PROCCHM = 6;	// ‘등록>승인>접수>처리>확인>종료(CHM 필드제어)’
/*

	함수 1 : 서비스요청 각 요청분류별 필드 제어 & process_type 지정
	
*/
var process_type = 6;	// 프로세스 유형(BASIC, APPR, PROCAPPR, ICM, CHM, PROCCHM)

function controlSRMFormField(cat_cd, srm_id, icm_trs_yn, ass_emp_id, cur_emp_id) {
	hideSRMFormField();		// 필드 숨기기
	
	hideButton('CTL_TRANS_CHM03'); //전산개발요청관련 버튼 (요청승인 -> 변경처리중)
	hideButton('CTL_TRANS_CHM03_1'); //전산개발요청관련 버튼 (요청승인 -> 변경처리중)
	hideButton('CTL_TRANS_CHM03_2'); //전산개발요청관련 버튼 (요청승인 -> 변경처리중)
	
	/* 단순문의/VOC(SRMCAT010) */
	if(cat_cd.substring(0, 9) == 'SRMCAT010'){
		process_type = BASIC;
	}
	
	/* 개발/데이터요청(SRMCAT020) */
		// 시스템 개발
	else if(cat_cd == 'SRMCAT02010'){
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCCHM;
	}
		// 데이터 제공
	else if(cat_cd == 'SRMCAT02020'){
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
	}
		// 데이터 생성/변경
	else if(cat_cd == 'SRMCAT02030'){
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCCHM;
	}
	
	/* 오류/장애신고(SRMCAT030) */
	else if(cat_cd.substring(0, 9) == 'SRMCAT030'){
		showFormField('srm_sys_id');		// 업무시스템		
		process_type = ICM;
	}
	
	// 장애관리
	else if(cat_cd == 'SRMNXTCAT07010'){
	process_type = CHM
	}
	
	/* 사용자지원 > PC/주변기기 요청(SRMCAT05010) */ 
		// 지급/교체 요청
    else if (cat_cd == 'SRMCAT0501010') {
        showFormField('srm_prov_rel');		// 지급/교체
		process_type = PROCAPPR;
    } 
		// 대여 요청
	else if (cat_cd == 'SRMCAT0501020') {
        showFormField('srm_rent_rel');		// 대여요청
		process_type = PROCAPPR;
    } 
		// 반납 요청
	else if (cat_cd == 'SRMCAT0501030') {
        showFormField('srm_return_rel');	// 반납요청
		process_type = PROCAPPR;
    } 
		// PC SW 요청
	else if (cat_cd == 'SRMCAT0501040') {
        showFormField('srm_pcsw_rel');		// PC/SW요청 
		process_type = PROCAPPR; 		
    }
		// AS 요청 및 문의 
	else if (cat_cd == 'SRMCAT0501050') {
		process_type = PROCAPPR; 		
    }
		// 사용자셋팅(변경)요청
	else if (cat_cd == 'SRMCAT0501060') {
		process_type = PROCAPPR; 		
    }
		// 전산 소모품 신청
	else if (cat_cd == 'SRMCAT0501070') {
		process_type = PROCAPPR; 		
    }
	
	/* 사용자지원 > 계정/권한 요청(SRMCAT05020) */
		// 계정 요청, 권한 요청
	else if(cat_cd == 'SRMCAT0502010' || cat_cd == 'SRMCAT0502020'){
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
	}
		// 서버 계정요청 
    else if(cat_cd == 'SRMCAT0502030'){
        showFormField('srm_os_nsec_rel');	// 시스템계정발급
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
    }
		// 서버 권한요청
	else if(cat_cd == 'SRMCAT0502040'){
        showFormField('srm_sys_auth_rel');	// 시스템접근권한 
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
    }
		// 공유 폴더 권한 요청
	else if(cat_cd == 'SRMCAT0502050') {
        showFormField('srm_share_folder_rel');	// 공유폴더권한
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
    }
		// DB 권한요청
	else if(cat_cd == 'SRMCAT0502060'){
        showFormField('srm_db_auth_rel');	// DB접근권한
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
    }
		// DB 계정요청
	else if (cat_cd == 'SRMCAT0502080') {
        showFormField('srm_db_nsec_rel');	// DB계정발급
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
    }
     
	/* 사용자지원 > 보안 요청(SRMCAT05030) */
	    // 보안 정책 추가, 개인/부서문서함 관련 요청, spam Mail 요청, 보안정책 예외적용, 화상회의 문의/요청, 유선/무선WiFi 네트워크 문의 및 요청
    else if (cat_cd == 'SRMCAT0503010' || cat_cd == 'SRMCAT0503020' || cat_cd == 'SRMCAT0503040' || cat_cd == 'SRMCAT0503060' || cat_cd == 'SRMCAT0503070' || cat_cd == 'SRMCAT0503080') {		
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
    } 
        // 방화벽 허용/차단 신청서
    else if (cat_cd == 'SRMCAT0503030') {		
        showFormField('srm_fw_rel');		// 방화벽
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
    } 
		// VPN client 접속 (외부접속사용 신청서)
	else if (cat_cd == 'SRMCAT0503050') {
        showFormField('srm_vpn_rel');		// VPN
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
    } 
		// 라우팅 추가/수정 요청
	else if (cat_cd == 'SRMCAT0503090') {
        showFormField('srm_routing_rel');	// 라우팅
		showFormField('srm_sys_id');		// 업무시스템
		process_type = PROCAPPR;
    }
	
	/* 사용자지원 > 기타 요청(SRMCAT05040) */
		// 기타 요청
	else if (cat_cd == 'SRMCAT05040') {
		process_type = PROCAPPR;
	}
	
	/* 인프라(SRMCAT080) */
	else if (cat_cd.substring(0, 9) == 'SRMCAT080' || cat_cd == 'SRMNXTCAT07010'){
		showFormField('srm_cit_id');		// 구성항목
		showFormField('srm_sys_id');		// 업무시스템
		showFormField('srm_cm_cat_cd');	    	// 자산분류
		process_type = CHM;
		if (cat_cd.substring(0,11) == 'SRMCAT08040') {
		   showFormField('srm_chm_trs_yn'); // 변경이관여부
		}
    } 
	
	/* 혁신제안요청(SRMCAT060) */
	else if (cat_cd.substring(0, 9) == 'SRMCAT060'){
		process_type = PROCAPPR;
    } 
	
	/* 정보화사업 검토요청(SRMCAT070) */
	else if (cat_cd.substring(0, 9) == 'SRMCAT070'){
		process_type = BASIC;
    } 
    
    /* 장애문의 테스트(COD02114) */
    else if (cat_cd == 'COD02114'){
        showFormField('srm_sys_id');		// 업무시스템
		process_type = ICM;
    }
	
	/* 변경문의 테스트(COD02115) */
    else if (cat_cd == 'COD02115'){
        showFormField('srm_sys_id');		// 업무시스템
		process_type = CHM;
    }
    
    /* 장애문의 테스트(COD02136) */
    else if (cat_cd == 'COD02136'){
        showFormField('srm_sys_id');		// 업무시스템
		process_type = ICM;
    }
    
    /* 변경문의 테스트(COD02137) */
    else if (cat_cd == 'COD02137'){
        showFormField('srm_sys_id');		// 업무시스템
		process_type = CHM;
    }
    
    else{
		process_type = BASIC;
	}
	
	
	controlSRMFormFieldNXT(cat_cd);
	controlSRMFormFieldType(cat_cd, srm_id, icm_trs_yn, ass_emp_id, cur_emp_id, process_type);
	controlSRMFormButton(cat_cd, srm_id, icm_trs_yn , process_type);

	return process_type;
	
}



/*

	함수 2 : 서비스요청(처리부터 종료)	요청분류 5가지 유형(BASIC, APPR, PROCAPPR, ICM, CHM) 별 필드 제어
	
*/
function controlSRMFormFieldType(cat_cd, srm_id, icm_trs_yn, ass_emp_id, cur_emp_id, process_type){
    
	var chm_json = getBizData('Get.SRM.Info','key='+ srm_id);
	var chm_trs_yn = chm_json.chm_trs_yn;
	var srm_tas_id = chm_json.srm_tas_id;
	/* !!변경이관 요청분류!!  */
	/* 처리단계 이후에는 변경이관여부가 '예'인 경우만 표시 */
    if ((process_type == CHM || process_type == PROCCHM) && ( srm_tas_id == 'TAS01637' || chm_trs_yn == '1')) {
		 
		var src_obj = getBizData('Get.CHM.Info','key='+ srm_id); 
		
		
		// 변경이관 된 내역이 존재할 때
		if (src_obj.row_cnt > 0 ){
			showFormGroup('srm_trschm_group');	 // 변경프로세스 이관  - 서비스요청처리
			showFormField('srm_chm_info_rel');   // 변경이관정보(내역) - 서비스요청처리, 처리확인 
			showFormField('srm_chm_ing_info');   // 변경이관정보(내역) - 변경처리중
			showFormField('srm_chm_info_rel_end'); // 서비스요청 종료
			
			showFormGroup('srm_act_group'); 	 // 처리정보
			showFormField('srm_actstart_dttm');  // 처리시작일시
			showFormField('srm_actfinish_dttm'); // 처리완료일시
			showFormField('srm_end_mh'); 		 // 투입공수(M/H)
			showFormField('srm_act_content'); 	 // 처리내용
			showFormField('srm_act_emp_id'); 	 // 처리자
			showFormField('srm_clo_cd');		 // 처리코드
		}
		// 변경이관 된 내역이 존재하지 않을 때
		else { 
			showFormGroup('srm_trschm_group'); 	 // 변경프로세스 이관  - 서비스요청처리 
			showFormField('srm_chm_rel'); 		 // 변경이관정보(추가) - 서비스요청처리
			showFormField('srm_chm_ing_info');   // 변경이관정보(내역) - 변경처리중
		}
		
        // 현재 로그인된 id와 현재 티켓의 처리자 id가 동일 할 때
		if (cur_emp_id == ass_emp_id){
			showFormField('srm_chm_ing_add_info');   //  추가 변경이관정보 - 변경처리중
		}
		
		// Service Desk로 등록한 경우 필드 제어
		if (icm_trs_yn == '0'){
		    showFormGroup('srm_act_group'); 	 // 처리정보
		    showFormField('srm_chm_info_rel_end'); // 서비스요청 종료
		    showFormField('srm_actstart_dttm');  // 처리시작일시
			showFormField('srm_actfinish_dttm'); // 처리완료일시
			showFormField('srm_end_mh'); 		 // 투입공수(M/H)
			showFormField('srm_act_content'); 	 // 처리내용
			showFormField('srm_act_emp_id'); 	 // 처리자
			showFormField('srm_clo_cd');		 // 처리코드
		}
		
    /* !!장애이관 요청분류!! */
    }else if (process_type == ICM) { 
	    var json = getBizData('SRM.ICM.CNT', 'rel_key=' + srm_id); 
	    var cnt = json.cnt;
	    
		// 장애이관 된 내역이 존재 안할 때
		if (cnt == '0') {    
			// 장애이관 여부가 '아니오' 일 때
			if(icm_trs_yn == '0'){
				showFormGroup('srm_act_group'); 	 // 처리정보
				showFormField('srm_icm_trs_yn'); 	 // 장애이관여부
				showFormField('srm_actstart_dttm');  // 처리시작일시
				showFormField('srm_actfinish_dttm'); // 처리완료일시
				showFormField('srm_end_mh'); 		 // 투입공수(M/H)
				showFormField('srm_act_content'); 	 // 처리내용
				showFormField('srm_act_emp_id'); 	 // 처리자
				showFormField('srm_clo_cd');		 // 처리코드
			}
			// 장애이관 여부가 '예' 일 때(장애처리중)
			else{
				showFormGroup('srm_act_group');   	 // 처리정보
				showFormField('srm_icm_trs_yn'); 	 // 장애이관여부
			}
		} 
		// 장애이관 된 내역이 존재 할 때
		else if(cnt != '0'){
			// 장애이관 여부가 '예' 일 때
			if (icm_trs_yn == '1') {
				showFormGroup('srm_act_group');  	 // 처리정보
				showFormField('srm_icm_trs_yn'); 	 // 장애이관여부
				showFormField('srm_icm_info_rel'); 	 // 장애이관정보
				showFormField('srm_actstart_dttm');  // 처리시작일시
				showFormField('srm_actfinish_dttm'); // 처리완료일시
				showFormField('srm_end_mh'); 		 // 투입공수(M/H)
				showFormField('srm_act_content'); 	 // 처리내용
				showFormField('srm_act_emp_id'); 	 // 처리자
				showFormField('srm_clo_cd');		 // 처리코드
			} else {
				// 장애처리중
				showFormGroup('srm_act_group'); 	 // 처리정보
				showFormField('srm_icm_trs_yn'); 	 // 장애이관여부
			}
		} 
	/* !!일반 요청분류!! */ 
	}else { // BASIC, APPR, PROCAPPR
        showFormGroup('srm_act_group'); 			  // 서비스요청처리 - 처리정보
        showFormField('srm_actstart_dttm'); 		  // 처리시작일시
        showFormField('srm_actfinish_dttm'); 		  // 처리완료일시
        showFormField('srm_end_mh'); 				  // 투입공수(M/H)
        showFormField('srm_act_content'); 			  // 처리내용
		showFormField('srm_act_emp_id'); 			  // 처리자
		showFormField('srm_clo_cd');				  // 처리코드
    }    
    
   
}



/*

	함수 3 : readonly가 아닐 경우 필드 전체를 숨기기 위한 함수

*/
function hideSRMFormField() {

	
    hideFormField('srm_os_nsec_rel');		// 시스템계정발급
    hideFormField('srm_sys_auth_rel');		// 시스템접근권한
    hideFormField('srm_share_folder_rel');	// 공유폴더권한
    hideFormField('srm_db_auth_rel');		// DB 접근권한
    hideFormField('srm_db_nsec_rel');		// DB 계정발급
	
    hideFormField('srm_vpn_rel');			// vpn
    hideFormField('srm_fw_rel');			// 방화벽
    hideFormField('srm_routing_rel');		// 라우팅
	
    hideFormField('srm_cit_id');			// 호스트명

    
    /* hideFormGroup('srm_trschm_group'); 		// 변경프로세스 이관(Group)  - 서비스요청처리
	hideFormField('srm_chm_trs_yn');        // 변경이관정보 - 변경이관여부 - 처리
    hideFormField('srm_chm_info_rel'); 		// 변경이관정보(내역) - 서비스요청처리, 처리확인
    hideFormField('srm_chm_info_rel_end');  // 변경이관정보(내역) - 종료
    hideFormField('srm_chm_rel'); 			// 변경이관정보(추가) - 서비스요청처리
	hideFormField('srm_chm_ing_info'); 		// 변경이관정보(내역) - 변경처리중
	hideFormField('srm_chm_ing_add_info');  // 추가 변경이관정보  - 변경처리중 
	*/
    hideFormGroup('srm_act_group');   		// 처리정보(Group) - 서비스요청처리
	hideFormField('srm_actstart_dttm'); 	// 처리시작일시
	hideFormField('srm_actfinish_dttm'); 	// 처리완료일시
	hideFormField('srm_end_mh'); 			// 투입공수(M/H)
	hideFormField('srm_act_content'); 		// 처리내용 
	hideFormField('srm_act_emp_id'); 		// 처리자
	hideFormField('srm_clo_cd');			// 처리코드
	hideFormField('srm_icm_trs_yn'); 		// 장애이관여부
	hideFormField('srm_icm_info_rel');	 	// 장애이관정보 - 서비스요청처리, 장애처리중
	hideFormField('srm_cm_cat_cd');	    	// 자산분류
	
    hideFormField('srm_rou_rel');           // 라우터 신청 (REL)
    hideFormField('srm_l4_rel');            // 로드밸런싱 신청 (REL)
    hideFormField('srm_fw_band_rel');       // 방화벽 정책 (REL)
    hideFormField('srm_firewall_band')      // 방화벽 정책
    hideFormField('srm_firewall_band_con'); // 방화벽 정책 내용
    
    hideFormField('srm_cit_id2');			// 구성항목(백업정책 요청)
    hideFormField('srm_cit_id2_text');		// 구성항목 옆 빈칸
    hideFormField('srm_cmbak2_rel');        // 백업정책 (REL)

}

function showSRMFormField() {

	
    showFormField('srm_os_nsec_rel');		// 시스템계정발급
    showFormField('srm_sys_auth_rel');		// 시스템접근권한
    showFormField('srm_share_folder_rel');	// 공유폴더권한
    showFormField('srm_db_auth_rel');		// DB 접근권한
    showFormField('srm_db_nsec_rel');		// DB 계정발급
	
    showFormField('srm_vpn_rel');			// vpn
    showFormField('srm_fw_rel');			// 방화벽
    showFormField('srm_routing_rel');		// 라우팅
	
    showFormField('srm_cit_id');			// 호스트명

    
    /* hideFormGroup('srm_trschm_group'); 		// 변경프로세스 이관(Group)  - 서비스요청처리
	hideFormField('srm_chm_trs_yn');        // 변경이관정보 - 변경이관여부 - 처리
    hideFormField('srm_chm_info_rel'); 		// 변경이관정보(내역) - 서비스요청처리, 처리확인
    hideFormField('srm_chm_info_rel_end');  // 변경이관정보(내역) - 종료
    hideFormField('srm_chm_rel'); 			// 변경이관정보(추가) - 서비스요청처리
	hideFormField('srm_chm_ing_info'); 		// 변경이관정보(내역) - 변경처리중
	hideFormField('srm_chm_ing_add_info');  // 추가 변경이관정보  - 변경처리중 
	*/
    showFormGroup('srm_act_group');   		// 처리정보(Group) - 서비스요청처리
	showFormField('srm_actstart_dttm'); 	// 처리시작일시
	showFormField('srm_actfinish_dttm'); 	// 처리완료일시
	showFormField('srm_end_mh'); 			// 투입공수(M/H)
	showFormField('srm_act_content'); 		// 처리내용 
	showFormField('srm_act_emp_id'); 		// 처리자
	showFormField('srm_clo_cd');			// 처리코드
	showFormField('srm_icm_trs_yn'); 		// 장애이관여부
	showFormField('srm_icm_info_rel');	 	// 장애이관정보 - 서비스요청처리, 장애처리중
	showFormField('srm_cm_cat_cd');	    	// 자산분류
	
    showFormField('srm_rou_rel');           // 라우터 신청 (REL)
    showFormField('srm_l4_rel');            // 로드밸런싱 신청 (REL)
    showFormField('srm_fw_band_rel');       // 방화벽 정책 (REL)
    showFormField('srm_firewall_band')      // 방화벽 정책
    showFormField('srm_firewall_band_con'); // 방화벽 정책 내용
    
    showFormField('srm_cit_id2');			// 구성항목(백업정책 요청)
    showFormField('srm_cit_id2_text');		// 구성항목 옆 빈칸
    showFormField('srm_cmbak2_rel');        // 백업정책 (REL)

}

/*

	함수 4 : 서비스요청 process_type 별 버튼 제어

*/
function controlSRMFormButton(cat_cd, srm_id, icm_trs_yn , process_type) {
    hideSRMFormButton();
	
	if(process_type == APPR || process_type == PROCCHM) {
		showButton('CTL02526');  // 승인요청 - 서비스요청 등록
		showButton('CTL02528');  // 승인요청 - 서비스요청 등록(임시저장)
		showButton('CTL02530');  // 승인요청 - 서비스요청 등록(재등록)
		showButton('CTL02534');  // 접수 	  - 서비스요청 접수
	}
	/* 개발/데이터 요청, 사용자지원, 혁신제안요청, 인프라 */
	else if(process_type == PROCAPPR || process_type == CHM){
		showButton('CTL02526');  // 승인요청 - 서비스요청 등록
		showButton('CTL02528');  // 승인요청 - 서비스요청 등록(임시저장)
		showButton('CTL02530');  // 승인요청 - 서비스요청 등록(재등록)
		showButton('CTL02721');  // 승인요청 - 서비스요청 접수
		if (cat_cd.substring(0, 9) == 'SRMCAT080'){
		    hideButton('CTL02721'); // 승인요청 - 서비스요청 접수
		    showButton('CTL02534'); // 접수     - 서비스요청 접수
		}
	}
	/* 단순문의/VOC, 오류 및 장애신고, 정보화사업 검토요청 */
	else{ // BASIC, ICM
		showButton('CTL02538');  // 등록 - 서비스요청 등록
		showButton('CTL02539');  // 등록 - 서비스요청 등록(임시저장)
		showButton('CTL02540');  // 등록 - 서비스요청 등록(재등록)
		showButton('CTL02534');  // 접수 - 서비스요청 접수 
	}
	
	controlSRMFormButtonType(cat_cd, srm_id, icm_trs_yn , process_type);
	
	
	/*등록 btn show_pcy*/
    hideButton('CTL02538');
}


/*

	함수 5 : 서비스요청(처리부터 종료) 요청분류 3가지 유형(ICM, CHM, 일반)별 버튼 제어

*/
function controlSRMFormButtonType(cat_cd, srm_id, icm_trs_yn, process_type){
	
	/* !!변경이관 요청분류!!  */
    if (process_type == CHM || process_type == PROCCHM) {

		var src_obj = getBizData('Get.CHM.Info','key='+ srm_id); 
				 
		// 변경이관 된 내역이 존재 할 때
		if (src_obj.row_cnt > 0 ){
			showButton('CTL02536'); // 처리완료 - 서비스요청 처리
		}
		// 변경이관 된 내역이 존재 안할 때
		else{
			showButton('CTL02533'); // 변경이관 - 서비스요청 처리
		}
		
    /* !!장애이관 요청분류!! */
    } else if (process_type == ICM) { 
	    var json = getBizData('SRM.ICM.CNT', 'rel_key=' + srm_id); 
	    var cnt = json.cnt;
	    
		// 장애이관 된 내역이 존재 안할 때
		if (cnt == '0') {    		
			// 장애이관 여부가 '아니오' 일 때		
			if(icm_trs_yn == '0'){
				showButton('CTL02536');  // 처리완료 - 서비스요청 처리
			}
			// 장애이관 여부가 '예' 일 때	
			else{
				showButton('CTL02532');  // 장애이관 - 서비스요청 처리
			}
		} 
		// 장애이관 된 내역이 존재 할 때
		else if(cnt != '0'){
			// 장애이관 여부가 '예' 일 때
			if (icm_trs_yn == '1') {
				showButton('CTL02536');  // 처리완료 - 서비스요청 처리
			}
		}
		
	/* !!일반 요청분류!! */
	} else { // BASIC, APPR, PROCAPPR
		if(cat_cd == 'SRMCAT07010' || cat_cd == 'SRMCAT07020'){
			showButton('CTL03124');		// 처리완료(종료) - 서비스요청처리
		}else{
			showButton('CTL02536');		// 처리완료 - 서비스요청 처리
		}
    }
}

/*

	함수 6 : 버튼 전체를 숨기기 위한 함수 

*/
function hideSRMFormButton() {
    hideButton('CTL02538');   // 서비스요청 등록 - 등록
    hideButton('CTL02526');   // 서비스요청 등록 - 승인요청
	
	hideButton('CTL02539');   // 서비스요청 등록(임시저장) - 등록
	hideButton('CTL02528');   // 서비스요청 등록(임시저장) - 승인요청
	
	hideButton('CTL02540');   // 서비스요청 등록(재등록) - 등록
	hideButton('CTL02530');   // 서비스요청 등록(재등록) - 승인요청
	
	hideButton('CTL02534');   // 서비스요청 접수 - 접수
	hideButton('CTL02721');   // 서비스요청 접수 - 승인요청
	
	hideButton('CTL02533');   // 서비스요청 처리 - 변경이관
    hideButton('CTL02532');   // 서비스요청 처리 - 장애이관
    hideButton('CTL02536');   // 서비스요청 처리 - 처리완료
	hideButton('CTL03124');   // 서비스요청 처리 - 처리완료(종료)
	hideButton('CTL03136');   // 서비스요청 처리 - 처리완료(ITSM)
    
	hideButton('CTL03090');   // 서비스요청 종료 - 저장
	hideButton('CTL03115');   // 서비스요청 종료 - 저장
}

/* 

	함수 7 : 장애이관여부 변경에 따른 필드 제어(요청분류가 ICM인 경우만 요청처리 폼에서 사용)

*/
function controlFieldIcm(val, cat_cd, srm_id, icm_trs_yn) { 
    var json = getBizData('SRM.ICM.CNT', 'rel_key=' + srm_id);
    var cnt = json.cnt;

   // process_type == ICM
   if(process_type == 4){ 
	 // 장애이관 된 내역이 존재 안할 때
     if(cnt == '0'){
		// 장애 이관 여부 '예'
		if (val == '1') {
			showFormField('srm_icm_trs_yn'); 		// 장애이관여부
			hideFormField('srm_icm_info_rel'); 		// 장애이관정보 
			hideFormField('srm_actstart_dttm'); 	// 처리시작일시
			hideFormField('srm_actfinish_dttm'); 	// 처리완료일시
			hideFormField('srm_end_mh'); 			// 투입공수(M/H)
			hideFormField('srm_act_content'); 		// 처리내용
			
			showButton('CTL02532'); // 장애이관
			hideButton('CTL02536'); // 확인

		//장애 이관 여부 '아니오'    
		} else {
			showFormField('srm_icm_trs_yn'); 		// 장애이관여부
			hideFormField('srm_icm_info_rel'); 		// 장애이관정보
			showFormField('srm_actstart_dttm'); 	// 처리시작일시
			showFormField('srm_actfinish_dttm'); 	// 처리완료일시
			showFormField('srm_end_mh'); 			// 투입공수(M/H)
			showFormField('srm_act_content'); 		// 처리내용
			
			hideButton('CTL02532'); // 장애이관
			showButton('CTL02536'); // 확인
		}
	}
  }
}

/* 

	함수 8 : 변경이관여부 변경에 따른 필드 제어(요청분류가 CHM인 경우만 요청처리 폼에서 사용)

*/

function controlFieldChm(val, cat_cd, srm_id, chm_trs_yn) {
  var src_obj = getBizData('Get.CHM.Info', 'key=' + srm_id);

   // process_type == CHM
   if(process_type == 5){ 
   
    // 변경이관 된 내역이 존재 안할 때
    if (src_obj.row_cnt == 0) {
      // 변경 이관 여부 '예'
      if (val == '1') {

	    hideFormGroup('srm_act_group'); 	 // 처리정보
        showFormField('srm_chm_rel'); // 변경이관정보(추가) - 서비스요청처리
		hideFormField('srm_chm_info_rel'); // 변경이관정보(내역) - 변경처리중
		hideFormField('srm_actstart_dttm'); 	// 처리시작일시
		hideFormField('srm_actfinish_dttm'); 	// 처리완료일시
		hideFormField('srm_end_mh'); 			// 투입공수(M/H)
		hideFormField('srm_act_content'); 		// 처리내용
		hideFormField('srm_clo_cd');		 // 처리코드
		hideFormField('srm_act_emp_id'); 	 // 처리자
			
		showButton('CTL02533'); // 변경이관
		hideButton('CTL02536'); // 확인

        //변경 이관 여부 '아니오'
      } else {

            showFormGroup('srm_act_group'); 	 // 처리정보
       	    showFormField('srm_chm_trs_yn'); 		// 변경이관여부
       		hideFormField('srm_chm_rel'); 		// 변경이관정보
			hideFormField('srm_chm_info_rel'); 		// 변경이관정보
			showFormField('srm_actstart_dttm'); 	// 처리시작일시
			showFormField('srm_actfinish_dttm'); 	// 처리완료일시
			showFormField('srm_end_mh'); 			// 투입공수(M/H)
			showFormField('srm_act_content'); 		// 처리내용
			showFormField('srm_act_emp_id'); 	 // 처리자
            showFormField('srm_clo_cd');		 // 처리코드
			
			hideButton('CTL02533'); // 변경이관
			showButton('CTL02536'); // 확인
      }
    }
  }
}


/*
	함수 9 : 서비스요청 각 요청분류별 필드 제어 & process_type 지정(NXT용)
*/

function controlSRMFormFieldNXT(cat_cd, srm_id, icm_trs_yn, chm_trs_yn, ass_emp_id, cur_emp_id) {
	hideSRMFormField();		// 필드 숨기기
	
    /*업무시스템, 구성항목 show_pcy*/
    showFormField('srm_cit_id');    // 구성항목
    
    /*SRMNXTCAT04050 (방화벽 정책) show_pcy*/
    if(cat_cd == 'SRMNXTCAT04050'){
        showFormField('srm_firewall_band');
        showFormField('srm_fw_band_rel');
    }
    
    /*SRMNXTCAT06010 (라우터신청)*/
    else if(cat_cd == 'SRMNXTCAT06010') {
		showFormField('srm_rou_rel'); 
    }
    
    /*SRMNXTCAT06020 (로드밸런싱 신청)*/
    else if(cat_cd == 'SRMNXTCAT06020'){
        showFormField('srm_l4_rel');
    }
    
    /* SRMNXTCAT06210 (백업정책 요청) */
    else if(cat_cd == 'SRMNXTCAT06210'){
        hideFormField('srm_cit_id');
        showFormField('srm_cit_id2');
    }
	
	/* 자료추출, 데이터변경, 계정 삭제(퇴사), 계정 정지(휴직),
	정보자산 반납, OA 지급/교체/고장, SW 설치 신청, 기타 OA 기기 신청,
	시스템 잠김해제/비번 초기화 신청, 대용량 망간자료 전송 신청, 대용량 외부파일 반입 신청 (USB), 보안성 심의·검토 요청,
	그룹웨어 추가 권한 신청, ERP 프로그램 권한 신청, 장애 관리, 전산센터 출입신청,
	ERP 비밀번호 초기화 신청, 그룹웨어 비밀번호 초기화 신청 */
	if (cat_cd == 'SRMNXTCAT01010' || cat_cd == 'SRMNXTCAT01020' || cat_cd == 'SRMNXTCAT02020' || cat_cd == 'SRMNXTCAT02030'
		|| cat_cd == 'SRMNXTCAT03010' || cat_cd == 'SRMNXTCAT03020' || cat_cd == 'SRMNXTCAT03030' || cat_cd == 'SRMNXTCAT03040'
		|| cat_cd == 'SRMNXTCAT04061' || cat_cd == 'SRMNXTCAT04062' || cat_cd == 'SRMNXTCAT04080'
		|| cat_cd == 'SRMNXTCAT05050' || cat_cd == 'SRMNXTCAT05060' || cat_cd == 'SRMNXTCAT07040' 
		|| cat_cd == 'SRMNXTCAT02040' || cat_cd == 'SRMNXTCAT02050' || cat_cd == 'SRMNXTCAT06202'){
			hideFormGroup('srm_acp_test_group'); // 테스트 접수
			hideFormGroup('srm_test_group'); // 테스트
			hideFormGroup('srm_test_check_group'); // 테스트 검토
			hideFormGroup('srm_test_re_group'); // 테스트 완료
	}else if(cat_cd == 'SRMNXTCAT04011' || cat_cd == 'SRMNXTCAT04012' || cat_cd == 'SRMNXTCAT05020' || cat_cd == 'SRMNXTCAT04031' || cat_cd == 'SRMNXTCAT04032' || cat_cd == 'SRMNXTCAT04033' || cat_cd == 'SRMNXTCAT07010'){
	// 보안요청 > 계정 및 ip 생성/변경 요청 > ad 계정 신청, 보안요청 > 계정 및 ip 생성/변경 요청 > 사용자 ip 할당 신청, 권한관리 > 개인정보처리 시스템 접근권한 신청, IT 운영관리 > 장애관리
			hideFormGroup('srm_test_group');
			hideFormGroup('srm_test_check_group');
			hideFormGroup('srm_test_re_group');
	}else if(cat_cd == 'SRMNXTCAT06230' || cat_cd == 'SRMNXTCAT06240' || cat_cd == 'SRMNXTCAT06250' || cat_cd == 'SRMNXTCAT06260'){
	// (시스템) 패치 및 업데이트, (DB) 패치 및 업데이트, (네트워크) 패치 및 업데이트, (보안) 패치 및 업데이트
			hideFormGroup('srm_acp_group');
	}else if(cat_cd == 'SRMNXTCAT02010'){ // 계정 관리 > 신규 생성(입사)
		hideFormGroup('srm_acp_group'); // 요청 접수
		hideFormGroup('srm_acp_test_group'); // 테스트 접수
		hideFormGroup('srm_test_group'); // 테스트
		hideFormGroup('srm_test_check_group'); // 테스트 검토
		hideFormGroup('srm_test_re_group'); // 테스트 검토 완료
	}else if(cat_cd == 'SRMNXTCAT07030'){
	hideFormGroup('srm_test_group');
	hideFormGroup('srm_test_re_group');
	}
	
	if(cat_cd != 'SRMNXTCAT06210'){ // 백업정책 유형이 아닐경우 cmbak2 rel 숨김처리
		hideFormField('srm_rel_cmbak2_info'); // 추가 백업정책
		hideFormField('srm_rel_cmbak2_list'); // 현재 백업정책
	}
	
	
	
  // 데이터베이스 변경 요청 유형에 따른 폼 제어
  if(cat_cd == 'SRMNXTCAT06201'){ 
    showFormField('srm_db_chm2'); // 유형
    hideFormField('srm_db_chm1'); // 유형
  }else if(cat_cd == 'SRMNXTCAT06202') {
    showFormField('srm_db_chm1');
    hideFormField('srm_db_chm2');
  }else{
    hideFormField('srm_db_chm1');
    hideFormField('srm_db_chm2');
  }
  
  // 'OA 요청' 유형에 따른 필드 제어
  if(cat_cd == 'SRMNXTCAT03020'){ // OA 요청 > OA 지급/교체/고장
	  hideFormField('srm_oasw_typ'); // OA SW 종류
	  showFormField('srm_oa_typ'); // OA 요청 종류
	  showFormField('srm_typ_cat'); // 요청 상세
  }else if(cat_cd == 'SRMNXTCAT03030'){ // OA 요청 > SW 설치 신청
	  showFormField('srm_oasw_typ');
	  hideFormField('srm_oa_typ');
	  hideFormField('srm_typ_cat');
  }else{
	  hideFormField('srm_oasw_typ');
	  hideFormField('srm_oa_typ');
	  hideFormField('srm_typ_cat');
  }
	
	// '보안요청 > 보안성 심의(검토) 요청' 유형일 경우
  if(cat_cd == 'SRMNXTCAT04080'){
    showFormField('srm_file_attch1') // 필수첨부
    hideFormField('srm_file_attch2') // 선택첨부
    hideFormField('srm_file_attch3') // 선택첨부
  }else if(cat_cd == 'SRMNXTCAT04170'){ // '보안요청 > 서버 접근제어 권한 신청 요청' 유형일 경우
    showFormField('srm_file_attch3')
    hideFormField('srm_file_attch2')
    hideFormField('srm_file_attch1')
  }else if(cat_cd == 'SRMNXTCAT04160'){
    showFormField('srm_file_attch2') // '보안요청 > DB 접근제어 권한 신청 요청' 유형일 경우
    hideFormField('srm_file_attch3')
    hideFormField('srm_file_attch1')
  }else{ // 그 외의 유형은 필드 숨기기
    hideFormField('srm_file_attch2')
    hideFormField('srm_file_attch3')
    hideFormField('srm_file_attch1')
  }
	
	
// 권한관리 > 개인정보처리 시스템 접근권한 신청 內 접근 권한 유형
if(cat_cd != 'SRMNXTCAT05020'){
	hideFormField('srm_am_cat')
}

// 'it운영관리 > 전산센터 출입신청' 유형이 아닐경우 '출입등록 정보'rel 숨김처리
if(cat_cd != 'SRMNXTCAT07040'){
	hideFormField('srm_sei_rel')
}

// '보안요청 > 계정 및 IP 생성/변경 요청' 유형의 'AD 계정 신청 & 사용자 IP 할당 신청'일 경우 'AD/IP 할당 여부' 폼 show
if(cat_cd == 'SRMNXTCAT04011' || cat_cd == 'SRMNXTCAT04012' || cat_cd == 'SRMNXTCAT04010'){ 
	showFormField('srm_adip_yn');
}else{
	hideFormField('srm_adip_yn');
}

// '데이터베이스 변경 작업요청 > 변경 > db 튜닝 요청' 선택 시 'sql tuning요청서' 필드 show → 'srm_db_chm2' 필드 action 참고
// default값 hidden
  hideFormField('db_file_att');
  
   hideFormGroup('srm_trschm_group');
 // 장애관리 유형일 경우 변경이관그룹 보이게 하기
 if(cat_cd == 'SRMNXTCAT07010'){ 
	    showFormGroup('srm_trschm_group');
	}
	
}

/*
 cod_id : srmcat
 fld_id : field id
 srmcat에 다른 요청내용 컨텐츠 나오게하기 & html일경우 도움말로 컨텐츠 보이게하기
 */
function changeContent(cat_cd, fld_id){
	var sql_id = 'NXTSQL00062';
	var parmas= 'key='+ cat_cd;
	var content = getBizData(sql_id, parmas)

	// 존재할 경우 실행
	if(content){ 
	// 
	if(content.cod_content){
			var text = content.cod_content;
			var type = content.cod_detail;
			
			if(type == 'NXTCODTYPE00200'){
				 $('#Field_'+fld_id).html(text);
			}else if(type == 'NXTCODTYPE00100'){
				setDataField_F004(text);
			}
		}
	}
}

// '작업요청 > 데이터베이스 변경작업요청' 요청분류에 따라 유형에 맞는 요청 내용 컨텐츠 보이게하기
function dbChm(srm_db_chm1){
	changeContent(srm_db_chm1);
	var dbChm1 = srm_db_chm1;
	
}


/* 방화벽 신청(SRMNXTCAT04050) 中 예외사항 선택 시, 필드 제어 && 방화벽 정책에 따른 도움말 or 요청내용 다르게 보이게하기 */
function band(srm_firewall_band){
    
  var fld_id= 'NXTF449'; // field 값
  changeContent(srm_firewall_band, fld_id);

  var band01 = srm_firewall_band; // 방화벽 정책
  
  if(band01 == 'SRMBAND030'){
    showFormField('srm_firewall_band_con');
	hideFormField('srm_firewall_info');
  }else{
    hideFormField('srm_firewall_band_con');
	showFormField('srm_firewall_info');
  }
}