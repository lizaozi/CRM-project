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
<link href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css" type="text/css" rel="stylesheet"/>

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">
	//搜索框参数
	var query_fullname = "";
	var query_company = "";
	var query_phone = "";
	var query_source = "";
	var query_owner = "";
	var query_mphone = "";
	var query_state = "";

	$(function(){
		//弹出创建线索模态窗口
		$("#createClueBtn").click(function () {
			//重置表单
			$("#createClueForm")[0].reset();
			//弹出
			$("#createClueModal").modal("show");
		});

		//给“保存”线索按钮添加单击事件
		$("#saveCreateClueBtn").click(function () {
			//收集参数
			var fullname         = $.trim($("#create-fullname").val());
			var appellation      = $("#create-appellation").val();
			var owner            = $("#create-owner").val();
			var company          = $.trim($("#create-company").val());
			var job              = $.trim($("#create-job").val());
			var email            = $.trim($("#create-email").val());
			var phone            = $.trim($("#create-phone").val());
			var website          = $.trim($("#create-website").val());
			var mphone           = $.trim($("#create-mphone").val());
			var state            = $("#create-status").val();
			var source           = $("#create-source").val();
			var description      = $.trim($("#create-describe").val());
			var contact_summary  = $.trim($("#create-contactSummary").val());
			var next_contact_time= $.trim($("#create-nextContactTime").val());
			var address          = $("#create-address").val();

			//表单验证
			if (company == ""){
				alert("公司名称不能为空！");
				return;
			}
			if (fullname == "") {
				alert("姓名不能为空！");
				return;
			}
			if (email != "") {
				var emailExp = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
				if (!emailExp.test(email)) {
					alert("邮箱格式不符合！");
					return;
				}
			}
			if (mphone != "") {
				var mphoneExp = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
				if (!mphoneExp.test(mphone)) {
					alert("手机号码格式不符！");
					return;
				}
			}

			//发送请求
			$.ajax({
				url:'workbench/clue/saveCreateClue.do',
				data:{
					fullname:fullname,
					appellation:appellation,
					owner:owner,
					company:company,
					job:job,
					email:email,
					phone:phone,
					website:website,
					mphone:mphone,
					state:state,
					source:source,
					description:description,
					contactSummary:contact_summary,
					nextContactTime:next_contact_time,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1"){
						$("#createClueModal").modal("hide");

						//重置并清空搜索框参数，防止带搜索框参数查询
						query_fullname = "";
						query_company = "";
						query_phone = "";
						query_source = "";
						query_owner = "";
						query_mphone = "";
						query_state = "";

						$("#query-fullname").val("");
						$("#query-company").val("");
						$("#query-phone").val("");
						$("#query-source").val("");
						$("#query-owner").val("");
						$("#query-mphone").val("");
						$("#query-state").val("");

						//刷新列表
						queryClueByConditionForPage(1,$("#page").bs_pagination('getOption','rowsPerPage'));
					}else {
						alert(data.message);
						$("#createClueModal").modal("show");
					}
				}
			});

		});

		//给”下次联系日期“加入日历插件
		$(".mDate").datetimepicker({
			language:'zh-CN',
			format:'yyyy-mm-dd',
			minView:'month',
			initialDate:new Date(),
			autoclose:true,
			todayBtn:true,
			clearBtn:true,
			pickerPosition:'top-right'//在输入框上方显示
		});

		//当线索主页面加载完成，查询所有数据的第一页以及所有数据的总条数,默认每页显示5条
		queryClueByConditionForPage(1,5);

		//给”查询“按钮添加单击事件
		$("#queryClueBtn").click(function () {
			//只有点击“查询”按钮时才给搜索框参数赋值
			query_fullname = $("#query-fullname").val();
			query_company = $("#query-company").val();
			query_phone = $("#query-phone").val();
			query_source = $("#query-source").val();
			query_owner = $("#query-owner").val();
			query_mphone = $("#query-mphone").val();
			query_state = $("#query-state").val();

			//查询所有符合条件的数据第一页以及所有符合条件的总条数
			queryClueByConditionForPage(1,$("#page").bs_pagination('getOption','rowsPerPage'));
		});

		//给“全选”按钮添加单击事件
		$("#checkAll").click(function () {
			//获取全选框的状态
			$("#tBody input[type='checkbox']").prop("checked",this.checked);
		});

		//如果列表中的所有checkbox都选中，则“全选”按钮也选中
		$("#tBody").on("click","input[type='checkbox']",function () {
			if ($("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size()) {
				$("#checkAll").prop("checked",true);
			}else {
				$("#checkAll").prop("checked",false);
			}
		});

		//给“删除”按钮添加单击事件
		$("#deleteClueBtn").click(function () {
			//收集id
			var checkIds = $("#tBody input[type='checkbox']:checked");
			if (checkIds.size() == 0) {
				alert("请选择需要删除的线索！");
				return;
			}
			if (window.confirm("确定要删除吗？")) {
				var checkId = "";
				$.each(checkIds,function (index,obj) {
					checkId += "id=" + obj.value + "&";//id=xxx&id=xxx&...&id=xxx&
				});
				//截取
				var id = checkId.substr(0,checkId.length-1);//id=xxx&id=xxx&...&id=xxx
				//发送请求
				$.ajax({
					url:'workbench/clue/deleteClueByIds.do',
					data:id,
					type:'post',
					dataType:'json',
					success:function (data) {
						if (data.code == "1") {
							//刷新列表
							queryClueByConditionForPage(1,$("#page").bs_pagination('getOption','rowsPerPage'));
						}else {
							alert(data.message);
						}
					}
				});
			}
		});

		//给“修改”按钮添加单击事件
		$("#editClueBtn").click(function () {
			//收集id
			var checkId = $("#tBody input[type='checkbox']:checked");
			if (checkId.size() == 0) {
				alert("请选择需要修改的线索！");
				return;
			}
			if (checkId.size() > 1) {
				alert("每次只能修改一条线索！");
				return;
			}
			var id = checkId[0].value;

			//发送请求
			$.ajax({
				url:'workbench/clue/queryClueById.do',
				data:{
					id:id
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					//数据回显
					$("#edit-id").val(data.id);
					$("#edit-owner").val(data.owner);
					$("#edit-appellation").val(data.appellation);
					$("#edit-fullname").val(data.fullname);
					$("#edit-company").val(data.company);
					$("#edit-job").val(data.job);
					$("#edit-email").val(data.email);
					$("#edit-phone").val(data.phone);
					$("#edit-website").val(data.website);
					$("#edit-mphone").val(data.mphone);
					$("#edit-source").val(data.source);
					$("#edit-state").val(data.state);
					$("#edit-description").val(data.description);
					$("#edit-contactSummary").val(data.contactSummary);
					$("#edit-nextContactTime").val(data.nextContactTime);
					$("#edit-address").val(data.address);

					//弹出模态窗口
					$("#editClueModal").modal("show");
				}
			});
		});

		//给“保存”按钮添加单击事件
		$("#saveEditClueBtn").click(function () {
			//收集参数
			var id = $("#edit-id").val();
			var owner = $("#edit-owner").val();
			var appellation = $("#edit-appellation").val();
			var fullname = $("#edit-fullname").val();
			var company = $("#edit-company").val();
			var job = $("#edit-job").val();
			var email = $("#edit-email").val();
			var phone = $("#edit-phone").val();
			var website = $("#edit-website").val();
			var mphone = $("#edit-mphone").val();
			var source = $("#edit-source").val();
			var state = $("#edit-state").val();
			var description = $("#edit-description").val();
			var contactSummary = $("#edit-contactSummary").val();
			var nextContactTime = $("#edit-nextContactTime").val();
			var address = $("#edit-address").val();

			//发送请求
			$.ajax({
				url:'workbench/clue/saveEditClue.do',
				data:{
					id:id,
					owner:owner,
					appellation:appellation,
					fullname:fullname,
					company:company,
					job:job,
					email:email,
					phone:phone,
					website:website,
					mphone:mphone,
					source:source,
					state:state,
					description:description,
					contactSummary:contactSummary,
					nextContactTime:nextContactTime,
					address:address
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						$("#editClueModal").modal("hide");
						//刷新数据
						queryClueByConditionForPage($("#page").bs_pagination('getOption','currentPage'),$("#page").bs_pagination('getOption','rowsPerPage'));
					}else {
						alert(data.message);
						$("#editClueModal").modal("show");
					}
				}
			});
		});



	});

	//封装成函数,查询线索并进行分页
	function queryClueByConditionForPage(pageNo,pageSize) {
		//发送请求
		$.ajax({
			url:'workbench/clue/queryClueByConditionForPage.do',
			data:{
				fullname:query_fullname,
				company:query_company,
				phone:query_phone,
				source:query_source,
				owner:query_owner,
				mphone:query_mphone,
				state:query_state,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType:'json',
			success:function (data) {
				//显示总条数
				//$("#totalRowsB").text(data.totalRows);

				//显示线索的列表
				//遍历clueList，拼接所有行数据
				var htmlStr = "";
				$.each(data.clueList,function (index,obj) {
					htmlStr += "<tr>";
					htmlStr += "<td><input type=\"checkbox\" value=\""+obj.id+"\"/></td>";
					htmlStr += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/clue/detailClue.do?id="+obj.id+"';\">"+obj.fullname+obj.appellation+"</a></td>";
					htmlStr += "<td>"+obj.company+"</td>";
					htmlStr += "<td>"+obj.phone+"</td>";
					htmlStr += "<td>"+obj.mphone+"</td>";
					htmlStr += "<td>"+obj.source+"</td>";
					htmlStr += "<td>"+obj.owner+"</td>";
					htmlStr += "<td>"+obj.state+"</td>";
					htmlStr += "</tr>";
				});
				$("#tBody").html(htmlStr);

				//取消“全选”按钮
				$("#checkAll").prop("checked",false);

				//计算总页数
				var totalPages = 1;
				if (data.totalRows % pageSize == 0) {
					totalPages = data.totalRows / pageSize;
				}else {
					totalPages = parseInt(data.totalRows / pageSize) + 1;
				}

				//分页插件
				$("#page").bs_pagination({
					currentPage:pageNo,
					rowsPerPage:pageSize,
					totalRows:data.totalRows,
					totalPages:totalPages,
					visiblePageLinks:5,
					showGoToPage:true,
					showRowsPerPage:true,
					showRowsInfo:true,

					//用户每次切换页号，都会自动触发该函数
					//每次返回切换页号之后的pageNo和pageSize
					onChangePage:function (event,pageObj){
						//刷新列表
						queryClueByConditionForPage(pageObj.currentPage,pageObj.rowsPerPage);
					}
				});
			}
		});
	}
	
</script>
</head>
<body>

	<!-- 创建线索的模态窗口 -->
	<div class="modal fade" id="createClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">创建线索</h4>
				</div>
				<div class="modal-body">
					<form id="createClueForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
									<c:forEach items="${requestScope.userList}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
							<label for="create-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
								  <c:forEach items="${requestScope.appellationList}" var="appellation">
									  <option value="${appellation.id}">${appellation.value}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
							<label for="create-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
							<label for="create-status" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-status">
								  <option></option>
								  <c:forEach items="${requestScope.clueStateList}" var="clue">
									  <option value="${clue.id}">${clue.value}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-source" class="col-sm-2 control-label">线索来源</label>
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
							<label for="create-describe" class="col-sm-2 control-label">线索描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
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
									<input type="text" class="form-control mDate" id="create-nextContactTime">
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
					<button type="button" class="btn btn-primary" id="saveCreateClueBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
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
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
								  <option></option>
									<c:forEach items="${requestScope.appellationList}" var="appellation">
										<option value="${appellation.id}">${appellation.value}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname" value="李四">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" value="CTO">
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" value="010-84846003">
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" value="12345678901">
							</div>
							<label for="edit-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-state">
								  <option></option>
									<c:forEach items="${requestScope.clueStateList}" var="clue">
										<option value="${clue.id}">${clue.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
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
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description">这是一条线索的描述信息</textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary">这个线索即将被转换</textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control mDate" id="edit-nextContactTime" value="2017-05-01">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address">北京大兴区大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveEditClueBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>线索列表</h3>
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
				      <input class="form-control" type="text" id="query-fullname">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司</div>
				      <input class="form-control" type="text" id="query-company">
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
				      <div class="input-group-addon">线索来源</div>
					  <select class="form-control" id="query-source">
					  	  <option></option>
						  <c:forEach items="${requestScope.sourceList}" var="source">
							  <option value="${source.id}">${source.value}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="query-owner">
				    </div>
				  </div>
				  
				  
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">手机</div>
				      <input class="form-control" type="text" id="query-mphone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索状态</div>
					  <select class="form-control" id="query-state">
					  	<option></option>
						  <c:forEach items="${requestScope.clueStateList}" var="clue">
							  <option value="${clue.id}">${clue.value}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>

				  <button type="button" class="btn btn-default" id="queryClueBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createClueBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editClueBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteClueBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 50px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>名称</td>
							<td>公司</td>
							<td>公司座机</td>
							<td>手机</td>
							<td>线索来源</td>
							<td>所有者</td>
							<td>线索状态</td>
						</tr>
					</thead>
					<tbody id="tBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">李四先生</a></td>
							<td>动力节点</td>
							<td>010-84846003</td>
							<td>12345678901</td>
							<td>广告</td>
							<td>zhangsan</td>
							<td>已联系</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">李四先生</a></td>
                            <td>动力节点</td>
                            <td>010-84846003</td>
                            <td>12345678901</td>
                            <td>广告</td>
                            <td>zhangsan</td>
                            <td>已联系</td>
                        </tr>--%>
					</tbody>
				</table>

				<%--分页插件--%>
				<div id="page">

				</div>
			</div>
			
			<%--<div style="height: 50px; position: relative;top: 60px;">
				<div>
					<button type="button" id="totalRowsB" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
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