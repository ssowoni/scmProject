<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>Job Korea</title>


<jsp:include page="/WEB-INF/view/common/common_include.jsp"></jsp:include>

<script type="text/javascript">
//그룹코드 페이징 설정
var pageSizeDailyOrder = 10;
var pageBlockSizeDailyOrder = 10;
	
// 상세코드 페이징 설정
var pageSizeComnDtlCod = 5;
var pageBlockSizeComnDtlCod = 10;

$(function() {
	// 일일 수주 조회
	//fListDailyOrderHistroy();
	
});

/** 일별 수주 내역 조회 */
function fListDailyOrderHistroy(currentPage) {
	

  currentPage = currentPage || 1;

  console.log("currentPage : " + currentPage);

  var param = {
    currentPage: currentPage
    , pageSize: pageSizeDailyOrder
  }

  var resultCallback = function(data) {
    flistDailyOrderHistroyResult(data, currentPage);
  };
  // Ajax실행 방식
  // callAjax("Url",type,return,async or sync방식,넘겨준거,값,Callback함수 이름)
  // html로 받을거라 text
  callAjax("/scm/dailyOrderHistory.do", "post", "text", true, param, resultCallback);
}

/** 일별 수주 내역 조회 콜백 함수 */
function flistDailyOrderHistroyResult(data, currentPage) {

  // alert(data);
  console.log(data);

  // 기존 목록 삭제
  $('#listDailyOrderHistroy').empty();

  var $data = $($(data).html());

  $("#listDailyOrderHistroy").append(data);

  // 총 개수 추출
  let totalCntDailyOrder = $("#totalCntDailyOrder").val();
  
  // 페이지 네비게이션 생성
	/* currentPage 현재 페이지
	totalCount 총 건수
	pageRow 페이지당 보여주는 목록 갯수
	blockPage 페이지 번호 갯수
	pageFunc 페이지 번호를 클릭하면 호출할 함수 객체
	exParams pageFunc에 넘겨줄 추가적인 파라미터 ( optional / 가능한 파라미터 형식: 문자열 ) */
  var paginationHtml = getPaginationHtml(currentPage, totalCntDailyOrder, pageSizeDailyOrder, pageBlockSizeDailyOrder, 'fListDailyOrderHistroy');
  console.log("paginationHtml : " + paginationHtml);

  $("#dailyOrderPagination").empty().append(paginationHtml);

  // 현재 페이지 설정
  $("#currentPageDailyOrder").val(currentPage);
  
}


/** 주문 정보 배송 지시서 모달 실행 */
function fPopModalDeliDirection(order_no, pro_no) {

	if ($("#refundCheck").is(":checked")) {
		
		swal("반품 요청된 주문 입니다.");

		return
		
	}
	
    // Tranjection type 설정
    $("#action").val("U");
    
    $("#shipping_tbody").children().remove();
    
    $("#order_qty_upper").val('');
    
    // 주문 번호, 제품 번호 단건 조회
    //fSelectOrderNoAndProNo(order_no, pro_no);
  
}

function fSelectProductNoResult(data, optionId){
	
	
	$("#"+optionId).find("option").remove();
	$("#productDetail").children().remove();
	
	$("#"+optionId).append("<option value=''> 창고 선택 </option>");
	
	// 해당 제품들 정보 hidden 저장
	$("#productDetail").find("input").remove();
	
	for (var i=0 ; i<data.productDetail.length ; i++) {
		var model = data.productDetail[i];
		$("#"+optionId).append("<option value='"+model.ware_no+"' >"+model.ware_name+"</option>");
		$("#productDetail").append("<div class='"+model.ware_no+"'"+"id="+model.ware_no+">"+"</div>");
		$("#"+model.ware_no).append("<input type='hidden' class='pd_ware_no' value='"+model.ware_no+"'>");

		$("#"+model.ware_no).append("<input type='hidden' class='pd_ware_name' value='"+model.ware_name+"'>");
		$("#"+model.ware_no).append("<input type='hidden' class='pd_pro_no' value='"+model.pro_no+"'>");
		$("#"+model.ware_no).append("<input type='hidden' class='pd_pro_name' value='"+model.pro_name+"'>");
		$("#"+model.ware_no).append("<input type='hidden' class='pd_company' value='"+model.deli_company+"'>");
		$("#"+model.ware_no).append("<input type='hidden' class='pd_pro_ware_qty' value='"+model.pro_ware_qty+"'>");
	}
	

	$("#"+optionId).trigger("chosen:updated");
	$("#"+optionId).chosen({no_results_text: "검색 결과가 없습니다 :("});
	
	
	
	let productDetail = data.productDetail[0];
	
	$("#pur_login_id").text(productDetail.login_id);
    $("#pur_pro_no").text(productDetail.pro_no);
    $("#pur_pro_name").text(productDetail.pro_name);
    $("#pur_deli_company").text(productDetail.deli_company);
    
    $("#pur_pro_no").focus();
    
    $("#pur_pro_ware_qty_upper").val('');

    $("#pur_order_qty_upper").text('');
    // 모달 팝업
    gfModalPop("#purchaseDirection");
}


