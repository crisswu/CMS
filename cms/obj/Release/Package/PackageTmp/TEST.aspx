<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TEST.aspx.cs" Inherits="CMS.TEST" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <script src="Script/jquery-1.10.2.min.js"></script>
    <script>

        $.ajaxWebService = function (url, dataMap, fnSuccess, async) {
    var asyncT = async == undefined ? true : async;
    $.ajax({
        type: "POST",
        contentType: "application/json",
        url: url,
        async: asyncT,
        data: dataMap,
        dataType: "json",
        success: fnSuccess
    });
        }


        function myclick1() {
            $.ajaxWebService("http://wuxiongjun.com:8088/API/Test/api.aspx/Get1", "{}", function (res) {
                alert(res.d);
            });
        }
         function myclick2() {
            $.ajaxWebService("http://wuxiongjun.com:8088/API/Test/api2.aspx", "{}", function (res) {
                alert(res.d);
            });
        }
         function myclick3() {
            $.ajaxWebService("http://wuxiongjun.com:8088/API/Test/api3.aspx", "{}", function (res) {
                alert(res.d);
            });
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>

            <input type="button" value="Click1" onclick="myclick1();" />
            <input type="button" value="Click2" onclick="myclick2();" />
            <input type="button" value="Click3" onclick="myclick3();" />
        </div>
    </form>
</body>
</html>
