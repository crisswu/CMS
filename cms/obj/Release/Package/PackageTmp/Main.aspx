<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Main.aspx.cs" Inherits="CMS.Main" %>

<!DOCTYPE html>

 <html lang="en">
<head>
	<meta charset="utf-8" />
    <script src="Script/jquery-1.10.2.min.js"></script>
	<link rel="apple-touch-icon" sizes="76x76" href="assets/img/apple-icon.png">
	<link rel="icon" type="image/png" sizes="96x96" href="assets/img/favicon.png">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />

	<title>Criss`s Memory</title>

	<meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0' name='viewport' />
    <meta name="viewport" content="width=device-width" />
    <link rel="icon" href="/Images/criss.ico" type="image/x-icon"/>
    <link href="bootstrap-3.3.7/css/bootstrap.css" rel="stylesheet" />
    <link href="assets/css/animate.min.css" rel="stylesheet"/>
    <link href="assets/css/paper-right.css" rel="stylesheet"/>
    <link href="assets/css/themify-icons.css" rel="stylesheet">
        <script>

        $(document).ready(function () {

            var width = document.body.clientWidth - 260;
            $("#iframe-main").css("width", width);

            var height = document.body.clientHeight-10;
            $("#iframe-main").css("height", height);

            $(window).resize(function () {          //当浏览器大小变化时
                var width = document.body.clientWidth - 260;
                $("#iframe-main").css("width", width);

            });

            $(".nav").find("li").click(function () {

                $(".active").removeClass("active");
                $(this).addClass("active");
               
            });
            $('.loading').fadeOut();

        });

        

    </script>
    <style>.loading{ 
 background:#FF6100;  
 height:5px;  
 position:fixed;  
 top:0;  
 z-index:99999  
}</style>
</head>
<body>
    <div class="loading"></div>
    <script type="text/javascript"> 
 $('.loading').animate({'width':'33%'},50); 
 //第一个进度节点 
</script> 
<div class="wrapper">
    <div class="sidebar" data-background-color="white" data-active-color="danger">

    <!--
		Tip 1: you can change the color of the sidebar's background using: data-background-color="white | black"
		Tip 2: you can change the color of the active button using the data-active-color="primary | info | success | warning | danger"
	-->

    	<div class="sidebar-wrapper" style="position:fixed;">
            <div class="logo">
                <a href="#" class="simple-text">
                   Criss`s Memory  
                </a>
            </div>

            <ul class="nav">
                
                <li>
                    <a href="/Page/NewIndex.aspx" target="iframe-main"    >
                        <i class="ti-home"></i>
                        <p>首页</p>
                    </a>
                </li>
                <li class="active">
                    <a href="/Page/TouTiao.aspx"  target="iframe-main">
                        <i class="ti-gallery"></i>
                        <p>网站导航</p>
                    </a>
                </li>
                <li>
                    <a href="/Page/Memory.aspx"  target="iframe-main">
                        <i class="ti-ink-pen"></i>
                        <p>Criss++</p>
                    </a>
                </li>
                <li>
                    <a href="/Page/MemoryQuery.aspx"  target="iframe-main">
                        <i class="ti-search"></i>
                        <p>记忆查询</p>
                    </a>
                </li>
                <li>
                    <a href="/Page/IEAddress.aspx"  target="iframe-main">
                        <i class="ti-html5"></i>
                        <p>网址收藏</p>
                    </a>
                </li>
                <li>
                    <a href="/Page/DataBaseQuery.aspx"  target="iframe-main">
                        <i class="ti-server"></i>
                        <p>数据库查询</p>
                    </a>
                </li>
                <li>
                    <a href="/Page/DataBaseEdit.aspx"  target="iframe-main">
                        <i class="ti-layers-alt"></i>
                        <p>数据库编辑</p>
                    </a>
                </li>
                <li>
                    <a href="/Page/UploadCodeFile.aspx"  target="iframe-main">
                        <i class="ti-folder"></i>
                        <p>我的文件</p>
                    </a>
                </li>
                <li>
                    <a href="/Page/UploadFile.aspx"  target="iframe-main">
                        <i class="ti-cloud"></i>
                        <p>我的云盘</p>
                    </a>
                </li>
                <li>
                    <a href="/Page/MyMusic.aspx"  target="iframe-main">
                        <i class="ti-music"></i>
                        <p>我的音乐</p>
                    </a>
                </li>
               <%-- <li>
                    <a href="/Page/MyBoy.html"  target="iframe-main">
                        <i class="ti-gallery"></i>
                        <p>我的画墙</p>
                    </a>
                </li>--%>
                 <li>
                    <a href="/Page/TimeAxis.aspx"  target="iframe-main">
                        <i class="ti-image"></i>
                        <p>时光轴</p>
                    </a>
                </li>
                  <li>
                    <a href="/Page/WatchIndex.aspx" target="iframe-main"    >
                        <i class="ti-signal"></i>
                        <p>监测站</p>
                    </a>
                </li>
                 <li>
                    <a href="/Page/SystemOption.aspx"  target="iframe-main">
                        <i class="ti-settings"></i>
                        <p>系统设置</p>
                    </a>
                </li>
            </ul>
    	</div>
    </div>
    <script type="text/javascript"> 
 $('.loading').animate({'width':'55%'},50); 
//第二个进度节点 
</script> 
        <iframe src="/Page/TouTiao.aspx"  id="iframe-main" name="iframe-main" frameborder='0' style="margin-left: 260px; height:1080px;"></iframe>
</div>
    <script type="text/javascript"> 
 $('.loading').animate({'width':'80%'},50); 
//第三个进度节点 
</script> 
  
</body>

     <script type="text/javascript"> 
 $('.loading').animate({'width':'100%'},50); 
//第三个进度节点 
</script>
</html>