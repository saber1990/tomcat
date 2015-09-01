<%@page pageEncoding="UTF-8" contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<html>
<head>
<link href="<%=basePath%>css/bootstrap.min.css" rel="stylesheet">
<script src="<%=basePath%>js/jquery.js"></script>
<script type="text/javascript">

//区分session操作 和 2ndcache操作
var postType = "memFind";

function link(){
	$.ajax({   
		cache : false,
	    type : "POST",   
	    url : "<%=basePath%>link.do", 
	    data : {
	      'linkStr' :$("#linkStr").val()
	    },  
	    dataType: "json",
	    success : function(data) { 
	    	$("#font_msg").html(data.linkMsg);
	    },
	    error :function(){
	    }   
	});   
	
} 

function show(postType){
	$.ajax({   
		cache : false,
	    type : "POST",   
	    url : "<%=basePath%>" + postType + ".do", 
	    data : {
	      'prefix' :$("#prefix").val(),
	      'key' :$("#key").val(),
	      'keyId' :$("#keyId").val()
	    },  
	    dataType: "text",
	    success : function(data) { 
		    data = eval(data);
		    var htmlT = "";
		    
		    var showDiv = $("#show_div");
		    showDiv.text("");

		    if(postType == "memFind"){
			    for(var x in data){
			    	htmlT += data[x];
			    }
		    	showDiv.append("<textarea id='valueArea' name='valueArea' class='form-control' rows='35'></textarea>");
			    $("#valueArea").val(htmlT);
			    
		    }else if(postType == "memFind2nd"){
		    	htmlT += "<table id='showTable' class='table table-hover'>";
			    for(var x in data){
			    	htmlT += "<tr>";
			    	if(data[x].indexOf("memcachedClient") > -1){
					    htmlT += "<td width=900' style='vertical-align:middle;'>           " + data[x] + "</td>";
			    		htmlT += "<td><button type='button' class='btn btn-danger' onclick='remove2ndCache(\"" + data[x] + "\")' disabled>删除</button></td>";
			    	}else{
			    		htmlT += "<td width=900' style='vertical-align:middle;'>   KEY  :  " + data[x] + "</td>";
			    		htmlT += "<td><button type='button' class='btn btn-danger' onclick='remove2ndCache(\"" + data[x] + "\")'>删除</button></td>";
			    	}
			    	htmlT += "</tr>";
			    }
			    htmlT += "</table>";
	    		showDiv.append(htmlT);
		    }
	    },
	    error :function(){
	        alert("出错！");   
	    }   
	});   
}  

function removeCache(){
	if(confirm("确定要删除该缓存内容吗?")){
		$.ajax({   
			cache : false,
		    type : "POST",
		    url : "<%=basePath%>removeCache.do", 
		    data : {
			  'prefix' :$("#prefix").val(),
			  'key' :$("#key").val()
		    },  
		    dataType: "json",
		    success : function(data) {
		    	if(eval(data.success)){
		    		alert("删除成功");
		    	}else{
		    		alert("删除失败,请检查是否存在该key");
		    	}
		    },
		    error :function(){
		    	alert("出错！"); 
		    }   
		});
	}
}

function remove2ndCache(key){
	if(confirm("确定要删除该缓存内容吗?")){
		$.ajax({   
			cache : false,
		    type : "POST",
		    url : "<%=basePath%>removeCache.do", 
		    data : {
			  'prefix' : '',
			  'key' : key
		    },  
		    dataType: "json",
		    success : function(data) {
		    	if(eval(data.success)){
		    		alert("删除成功");
		    	}else{
		    		alert("删除失败,请检查是否存在该key");
		    	}
		    },
		    error :function(){
		    	alert("出错！"); 
		    }   
		});
	}
	show(postType);
}

function updatePH(s_val){
	var phMsg = "";
	if(s_val.indexOf("xhcms")>-1){
		phMsg = "请输入缓存实体的类名    *区分大小写*";
	}else if(s_val == "M_JSID_"){
		phMsg = "shareSession 请输入sessionKey 例:1436249096171-C84B7DA02ECBF0229DD3F4";
	}else if(s_val == "sys-userCache_username-"){
		phMsg = "手动cache 请输入username 例:lilei";
	}else if(s_val == "sys-userCache_email-"){
		phMsg = "手动cache 请输入userEmail 例:187354952@qq.com";
	}else if(s_val == "sys-userCache_mobilePhoneNumber-"){
		phMsg = "手动cache 请输入phoneNum 例:13934104924";
	}else{
		phMsg = "手动cache 请输入userId 例:598";
	}
	$("#key").val("");
	$("#key").attr("placeholder", phMsg);
}

