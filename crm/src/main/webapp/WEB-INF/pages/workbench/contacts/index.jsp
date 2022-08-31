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
<link href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

<script type="text/javascript">

	var query_owner = "";
	var query_fullname = "";
	var query_customerName = "";
	var query_source = "";

	$(function(){
		
		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		//加载联系人数据
		queryContactsByConditionForPage(1,5);

		//给点击”查询“按钮添加单击事件
		$("#queryContactsBtn").click(function () {
			//收集参数
			query_owner = $.trim($("#query-owner").val());
			query_fullname = $.trim($("#query-fullname").val());
			query_customerName = $.trim($("#query-customerName").val());
			query_source = $("#query-source").val();

			queryContactsByConditionForPage(1,$("#page").bs_pagination('getOption','rowsPerPage'));
		});

		//给”全选“框添加单击事件
		$("#checkAll").click(function () {
			$("#tBody input[type='checkbox']").prop("checked",this.checked);
		});

		$("#tBody").on("click","input[type='checkbox']",function () {
			//如果有至少一个没有勾选，则取消全选
			if ($("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size()) {
				$("#checkAll").prop("checked",true);
			}else {
				$("#checkAll").prop("checked",false);
			}
		});

		//日历插件
		$(".myDate").datetimepicker({
			language:'zh-CN',
			initialDate:new Date(),
			format:'yyyy-mm-dd',
			minView:'month',
			autoclose:true,
			todayBtn:true,
			clearBtn:true,
			pickerPosition:'top-right'//在输入框上方显示
		});

		//创建联系人
		$("#createContactsBtn").click(function () {
			//清空表单
			$("#createContactsForm")[0].reset();
			//弹出模态窗口
			$("#createContactsModal").modal("show");
		});

		//客户名称自动补全, typeahead插件用于下方显示列表
		$("#create-customerName").typeahead({
			source: function (jquery,process) {//jquery用于获取输入框内容，process用于将后台获取到的数据注入source
				$.ajax({
					url:'workbench/contacts/queryAllCustomerName.do',
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

		//给“保存”按钮添加事件
		$("#saveCreateContactsBtn").click(function () {
			//收集参数
			var owner = $("#create-owner").val();
			var source = $("#create-source").val();
			var fullname = $.trim($("#create-fullname").val());
			var appellation = $("#create-appellation").val();
			var job = $.trim($("#create-job").val());
			var mphone = $.trim($("#create-mphone").val());
			var email = $.trim($("#create-email").val());
			var customerName = $("#create-customerName").val();
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
				url:'workbench/contacts/saveCreateContacts.do',
				data:{
					owner:owner,
					source:source,
					fullname:fullname,
					appellation:appellation,
					job:job,
					email:email,
					mphone:mphone,
					customerName:customerName,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						//关闭
						$("#createContactsModal").modal("hide");
						//清空搜索框参数
						query_owner = "";
						query_fullname = "";
						query_customerName = "";
						query_source = "";
						$("#query-owner").val("");
						$("#query-fullname").val("");
						$("#query-customerName").val("");
						$("#query-source").val("");

						//刷新列表
						queryContactsByConditionForPage(1,$("#page").bs_pagination('getOption','rowsPerPage'));
					}else {
						alert(data.message);
						$("#createContactsModal").modal("show");
					}
				}
			});
		});

		//给“删除”按钮添加事件
		$("#deleteContactsBtn").click(function () {
			//获取id
			var checkIds = $("#tBody input[type='checkbox']:checked");
			if (checkIds.size() == 0) {
				alert("请选择需要删除的联系人");
				return;
			}
			if (window.confirm("确认要删除该联系人吗？")) {
				var id = "";
				$.each(checkIds,function (index,obj) {
					id += "id=" + obj.value + "&";//id=xxx&...&id=xxx&
				});
				//截取
				id = id.substr(0,id.length-1);//id=xxx&...&id=xxx
				//发送请求
				$.ajax({
					url:'workbench/contacts/deleteContactsByIds.do',
					data:id,
					type:'post',
					dataType:'json',
					success:function (data) {
						if (data.code == "1") {
							//刷新列表
							queryContactsByConditionForPage(1,$("#page").bs_pagination('getOption','rowsPerPage'));
						}else {
							alert(data.message);
						}
					}
				});
			}

		});

		//给“修改”按钮添加单击事件
		$("#editContactsBtn").click(function () {
			//获取id
			var checkIds = $("#tBody input[type='checkbox']:checked");
			if (checkIds.size() == 0) {
				alert("请选择需要修改的联系人");
				return;
			}
			if (checkIds.size() > 1) {
				alert("每次只能修改一条数据");
				return;
			}
			var id = checkIds[0].value;

			//发送请求
			$.ajax({
				url:'workbench/contacts/queryContactsById.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					//数据回显
					$("#edit-id").val(data.id);
					$("#edit-owner").val(data.owner);
					$("#edit-source").val(data.source);
					$("#edit-fullname").val(data.fullname);
					$("#edit-appellation").val(data.appellation);
					$("#edit-job").val(data.job);
					$("#edit-mphone").val(data.mphone);
					$("#edit-email").val(data.email);
					$("#edit-customerName").val(data.customerName);
					$("#edit-customerId").val(data.customerId);
					$("#edit-description").val(data.description);
					$("#edit-contactSummary").val(data.contactSummary);
					$("#edit-nextContactTime").val(data.nextContactTime);
					$("#edit-address").val(data.address);

					//弹出
					$("#editContactsModal").modal("show");
				}
			});
		});

		//客户名称自动补全, typeahead插件用于下方显示列表
		$("#edit-customerName").typeahead({
			source: function (jquery,process) {//jquery用于获取输入框内容，process用于将后台获取到的数据注入source
				$.ajax({
					url:'workbench/contacts/queryAllCustomerName.do',
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

		//给“更新”按钮添加单击事件
		$("#saveEditContactsBtn").click(function () {
			//收集参数
			var id = $("#edit-id").val();
			var owner = $("#edit-owner").val();
			var source = $("#edit-source").val();
			var fullname = $("#edit-fullname").val();
			var appellation = $("#edit-appellation").val();
			var job = $("#edit-job").val();
			var mphone = $("#edit-mphone").val();
			var email = $("#edit-email").val();
			var customerName = $("#edit-customerName").val();
			var description = $("#edit-description").val();
			var contactSummary = $("#edit-contactSummary").val();
			var nextContactTime = $("#edit-nextContactTime").val();
			var address = $("#edit-address").val();

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
				url:'workbench/contacts/saveEditContacts.do',
				data:{
					id:id,
					owner:owner,
					source:source,
					fullname:fullname,
					appellation:appellation,
					job:job,
					mphone:mphone,
					email:email,
					customerName:customerName,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						//关闭
						$("#editContactsModal").modal("hide");
						//刷新
						queryContactsByConditionForPage($("#page").bs_pagination('getOption','currentPage'),$("#page").bs_pagination('getOption','rowsPerPage'));
					}else {
						alert(data.message);
						$("#editContactsModal").modal("show");
					}
				}
			});
		});

	});

	//封装成函数
	function queryContactsByConditionForPage(pageNo,pageSize) {
		//收集参数
		/*var owner = $.trim($("#query-owner").val());
		var fullname = $.trim($("#query-fullname").val());
		var customerName = $.trim($("#query-customerName").val());
		var source = $("#query-source").val();*/

		//发送请求
		$.ajax({
			url:'workbench/contacts/queryContactsByConditionForPage.do',
			data:{
				owner:query_owner,
				fullname:query_fullname,
				customerName:query_customerName,
				source:query_source,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType:'json',
			success:function (data) {
				var htmlStr = "";
				//遍历显示数据
				$.each(data.contactsList,function (index,obj) {
					htmlStr += "<tr id=\"tr_"+obj.id+"\">";
					htmlStr += "<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
					htmlStr += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/contacts/detailContacts.do?id="+obj.id+"';\">"+obj.fullname+"</a></td>";
					htmlStr += "<td>"+obj.customerId+"</td>";
					htmlStr += "<td>"+obj.owner+"</td>";
					htmlStr += "<td>"+obj.source+"</td>";
					htmlStr += "</tr>";
				});

				//动态显示数据
				$("#tBody").html(htmlStr);

				//给”全选“框取消
				$("#checkAll").prop("checked",false);

				//计算页数
				var totalPages = 1;
				if (data.totalRows % pageSize == 0) {
					totalPages = data.totalRows / pageSize;
				}else {
					totalPages = parseInt((data.totalRows / pageSize)) + 1;
				}

				//分页插件
				$("#page").bs_pagination({
					totalRows:data.totalRows,
					totalPages:totalPages,
					rowsPerPage:pageSize,
					currentPage:pageNo,
					visiblePageLinks:5,
					showGoToPage:true,
					showRowsInfo:true,
					showRowsPerPage:true,

					//用户每次切换页号，都会自动触发该函数
					//每次返回切换页号之后的pageNo和pageSize
					onChangePage:function (event,pageObj) {
						//手动刷新列表
						queryContactsByConditionForPage(pageObj.currentPage,pageObj.rowsPerPage);
					}
				});
			}
		});
	}
	
</script>
</head>
<body>

	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
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
								<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
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
									<input type="text" class="form-control myDate" id="create-nextContactTime" readonly>
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
	
	<!-- 修改联系人的模态窗口 -->
	<div class="modal fade" id="editContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
								  <c:forEach items="${requestScope.userList}" var="user">
									  <option value="${user.id}">${user.name}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="edit-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
								  <option></option>
								  <c:forEach items="${requestScope.sourceList}" var="source">
									  <option value="${source.id}">${source.value}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname" value="李四">
							</div>
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
								  <option></option>
								  <c:forEach items="${requestScope.appellationList}" var="app">
									  <option value="${app.id}">${app.value}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" value="CTO">
							</div>
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" value="12345678901">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
							</div>
							<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="hidden" id="edit-customerId">
								<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>

						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control myDate" id="edit-nextContactTime" readonly>
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveEditContactsBtn">更新</button>
				</div>
			</div>
		</div>
	</div>

	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>联系人列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="query-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">姓名</div>
				      <input class="form-control" type="text" id="query-fullname">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="query-customerName">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="query-source">
						  <option></option>
						  <c:forEach items="${requestScope.sourceList}" var="source">
							  <option value="${source.id}">${source.value}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>

				  <button type="button" class="btn btn-default" id="queryContactsBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createContactsBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editContactsBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteContactsBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 20px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>姓名</td>
							<td>客户名称</td>
							<td>所有者</td>
							<td>来源</td>
						</tr>
					</thead>
					<tbody id="tBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">李四</a></td>
							<td>动力节点</td>
							<td>zhangsan</td>
							<td>广告</td>
						</tr>--%>
					</tbody>
				</table>
				<%--用于分页插件--%>
				<div id="page"></div>
			</div>
			
			<%--<div style="height: 50px; position: relative;top: 10px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>
			</div>--%>
			
		</div>
		
	</div>
</body>
</html>