function fPurchaseSelectedOptions(ware_no, optionId){

	$("#pur_order_qty_upper").val('');
	
	let option_pro_ware_qty = $("#productDetail").find('.'+ware_no).children('.pd_pro_ware_qty').val();
	
	$("#pur_pro_ware_qty_upper").val(option_pro_ware_qty);
	
}

function faddPurchaseBtn(){
	
	let pur_order_qty_upper = $("#pur_order_qty_upper").val() * 1;
	
	// 0개 발주의 경우
	if(pur_order_qty_upper<=0){
		swal("1개 이상의 수량만 수주 가능합니다.")
		return
	}
	if(!numCheck(pur_order_qty_upper)){
		swal("소숫점은 입력할 수 없습니다.");
		return
	}
	
	let seleted_ware_no = $("#pur_ware_name_option option:selected").val();
	
	let purchase_tbody_tr_length = $('#purchase_tbody tr').length;
	
	// 이미 해당 창고에서 주문한 경우
	for(var i = 0 ; i<purchase_tbody_tr_length; i++){

		let existing_ware_no = $("td[id=pur_ware_no]:eq(" + i + ")").text() * 1;
		
		if(seleted_ware_no == existing_ware_no){
			swal("해당 창고에서 이미 발주량을 결정 하셨습니다.");
			return
		}
	}
	
	
	let seleted_ware_name = $("#pur_ware_name_option option:selected").text();
	

	let seleted_pro_no = $("#productDetail").find('.'+seleted_ware_no).children('.pd_pro_no').val();
	let seleted_pro_name = $("#productDetail").find('.'+seleted_ware_no).children('.pd_pro_name').val();
	let seleted_deli_company = $("#productDetail").find('.'+seleted_ware_no).children('.pd_company').val();
	var pur_login_id = $("#pur_login_id").text();
	// alert(seleted_ware_name);
	
	
	let html = "<tr>" +"<td id='pur_pro_no'>"+seleted_pro_no+"</td>"+
	"<td id='pur_pro_name'>"+seleted_pro_name+"</td>"+
	"<td id='pur_deli_company'>"+seleted_deli_company+"</td>"+
	"<td id='pur_ware_no'>"+seleted_ware_no+"</td>"+
	"<td id='pur_ware_name'>"+seleted_ware_name+"</td>"+
	"<td id='purchase_qty'>"+pur_order_qty_upper+"</td>"+
	"<td id='pur_login_id'>"+pur_login_id+"</td>"+
	"<td><a class='btnType gray' id='deletePurchaseBtn' name='deletePurchaseBtn'><span>삭제</span></a></td></tr>"
	;
	
	$("#purchase_tbody").append(html);
	
	
	$('a[name=deletePurchaseBtn]').click(function(e) {
		e.preventDefault();
		$(this).parent().parent().remove();
	});
	
	// 주문 개수 입력 란 비워 주기
	$("#pur_order_qty_upper").val('');
}

// 미입금 주문 팝업
function fNotDepositPopUp(){
	swal("입금되지 않은 주문입니다.");
}

// 재고가 부족한 상황
function fNoneWareQtyPopUp(){
	swal("재고가 부족합니다. 발주 지시서를 작성해주세요.");
}

