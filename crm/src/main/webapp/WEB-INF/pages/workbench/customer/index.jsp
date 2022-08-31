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
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">

	//搜索框参数
	var query_name = "";
	var query_owner = "";
	var query_phone = "";
	var query_website = "";

	$(function(){
		
		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		//当客户主页面加载完成，查询所有数据的第一页以及所有数据的总条数,默认每页显示5条
		queryCustomerByConditionForPage(1,5);

		//给“查询”按钮添加单击事件
		$("#queryBtn").click(function () {
			//获取搜索框参数
			query_name = $.trim($("#query-name").val());
			query_owner = $.trim($("#query-owner").val());
			query_phone = $.trim($("#query-phone").val());
			query_website= $.trim($("#query-website").val());

			queryCustomerByConditionForPage(1,$("#page").bs_pagination('getOption','rowsPerPage'));
		});

		//给“创建”按钮添加单击事件
		$("#createCustomerBtn").click(function () {
			//初始化
			$("#createCustomerForm").get(0).reset();
			//弹出窗口
			$("#createCustomerModal").modal("show");
		});

		//给“保存”按钮添加单击事件
		$("#saveCreateCustomerBtn").click(function () {
			//收集参数
			var owner = $("#create-owner").val();
			var name = $.trim($("#create-name").val());
			var website = $.trim($("#create-website").val());
			var phone = $.trim($("#create-phone").val());
			var description = $("#create-description").val();
			var contactSummary = $("#create-contactSummary").val();
			var nextContactTime = $("#create-nextContactTime").val();
			var address = $("#create-address").val();
			//表单验证
			if (name == "") {
				alert("名称不能为空！");
				return;
			}
			//发送请求
			$.ajax({
				url:'workbench/customer/saveCreateCustomer.do',
				data:{
					owner:owner,
					name:name,
					website:website,
					phone:phone,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						$("#createCustomerModal").modal("hide");

						//清空搜索框,防止带参数搜索
						query_name = "";
						query_owner = "";
						query_phone = "";
						query_website = "";
						$("#query-name").val("");
						$("#query-owner").val("");
						$("#query-phone").val("");
						$("#query-website").val("");

						//刷新列表
						queryCustomerByConditionForPage(1,$("#page").bs_pagination('getOption','rowsPerPage'));
					}else {
						alert(data.message);
						$("#createCustomerModal").modal("show");
					}
				}
			});

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

		//给“全选”框添加单击事件
		$("#checkAll").click(function () {
			$("tBody input[type='checkbox']").prop("checked",this.checked);
		});

		$("#tBody").on("click","input[type='checkbox']",function () {
			//如果至少有一个勾选框没有勾选，全选框则取消勾选
			if ($("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size()){
				$("#checkAll").prop("checked",true);
			}else {
				$("#checkAll").prop("checked",false);
			}
		});

		//给“删除”按钮添加单击事件
		$("#deleteCustomerBtn").click(function () {
			//收集id
			var checkId = $("#tBody input[type='checkbox']:checked");
			if (checkId.size() == 0) {
				alert("请选择需要删除的客户！");
				return;
			}
			if (window.confirm("确定要删除吗？")) {
				var id = "";
				$.each(checkId,function (index,obj) {
					id += "id=" + this.value + "&";//id=xxx&...&id=xxx&
				});
				id = id.substr(0,id.length-1);//id=xxx&...&id=xxx

				//发送请求
				$.ajax({
					url:'workbench/customer/deleteCustomerByIds.do',
					data:id,
					type:'post',
					dataType:'json',
					success:function (data) {
						if (data.code == "1") {
							//刷新列表
							queryCustomerByConditionForPage(1,$("#page").bs_pagination('getOption','rowsPerPage'));
						}else {
							alert(data.message);
						}
					}
				});
			}
		});

		//给“修改”按钮添加单击事件
		$("#editCustomerBtn").click(function () {
			//收集id
			var checkId = $("#tBody input[type='checkbox']:checked");
			if (checkId.size() == 0) {
				alert("请选择需要修改的客户！");
				return;
			}
			if (checkId.size() > 1) {
				alert("每次只能修改一条数据！");
				return;
			}
			var id = checkId[0].value;
			//发送请求
			$.ajax({
				url:'workbench/customer/queryCustomerById.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					//回显
					$("#edit-id").val(data.id);
					$("#edit-owner").val(data.owner);
					$("#edit-name").val(data.name);
					$("#edit-website").val(data.website);
					$("#edit-phone").val(data.phone);
					$("#edit-description").val(data.description);
					$("#edit-contactSummary").val(data.contactSummary);
					$("#edit-nextContactTime").val(data.nextContactTime);
					$("#edit-address").val(data.address);

					$("#editCustomerModal").modal("show");
				}
			});
		});

		//给“更新”按钮添加单击事件
		$("#saveEditCustomerBtn").click(function () {
			//收集参数
			var id = $("#edit-id").val();
			var owner = $("#edit-owner").val();
			var name = $("#edit-name").val();
			var website = $("#edit-website").val();
			var phone = $("#edit-phone").val();
			var description = $("#edit-description").val();
			var contactSummary = $("#edit-contactSummary").val();
			var nextContactTime = $("#edit-nextContactTime").val();
			var address = $("#edit-address").val();
			//发送
			$.ajax({
				url:'workbench/customer/saveEditCustomer.do',
				data:{
					id:id,
					owner:owner,
					name:name,
					website:website,
					phone:phone,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						$("#editCustomerModal").modal("hide");
						//刷新数据
						queryCustomerByConditionForPage($("#page").bs_pagination('getOption','currentPage'),$("#page").bs_pagination('getOption','rowsPerPage'));
					}else {
						alert(data.message);
						$("#editCustomerModal").modal("show");
					}
				}
			});
		});

	});

	//封装函数，用于分页和显示数据
	function queryCustomerByConditionForPage(pageNo,pageSize) {
		//收集参数

		//发送请求
		$.ajax({
			url:'workbench/customer/queryCustomerByConditionForPage.do',
			data:{
				name:query_name,
				owner:query_owner,
				phone:query_phone,
				website:query_website,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType:'json',
			success:function (data) {
				//动态显示客户数据
				var htmlStr = "";
				$.each(data.customerList,function (index,obj) {
					htmlStr += "<tr>";
					htmlStr += "<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
					htmlStr += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/customer/detailCustomer.do?id="+obj.id+"';\">"+obj.name+"</a></td>";
					htmlStr += "<td>"+obj.owner+"</td>";
					htmlStr += "<td>"+obj.phone+"</td>";
					htmlStr += "<td>"+obj.website+"</td>";
					htmlStr += "</tr>";
				});
				$("#tBody").html(htmlStr);

				//给“全选框”取消勾选
				$("#checkAll").prop("checked",false);

				//计算总页数
				var totalPages = 1;
				if (data.totalRows % pageSize == 0) {
					totalPages = data.totalRows / pageSize;
				}else {
					totalPages = parseInt(data.totalRows / pageSize) + 1;
				}
				//分页
				$("#page").bs_pagination({
					currentPage:pageNo,
					totalRows:data.totalRows,
					totalPages:totalPages,
					rowsPerPage:pageSize,
					visiblePageLinks:5,
					showGoToPage:true,
					showRowsInfo:true,
					showRowsPerPage:true,

					//用户每次切换页号，都会自动触发该函数
					//每次返回切换页号之后的pageNo和pageSize
					onChangePage:function (event,pageObj) {
						//手动刷新列表
						queryCustomerByConditionForPage(pageObj.currentPage,pageObj.rowsPerPage);
					}
				});
			}
		});
	}
	
</script>
</head>
<body>

	<!-- 创建客户的模态窗口 -->
	<div class="modal fade" id="createCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="createCustomerForm">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
								 <c:forEach items="${requestScope.sessionUser}" var="user">
									 <option value="${user.id}">${user.name}</option>
								 </c:forEach>
								</select>
							</div>
							<label for="create-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-name">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-website">
                            </div>
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
						</div>
						<div class="form-group">
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
                                    <input type="text" class="form-control myDate" id="create-nextContactTime">
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
					<button type="button" class="btn btn-primary" id="saveCreateCustomerBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改客户的模态窗口 -->
	<div class="modal fade" id="editCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
									<c:forEach items="${requestScope.sessionUser}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-name" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
                            </div>
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" value="010-84846003">
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
                                    <input type="text" class="form-control myDate" id="edit-nextContactTime">
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address">北京大兴大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveEditCustomerBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	

	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>客户列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="query-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="query-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="query-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司网站</div>
				      <input class="form-control" type="text" id="query-website">
				    </div>
				  </div>
				  
				  <button type="button" id="queryBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createCustomerBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editCustomerBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteCustomerBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>名称</td>
							<td>所有者</td>
							<td>公司座机</td>
							<td>公司网站</td>
						</tr>
					</thead>
					<tbody  id="tBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点</a></td>
							<td>zhangsan</td>
							<td>010-84846003</td>
							<td>http://www.bjpowernode.com</td>
						</tr>--%>
					</tbody>
				</table>
				<%--分页插件--%>
				<div id="page"></div>
			</div>
			
			<%--<div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="totalRowsB">50</b>条记录</button>
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