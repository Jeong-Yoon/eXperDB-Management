<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<%
	/**
	* @Class Name : dumpRegForm.jsp
	* @Description : rman 백업 등록 화면
	* @Modification Information
	*
	*   수정일         수정자                   수정내용
	*  ------------    -----------    ---------------------------
	*  2017.06.07     최초 생성
	*
	* author YoonJH
	* since 2017.06.07
	*
	*/
%>
<script type="text/javascript">
	var haCnt = 0;

	$(window.document).ready(function() {
		//validate
	    $("#workDumpRegForm").validate({
 	        rules: {
	        	ins_dump_wrk_nm: {
					required: true
				},
				ins_dump_wrk_exp: {
					required: true
				},
				ins_dump_db_id: {
					required: true
				},
				ins_dump_save_pth: {
					required: true
				}
	        },
	        messages: {
	        	ins_dump_wrk_nm: {
	        		required: '<spring:message code="message.msg107" />'
				},
				ins_dump_wrk_exp: {
	        		required: '<spring:message code="message.msg108" />'
				},
				ins_dump_db_id: {
	        		required: '<spring:message code="backup_management.bck_database_choice" />'
				},
				ins_dump_save_pth: {
	        		required: '<spring:message code="message.msg79" />'
				}
	        },
			submitHandler: function(form) { //모든 항목이 통과되면 호출됨 ★showError 와 함께 쓰면 실행하지않는다★
				fn_dump_insert_work();
			},
	        errorPlacement: function(label, element) {
	          label.addClass('mt-2 text-danger');
	          label.insertAfter(element);
	        },
	        highlight: function(element, errorClass) {
	          $(element).parent().addClass('has-danger')
	          $(element).addClass('form-control-danger')
	        }
		});
	});
	
	/* ********************************************************
	 * 팝업시작 dump 백업
	 ******************************************************** */
	function fn_insertDumpWorkPopStart() {
		//HA구성확인
		$.ajax({
			async : false,
			url : "/selectHaCnt.do",
			data : {
				db_svr_id : $("#db_svr_id","#findList").val()
			},
			type : "post",
			beforeSend: function(xhr) {
				xhr.setRequestHeader("AJAX", true);
			},
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
				}
			},
			success : function(result) {
				haCnt = result[0].hacnt;
			}
		});
		
		//PATH  정보 호출
		$.ajax({
			async : false,
			url : "/selectPathInfo.do",
			data : {
				db_svr_id : $("#db_svr_id","#findList").val()
			},
			type : "post",
			beforeSend: function(xhr) {
				xhr.setRequestHeader("AJAX", true);
			},
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
				}
			},
			success : function(result) {
				if (result != null && result != ",") {
					if (result[1].PGDBAK != null) {
						$('#ins_dump_save_pth', '#workDumpRegForm').val(nvlPrmSet(result[1].PGDBAK, ""));
					}
				}
			}
		});
	}
	
	/* ********************************************************
	 * work명 중복체크
	 ******************************************************** */
	function fn_ins_dump_worknm_check() {
		if ($('#ins_dump_wrk_nm', '#workDumpRegForm').val() == "") {
			showSwalIcon('<spring:message code="message.msg107" />', '<spring:message code="common.close" />', '', 'warning');
			return;
		}
		
		//msg 초기화
		$("#ins_dump_worknm_check_alert", "#workDumpRegForm").html('');
		$("#ins_dump_worknm_check_alert", "#workDumpRegForm").hide();
		
		$.ajax({
			url : '/wrk_nmCheck.do',
			type : 'post',
			data : {
				wrk_nm : $('#ins_dump_wrk_nm', '#workDumpRegForm').val()
			},
			beforeSend: function(xhr) {
				xhr.setRequestHeader("AJAX", true);
			},
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
				}
			},
			success : function(result) {
				if (result == "true") {
					showSwalIcon('<spring:message code="backup_management.reg_possible_work_nm" />', '<spring:message code="common.close" />', '', 'success');
					$('#ins_dump_wrk_nmChk', '#workDumpRegForm').val("success");
				} else {
					showSwalIcon('<spring:message code="backup_management.effective_work_nm" />', '<spring:message code="common.close" />', '', 'error');
					$('#ins_dump_wrk_nmChk', '#workDumpRegForm').val("fail");
				}
			}
		});
	}


	/* ********************************************************
	 * 저장경로의 존재유무 체크
	 ******************************************************** */
	function fn_ins_dump_checkFolder(keyType){
		var save_path = nvlPrmSet($("#ins_dump_save_pth", "#workDumpRegForm").val(), "");

		if(save_path == "" && keyType == 2){
			showSwalIcon('<spring:message code="message.msg79" />', '<spring:message code="common.close" />', '', 'warning');
			return;
		}
		
		//초기화
		$("#ins_dump_save_pth_alert", "#workDumpRegForm").html('');
		$("#ins_dump_save_pth_alert", "#workDumpRegForm").hide();

		$.ajax({
			async : false,
			/* url : "/existDirCheck.do", */
			url : "/existDirCheckMaster.do",   //2019-09-26 변승우 대리, 수정(경로체크 시 MASTER만)
			data : {
				db_svr_id : $("#db_svr_id","#findList").val(),
				path : save_path
			},
			type : "post",
			beforeSend: function(xhr) {
				xhr.setRequestHeader("AJAX", true);
			},
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
				}
			},
			success : function(data) {
				if (data != null) {
					if(data.result.ERR_CODE == ""){
						if(data.result.RESULT_DATA.IS_DIRECTORY == 0){
							var volume = data.result.RESULT_DATA.CAPACITY;
							
							showSwalIcon('<spring:message code="message.msg100" />', '<spring:message code="common.close" />', '', 'success');
							
							if(keyType == 2){
								$("#ins_dump_check_path2", "#workDumpRegForm").val("Y");
								
								$("#dump_backupVolume", "#workDumpRegForm").html("<spring:message code='common.volume' /> : "+volume);
								$("#dump_backupVolume_div", "#workDumpRegForm").show();
							}
						}else{
							if(haCnt > 1){
								showSwalIcon('<spring:message code="backup_management.ha_configuration_cluster"/>'+data.SERVERIP+'<spring:message code="backup_management.node_path_no"/>', '<spring:message code="common.close" />', '', 'error');
							}else{
								showSwalIcon('<spring:message code="backup_management.invalid_path"/>', '<spring:message code="common.close" />', '', 'error');
							}	

							$("#ins_dump_check_path2", "#workDumpRegForm").val("N");
							$("#dump_backupVolume", "#workDumpRegForm").html('<spring:message code="common.volume" /> : 0');
							$("#dump_backupVolume_div", "#workDumpRegForm").show();
						}
					}else{
						showSwalIcon('<spring:message code="message.msg76" />', '<spring:message code="common.close" />', '', 'error');

						$("#ins_dump_check_path2", "#workDumpRegForm").val("N");
						$("#dump_backupVolume", "#workDumpRegForm").html('<spring:message code="common.volume" /> : 0');
						$("#dump_backupVolume_div", "#workDumpRegForm").show();
					}
				} else {
					showSwalIcon('<spring:message code="message.msg76" />', '<spring:message code="common.close" />', '', 'error');

					$("#ins_dump_check_path2", "#workDumpRegForm").val("N");
					$("#dump_backupVolume", "#workDumpRegForm").html('<spring:message code="common.volume" /> : 0');
					$("#dump_backupVolume_div", "#workDumpRegForm").show();
				}
			}
		});
	}

	/* ********************************************************
	 * 쿼리에서 Use Column Inserts, Use Insert Commands선택시 "OIDS포함" disabled
	 ******************************************************** */
	function fn_ins_dump_checkOid(){
		var check = false;
		$("input[name=ins_dump_opt]").each(function(){
			if( ($(this).attr("opt_cd") == "TC000901" || $(this).attr("opt_cd") == "TC000902") && $(this).is(":checked")){
				check = true;
			}
		});
			
		$("input[name=ins_dump_opt]").each(function(){
			if( $(this).attr("opt_cd") == "TC001001" ){
				if(check){
					$(this).attr("disabled",true);
				}else{
					$(this).removeAttr("disabled");
				}
			}
		});
	}

	/* ********************************************************
	 * Object형태 중 Only data, Only Schema 중 1개만 체크가능
	 ******************************************************** */
	function fn_ins_dump_checkObject(code){
		var check1 = false;
		var check2 = false;

		$("input[name=ins_dump_opt]").each(function(){
			if(code == "TC000701" && $(this).attr("opt_cd") == "TC000701" && $(this).is(":checked") ){
				check1 = true;
			}else if(code == "TC000702" && $(this).attr("opt_cd") == "TC000702" && $(this).is(":checked") ){
				check2 = true;
			}
		});

		$("input[name=ins_dump_opt]").each(function(){
			if(check1 && code == "TC000701" && $(this).attr("opt_cd") == "TC000702"){
				$(this).prop("checked", false); 
			}else if(check2 && code == "TC000702" && $(this).attr("opt_cd") == "TC000701"){
				$(this).prop("checked", false); 
			}
		});
	}

	/* ********************************************************
	 * Sections에 체크시 Object형태중 Only data, Only Schema를 비활성화 시킨다.
	 ******************************************************** */
	function fn_ins_dump_checkSection(){
		var check = false;
		$("input[name=ins_dump_opt]").each(function(){
			if( ($(this).attr("opt_cd") == "TC000601" || $(this).attr("opt_cd") == "TC000602" || $(this).attr("opt_cd") == "TC000603") && $(this).is(":checked")){
				check = true;
			}
		});
		$("input[name=ins_dump_opt]").each(function(){
			if( $(this).attr("opt_cd") == "TC000701" || $(this).attr("opt_cd") == "TC000702" ){
				if(check){
					$(this).attr("disabled",true);
				}else{
					$(this).removeAttr("disabled");
				}
			}
		});
	}


	/* ********************************************************
	 * File Format에 따른 Checkbox disabled Check
	 ******************************************************** */
	function fn_ins_changeFileFmtCd(){
		if($("#ins_dump_file_fmt_cd", "#workDumpRegForm").val() == "TC000401"){
			$("#ins_dump_cprt", "#workDumpRegForm").removeAttr("disabled");
		}else{
			$("#ins_dump_cprt", "#workDumpRegForm").attr("disabled",true);
			$("#ins_dump_cprt", "#workDumpRegForm").val("0");
		}

		if($("#ins_dump_file_fmt_cd", "#workDumpRegForm").val() == "TC000402"){
			$("input[name=ins_dump_opt]").each(function(){
				if( $(this).attr("opt_cd") == "TC000801" || $(this).attr("opt_cd") == "TC000903" || $(this).attr("opt_cd") == "TC000904" ){
					$(this).removeAttr("disabled");
				}
			});
		}else{
			$("input[name=ins_dump_opt]").each(function(){
				if( $(this).attr("opt_cd") == "TC000801" || $(this).attr("opt_cd") == "TC000903" || $(this).attr("opt_cd") == "TC000904" ){
					$(this).attr("disabled",true);
				}
			});
		}
	}

	/* ********************************************************
	 * work 명 변경시
	 ******************************************************** */
	function fn_ins_dump_wrk_nmChk() {
		$('#ins_dump_wrk_nmChk', '#workDumpRegForm').val("fail");
		
		$("#ins_dump_worknm_check_alert", "#workDumpRegForm").html('');
		$("#ins_dump_worknm_check_alert", "#workDumpRegForm").hide();
	}

	/* ********************************************************
	 * 백업경로변경시
	 ******************************************************** */
	function fn_ins_check_pathChk(val) {
		$('#ins_dump_check_path2', '#workDumpRegForm').val(val);
		
		$("#ins_dump_save_pth_alert", "#workDumpRegForm").html('');
		$("#ins_dump_save_pth_alert", "#workDumpRegForm").hide();
	}

	/* ********************************************************
	 * Get Selected Database`s Object List
	 ******************************************************** */
	function fn_ins_get_object_list(){
 		var db_nm = nvlPrmSet($("#ins_dump_db_id option:selected", "#workDumpRegForm").text(), "");
		var db_id = nvlPrmSet($("#ins_dump_db_id option:selected", "#workDumpRegForm").val(), "");
		
		if (db_nm == "" || db_id == "") {
			$("#ins_treeview").html("");
			return;
		}

		$.ajax({
			async : false,
			url : "/getObjectList.do",
		  	data : {
			  	db_svr_id : $("#db_svr_id","#findList").val(),
				db_nm : db_nm
			},
			type : "post",
			beforeSend: function(xhr) {
				xhr.setRequestHeader("AJAX", true);
			},
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
				}
			},
			success : function(data) {
				if (data != null) {
					fn_ins_make_object_list(data);
				} else {
					$("#ins_treeview").html("");
				}
			}
		});
	}


	/* ********************************************************
	 * 전체선택
	 ******************************************************** */
	function fn_ins_checkAll(schema_id, schema_name) {
		var schemaChkBox = document.getElementById("schema"+schema_id);

		if(schemaChkBox.checked) { 
			$("input[name=ins_tree]").each(function(){
	    		if($(this).attr("schema") == schema_name) {
	    			this.checked = true;
	    		}
	    	});
	    } else { 
	    	$("input[name=ins_tree]").each(function(){
	    		if($(this).attr("schema") == schema_name) {
	    			this.checked = false;
	    		}
	    	});
	    }
	}

	/* ********************************************************
	 * dump Backup Insert
	 ******************************************************** */
	function fn_dump_insert_work(){
		if (!ins_dump_valCheck()) return false;

		$.ajax({
			async : false,
			url : "/popup/workDumpWrite.do",
			data : {
				db_svr_id : $("#db_svr_id","#findList").val(),
				wrk_nm : nvlPrmSet($('#ins_dump_wrk_nm', '#workDumpRegForm').val(), "").trim(),
				wrk_exp : nvlPrmSet($('#ins_dump_wrk_exp', '#workDumpRegForm').val(), ""),
				db_id : $("#ins_dump_db_id", '#workDumpRegForm').val(),
		  		bck_bsn_dscd : "TC000202",
		  		save_pth : $("#ins_dump_save_pth", "#workDumpRegForm").val(),
		  		log_file_pth : "",
		  		file_fmt_cd : $("#ins_dump_file_fmt_cd", "#workDumpRegForm").val(),
		  		cprt : $("#ins_dump_cprt", "#workDumpRegForm").val(),
		  		encd_mth_nm : $("#ins_dump_encd_mth_nm", "#workDumpRegForm").val(),
		  		usr_role_nm : $("#ins_dump_usr_role_nm", "#workDumpRegForm").val(),
		  		file_stg_dcnt : $("#ins_dump_file_stg_dcnt", "#workDumpRegForm").val(),
				bck_mtn_ecnt : $("#ins_dump_bck_mtn_ecnt", '#workDumpRegForm').val(),
		  		bck_filenm : ""
			},
			type : "post",
			beforeSend: function(xhr) {
				xhr.setRequestHeader("AJAX", true);
			},
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
				}
			},
			success : function(data) {
				if(data == "F"){ //중복 work명 일경우
					showSwalIcon('<spring:message code="message.msg191" />', '<spring:message code="common.close" />', '', 'error');
					$('#pop_layer_reg_dump').modal('show');
					return;
				} else if(data == "D"){
					showSwalIcon('<spring:message code="migration.msg06" />', '<spring:message code="common.close" />', '', 'error');
					$('#pop_layer_reg_dump').modal('show');
					return;
				}else{
					fn_dump_insert_opt(data);
				}
			}
		});
	}

	/* ********************************************************
	 * Dump Backup Option Insert
	 ******************************************************** */
	function fn_dump_insert_opt(data){
		var sn = 1;
		if(data != "0"){
			if (data == "S") {
				showSwalIcon('<spring:message code="message.msg106" />', '<spring:message code="common.close" />', '', 'success');
				$('#pop_layer_reg_dump').modal('hide');
				fn_get_dump_list();
			} else {
				$("input[name=ins_dump_opt]").each(function(){
					if( $(this).not(":disabled") && $(this).is(":checked")){
						fn_dump_insert_opt_val(data,sn,$(this).attr("grp_cd"),$(this).attr("opt_cd"),"Y");
					}
					sn++;
				});
				fn_dump_insert_object(data);
			}
		}else {
			showSwalIcon('<spring:message code="message.msg106" />', '<spring:message code="common.close" />', '', 'success');
			$('#pop_layer_reg_dmup').modal('hide');
			fn_get_dump_list();
		}
	}

	/* ********************************************************
	 * Dump Backup Each Option Insert
	 ******************************************************** */
	function fn_dump_insert_opt_val(bck_wrk_id, opt_sn, grp_cd, opt_cd, bck_opt_val){
		$.ajax({
			async : false,
			url : "/popup/workOptWrite.do",
		  	data : {
		  		bck_wrk_id : bck_wrk_id,
		  		opt_sn : opt_sn,
		  		grp_cd : grp_cd,
		  		opt_cd : opt_cd,
		  		bck_opt_val : bck_opt_val
		  	},
			type : "post",
			beforeSend: function(xhr) {
		        xhr.setRequestHeader("AJAX", true);
		    },
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
				}
			},
			success : function() {}
		});
	}

	/* ********************************************************
	 * Dump Backup Object Insert
	 ******************************************************** */
	function fn_dump_insert_object(data){
		$("input[name=ins_tree]").each(function(){
			if( $(this).is(":checked")){
				fn_dump_insert_object_val(data,$(this).attr("otype"),$(this).attr("schema"),$(this).val());
			}
		});

		fn_get_dump_list();
		showSwalIcon('<spring:message code="message.msg106" />', '<spring:message code="common.close" />', '', 'success');
		$('#pop_layer_reg_dump').modal('hide');
	}

	/* ********************************************************
	 * Dump Backup Each Object Insert
	 ******************************************************** */
	 function fn_dump_insert_object_val(bck_wrk_id,otype,scm_nm,obj_nm){
		var db_id = $("#ins_dump_db_id", "#workDumpRegForm").val();

		if(otype != "table") obj_nm = "";
		$.ajax({
			async : false,
			url : "/popup/workObjWrite.do",
		  	data : {
		  		bck_wrk_id : bck_wrk_id,
		  		db_id : db_id,
		  		scm_nm : scm_nm,
		  		obj_nm : obj_nm
		  	},
			type : "post",
			beforeSend: function(xhr) {
		        xhr.setRequestHeader("AJAX", true);
		    },
			error : function(xhr, status, error) {
				if(xhr.status == 401) {
					showSwalIconRst('<spring:message code="message.msg02" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else if(xhr.status == 403) {
					showSwalIconRst('<spring:message code="message.msg03" />', '<spring:message code="common.close" />', '', 'error', 'top');
				} else {
					showSwalIcon("ERROR CODE : "+ xhr.status+ "\n\n"+ "ERROR Message : "+ error+ "\n\n"+ "Error Detail : "+ xhr.responseText.replace(/(<([^>]+)>)/gi, ""), '<spring:message code="common.close" />', '', 'error');
				}
			},
			success : function() {}
		});
	}

	/* ********************************************************
	 * Validation Check
	 ******************************************************** */
	function ins_dump_valCheck(){
		var iChkCnt = 0;

		if(nvlPrmSet($("#ins_dump_wrk_nmChk", "#workDumpRegForm").val(), "") == "" || nvlPrmSet($("#ins_dump_wrk_nmChk", "#workDumpRegForm").val(), "") == "fail") {
			$("#ins_dump_worknm_check_alert", "#workDumpRegForm").html('<spring:message code="backup_management.work_overlap_check"/>');
			$("#ins_dump_worknm_check_alert", "#workDumpRegForm").show();
			
			iChkCnt = iChkCnt + 1;
		}
		
		if(nvlPrmSet($("#ins_dump_check_path2", "#workDumpRegForm").val(), "") != "Y") {
			$("#ins_dump_save_pth_alert", "#workDumpRegForm").html('<spring:message code="backup_management.bckPath_effective_check"/>');
			$("#ins_dump_save_pth_alert", "#workDumpRegForm").show();
			
			iChkCnt = iChkCnt + 1;
		}
		
		if (nvlPrmSet($("#ins_dump_file_fmt_cd", "#workDumpRegForm").val(),"") == "0000" || nvlPrmSet($("#ins_dump_file_fmt_cd", "#workDumpRegForm").val(),"") == "") {
			$("#ins_dump_file_fmt_cd_alert", "#workDumpRegForm").html('<spring:message code="message.msg217"/>');
			$("#ins_dump_file_fmt_cd_alert", "#workDumpRegForm").show();
			
			iChkCnt = iChkCnt + 1;
		}
		
		if (nvlPrmSet($("#ins_dump_encd_mth_nm", "#workDumpRegForm").val(),"") == "0000" || nvlPrmSet($("#ins_dump_encd_mth_nm", "#workDumpRegForm").val(),"") == "") {
			$("#ins_dump_encd_mth_nm_alert", "#workDumpRegForm").html('<spring:message code="message.msg218"/>');
			$("#ins_dump_encd_mth_nm_alert", "#workDumpRegForm").show();
			
			iChkCnt = iChkCnt + 1;
		}
		
		if (nvlPrmSet($("#ins_dump_usr_role_nm", "#workDumpRegForm").val(),"") == "0000" || nvlPrmSet($("#ins_dump_usr_role_nm", "#workDumpRegForm").val(),"") == "") {
			$("#ins_dump_usr_role_nm_alert", "#workDumpRegForm").html('<spring:message code="message.msg219"/>');
			$("#ins_dump_usr_role_nm_alert", "#workDumpRegForm").show();
			
			iChkCnt = iChkCnt + 1;
		}
		
		if (iChkCnt > 0) {
			return false;
		}

		return true;
	}
	

	/* ********************************************************
	 * Make Object Tree
	 ******************************************************** */
	function fn_ins_make_object_list(data){
		var html = "<ul id='ins_treeview' class='hummingbird-base'>";
		var schema = "";
		var schemaCnt = 0;

		$(data.data).each(function (index, item) {
			var inSchema = item.schema;

			if(schemaCnt > 0 && schema != inSchema){
				html += "</ul></li>\n";
			}

 			if(schema != inSchema){
 				html += "<li>\n";
 				html += "<i class='fa fa-minus'></i>\n";
 				html += "<label for='ins_schema"+schemaCnt+"'> <input id='ins_schema"+schemaCnt+"' name='ins_tree' value='"+item.schema+"' otype='schema' schema='"+item.schema+"' data-id='custom-0' type='checkbox'> "+item.schema+"</label>\n";
 				html += '<ul style="display: block;">\n';
			}
			
 			html += "<li style='padding-left:20px;'>";
 			html += "<label for='ins_table"+index+"'> <input id='ins_table"+index+"' name='ins_tree' value='"+item.name+"' otype='table' schema='"+item.schema+"' data-id='custom-1' type='checkbox'>  "+item.name+"</label></li>\n";

			if(schema != inSchema){ 
				schema = inSchema;
				schemaCnt++;
			} 
		});
		if(schemaCnt > 0) html += "</ul></li>";
		html += "</ul>";

		$("#treeview_container", "#workDumpRegForm").html("");
		$("#treeview_container", "#workDumpRegForm").html(html);

		$("#ins_treeview", "#workDumpRegForm").hummingbird();
	}

	/* ********************************************************
	 * 옵션 숫자 입력 blur
	 ******************************************************** */
	function fn_dumpAlertChk(obj) {
		$("#" + obj.id + "_alert", "#workDumpRegForm").html("");
		$("#" + obj.id + "_alert", "#workDumpRegForm").hide();
	}

	
</script>

<div class="modal fade" id="pop_layer_reg_dump" tabindex="-1" role="dialog" aria-labelledby="ModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
	<div class="modal-dialog  modal-xl-top" role="document" style="margin: 40px 110px;">
		<div class="modal-content" style="width:1500px; ">		 	 
			<div class="modal-body" style="margin-bottom:-30px;">
				<h4 class="modal-title mdi mdi-alert-circle text-info" id="ModalLabel" style="padding-left:5px;margin-bottom:10px;">
					Dump <spring:message code="dashboard.Register_backup"/>
				</h4>

				<div class="card" style="border:0px;max-height:698px;">
					<form class="cmxform" id="workDumpRegForm">
						<input type="hidden" name="ins_dump_check_path2" id="ins_dump_check_path2" value="N"/>
						<input type="hidden" name="ins_dump_wrk_nmChk" id="ins_dump_wrk_nmChk" value="fail" />

						<fieldset>
							<div class="row">
								<div class="col-md-9 system-tlb-scroll" style="border:0px;height: 620px; overflow-x: hidden;  overflow-y: auto; ">
									<div class="card-body" style="border: 1px solid #adb5bd;">
										<div class="form-group row div-form-margin-z" style="margin-top:-10px;">
											<label for="ins_dump_wrk_nm" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="common.work_name" />
											</label>
		
											<div class="col-sm-8">
												<input type="text" class="form-control form-control-sm" maxlength="20" id="ins_dump_wrk_nm" name="ins_dump_wrk_nm" onkeyup="fn_checkWord(this,20)" placeholder='20<spring:message code='message.msg188'/>' onchange="fn_ins_dump_wrk_nmChk();" onblur="this.value=this.value.trim()" tabindex=1 required />
											</div>
		
											<div class="col-sm-2">
												<button type="button" class="btn btn-inverse-danger btn-fw" style="width: 115px;" onclick="fn_ins_dump_worknm_check()"><spring:message code="common.overlap_check" /></button>
											</div>
										</div>
		
										<div class="form-group row div-form-margin-z">
											<div class="col-sm-2">
											</div>
		
											<div class="col-sm-10">
												<div class="alert alert-danger" style="margin-top:5px;display:none;" id="ins_dump_worknm_check_alert"></div>
											</div>
										</div>
		
										<div class="form-group row div-form-margin-z" style="margin-bottom:-10px;">
											<label for="ins_dump_wrk_exp" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="common.work_description" />
											</label>
		
											<div class="col-sm-10">
												<textarea class="form-control" id="ins_dump_wrk_exp" name="ins_dump_wrk_exp" rows="2" maxlength="200" onkeyup="fn_checkWord(this,200)" placeholder="200<spring:message code='message.msg188'/>" required tabindex=2></textarea>
											</div>
										</div>
									</div>
									
									<br/>
									
									<div class="card-body" style="border: 1px solid #adb5bd;">
										<div class="form-group row div-form-margin-z" style="margin-bottom:-30px;margin-top:-10px;">
											<label for="ins_dump_db_id" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-dot-circle-o"></i>
												<spring:message code="common.database" />
											</label>
		
											<div class="col-sm-10">
												<select class="form-control form-control-xsm" style="margin-right: 1rem;width:300px;" name="ins_dump_db_id" id="ins_dump_db_id" onChange="fn_ins_get_object_list();" tabindex=3>
													<option value=""><spring:message code="common.choice" /></option>
													<c:forEach var="result" items="${dbList}" varStatus="status">
														<option value="<c:out value="${result.db_id}"/>"><c:out value="${result.db_nm}"/></option>
													</c:forEach>
												</select>
											</div>
										</div>
									</div>
									
									<br/>

									<div class="card-body" style="border: 1px solid #adb5bd;">
										<div class="form-group row div-form-margin-z" style="margin-top:-10px;">
											<label for="ins_dump_save_pth" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-angle-double-right"></i>
												<spring:message code="backup_management.backup_dir" />
											</label>
		
											<div class="col-sm-6">
												<input type="text" class="form-control form-control-sm" maxlength="200" id="ins_dump_save_pth" name="ins_dump_save_pth" onkeyup="fn_checkWord(this,200)" onKeydown="fn_ins_dump_check_pathChk('N');" onblur="this.value=this.value.trim()" tabindex=4 />
											</div>
		
											<div class="col-sm-4">
												<div class="input-group input-daterange d-flex align-items-center" >
													<button type="button" class="btn btn-inverse-info btn-fw" style="width: 115px;" onclick="fn_ins_dump_checkFolder(2)"><spring:message code="common.dir_check" /></button>
													<div class="input-group-addon mx-4">
														<div class="card card-inverse-primary" id="dump_backupVolume_div" style="display:none;border:none;">
															<div class="card-body" style="padding-top:10px;padding-bottom:10px;">
																<p class="card-text" id="dump_backupVolume"></p>
															</div>
														</div>
													</div>
												</div>
											</div>
										</div>

										<div class="form-group row div-form-margin-z">
											<div class="col-sm-2"></div>
		
											<div class="col-sm-10">
												<div class="alert alert-danger" style="margin-top:5px;display:none;" id="ins_dump_save_pth_alert"></div>
											</div>
										</div>
										
										<div class="form-group row div-form-margin-z">
											<label for="ins_dump_file_fmt_cd" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-angle-double-right"></i>
												<spring:message code="backup_management.file_format" />
											</label>
		
											<div class="col-sm-2">
												<select class="form-control form-control-xsm" style="margin-right: 1rem;width:130px;" name="ins_dump_file_fmt_cd" onChange="fn_ins_changeFileFmtCd();fn_dumpAlertChk(this);" id="ins_dump_file_fmt_cd" tabindex=5>
													<option value="0000"><spring:message code="common.choice" /></option>
													<option value="TC000401">tar</option>
													<option value="TC000402">plain</option>
													<option value="TC000403">directory</option>
													<option value="TC000404">custom</option>
												</select>
											</div>
											
											<label for="ins_dump_encd_mth_nm" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-angle-double-right"></i>
												<spring:message code="backup_management.incording_method" />
											</label>
		
											<div class="col-sm-2">
												<select class="form-control form-control-xsm" style="margin-right: 1rem;width:150px;" name="ins_dump_encd_mth_nm" id="ins_dump_encd_mth_nm" onChange="fn_dumpAlertChk(this);" tabindex=6 >
													<option value="0000"><spring:message code="common.choice" /></option>
													<c:forEach var="result" items="${incodeList}" varStatus="status">
														<option value="<c:out value="${result.sys_cd}"/>"><c:out value="${result.sys_cd_nm}"/></option>
													</c:forEach>
												</select>
											</div>

											<label for="ins_dump_usr_role_nm" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-angle-double-right"></i>
												<spring:message code="backup_management.rolename" />
											</label>
		
											<div class="col-sm-2">
												<select class="form-control form-control-xsm" style="margin-right: 1rem;width:150px;" name="ins_dump_usr_role_nm" id="ins_dump_usr_role_nm" onChange="fn_dumpAlertChk(this);" tabindex=7 >
													<option value="0000"><spring:message code="common.choice" /></option>
												</select>
											</div>
										</div>
										

										<div class="form-group row div-form-margin-z">
											<div class="col-sm-4">
												<div class="alert alert-danger" style="margin-top:5px;display:none;" id="ins_dump_file_fmt_cd_alert"></div>
											</div>
		
											<div class="col-sm-4">
												<div class="alert alert-danger" style="margin-top:5px;display:none;" id="ins_dump_encd_mth_nm_alert"></div>
											</div>
		
											<div class="col-sm-4">
												<div class="alert alert-danger" style="margin-top:5px;display:none;" id="ins_dump_usr_role_nm_alert"></div>
											</div>
										</div>

										
										<div class="form-group row div-form-margin-z" style="margin-bottom:-20px;">
											<label for="ins_dump_cprt" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-angle-double-right"></i>
												<spring:message code="backup_management.compressibility" />
											</label>
											<div class="col-sm-2">
												<select class="form-control form-control-xsm" style="margin-right: 1rem;width:130px;" name="ins_dump_cprt" id="ins_dump_cprt" tabindex=8 >
													<option value="0"><spring:message code="backup_management.uncompressed" /></option>
													<option value="1">1Level</option>
													<option value="2">2Level</option>
													<option value="3">3Level</option>
													<option value="4">4Level</option>
													<option value="5">5Level</option>
													<option value="6">6Level</option>
													<option value="7">7Level</option>
													<option value="8">8Level</option>
													<option value="9">9Level</option>
												</select>
											</div>
											
											<label for="ins_dump_file_stg_dcnt" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-angle-double-right"></i>
												<spring:message code="backup_management.file_keep_day" />
											</label>
											<div class="col-sm-2">
												<div class="input-group input-daterange d-flex align-items-center" >
													<input type="number" class="form-control form-control-sm"  style="width:50px;margin-right:-17px;" maxlength="3" id="ins_dump_file_stg_dcnt" name="ins_dump_file_stg_dcnt" min=1 value="1" tabindex=9  />
													<div class="input-group-addon mx-4" style="font-size: 12px;"><spring:message code="common.day" /></div>
												</div>
											</div>
											
											<label for="ins_dump_bck_mtn_ecnt" class="col-sm-2 col-form-label pop-label-index" style="padding-top:7px;">
												<i class="item-icon fa fa-angle-double-right"></i>
												<spring:message code="backup_management.backup_maintenance_count" />
											</label>
											<div class="col-sm-2">
												<div class="input-group input-daterange d-flex align-items-center" >
													<input type="number" class="form-control form-control-sm"  style="width:50px;margin-right:-17px;" maxlength="3" id="ins_dump_bck_mtn_ecnt" name="ins_dump_bck_mtn_ecnt" min=1 value="1" tabindex=10 />
													<div class="input-group-addon mx-4" style="font-size: 12px;"><spring:message code="backup_management.count" /></div>
												</div>
											</div>
										</div>
									</div>
									
									<br/>

									<div class="card-body" style="border: 1px solid #adb5bd;">
										<div class="form-group row div-form-margin-z" style="margin-top:-10px;margin-bottom:-10px;">
											<div class="col-12" >
												<ul class="nav nav-pills nav-pills-setting nav-justified" style="border-bottom:0px;" id="server-tab" role="tablist">
													<li class="nav-item">
														<a class="nav-link active" id="ins-dump-tab-1" data-toggle="pill" href="#insDumpOptionTab1" role="tab" aria-controls="insDumpOptionTab1" aria-selected="true" >
															<spring:message code="backup_management.add_option" /> #1
														</a>
													</li>
													<li class="nav-item">
														<a class="nav-link" id="ins-dump-tab-2" data-toggle="pill" href="#insDumpOptionTab2" role="tab" aria-controls="insDumpOptionTab2" aria-selected="false">
															<spring:message code="backup_management.add_option" /> #2
														</a>
													</li>
												</ul>
											</div>
										</div>
						
										<!-- tab화면 -->
										<div class="tab-content" id="pills-tabContent" style="border-top: 1px solid #c9ccd7;margin-bottom:-10px;">
											<div class="tab-pane fade show active" role="tabpanel" id="insDumpOptionTab1">
							
												<div class="form-group row div-form-margin-z" style="margin-top:-30px;">
													<label class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
														<i class="item-icon fa fa-angle-double-right"></i>
														<spring:message code="backup_management.sections" />
													</label>
													<div class="col-sm-10">
														<div class="input-group input-daterange d-flex" >
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_1_1" class="form-check-label" style="width:100px;">
																	<input type="checkbox" id="ins_dump_option_1_1" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0006" opt_cd="TC000601" onClick="fn_ins_dump_checkSection();" />
																	<spring:message code="backup_management.pre-data" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_1_2" class="form-check-label" style="width:100px;">
																	<input type="checkbox" id="ins_dump_option_1_2" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0006" opt_cd="TC000602" onClick="fn_ins_dump_checkSection();" />
																	<spring:message code="backup_management.data" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_1_3" class="form-check-label" style="width:100px;">
																	<input type="checkbox" id="ins_dump_option_1_3" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0006" opt_cd="TC000603" onClick="fn_ins_dump_checkSection();" />
																	<spring:message code="backup_management.post-data" />
																</label>
															</div>
														</div>
													</div>
												</div>

												<div class="form-group row div-form-margin-z" style="margin-top:-15px;">
													<label class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
														<i class="item-icon fa fa-angle-double-right"></i>
														<spring:message code="backup_management.object_type" />
													</label>
													<div class="col-sm-10">
														<div class="input-group input-daterange d-flex" >
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_2_1" class="form-check-label" style="width:100px;">
																	<input type="checkbox" id="ins_dump_option_2_1" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0007" opt_cd="TC000701" onClick="fn_ins_dump_checkObject('TC000701');" />
																	<spring:message code="backup_management.only_data" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_2_2" class="form-check-label" style="width:100px;">
																	<input type="checkbox" id="ins_dump_option_2_2" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0007" opt_cd="TC000702" onClick="fn_ins_dump_checkObject('TC000702');" />
																	<spring:message code="backup_management.only_schema" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_2_3" class="form-check-label" style="width:100px;">
																	<input type="checkbox" id="ins_dump_option_2_3" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0007" opt_cd="TC000703" />
																	<spring:message code="backup_management.blobs" />
																</label>
															</div>
														</div>
													</div>
												</div>
												
												<div class="form-group row div-form-margin-z" style="margin-top:-15px;margin-bottom:-35px;">
													<label class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
														<i class="item-icon fa fa-angle-double-right"></i>
														<spring:message code="backup_management.save_yn_choice" />
													</label>
													<div class="col-sm-10">
														<div class="input-group input-daterange d-flex" >
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_3_1" class="form-check-label" style="width:100px;">
																	<input type="checkbox" id="ins_dump_option_3_1" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0008" opt_cd="TC000801" disabled />
																	<spring:message code="backup_management.owner" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_3_2" class="form-check-label" style="width:100px;">
																	<input type="checkbox" id="ins_dump_option_3_2" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0008" opt_cd="TC000802" />
																	<spring:message code="backup_management.privilege" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_3_3" class="form-check-label" style="width:100px;">
																	<input type="checkbox" id="ins_dump_option_3_3" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0008" opt_cd="TC000803" />
																	<spring:message code="backup_management.tablespace" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_3_4" class="form-check-label" style="width:150px;">
																	<input type="checkbox" id="ins_dump_option_3_4" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0008" opt_cd="TC000804" />
																	<spring:message code="backup_management.unlogged_table_data" />
																</label>
															</div>
														</div>
													</div>
												</div>
											</div>
											
											<div class="tab-pane fade" role="tabpanel" id="insDumpOptionTab2">
							
												<div class="form-group row div-form-margin-z" style="margin-top:-30px;">
													<label class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
														<i class="item-icon fa fa-angle-double-right"></i>
														<spring:message code="backup_management.query" />
													</label>
													<div class="col-sm-10">
														<div class="input-group input-daterange d-flex" >
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_4_1" class="form-check-label" style="width:200px;">
																	<input type="checkbox" id="ins_dump_option_4_1" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0009" opt_cd="TC000901" onClick="fn_ins_dump_checkOid();" />
																	<spring:message code="backup_management.use_column_inserts" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_4_2" class="form-check-label" style="width:200px;">
																	<input type="checkbox" id="ins_dump_option_4_2" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0009" opt_cd="TC000902" onClick="fn_ins_dump_checkOid();" />
																	<spring:message code="backup_management.use_column_commands" />
																</label>
															</div>
														</div>
													</div>
												</div>
													
												<div class="form-group row div-form-margin-z" style="margin-top:-25px;">
													<div class="col-sm-2"></div>
													<div class="col-sm-10">
														<div class="input-group input-daterange d-flex" >
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_4_3" class="form-check-label" style="width:200px;">
																	<input type="checkbox" id="ins_dump_option_4_3" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0009" opt_cd="TC000903" disabled />
																	<spring:message code="backup_management.create_database_include" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_4_4" class="form-check-label" style="width:180px;">
																	<input type="checkbox" id="ins_dump_option_4_4" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0009" opt_cd="TC000904" disabled />
																	<spring:message code="backup_management.drop_database_include" />
																</label>
															</div>
														</div>
													</div>
												</div>
												
												<div class="form-group row div-form-margin-z" style="margin-top:-5px;">
													<label class="col-sm-2 col-form-label-sm pop-label-index" style="padding-top:calc(0.5rem-1px);">
														<i class="item-icon fa fa-angle-double-right"></i>
														<spring:message code="common.etc" />
													</label>
													<div class="col-sm-10">
														<div class="input-group input-daterange d-flex" >
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_5_1" class="form-check-label" style="width:200px;">
																	<input type="checkbox" id="ins_dump_option_5_1" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0010" opt_cd="TC001001" />
																	<spring:message code="backup_management.oids_include" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_5_2" class="form-check-label" style="width:180px;">
																	<input type="checkbox" id="ins_dump_option_5_2" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0010" opt_cd="TC001002" />
																	<spring:message code="backup_management.quote_include" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_5_3" class="form-check-label" style="width:180px;">
																	<input type="checkbox" id="ins_dump_option_5_3" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0010" opt_cd="TC001003" />
																	<spring:message code="backup_management.Identifier_quotes_apply" />
																</label>
															</div>
															
														</div>
													</div>
												</div>
												
												<div class="form-group row div-form-margin-z" style="margin-top:-25px;margin-bottom:-40px;">
													<div class="col-sm-2"></div>
													<div class="col-sm-10">
														<div class="input-group input-daterange d-flex" >
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_5_4" class="form-check-label" style="width:200px;">
																	<input type="checkbox" id="ins_dump_option_5_4" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0010" opt_cd="TC001004" />
																	<spring:message code="backup_management.set_session_auth_use" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label for="ins_dump_option_5_5" class="form-check-label" style="width:180px;">
																	<input type="checkbox" id="ins_dump_option_5_5" name="ins_dump_opt" class="form-check-input" value="Y" grp_cd="TC0010" opt_cd="TC001005" />
																	<spring:message code="backup_management.detail_message_include" />
																</label>
															</div>
															
															<div class="form-check input-group-addon mx-4">
																<label class="form-check-label" style="width:180px;">
																</label>
															</div>
														</div>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
								
								<div class="col-md-3 system-tlb-scroll" style="border:0px;height: 620px; overflow-x: hidden;  overflow-y: auto; ">
									<div class="card-body-modal" style="border: 1px solid #adb5bd;">
										<!-- title -->
										<h3 class="card-title fa fa-dot-circle-o">
											<spring:message code="backup_management.object_choice" />
										</h3>
				
										<div class="table-responsive system-tlb-scroll">
											<table class="table">
												<tbody>
													<tr>
														<td class="py-1" style="width: 100%; word-break:break-all;">
															<div class="row">
																<div class="col-md-12">
	 																<div id="treeview_container" class="hummingbird-treeview well h-scroll-large">
																	</div>																	
																</div>
															</div>
														</td>
													</tr>
												</tbody>
											</table>
										</div>
									</div>
								</div>
							</div>

							<div class="card-body">
								<div class="top-modal-footer" style="text-align: center !important; margin: -20px 0 -30px -20px;" >
									<input class="btn btn-primary" width="200px;" style="vertical-align:middle;" type="submit" value='<spring:message code="common.registory" />' />
									<button type="button" class="btn btn-light" data-dismiss="modal"><spring:message code="common.cancel"/></button>
								</div>
							</div>
						</fieldset>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>