function showS(){
	$('#s_bt').attr("class","btn btn-success active");
	$('#2nd_bt').attr("class","btn btn-success");
	
	//select link
	$("#linkStr").empty();
	$("#linkStr").append("<option value='192.168.86.81:11212' ${sessionScope.linkStr=='192.168.86.81:11212'?'selected':''}>测试线:8681--shareSession</option>");
	$("#linkStr").append("<option value='192.168.86.82:11211' ${sessionScope.linkStr=='192.168.86.82:11211'?'selected':''}>测试线:8682--手动cache</option>");
	$("#linkStr").append("<option value='192.168.65.11:11211' ${sessionScope.linkStr=='192.168.65.11:11211'?'selected':''}>正式线:6511--shareSession</option>");
	$("#linkStr").append("<option value='192.168.65.12:11211' ${sessionScope.linkStr=='192.168.65.12:11211'?'selected':''}>正式线:6512--手动cache</option>");
	
	//select prefix
	$("#prefix").empty();
	$("#prefix").append("<option value='M_JSID_' selected='selected'>M_JSID_</option>");
	$("#prefix").append("<option value='sys-siteCache_site-'>sys-siteCache_site-</option>");
	$("#prefix").append("<option value='sys-userCache_id-'>sys-userCache_id-</option>");
	$("#prefix").append("<option value='sys-userCache_username-'>sys-userCache_username-</option>");
	$("#prefix").append("<option value='sys-userCache_email-'>sys-userCache_email-</option>");
	$("#prefix").append("<option value='sys-userCache_mobilePhoneNumber-'>sys-userCache_mobilePhoneNumber-</option>");
	$("#prefix").append("<option value='sys-authCache_roles-'>sys-authCache_roles-</option>");
	$("#prefix").append("<option value='sys-authCache_string-roles-'>sys-authCache_string-roles-</option>");
	$("#prefix").append("<option value='sys-authCache_string-permissions-'>sys-authCache_string-permissions-</option>");
	$("#prefix").append("<option value='sys-resourcesCache_resources-'>sys-resourcesCache_resources-</option>");
	$("#prefix").append("<option value='sys-menuCache_menus-'>sys-menuCache_menus-</option>");
	
	$("#delete_bt").attr("class", "btn btn-danger");
	$("#fs").attr("disabled", true);
	
	$("#key").attr("placeholder", "shareSession 请输入sessionKey 例:1436249096171-C84B7DA02ECBF0229DD3F4");
	
	postType = "memFind";
	
	var showDiv = $("#show_div");
	showDiv.text("");
	showDiv.append("<textarea id='valueArea' name='valueArea' class='form-control' rows='35'></textarea>");
}

function show2nd(){
	$('#s_bt').attr("class","btn btn-success");
	$('#2nd_bt').attr("class","btn btn-success active");
	
	//select link
	$("#linkStr").empty();
	$("#linkStr").append("<option value='192.168.86.81:11211' selected='selected'>测试线:8681--2ndCache</option>");
	$("#linkStr").append("<option value='192.168.65.12:11211'>正式线:6512--2ndCache</option>");
	
	//select prefix
	$("#prefix").empty();
	$("#prefix").append("<option value='xhcms_branch_0_2.cache.memcache'>xhcms_branch_0_2.cache.memcache</option>");
	
	$("#delete_bt").attr("class", "hidden");
	$("#fs").attr("disabled", false);	
	
	$("#key").attr("placeholder", "请输入缓存实体的类名    *区分大小写*");
	
	postType = "memFind2nd";
	
	var showDiv = $("#show_div");
    showDiv.text("");
}

function changeLink(){
	var linkStr = $('#linkStr option:selected').text(); 
	if(linkStr == "测试线:8681--2ndCache"){
		$("#prefix").empty();
		$("#prefix").append("<option value='xhcms_branch_0_2.cache.memcache'>xhcms_branch_0_2.cache.memcache</option>");
	}else if (linkStr == "正式线:6512--2ndCache"){
		$("#prefix").empty();
		$("#prefix").append("<option value='xhcms.cache.memcache' selected='selected'>xhcms.cache.memcache</option>");
	}
	
}

