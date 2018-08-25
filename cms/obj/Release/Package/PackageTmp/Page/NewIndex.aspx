<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NewIndex.aspx.cs" Inherits="CMS.Page.NewIndex" %>

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
    <link href="/Style/NewIndex.css" rel="stylesheet" />
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
 
     <div class="divYBP">
         <div  id="repMemroy" style="float:left;" data-dimension="200" data-text="<%=YJL %>" data-info="记忆量" data-width="30" data-fontsize="38" data-percent="<%=YJL_Full %>" data-fgcolor="<%=YJL_Fgcolor %>" data-bgcolor="#eee"></div>
        <div id="repToday" style="float:left" data-dimension="200" data-text="<%=JRL %>" data-info="今日访问量" data-width="30" data-fontsize="38" data-percent="<%=JRL_Full %>" data-fgcolor="<%=JRL_Fgcolor %>" data-bgcolor="#eee"></div>
         <div id="repAllDay" style="float:left" data-dimension="200" data-text="<%=ZGL %>" data-info="总共访问量" data-width="30" data-fontsize="38" data-percent="<%=ZGL_Full %>" data-fgcolor="<%=ZGL_Fgcolor %>" data-bgcolor="#eee"></div>
         <div class="Leves"><span class="LeveSP">等级:</span><div class="Level1"></div><div class="Level2"></div><div class="Level3"></div><div class="Level4"></div><div class="Level5"></div></div>
     </div>
 
     <div class="divRemind">
        <div class="textAreaOut">
          <textarea class="textArea" spellcheck="false" id="txtContent" runat="server" ></textarea>
            </div>
    </div>
 

       <button class="btnSave" id="btnSave" onclick="return SaveRem();" >保存</button>
        <asp:HiddenField ID="txtType" runat="server" />

     <%--<iframe src="BackGround.html"  style=" overflow:hidden;"  id="mylove" name="mylove" ></iframe>--%>
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
