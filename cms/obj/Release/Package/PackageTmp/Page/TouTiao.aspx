<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TouTiao.aspx.cs" Inherits="CMS.Page.TouTiao" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <script src="../Script/jquery-1.10.2.min.js"></script>
     <link rel="icon" href="/Images/criss.ico" type="image/x-icon"/>
    <link href="/bootstrap-3.3.7/css/bootstrap.css" rel="stylesheet" />
    <link href="/assets/css/animate.min.css" rel="stylesheet"/>
    <link href="/assets/css/paper-right.css" rel="stylesheet"/>
    <link href="/assets/css/themify-icons.css" rel="stylesheet">
    <style>
        .Memu {
          width:80px;
          background-color:#F2F2F2;
          float:left;
        }
         .ulKJL {
            list-style:none; 
              padding-top: 6px;
                  padding-left: 20px;
        }
        .ulKJL li {
 
          margin-top: 40px;
        }
        .divHid {
          width:50px;
          background-color:white;
          float:left;
          margin-left: -19px;
          z-index: 100;
        }
    </style>
    <script>

        $(document).ready(function () {


            $("#mylove").css("width", "1300");

           //// $("#mylove").css("width", document.body.offsetWidth -105 );
           // $("#mylove").css("height", document.body.scrollHeight-5);
           // $("#divMemun").css("height", document.body.scrollHeight-5);
            // $(".divHid").css("height", document.body.scrollHeight - 5);

            //window.screen.availHeight  window.screen.availHeight
            $("#mylove").css("height", window.screen.availHeight - 5);
            $("#divMemun").css("height", window.screen.availHeight - 5);
            $(".divHid").css("height", window.screen.availHeight - 5);


            $("#btnSet").click(function () {

                if ($("#iSet").data("text") == "0") {

                    $("#mylove").css("width", document.body.offsetWidth - 105);
                    $("#iSet").removeClass("ti-angle-double-right");
                    $("#iSet").addClass("ti-angle-double-left");
                    $("#iSet").data("text", "1");
                }
                else {
                    $("#mylove").css("width", "1300");
                    $("#iSet").removeClass("ti-angle-double-left");
                    $("#iSet").addClass("ti-angle-double-right");
                    $("#iSet").data("text", "0");
                }

            });

            $("#btnSet").click();
       });

    </script>
</head>
<body style="margin:0; padding:0; overflow:hidden;" >
     <div id="divMemun" class="Memu">

          <ul class="ulKJL">
            <li><a href="#" id="btnSet"><i id="iSet" class="ti-angle-double-right" data-text="0" style=" font-size:32px;" ></i></a></li>
            <li><a href="http://www.baidu.com" target="mylove" ><img src="https://www.baidu.com/favicon.ico" width="32" height="32" /></a></li>
            <li><a href="http://www.toutiao.com/" target="mylove" ><img src="http://s3a.pstatp.com/toutiao/resource/ntoutiao_web/static/image/favicon_8e9c9c7.ico" width="32" height="32" /></a></li>
            <li><a href="http://www.gamersky.com/" target="mylove"><img src="https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=2769352318,3699298963&fm=58" width="32" height="32" /></a></li>
            <li><a href="http://fanyi.baidu.com/" target="mylove"><img src="http://fanyi.baidu.com/static/translation/img/favicon/favicon-32x32_ca689c3.png" width="32" height="32" /></a></li>
            <li><a href="http://gaoqing.la/" target="mylove"><img src="http://gaoqing.la/wp-content/themes/Loostrive/images/favicon.ico" width="32" height="32" /></a></li>
            <li><a href="https://www.taobao.com/" target="mylove"><img src="https://img.alicdn.com/tps/i3/T1OjaVFl4dXXa.JOZB-114-114.png" width="32" height="32" /></a></li>
              <li><a href="https://www.jd.com/" target="mylove"><img src="https://www.jd.com/favicon.ico" width="32" height="32" /></a></li>
            <li><a href="http://www.youku.com/" target="mylove"><img src="https://ss1.baidu.com/70cFfyinKgQFm2e88IuM_a/forum/pic/item/472309f79052982277043cb5deca7bcb0a46d494.jpg" width="32" height="32" /></a></li>
              <li><a href="http://www.iqiyi.com/" target="mylove"><img src="https://ss0.baidu.com/6ONWsjip0QIZ8tyhnq/it/u=63888363,1578153921&fm=58" width="32" height="32" /></a></li>
            
        </ul>

     </div>
     <iframe src="http://www.baidu.com"  style=" overflow:hidden; float:left; "  id="mylove" name="mylove" ></iframe>
    <div class="divHid">

    </div>
    
</body>
</html>