</script>
</head>
<style type="text/css">
body {
  padding-top: 40px;
  padding-bottom: 40px;
  background-color: #eee;
}
table {
  width:1500px; 
}
.tb_td1 {
  width: 300px;
}
.tb_td2 {
  width: 600px;
}
.tb_td3 {
  width: 150px;
}
</style> 
<body>
	
	<table class="center-block">
		<tr>
			<td>
				<button type="button" id="s_bt" class="btn btn-success active" onclick="showS()">session查询</button>		
				<button type="button" id="2nd_bt" class="btn btn-success" onclick="show2nd()">二级缓存查询</button>
			</td>
			<td colspan="3">
		</tr>
		<tr>
			<td colspan="4">&nbsp;<td>
		</tr>
		<tr>
			<td colspan="3">
				<form class="form-inline">
					<div class="form-group">
						<select class="form-control" name="linkStr" id="linkStr" onchange="changeLink()">
							<option value="192.168.86.81:11212" ${sessionScope.linkStr=='192.168.86.81:11212'?'selected':''}>测试线:8681--shareSession</option>
							<option value="192.168.86.82:11211" ${sessionScope.linkStr=='192.168.86.82:11211'?'selected':''}>测试线:8682--手动cache</option>
							<option value="192.168.65.11:11211" ${sessionScope.linkStr=='192.168.65.11:11211'?'selected':''}>正式线:6511--shareSession</option>
							<option value="192.168.65.12:11211" ${sessionScope.linkStr=='192.168.65.12:11211'?'selected':''}>正式线:6512--手动cache</option>
						</select>
					</div>
				  	<button type="button" class="btn btn-primary" onclick = "link()">连接</button>				  
					<mark>
						<font id="font_msg" style="color: green;font-size: 20;">
							<c:if test="${empty sessionScope.linkMsg}">请连接服务器</c:if>
							<c:if test="${!empty sessionScope.linkMsg}">${sessionScope.linkMsg}</c:if>
						</font>
					</mark>
				</form>
			</td>
			<td></td>		
		</tr>
		<tr>
			<td class="tb_td1">
				<select class="form-control" name="prefix" id="prefix" onchange="updatePH(this.value)">
					<option value="M_JSID_" selected="selected">M_JSID_</option>
					<option value="sys-siteCache_site-">sys-siteCache_site-</option>
					<option value="sys-userCache_id-">sys-userCache_id-</option>
					<option value="sys-userCache_username-">sys-userCache_username-</option>
					<option value="sys-userCache_email-">sys-userCache_email-</option>
					<option value="sys-userCache_mobilePhoneNumber-">sys-userCache_mobilePhoneNumber-</option>
					<option value="sys-authCache_roles-">sys-authCache_roles-</option>
					<option value="sys-authCache_string-roles-">sys-authCache_string-roles-</option>
					<option value="sys-authCache_string-permissions-">sys-authCache_string-permissions-</option>
					<option value="sys-resourcesCache_resources-">sys-resourcesCache_resources-</option>
					<option value="sys-menuCache_menus-">sys-menuCache_menus-</option>
				</select>
			</td>
			<td class="tb_td2">
				<input type="text" name="key" id="key" class="form-control" placeholder="shareSession 请输入sessionKey 例:1436249096171-C84B7DA02ECBF0229DD3F4">
			</td>
			<td class="tb_td3">
				<fieldset id="fs" disabled><input type="text" name="keyId" id="keyId" class="form-control" placeholder="对象Id *选填*"></fieldset>
			</td>
			<td>&nbsp;
				<button type="submit" class="btn btn-primary" id="show_bt" onclick="javascript:show(postType)">查询</button>
				<button type="button" class="btn btn-danger" id="delete_bt" onclick="removeCache()">删除</button>
			</td>
		</tr>
		<tr>
			<td colspan="4">
				<br/><div id="show_div" class="table-responsive"><textarea id="valueArea" name="valueArea" class="form-control" rows="35"></textarea></div>
			</td>
		</tr>
	</table>
	
</body>
</html>