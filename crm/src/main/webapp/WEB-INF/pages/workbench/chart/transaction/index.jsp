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

    <%--引入jquery和echarts--%>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/echarts/echarts.min.js"></script>

    <script type="text/javascript">
        $(function () {
            //发送查询请求
            $.ajax({
               url:'workbench/chart/transaction/queryCountOfTranGroupByStage.do',
               type:'post',
               dataType:'json',
               success:function (data) {
                   //调用echarts工具，绘图
                   //初始化实例
                   var myChart = echarts.init(document.getElementById("main"));
                   //指定图表的配置项和数据
                   var option = {
                       title: {
                           text: '交易统计图图表',
                           subtext: '交易表中各个阶段的数量',
                           textStyle: {
                               fontSize: 22
                           },
                           subtextStyle: {
                               fontSize: 12
                           }
                       },
                       tooltip: {
                           trigger: 'item',
                           formatter: '{a} <br/>{b} : {c}'
                       },
                       toolbox: {
                           feature: {
                               dataView: { readOnly: true },
                               saveAsImage: {}
                           },
                           itemSize: 20,
                           right: "5%"
                       },
                       series: [
                           {
                               name: '数据量',
                               type: 'funnel',
                               left: '10%',
                               width: '80%',
                               label: {
                                   formatter: '{b}'
                               },
                               labelLine: {
                                   show: false
                               },
                               itemStyle: {
                                   opacity: 0.7
                               },
                               emphasis: {
                                   label: {
                                       position: 'inside',
                                       formatter: '{b}: {c}'
                                   }
                               },
                               data: data
                           }
                       ]
                   };
                    //使用配置项显示图表
                   myChart.setOption(option);
               }
            });
        });
    </script>
</head>
<body>
    <%--容器--%>
    <div id="main" style="margin-left: 50px;margin-top: 50px;width: 800px;height: 600px;"></div>
</body>
</html>
