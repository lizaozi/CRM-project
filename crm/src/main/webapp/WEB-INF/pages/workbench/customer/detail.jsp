<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
	String basePath = request.getScheme() + "://"
	+ request.getServerName() + ":"
	+ request.getServerPort()
	+ request.getContextPath() + "/";
%>

<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});

		$("#remarkDivList").on("mouseover",".remarkDiv",function () {
			$(this).children("div").children("div").show();
		})

		$("#remarkDivList").on("mouseout",".remarkDiv",function () {
			$(this).children("div").children("div").hide();
		})

		$("#remarkDivList").on("mouseover",".myHref",function () {
			$(this).children("span").css("color","red");
		})

		$("#remarkDivList").on("mouseout",".myHref",function () {
			$(this).children("span").css("color","#E6E6E6");
		})

		//给“保存”按钮添加单击事件
		$("#saveCustomerRemarkBtn").click(function () {
			//收集参数
			var noteContent = $.trim($("#remark").val());
			var customerId = '${requestScope.customer.id}';
			if (noteContent == "") {
				alert("备注内容不能为空！");
				return;
			}
			//发送请求
			$.ajax({
				url:'workbench/customer/saveCustomerRemark.do',
				data:{
					noteContent:noteContent,
					customerId:customerId
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						//清空输入框
						$("#remark").val("");
						//追加备注信息
						var htmlStr = "";
						htmlStr += "<div class=\"remarkDiv\" id=\"div_"+data.retData.id+"\" style=\"height: 60px;\">";
						htmlStr += "<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
						htmlStr += "<div style=\"position: relative; top: -40px; left: 40px;\" >";
						htmlStr += "<h5>"+data.retData.noteContent+"</h5>";
						htmlStr += "<font color=\"gray\">客户</font> <font color=\"gray\">-</font> <b>${requestScope.customer.name}</b> <small style=\"color: gray;\"> "+data.retData.createTime+" 由 ${sessionScope.sessionUser.name} 创建</small>";
						htmlStr += "<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
						htmlStr += "<a class=\"myHref\" name=\"editA\" remarkId=\"+data.retDate.id+\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						htmlStr += "&nbsp;&nbsp;&nbsp;&nbsp;";
						htmlStr += "<a class=\"myHref\" name=\"deleteA\" remarkId=\"+data.retDate.id+\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						htmlStr += "</div>";
						htmlStr += "</div>";
						htmlStr += "</div>";

						$("#remarkDiv").before(htmlStr);
					}else {
						alert(data.message);
					}
				}
			});
		});

		//给”删除“图标添加单击事件
		$("#remarkDivList").on("click","a[name='deleteA']",function () {
			//获取id
			var id = $(this).attr("remarkId");
			//发送
			$.ajax({
				url:'workbench/customer/deleteCustomerRemark.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						//删除该行
						$("#div_"+id).remove();
					}else {
						alert(data.message);
					}
				}
			});
		});

		//给”修改“图标添加单击事件
		$("#remarkDivList").on("click","a[name='editA']",function () {
			//获取参数
			var remarkId = $(this).attr("remarkId");
			var noteContent = $("#div_"+remarkId+" h5").text();
			//回显
			$("#remarkId").val(remarkId);
			$("#edit-noteContent").val(noteContent);
			//弹出
			$("#editRemarkModal").modal("show");
		});

		//给”更新“按钮添加单击事件
		$("#editCustomerRemarkBtn").click(function () {
			//获取参数
			var id = $("#remarkId").val();
			var noteContent = $.trim($("#edit-noteContent").val());
			if (noteContent == "") {
				alert("备注内容不能为空！");
				return;
			}
			//发送
			$.ajax({
				url:'workbench/customer/editCustomerRemark.do',
				data:{
					id:id,
					noteContent:noteContent
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						//关闭窗口
						$("#editRemarkModal").modal("hide");
						//刷新
						$("#div_"+id+" h5").text(noteContent);
						$("#div_"+id+" small").text(" "+data.retData.editTime+" 由 ${sessionScope.sessionUser.name} 修改");
					}else {
						alert(data.message);
						$("#editRemarkModal").modal("show");
					}
				}
			});
		});

		//给”删除“交易图标添加单击事件
		$("#tBody-tran").on("click","a[name='deleteA']",function () {
			//获取id，赋值到隐藏id中
			var id = $(this).attr("tranId");
			$("#delete-tranId").val(id);
			//弹出
			$("#removeTransactionModal").modal("show");
		});

		//给交易删除按钮添加单击事件
		$("#deleteTranBtn").click(function () {
			//从隐藏框中获取id
			var id = $("#delete-tranId").val();
			//发送
			$.ajax({
				url:'workbench/customer/deleteTran.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						$("#removeTransactionModal").modal("hide");
						//删除
						$("#tr_"+id).remove();
					}else {
						alert(data.message);
						$("#removeTransactionModal").modal("show");
					}
				}
			});
		});

		//给“新建交易”添加单击事件
		$("#createTranA").click(function () {
			//初始化
			$("#createTranForm")[0].reset();
			//弹出
			$("#createTranModal").modal("show");
		});

		//给市场活动源“搜索”图标添加单击事件
		$("#queryActivityA").click(function () {
			//弹出
			$("#findMarketActivityModal").modal("show");
			//
			$("#createTranModal").modal("")
		});

		//给市场活动名称输入框添加键盘弹起事件
		$("#queryActivityTxt").keyup(function () {
			//获取参数
			var activityName = $("#queryActivityTxt").val();
			//发送请求
			$.ajax({
				url:'workbench/transaction/queryActivityForCreateTran.do',
				data:{
					activityName:activityName
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					var htmlStr = "";
					$.each(data,function (index,obj) {
						htmlStr += "<tr>";
						htmlStr += "<td><input type=\"radio\" value=\""+obj.id+"\" activityName=\""+obj.name+"\" name=\"activity\"/></td>";
						htmlStr += "<td>"+obj.name+"</td>";
						htmlStr += "<td>"+obj.startDate+"</td>";
						htmlStr += "<td>"+obj.endDate+"</td>";
						htmlStr += "<td>"+obj.owner+"</td>";
						htmlStr += "</tr>";
					});
					$("#tBody-activity").html(htmlStr);
				}
			});
		});

		//给”单选框“添加点击事件
		$("#tBody-activity").on("click","input[type='radio']",function () {
			//获取id和名字
			var activityId = this.value;
			var activityName = $(this).attr("activityName");
			//关闭模态窗口
			$("#findMarketActivityModal").modal("hide");
			//给隐藏域赋值
			$("#createTran-activityId").val(activityId);
			$("#createTran-activityName").val(activityName);
		});

		//给“联系人名称”添加单击事件
		$("#queryContactsA").click(function () {
			$("#findContactsModal").modal("show");
		});

		//给联系人名称输入框添加键盘弹起事件
		$("#queryContactsTxt").keyup(function () {
			//获取参数
			var contactsName = $("#queryContactsTxt").val();
			//发送
			$.ajax({
				url:'workbench/transaction/queryContactsForCreateTran.do',
				data:{
					contactsName:contactsName
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					var htmlStr = "";
					$.each(data,function (index,obj) {
						htmlStr += "<tr>";
						htmlStr += "<td><input type=\"radio\" value=\""+obj.id+"\" contactsName=\""+obj.fullname+"\" name=\"activity\"/></td>";
						htmlStr += "<td>"+obj.fullname+"</td>";
						htmlStr += "<td>"+obj.email+"</td>";
						htmlStr += "<td>"+obj.mphone+"</td>";
						htmlStr += "</tr>";
					});
					$("#tBody-contacts").html(htmlStr);
				}
			});
		});

		//给”单选框“添加点击事件
		$("#tBody-contacts").on("click","input[type='radio']",function () {
			var contactsId = this.value;
			var contactsName = $(this).attr("contactsName");
			//关闭
			$("#findContactsModal").modal("hide");
			//赋值
			$("#createTran-contactsId").val(contactsId);
			$("#createTran-contactsName").val(contactsName);
		});

		//日历插件
		$(".myDate").datetimepicker({
			language:'zh-CN',
			format:'yyyy-mm-dd',
			minView:'month',
			initialDate:new Date(),
			autoclose:true,
			todayBtn:true,
			clearBtn:true
		});

		//给”阶段“添加改变事件
		$("#createTran-stage").change(function () {
			//获取参数
			var stageValue = $("#createTran-stage option:selected").text();
			if (stageValue == "") {
				//清空可能性输入框
				$("#createTran-possibility").val("");
				return;
			}
			$.ajax({
				url:'workbench/transaction/getPossibilityByStageValue.do',
				data:{
					stageValue:stageValue
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					//在可能性输入框显示
					$("#createTran-possibility").val(data);
				}
			})
		});

		//给“保存”按钮添加单击事件
		$("#saveCreateTranBtn").click(function () {
			//获取参数
			var owner = $("#createTran-owner").val();
			var money = $.trim($("#createTran-money").val());
			var name = $.trim($("#createTran-name").val());
			var expectedDate = $("#createTran-expectedDate").val();
			var customerName = $.trim($("#createTran-customerName").val());
			var stage = $("#createTran-stage").val();
			var source = $("#createTran-source").val();
			var type = $("#createTran-type").val();
			var activityId = $("#createTran-activityId").val();
			var activityName = $("#createTran-activityName").val()
			var contactsId = $("#createTran-contactsId").val();
			var contactsName = $("#createTran-contactsName").val();
			var description= $("#createTran-description").val();
			var contactSummary = $("#createTran-contactSummary").val();
			var nextContactTime = $("#createTran-nextContactTime").val();

			//表单验证
			var moneyExp = /^(([1-9]\d*)|0)$|(^$)/;
			if (!moneyExp.test(money)) {
				alert("金额只能是非负整数！");
				return;
			}
			if (name == "") {
				alert("名称不能为空！");
				return;
			}
			if (expectedDate == "") {
				alert("预计成交日期不能为空！");
				return;
			}
			if (customerName == "") {
				alert("客户名称不能为空！");
				return;
			}
			if (stage == "") {
				alert("请选择阶段！");
				return;
			}
			if (activityName == "") {
				//清空acitivityId
				activityId = "";
			}
			if (contactsName == "") {
				//清空contactsId
				contactsId = "";
			}

			//发送
			$.ajax({
				url:'workbench/transaction/saveCreateTran.do',
				data:{
					owner:owner,
					money:money,
					name:name,
					expectedDate:expectedDate,
					customerName:customerName,
					stage:stage,
					source:source,
					type:type,
					activityId:activityId,
					contactsId:contactsId,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						$("#createTranModal").modal("hide");
						//从新跳转页面，刷新列表
						window.location.href="workbench/customer/detailCustomer.do?id=${requestScope.customer.id}";
					}else {
						alert(data.message);
						$("#createTranModal").modal("show");
					}
				}
			});

		});

		//给“新建联系人”添加单击
		$("#createContactsA").click(function () {
			//清空表单
			$("#createContactsForm")[0].reset();
			//弹出
			$("#createContactsModal").modal("show");
		});

		//给“新建联系人”按钮添加单击事件
		$("#saveCreateContactsBtn").click(function () {
			//收集参数
			var owner = $("#create-owner").val();
			var source = $("#create-source").val();
			var fullname = $.trim($("#create-fullname").val());
			var appellation = $("#create-appellation").val();
			var job = $.trim($("#create-job").val());
			var email = $("#create-email").val();
			var mphone = $("#create-mphone").val();
			var customerId = $("#create-customerId").val();
			var description = $("#create-description").val();
			var contactSummary = $("#create-contactSummary").val();
			var nextContactTime = $("#create-nextContactTime").val();
			var address = $("#create-address").val();

			//表单验证
			if (fullname == "") {
				alert("姓名不能为空！");
				return;
			}
			var mphoneExp = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
			if (mphone != "") {
				if (!mphoneExp.test(mphone)) {
					alert("手机格式不符！")
					return;
				}
			}
			var emailExp = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
			if (email != "") {
				if (!emailExp.test(email)) {
					alert("邮箱格式不符！");
					return;
				}
			}

			//发送请求
			$.ajax({
				url:'workbench/customer/saveContacts.do',
				data:{
					owner:owner,
					source:source,
					fullname:fullname,
					appellation:appellation,
					job:job,
					mphone:mphone,
					email:email,
					customerId:customerId,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					description:description,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						//关闭
						$("#createContactsModal").modal("hide");
						//刷新数据
						var htmlStr = "";
						htmlStr += "<tr id=\"tr_"+data.retData.id+"\">";
						htmlStr += "<td><a href=\"../contacts/detail.jsp\" style=\"text-decoration: none;\">"+data.retData.fullname+"</a></td>";
						htmlStr += "<td>"+data.retData.email+"</td>";
						htmlStr += "<td>"+data.retData.mphone+"</td>";
						htmlStr += "<td><a name=\"deleteA\" contId=\""+data.retData.id+"\" href=\"javascript:void(0);\" style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>删除</a></td>";
						htmlStr += "</tr>";

						$("#tBody-cont").append(htmlStr);
					}else {
						alert(data.message);
						$("#createContactsModal").modal("show");
					}
				}
			});
		});

		//给联系人后的“删除”添加单击事件
		$("#tBody-cont").on("click","a[name='deleteA']",function () {
			//赋值
			var contactsId = $(this).attr("contId");
			$("#delete-contactsId").val(contactsId);
			//弹出
			$("#removeContactsModal").modal("show");
		});

		//给联系人模态窗口“删除”按钮添加单击事件
		$("#deleteContactsBtn").click(function () {
			//获取id
			var id = $("#delete-contactsId").val();
			//发送请求
			$.ajax({
				url:'workbench/customer/deleteContactsById.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						//关闭
						$("#removeContactsModal").modal("hide");
						//刷新数据
						$("#tr_"+id).remove();
					}else {
						alert(data.message);
						$("#removeContactsModal").modal("show");
					}
				}
			});
		});

	});
	