/** 주문 단건 조회 */
/* function fSelectOrderNoAndProNo(order_no, pro_no) {

  var param = { 
		  order_no : order_no,
		  pro_no : pro_no
		  };

  var resultCallback = function(data) {
	  fSelectOrderNoAndProNoResult(data);
  };
  
  var prefix = "/scm/dailyOrderHistory.do/order/";
  var suffix = "/product/";
  var url = prefix + order_no + suffix + pro_no;

  callAjax(url, "get", "json", true, null, resultCallback);
} */

/** 주문 단건 조회 콜백 함수 */
function fSelectOrderNoAndProNoResult(data) {

    // 일별 수주내역 폼 데이터 설정
    fInitFormDeliyDirection(data.orderDetail);


    // 모달 팝업
    gfModalPop("#deliDirection");

}



/** 일별 수주 내역 폼 초기화 */
function fInitFormDeliyDirection(object) {
  $("#order_no").focus();
  if (object == "" || object == null || object == undefined) {

    $("#order_no").val("");
    $("#order_date").val("");
    $("#user_company").val("");
    $("#pro_name").val("");
    $("#pro_ware_qty").val("");
    $("#name").val("");
    $("#order_cd").val("");
    $("#order_no").focus();

  } else {

	    $("#order_no").text(object.order_no);
	    $("#order_date").text(object.order_date);
	    $("#user_company").text(object.user_company);
	    $("#pro_name").text(object.pro_name);
	    $("#order_qty").text(object.order_qty);
		
	    $("#order_no").focus();
	    
	    
	    $("#ware_name").text('');
	    $("#pro_ware_qty_upper").val('');

	    $("#pro_name_bottom").text('');   
	    
  }

</script>

</head>
<body>
	<input type="hidden" id="currentPageDailyOrder" value="1">
	<input type="hidden" id="currentPageComnDtlCod" value="1">
	<input type="hidden" id="tmpGrpCod" value="">
	<input type="hidden" id="tmpGrpCodNm" value="">
	<input type="hidden" name="action" id="action" value="">

	<div id="whInfoData"></div>
	
	<div id="productDetail"></div>

	<!-- 모달 배경 -->
	<div id="mask"></div>

	<div id="wrap_area">

		<h2 class="hidden">header 영역</h2>
		<jsp:include page="/WEB-INF/view/common/header.jsp"></jsp:include>

		<h2 class="hidden">컨텐츠 영역</h2>
		<div id="container">
			<ul>
				<li class="lnb">
					<!-- lnb 영역 --> <jsp:include
						page="/WEB-INF/view/common/lnbMenu.jsp"></jsp:include> <!--// lnb 영역 -->
				</li>
				<li class="contents">
					<!-- contents -->
					<h3 class="hidden">contents 영역</h3> <!-- content -->
					<div class="content">

						<p class="Location">
							<a href="/dashboard/dashboard.do" class="btn_set home">메인으로</a>
							<span class="btn_nav bold">일별 수주 내역</span> <a href="../admtrd/AdmstdOrderDetails.do" class="btn_set refresh">새로고침</a>
						</p>

						<p class="conTitle">
							<span>일별 수주 내역</span> <span class="fr"> 
							
								<input class="datetype" type="date" name = "date" id="startDate" value="${nowTime }">
								&nbsp; ~ &nbsp;
								<input class="datetype" type="date" name = "date" id="endDate" value="${nowTime }">
								
								<label><input type="checkbox" id="refundCheck" name="refundCheck" value="refund"> 입금 목록 조회</label> 
								 
							</span>
						</p>

						<div class="divComGrpCodList">
							<table class="col" id="dailyOrderTable">
								<caption>caption</caption>
								<colgroup>
									<col width="5%">
									<col width="9%">
									<col width="9%">
									<col width="9%">
									<col width="5%">
									<col width="8%">
									<col width="7%">
									<col width="8%">
									<col width="5%">
									<col width="9%">
									<col width="9%">
									<col width="7%">
									<col width="7%">
								</colgroup>

								<thead>
									<tr>
										<th scope="col">주문 번호</th>
										<th scope="col">주문 일자</th>
										<th scope="col">고객기업명</th>
										<th scope="col">주문제품명</th>
										<th scope="col">재고 개수</th>
										<th scope="col">공급가</th>
										<th scope="col">주문 개수</th>
										<th scope="col">금액 합계</th>
										<th scope="col">주문구분</th>
										<th scope="col">납품희망날짜</th>
										<th scope="col">입금여부</th>
										<th scope="col">배송지시서 작성</th>
										<th scope="col">발주지시서 작성</th>
									</tr>
								</thead>
								<!-- 리스트 가져오기 -->
								<tbody id="listDailyOrderHistroy"></tbody>
							</table>
						</div>
						<!-- 페이징 처리 -->
						<div class="paging_area" id="pagingnavi">
							<div class="paging">
								<a class="first" href="javascript:selectUserList(1)">
								<span class="hidden">맨앞</span></a>
								<a class="pre" href="javascript:selectUserList(1)">
								<span class="hidden">이전</span></a>
								<strong>1</strong> 
								<a href="javascript:selectUserList(2)">2</a> 
								<a href="javascript:selectUserList(3)">3</a> 
								<a href="javascript:selectUserList(4)">4</a>
								<a href="javascript:selectUserList(5)">5</a>
								<a class="next" href="javascript:selectUserList(5)">
								<span class="hidden">다음</span></a>
								<a class="last" href="javascript:selectUserList(5)">
								<span class="hidden">맨뒤</span></a>
							</div>
						</div>


					</div> <!--// content -->

					<h3 class="hidden">풋터 영역</h3> <jsp:include
						page="/WEB-INF/view/common/footer.jsp"></jsp:include>
				</li>
			</ul>
		</div>
	</div>

	<!-- 모달팝업 -->
	<div id="deliDirection" class="layerPop layerType2"
		style="width: 900px;">
		<dl>
			<dt>
				<strong>배송 지시서 작성</strong>
			</dt>
			<dd class="content">
				<!-- s : 여기에 내용입력 -->

				<table class="col">
					<caption>caption</caption>
					<colgroup>
						<col width="8%">
						<col width="14%">
						<col width="10%">
						<col width="18%">
						<col width="6%">
						<col width="8%">
						<col width="6%">
					</colgroup>

					<thead>
						<tr>
							<th scope="col">주문 번호</th>
							<th scope="col">주문 일자</th>
							<th scope="col">고객기업명</th>
							<th scope="col">주문제품명</th>
							<th scope="col">주문 개수</th>
						</tr>
					</thead>
					<tbody>

						<tr>
							<td><a type="text" class="inputTxt p100" name="order_no"
								id="order_no" readonly="readonly" /></a></td>
							<td id="order_date"></td>
							<td id="user_company"></td>
							<td id="pro_name"></td>
							<td id="order_qty"></td>
						</tr>
					</tbody>
				</table>

				<table class="row">
					<caption>caption</caption>
					<colgroup>
						<col width="15%">
						<col width="5%">
						<col width="10%">
						<col width="15%">
					</colgroup>

					<tbody>
						<tr>
							<th scope="row">창고 선택</th>
							<td><select style="width: 160px" id="ware_name_option"
								name="ware_name_option"
								onchange="fSelectedOptions(this.options[this.selectedIndex].value, ware_name_option)">
							</select></td>

							<th scope="row">재고 개수 <span class="font_red"></span></th>
							<td><input type="text" class="inputTxt p100"
							id="pro_ware_qty_upper" readonly="readonly" /></td>
							<th scope="row">주문 개수 <span class="font_red"></span></th>
							<td><input type="text" class="inputTxt p100"
							id="order_qty_upper" /></td>
							<td>
							<a href="javascript:faddShppingBtn();"
							 class="btnType blue"><span>추가</span></a>
							</td>
						</tr>

					</tbody>
				</table>
				
				<table class="col" id ="shippingDiretionTable">
					<caption>caption</caption>
					<colgroup>
					
						<col width="3%">
						<col width="12%">
						<col width="12%">
						<col width="16%">
						<col width="3%">
						<col width="8%">
						<col width="3%">
					</colgroup>

					<thead>
						<tr>
							<th scope="col">창고번호</th>
							<th scope="col">창고명</th>
							<th scope="col">제품번호</th>
							<th scope="col">제품명</th>
							<th scope="col">수주 개수</th>
							<th scope="col">배송 담당자</th>
							<th scope="col">비고</th>
						</tr>
					</thead>
					<tbody id="shipping_tbody">
						<tr>
							<td id="ware_name"></td>
							<td id="pro_name_bottom"></td>
							<td id="ship_manager_name"></td>
							<td id="ship_qty"></td>
							<td></td>
						</tr>
					</tbody>
				</table>

				<!-- e : 여기에 내용입력 -->

				<div class="btn_areaC mt30">
					<a href="" class="btnType blue" id="shippingDoneBtn" name="btn"><span>완료</span></a>
					<a href="" class="btnType gray" id="btnClose" name="btn"><span>취소</span></a>
				</div>
			</dd>
		</dl>
		<a href="" class="closePop"><span class="hidden">닫기</span></a>
	</div>

	<div id="purchaseDirection" class="layerPop layerType2" style="width: 900px;">
		<dl>
			<dt>
				<strong>발주 지시서 작성</strong>
			</dt>
			<dd class="content">

				<!-- s : 여기에 내용입력 -->


				<table class="col">
					<caption>caption</caption>
					<colgroup>
						<col width="10%">
						<col width="12%">
						<col width="10%">
						<col width="6%">
					</colgroup>

					<thead>
						<tr>
							<th scope="col">제품번호</th>
							<th scope="col">제품명</th>
							<th scope="col">납품기업</th>
							<th scope="col">발주자</th>
						</tr>
					</thead>
					<tbody>

						<tr>
							<td id="pur_pro_no"></td>
							<td id="pur_pro_name"></td>
							<td id="pur_deli_company"></td>
							<td id="pur_login_id"></td>
						</tr>
					</tbody>
				</table>

				<table class="row">
					<caption>caption</caption>
					<colgroup>
						<col width="15%">
						<col width="5%">
						<col width="10%">
						<col width="15%">
					</colgroup>

					<tbody>
						<tr>
							<th scope="row">창고 선택</th>
							<td><select style="width: 160px" id="pur_ware_name_option"
								name="pur_ware_name_option"
								onchange="fPurchaseSelectedOptions(this.options[this.selectedIndex].value, pur_ware_name_option)">
							</select></td>

							<th scope="row">재고 개수 <span class="font_red"></span></th>
							<td><input type="text" class="inputTxt p100"
							id="pur_pro_ware_qty_upper" readonly="readonly" /></td>
							<th scope="row">발주 개수 <span class="font_red"></span></th>
							<td><input type="text" class="inputTxt p100"
							id="pur_order_qty_upper" /></td>
							<td>
							<a href="javascript:faddPurchaseBtn();"
							 class="btnType blue"><span>추가</span></a>
							</td>
						</tr>

					</tbody>
				</table>
				
				<table class="col" id ="purchaseDiretionTable">
					<caption>caption</caption>
					<colgroup>
					
						<col width="10%">
						<col width="12%">
						<col width="10%">
						<col width="3%">
						<col width="10%">
						<col width="3%">
						<col width="8%">
						<col width="3%">
					</colgroup>

					<thead>
						<tr>
							<th scope="col">제품번호</th>
							<th scope="col">제품명</th>
							<th scope="col">납품기업</th>
							<th scope="col">창고번호</th>
							<th scope="col">창고명</th>
							<th scope="col">발주개수</th>
							<th scope="col">발주자</th>
							<th scope="col">비고</th>
						</tr>
					</thead>
					<tbody id="purchase_tbody">
					</tbody>
				</table>

				<!-- e : 여기에 내용입력 -->

				<div class="btn_areaC mt30">
					<a href="" class="btnType blue" id="btnPurDirDone" name="btn"><span>신청</span></a>
					<a href="" class="btnType gray" id="btnClosePurDir" name="btn"><span>취소</span></a>
				</div>
			</dd>
		</dl>
		<a href="" class="closePop"><span class="hidden">닫기</span></a>
	</div>
	<!--// 모달팝업 -->
</body>
</html>