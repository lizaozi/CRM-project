<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

<script type="text/javascript">
	$(function () {
		//给“市场活动源”添加单击事件
		$("#queryActivityA").click(function () {
			//弹出模态窗口
			$("#findMarketActivityModal").modal("show");
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
			$("#create-activityId").val(activityId);
			$("#create-activitySrc").val(activityName);
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
			$("#create-contactsId").val(contactsId);
			$("#create-contactsName").val(contactsName);
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
		$("#create-transactionStage").change(function () {
			//获取参数
			var stageValue = $("#create-transactionStage option:selected").text();
			if (stageValue == "") {
				//清空可能性输入框
				$("#create-possibility").val("");
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
					$("#create-possibility").val(data);
				}
			})
		});

		//客户名称自动补全, typeahead插件用于下方显示列表
		$("#create-accountName").typeahead({
			source:function (jquery,process) {//jquery用于获取输入框内容，process用于将后台获取到的数据注入source
				$.ajax({
					url:'workbench/transaction/queryAllCustomerName.do',
					data:{
						customerName:jquery
					},
					type:'post',
					dataType:'json',
					success:function (data) {
						process(data);
					}
				});
			}
		});

		//给“保存”按钮添加单击事件
		$("#saveCreateTranBtn").click(function () {
			//获取参数
			var owner = $("#create-transactionOwner").val();
			var money = $.trim($("#create-amountOfMoney").val());
			var name = $.trim($("#create-transactionName").val());
			var expectedDate = $("#create-expectedClosingDate").val();
			var customerName = $.trim($("#create-accountName").val());
			var stage = $("#create-transactionStage").val();
			var source = $("#create-clueSource").val();
			var type = $("#create-transactionType").val();
			var activityId = $("#create-activityId").val();
			var activityName = $("#create-activitySrc").val();
			var contactsId = $("#create-contactsId").val();
			var contactsName = $("#create-contactsName").val();
			var description= $("#create-describe").val();
			var contactSummary = $("#create-contactSummary").val();
			var nextContactTime = $("#create-nextContactTime").val();

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
						//跳转到交易主页
						window.location.href="workbench/transaction/index.do";
					}else {
						alert(data.message);
					}
				}
			});

		});

		//给“取消”按钮添加单击事件
		$("#cancelCreateTranBtn").click(function () {
			window.location.href="workbench/transaction/index.do";
		});

	});
</script>
</head>
<body>

	<!-- 查找市场活动模态窗口 -->
	<div class="modal fade" id="findMarketActivityModal" role="dialog">
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
	<div class="modal fade" id="findContactsModal" role="dialog">
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
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
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
	
	
	<div style="position:  relative; left: 30px;">
		<h3>创建交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="saveCreateTranBtn">保存</button>
			<button type="button" class="btn btn-default" id="cancelCreateTranBtn">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="create-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionOwner">
				 <c:forEach items="${requestScope.userList}" var="user">
					 <option value="${user.id}">${user.name}</option>
				 </c:forEach>
				</select>
			</div>
			<label for="create-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-amountOfMoney">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionName" class="col-sm-2 control-label">交易名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-transactionName">
			</div>
			<label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control myDate" id="create-expectedClosingDate" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-accountName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-accountName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="create-transactionStage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="create-transactionStage">
			  	<option></option>
			  	<c:forEach items="${requestScope.stageList}" var="stage">
					<option value="${stage.id}">${stage.value}</option>
				</c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-transactionType">
				  <option></option>
				  <c:forEach items="${requestScope.tranTypeList}" var="type">
					  <option value="${type.id}">${type.value}</option>
				  </c:forEach>
				</select>
			</div>
			<label for="create-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="create-possibility" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="create-clueSource">
				  <option></option>
				  <c:forEach items="${requestScope.sourceList}" var="source">
					  <option value="${source.id}">${source.value}</option>
				  </c:forEach>
				</select>
			</div>
			<label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" id="queryActivityA"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="hidden" id="create-activityId">
				<input type="text" class="form-control" id="create-activitySrc" placeholder="点击左边“搜索”图标进行搜索">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" id="queryContactsA"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="hidden" id="create-contactsId">
				<input type="text" class="form-control" id="create-contactsName" placeholder="点击左边“搜索”图标进行搜索">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-describe"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control myDate" id="create-nextContactTime" readonly>
			</div>
		</div>
		
	</form>
</body>
</html>