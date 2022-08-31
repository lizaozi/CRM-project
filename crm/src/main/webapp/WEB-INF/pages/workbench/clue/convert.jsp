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
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>


<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">
	$(function(){
		$("#isCreateTransaction").click(function(){
			if(this.checked){
				$("#create-transaction2").show(200);
			}else{
				$("#create-transaction2").hide(200);
			}
		});

		//给“搜索”按钮添加单击事件
		$("#searchActivityA").click(function () {
			//初始化
			/*$("#searchActivityByNameTxt").val("");
			$("#tBody").html("");*/
			//弹出模态窗口
			$("#searchActivityModal").modal("show");
		});

		//给“市场活动搜索框”添加键盘弹起事件
		$("#searchActivityByNameTxt").keyup(function () {
			//收集参数
			var activityName = $("#searchActivityByNameTxt").val();
			var clueId = '${requestScope.clue.id}';
			//发送请求
			$.ajax({
				url:'workbench/clue/queryActivityForConvertByNameClueId.do',
				data:{
					activityName:activityName,
					clueId:clueId
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					//遍历动态显示数据
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
					$("#tBody").html(htmlStr);
				}
			});
		});

		//给市场活动”单选框“添加单击事件
		$("#tBody").on("click","input[type='radio']",function () {
			//收集参数
			var activityId = this.value;
			var activityName = $(this).attr("activityName");
			//关闭模态窗口
			$("#searchActivityModal").modal("hide");
			//给”市场活动源“下方隐藏域赋值
			$("#activityId").val(activityId);
			//在”市场活动源“下方显示市场活动名称
			$("#activity").val(activityName);
		});

		//给“预计成交日期”加上日历
		$("#expectedDate").datetimepicker({
			language:'zh-CN',
			format:'yyyy-mm-dd',
			minView:'month',
			initialDate:new Date(),
			autoclose:true,
			todayBtn:true,
			clearBtn:true
		});

		//给“转换”按钮添加单击事件
		$("#saveConvertClueBtn").click(function () {
			//收集参数
			var clueId = '${requestScope.clue.id}';
			var money = $.trim($("#money").val());
			var name = $("#name").val();
			var expectedDate = $("#expectedDate").val();
			var stage = $("#stage").val();
			var activityId = $("#activityId").val();
			var isCreateTran = $("#isCreateTransaction").prop("checked");

			//表单验证
			if (isCreateTran) {
				var moneyExp = /^(([1-9]\d*)|0)$/;
				if (!moneyExp.test(money)) {
					alert("金额只能是非负整数！");
					return;
				}
				if (name == "") {
					alert("交易名称不能为空！");
					return;
				}
				if (expectedDate == "") {
					alert("预计成交日期不能为空！");
					return;
				}
				if (stage == "") {
					alert("请选择阶段！");
					return;
				}
				if (activityId == "") {
					alert("请选择市场活动源！");
					return;
				}
			}
			//发送请求
			$.ajax({
				url:'workbench/clue/saveConvertClue.do',
				data:{
					clueId:clueId,
					money:money,
					name:name,
					expectedDate:expectedDate,
					stage:stage,
					activityId:activityId,
					isCreateTran:isCreateTran
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						//跳转线索主页面
						window.location.href="workbench/clue/index.do";
					}else {
						alert(data.message);
					}
				}
			});
		});
	});
</script>

</head>
<body>
	
	<!-- 搜索市场活动的模态窗口 -->
	<div class="modal fade" id="searchActivityModal" role="dialog" >
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">搜索市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input id="searchActivityByNameTxt" type="text" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="tBody">
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

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>

	<div id="title" class="page-header" style="position: relative; left: 20px;">
		<h4>转换线索 <small>${requestScope.clue.fullname}${requestScope.clue.appellation}-${requestScope.clue.company}</small></h4>
	</div>
	<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
		新建客户：${requestScope.clue.company}
	</div>
	<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
		新建联系人：${requestScope.clue.fullname}${requestScope.clue.appellation}
	</div>
	<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
		<input type="checkbox" id="isCreateTransaction"/>
		为客户创建交易
	</div>
	<div id="create-transaction2" style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;" >
	
		<form>
		  <div class="form-group" style="width: 400px; position: relative; left: 20px;">
		    <label for="money">金额</label>
		    <input type="text" class="form-control" id="money">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="name">交易名称</label>
		    <input type="text" class="form-control" id="name" value="${requestScope.clue.company}-">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="expectedDate">预计成交日期</label>
		    <input type="text" class="form-control" id="expectedDate">
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="stage">阶段</label>
		    <select id="stage"  class="form-control">
		    	<option></option>
				<c:forEach items="${requestScope.stageList}" var="stage">
					<option value="${stage.id}">${stage.value}</option>
				</c:forEach>
		    </select>
		  </div>
		  <div class="form-group" style="width: 400px;position: relative; left: 20px;">
		    <label for="activity">市场活动源&nbsp;&nbsp;<a id="searchActivityA" href="javascript:void(0);" style="text-decoration: none;"><span class="glyphicon glyphicon-search"></span></a></label>
		  	<input type="hidden" id="activityId">
		    <input type="text" class="form-control" id="activity" placeholder="点击上面搜索" readonly>
		  </div>
		</form>
		
	</div>
	
	<div id="owner" style="position: relative; left: 40px; height: 35px; top: 50px;">
		记录的所有者：<br>
		<b>${requestScope.clue.owner}</b>
	</div>
	<div id="operation" style="position: relative; left: 40px; height: 35px; top: 100px;">
		<input class="btn btn-primary" id="saveConvertClueBtn" type="button" value="转换">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="btn btn-default" type="button" value="取消">
	</div>
</body>
</html>