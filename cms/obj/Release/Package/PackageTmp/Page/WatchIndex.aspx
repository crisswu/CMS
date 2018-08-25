<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WatchIndex.aspx.cs" Inherits="CMS.Page.WatchIndex" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
     <script src="../Script/jquery-1.10.2.min.js"></script>

	<meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0' name='viewport' />
    <meta name="viewport" content="width=device-width" />
    <link href="/bootstrap-3.3.7/css/bootstrap.css" rel="stylesheet" />
    <link href="/assets/css/paper-right.css" rel="stylesheet"/>
    <script src="../js/jquery.circliful.js"></script>
    <link href="../css/jquery.circliful.css" rel="stylesheet" />
    <link href="/Style/WatchIndex.css" rel="stylesheet" />
    <script>

        var isKey = true;

        $(document).ready(function () {

            $("#mylove").width(document.body.clientWidth-22);

            var height = Math.max(screen.availHeight, document.body.scrollHeight) - 5;
            $("#mylove").css("height", height);

            $("#txtContent").focus(function () {

                $("#btnSave").css("display", "block");
            });
            $("#txtContent").blur(function () {

                if(isKey)
                  $("#btnSave").css("display", "none");
            });

            $("#btnSave").mousemove(function () {

                isKey = false;
            });
            $("#btnSave").mouseleave(function () {

                isKey = true;
            });

        });
 
        function SaveRem()
        {
            $("#<%=txtType.ClientID %>").val("Submit");
            form1.submit();
            return false;
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
      
     
     <div class="divBackUp">
                                   <table id="MyTable"  class="table table-hover" border="0">
                                    <thead><th style=" text-align:center; width:40%">备份时间</th><th style=" text-align:center;width:30% ">备份类型</th><th style=" text-align:center;width:30% ">备份状态</th></thead>
                                     <tbody>
                                        <%=BackUp %>
                                    </tbody>
                                </table>
    </div>
 
     <div class="divError">
        <table id="MyError"  class="table table-hover" border="0">
                                    <thead><th style=" text-align:center; width:25%">异常名称</th><th style=" text-align:center;width:25% ">出现时间</th><th style=" text-align:center;width:25% ">异常说明</th><th style=" text-align:center;width:25% ">代码模块</th></thead>
                                     <tbody>
                                         <%=ErrorStr %>
 
                                    </tbody>
                                </table>

    </div>
    <div class="divVisit">
        <table id="MyVisit"  class="table table-hover" border="0">
                                    <thead><th style=" text-align:center; width:20%">访问日期</th><th style=" text-align:center;width:20% ">最后时间</th><th style=" text-align:center;width:20% ">访问数量</th><th style=" text-align:center;width:20% ">登录成功数</th><th style=" text-align:center;width:20% ">登录失败数</th></thead>
                                     <tbody>
                                         <%=VisitStr %>
 
                                    </tbody>
                                </table>

    </div>

       
        <asp:HiddenField ID="txtType" runat="server" />

     <iframe src="BackGroundXK.html"  style=" overflow:hidden;"  id="mylove" name="mylove" ></iframe>
    </form>
    <script>
    $( document ).ready(function() {
        $('#repMemroy').circliful();
        $('#repToday').circliful();
        $('#repAllDay').circliful();


        });
</script>
</body>
</html>