</script>

</head>
<body>

	<!-- 修改客户备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-noteContent" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="editCustomerRemarkBtn">更新</button>
				</div>
			</div>
		</div>
	</div>

    <!-- 删除交易的模态窗口 -->
    <div class="modal fade" id="removeTransactionModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 30%;">
			<input type="hidden" id="delete-tranId">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title">删除交易</h4>
                </div>
                <div class="modal-body">
                    <p>您确定要删除该交易吗？</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                    <button type="button" class="btn btn-danger" id="deleteTranBtn">删除</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 删除联系人的模态窗口 -->
	<div class="modal fade" id="removeContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<input type="hidden" id="delete-contactsId">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">删除联系人</h4>
				</div>
				<div class="modal-body">
					<p>您确定要删除该联系人吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-danger" id="deleteContactsBtn">删除</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找市场活动模态窗口 -->
	<div class="modal fade" id="findMarketActivityModal" role="dialog" style="z-index: 1060">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
							<div class="form-group has-feedback">
								<input type="text" id="queryActivityTxt" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
								<span class="glyphicon glyphicon-search form-control-feedback"></span>
							</div>
						</form>
					</div>
					<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
						<tr style="color: #B3B3B3;">
							<td></td>
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
						</tr>
						</thead>
						<tbody id="tBody-activity">
						<%--<tr>
                            <td><input type="radio" name="activity"/></td>
                            <td>发传单</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                            <td>zhangsan</td>
                        </tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人模态窗口 -->
	<div class="modal fade" id="findContactsModal" role="dialog" style="z-index: 1060">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
							<div class="form-group has-feedback">
								<input type="text" id="queryContactsTxt" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
								<span class="glyphicon glyphicon-search form-control-feedback"></span>
							</div>
						</form>
					</div>
					<table id="activityTable1" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
						<tr style="color: #B3B3B3;">
							<td></td>
							<td>名称</td>
							<td>邮箱</td>
							<td>手机</td>
						</tr>
						</thead>
						<tbody id="tBody-contacts">
						<%--<tr>
                            <td><input type="radio" name="activity"/></td>
                            <td>李四</td>
                            <td>lisi@bjpowernode.com</td>
                            <td>12345678901</td>
                        </tr>--%>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<!-- 创建交易的模态窗口 -->
	<div class="modal fade" id="createTranModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createTranModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">创建交易</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="createTranForm">
						<div class="form-group">
							<label for="createTran-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="createTran-owner">
									<c:forEach items="${requestScope.userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
							<label for="createTran-money" class="col-sm-2 control-label">金额</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="createTran-money">
							</div>
						</div>

						<div class="form-group">
							<label for="createTran-name" class="col-sm-2 control-label">交易名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="createTran-name" value="${requestScope.customer.name}-">
							</div>
							<label for="createTran-expectedDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDate" id="createTran-expectedDate" readonly>
							</div>
						</div>

						<div class="form-group">
							<label for="createTran-customerName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="createTran-customerName" value="${requestScope.customer.name}" readonly>
							</div>
							<label for="createTran-stage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="createTran-stage">
									<option></option>
									<c:forEach items="${requestScope.stageList}" var="stage">
										<option value="${stage.id}">${stage.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>

						<div class="form-group">
							<label for="createTran-type" class="col-sm-2 control-label">类型</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="createTran-type">
									<option></option>
									<c:forEach items="${requestScope.typeList}" var="type">
										<option value="${type.id}">${type.value}</option>
									</c:forEach>
								</select>
							</div>
							<label for="createTran-possibility" class="col-sm-2 control-label">可能性</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="createTran-possibility" readonly>
							</div>
						</div>

						<div class="form-group">
							<label for="createTran-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="createTran-source">
									<option></option>
									<c:forEach items="${requestScope.sourceList}" var="source">
										<option value="${source.id}">${source.value}</option>
									</c:forEach>
								</select>
							</div>
							<label for="createTran-activityName" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="queryActivityA"><span class="glyphicon glyphicon-search"></span></a></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="hidden" id="createTran-activityId">
								<input type="text" class="form-control" id="createTran-activityName" placeholder="点击左边“搜索”图标进行搜索">
							</div>
						</div>

						<div class="form-group">
							<label for="createTran-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" id="queryContactsA"><span class="glyphicon glyphicon-search"></span></a></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="hidden" id="createTran-contactsId">
								<input type="text" class="form-control" id="createTran-contactsName" placeholder="点击左边“搜索”图标进行搜索">
							</div>
						</div>

						<div class="form-group">
							<label for="createTran-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 70%;">
								<textarea class="form-control" rows="3" id="createTran-description"></textarea>
							</div>
						</div>

						<div class="form-group">
							<label for="createTran-contactSummary" class="col-sm-2 control-label">联系纪要</label>
							<div class="col-sm-10" style="width: 70%;">
								<textarea class="form-control" rows="3" id="createTran-contactSummary"></textarea>
							</div>
						</div>

						<div class="form-group">
							<label for="createTran-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control myDate" id="createTran-nextContactTime" readonly>
							</div>
						</div>

					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateTranBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="createContactsForm">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
									<c:forEach items="${requestScope.userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
							<label for="create-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
								  <option></option>
									<c:forEach items="${requestScope.sourceList}" var="source">
										<option value="${source.id}">${source.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
									<c:forEach items="${requestScope.appellationList}" var="app">
										<option value="${app.id}">${app.value}</option>
									</c:forEach>
								</select>
							</div>
							
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="hidden" id="create-customerId" value="${requestScope.customer.id}">
								<input type="text" class="form-control" id="create-customerName" value="${requestScope.customer.name}" readonly>
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control" id="create-nextContactTime">
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateContactsBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${requestScope.customer.name}<small><a href="<%=request.getScheme()+"://"%>${requestScope.customer.website}" target="_blank">${requestScope.customer.website}</a></small></h3>
		</div>
	</div>
	
	<br/>
	<br/>
	<br/>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.customer.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.customer.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${requestScope.customer.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${requestScope.customer.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 40px;">
            <div style="width: 300px; color: gray;">联系纪要</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${requestScope.customer.contactSummary}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
        <div style="position: relative; left: 40px; height: 30px; top: 50px;">
            <div style="width: 300px; color: gray;">下次联系时间</div>
            <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.nextContactTime}</b></div>
            <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
        </div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${requestScope.customer.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 70px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${requestScope.customer.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkDivList" style="position: relative; top: 10px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<c:forEach items="${requestScope.remarkList}" var="remark">
			<div class="remarkDiv" id="div_${remark.id}" style="height: 60px;">
				<img title="${remark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
				<div style="position: relative; top: -40px; left: 40px;" >
					<h5>${remark.noteContent}</h5>
					<font color="gray">客户</font> <font color="gray">-</font> <b>${requestScope.customer.name}</b> <small style="color: gray;"> ${remark.editFlag=='0'?remark.createTime:remark.editTime} 由${remark.editFlag=='0'?remark.createBy:remark.editBy}${remark.editFlag=='0'?"创建":"修改"}</small>
					<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
						<a class="myHref" name="editA" remarkId="${remark.id}" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a class="myHref" name="deleteA" remarkId="${remark.id}" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
					</div>
				</div>
			</div>
		</c:forEach>

		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button id="saveCustomerRemarkBtn" type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable2" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="tBody-tran">
						<c:forEach items="${requestScope.tranList}" var="tran">
							<!-- 加载possibility配置文件 -->
							<fmt:setBundle basename="possibility" var="possibility" />
							<!-- 读取配置值，并赋值给变量 -->
							<fmt:message key="${tran.stage}" var="stage" bundle="${possibility}" />
							<tr id="tr_${tran.id}">
								<td><a href="../transaction/detail.jsp" style="text-decoration: none;">${tran.name}</a></td>
								<td>${tran.money}</td>
								<td>${tran.stage}</td>
								<td>${stage}</td>
								<td>${tran.expectedDate}</td>
								<td>${tran.type}</td>
								<td><a name="deleteA" tranId="${tran.id}" href="javascript:void(0);" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
							</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>
			
			<div>
				<a id="createTranA" href="javascript:void(0);" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>
		</div>
	</div>
	
	<!-- 联系人 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>联系人</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>邮箱</td>
							<td>手机</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="tBody-cont">
						<c:forEach items="${requestScope.contactsList}" var="cont">
							<tr id="tr_${cont.id}">
								<td><a href="../contacts/detail.jsp" style="text-decoration: none;">${cont.fullname}</a></td>
								<td>${cont.email}</td>
								<td>${cont.mphone}</td>
								<td><a name="deleteA" contId="${cont.id}" href="javascript:void(0);" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
							</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" id="createContactsA" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
			</div>
		</div>
	</div>
	
	<div style="height: 200px;"></div>
</body>
</html>