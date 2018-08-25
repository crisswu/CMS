<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeAxis.aspx.cs" Inherits="CMS.Page.TimeAxis" %>
<!DOCTYPE html>

<html>
  <head>
    <title>Timeline</title>     <script src="../Script/jquery-1.10.2.min.js"></script>    <link href="../bootstrap-3.3.7/css/bootstrap.css" rel="stylesheet" />
    <link href="http://www.jq22.com/jquery/font-awesome.4.6.0.css" media="all" rel="stylesheet" />    <link href="../css/TimeAxis/styles.css" rel="stylesheet" />    <link href="../css/TimeAxis/font-awesome.min.css" rel="stylesheet" />    <script src="../js/TimeAxis/modernizr.min.js"></script>
  <link rel="stylesheet" href="/css/x0popup.min.css" />
<script src="/js/x0popup.min.js"></script>
      <style>

          .ImgDiv {

              border:10px solid #eee;
               border-radius: 5px;  
               width:500px;
               height:420px;
               
          }
          .FoodDiv {

              border:5px solid #eee;
               border-radius: 5px;  
               width:500px;
               height:68px;
               padding:3px 3px;
               margin-top: 5px;
 
          }
              .FoodDiv img { margin-left:3px;}

                  .FoodDiv img:hover {
                      cursor:pointer ;
                  }
                  .FoodDiv img:default {
                  cursor:default;
                  }

      </style>

     <script>


         function ImgXZ(img)
         {
             x0p({
                 title: 'Crss++',
                 text: '确定要旋转当前图片吗？',
                 animationType: 'slideUp',
                 icon: 'custom',
                 iconURL: 'image/thinking.svg',
                 buttons: [
                     {
                         type: 'error',
                         text: '取消'
                     },
                     {
                         type: 'info',
                         text: '确定'
                     }
                 ]
             }, function (button) {

                 //确认
                 if (button == "info") {
                     $.ajax({
                         type: "Get",
                         url: "/ashx/FindMemory.ashx",
                         async: false,
                         data: { funType: "ImgXZ", Img: img },
                         success: function (imgRes) {
                             
                         }
                     });
                 }
                 else {
                     //取消

                 }

             });
         }

         var PageIndex = 0; //当前页码
         var PageSize = 5; //每页加载数量

         $(document).ready(function () {

             $.ajax({
                 type: "Get",
                 url: "/ashx/FindMemory.ashx",
                 data: { funType: "GetFirst" },
                 async: false,
                 success: function (result) {

                     if (result != "") {
                         var dt = JSON.parse(result);
                         var html = "";
                         for (var i = 0; i < dt.Notes.length; i++) {

                             var block = "";
                             var endblock = "";
                             var bn = "";
                             var jm = "";
                             if (dt.Notes[i].AllBNTime != "" || dt.Notes[i].AllJMTime != "") {
                                 block = "<blockquote>";
                                 endblock = "</blockquote>";
                             }
                             if (dt.Notes[i].AllBNTime != "")
                                 bn = "<small>距伯恩出生" + dt.Notes[i].AllBNTime + "(" + dt.Notes[i].AllBNDay + ")</small>";
                             if (dt.Notes[i].AllJMTime != "")
                                 jm = "<small>距娇梅相识" + dt.Notes[i].AllJMTime + "(" + dt.Notes[i].AllJmDay + ")</small>";


                             if (dt.Notes[i].Type == "0")//文本内容
                             {

                                html += "<div class=\"timeline-row\"><div class=\"timeline-time\"><small>" + dt.Notes[i].OrderDate.substring(0, 10) + "</small>" + GetTimeStr(dt.Notes[i].OrderDate) + " </div><div class=\"timeline-icon\"><div class=\"bg-primary\"><i class=\"fa fa-pencil\"></i></div></div><div class=\"panel timeline-content\"><div class=\"panel-body\"><h2>" + dt.Notes[i].Title + "</h2>" + block + "<p>" + dt.Notes[i].Content + "</p>" + bn + jm + endblock + "</div></div></div>";
                                
                             }
                             else if (dt.Notes[i].Type == "1") { //图文信息

                                 var img = "";

                                 $.ajax({
                                     type: "Get",
                                     url: "/ashx/FindMemory.ashx",
                                     async: false,
                                     data: { funType: "GetImg", ID: dt.Notes[i].ID },
                                     success: function (imgRes) {
                                         img = imgRes;
                                     }
                                 });

                                 html += "<div class=\"timeline-row\"><div class=\"timeline-time\"><small>" + dt.Notes[i].OrderDate.substring(0, 10) + "</small>" + GetTimeStr(dt.Notes[i].OrderDate) + " </div><div class=\"timeline-icon\"><div class=\"bg-info\"><i onClick=\"ImgXZ('" + img + "');\" class=\"fa fa-camera\"></i></div></div><div class=\"panel timeline-content\"><div class=\"panel-body\"><h2>" + dt.Notes[i].Title + "</h2>" + block + "<img class=\"img-responsive\" src=\"\\UploadTimeAxis\\" + img + "\" /><p>" + dt.Notes[i].Content + "</p>" + bn + jm + endblock + "</div></div></div>";

                             }
                             else if (dt.Notes[i].Type == "2") { //图片列表

                                 var img;

                                 $.ajax({
                                     type: "Get",
                                     url: "/ashx/FindMemory.ashx",
                                     async: false,
                                     data: { funType: "GetImgList", ID: dt.Notes[i].ID },
                                     success: function (imgRes) {
                                         img = imgRes;
                                     }
                                 });

                                 var imgList = JSON.parse(img);
                                 var htmlTP = "<div class=\"ImgDiv\"><img id=\"imgMain\" src=\"\\UploadTimeAxis\\" + imgList.Notes[0].Img + "\" width=\"480\" height=\"400\" ></div><div class=\"FoodDiv\">";
                                 for (var j = 0; j < imgList.Notes.length; j++) {
                                    
                                     htmlTP += "<img src=\"\\UploadTimeAxis\\" + imgList.Notes[j].Img + "\" data-img=\"" + imgList.Notes[j].Img + "\"  class=\"imgClick\" width=\"50\" height=\"50\" >";
                                 }
 
                                 htmlTP += "</div>";
                 

                                 html += "<div class=\"timeline-row\"><div class=\"timeline-time\"><small>" + dt.Notes[i].OrderDate.substring(0, 10) + "</small>" + GetTimeStr(dt.Notes[i].OrderDate) + " </div><div class=\"timeline-icon\"><div class=\"bg-info\"><i onClick=\"ImgXZ('" + imgList.Notes[0].Img + "');\" class=\"fa fa-camera\"></i></div></div><div class=\"panel timeline-content\"><div class=\"panel-body\"><h2>" + dt.Notes[i].Title + "</h2>" + block + "" + htmlTP + "<p>" + dt.Notes[i].Content + "</p>" + bn + jm + endblock + "</div></div></div>";

                             }
                             else { //小视频

                                 var img = "";

                                 $.ajax({
                                     type: "Get",
                                     url: "/ashx/FindMemory.ashx",
                                     async: false,
                                     data: { funType: "GetImg", ID: dt.Notes[i].ID },
                                     success: function (imgRes) {
                                         img = imgRes;
                                     }
                                 });

                                 html += "<div class=\"timeline-row\"><div class=\"timeline-time\"><small>" + dt.Notes[i].OrderDate.substring(0, 10) + "</small>" + GetTimeStr(dt.Notes[i].OrderDate) + " </div><div class=\"timeline-icon\"><div class=\"bg-info\"><i class=\"fa fa-video-camera\"></i></div></div><div class=\"panel timeline-content\"><div class=\"panel-body\"><h2>" + dt.Notes[i].Title + "</h2>" + block + "<video id=\"myAudio\" controls style=\"width:500px\" preload=\"none\"  src=\"\\UploadTimeAxis\\" + img + "\"></video><p>" + dt.Notes[i].Content + "</p>" + bn + jm + endblock + "</div></div></div>";

                             }
                             
                         }

                         $("#myDiv").html(html);
                         $(".imgClick").click(function (event) {

                             $("#imgMain").attr("src", $(this).attr("src"));
                             $("#imgMain").attr("data-img", $(this).attr("data-img"));

                         });

                     }
                 }
             });


             //最底部加载数据
             $(window).scroll(function () {

                 //当滚动条达到底部时候 触发加载事件
                 if ($(document).scrollTop() >= $(document).height() - $(window).height()) {

                     PageIndex++;//先增加页码

                     $.ajax({
                         type: "Get",
                         url: "/ashx/FindMemory.ashx",
                         data: { funType: "GetTimeAxis", Size: PageSize, index: PageIndex },
                         async: false,
                         success: function (result) {

                             if (result != "") {
                                 var dt = JSON.parse(result);
                                 var html = "";
                                 for (var i = 0; i < dt.Notes.length; i++) {

                                     var block = "";
                                     var endblock = "";
                                     var bn = "";
                                     var jm = "";
                                     if (dt.Notes[i].AllBNTime != "" || dt.Notes[i].AllJMTime != "") {
                                         block = "<blockquote>";
                                         endblock = "</blockquote>";
                                     }
                                     if (dt.Notes[i].AllBNTime != "")
                                         bn = "<small>距伯恩出生" + dt.Notes[i].AllBNTime + "(" + dt.Notes[i].AllBNDay + ")</small>";
                                     if (dt.Notes[i].AllJMTime != "")
                                         jm = "<small>距娇梅相识" + dt.Notes[i].AllJMTime + "(" + dt.Notes[i].AllJmDay + ")</small>";


                                     if (dt.Notes[i].Type == "0")//文本内容
                                     {

                                         html += "<div class=\"timeline-row\"><div class=\"timeline-time\"><small>" + dt.Notes[i].OrderDate.substring(0, 10) + "</small>" + GetTimeStr(dt.Notes[i].OrderDate) + " </div><div class=\"timeline-icon\"><div class=\"bg-primary\"><i class=\"fa fa-pencil\"></i></div></div><div class=\"panel timeline-content\"><div class=\"panel-body\"><h2>" + dt.Notes[i].Title + "</h2>" + block + "<p>" + dt.Notes[i].Content + "</p>" + bn + jm + endblock + "</div></div></div>";

                                     }
                                     else if (dt.Notes[i].Type == "1") { //图文信息

                                         var img = "";

                                         $.ajax({
                                             type: "Get",
                                             url: "/ashx/FindMemory.ashx",
                                             async: false,
                                             data: { funType: "GetImg", ID: dt.Notes[i].ID },
                                             success: function (imgRes) {
                                                 img = imgRes;
                                             }
                                         });

                                         html += "<div class=\"timeline-row\"><div class=\"timeline-time\"><small>" + dt.Notes[i].OrderDate.substring(0, 10) + "</small>" + GetTimeStr(dt.Notes[i].OrderDate) + " </div><div class=\"timeline-icon\"><div class=\"bg-info\"><i onClick=\"ImgXZ('" + img + "');\" class=\"fa fa-camera\"></i></div></div><div class=\"panel timeline-content\"><div class=\"panel-body\"><h2>" + dt.Notes[i].Title + "</h2>" + block + "<img class=\"img-responsive\" src=\"\\UploadTimeAxis\\" + img + "\" /><p>" + dt.Notes[i].Content + "</p>" + bn + jm + endblock + "</div></div></div>";

                                     }
                                     else if (dt.Notes[i].Type == "2") { //图片列表

                                         var img;

                                         $.ajax({
                                             type: "Get",
                                             url: "/ashx/FindMemory.ashx",
                                             async: false,
                                             data: { funType: "GetImgList", ID: dt.Notes[i].ID },
                                             success: function (imgRes) {
                                                 img = imgRes;
                                             }
                                         });

                                         var imgList = JSON.parse(img);
                                         var htmlTP = "<div class=\"ImgDiv\"><img id=\"imgMain\" src=\"\\UploadTimeAxis\\" + imgList.Notes[0].Img + "\" width=\"480\" height=\"400\" ></div><div class=\"FoodDiv\">";
                                         for (var j = 0; j < imgList.Notes.length; j++) {

                                             htmlTP += "<img src=\"\\UploadTimeAxis\\" + imgList.Notes[j].Img + "\" class=\"imgClick\" width=\"50\" height=\"50\" >"; 

                                             htmlTP += "<audio id=\"myAudio\" autoplay src=\"\\UploadTimeAxis\\" + imgList.Notes[j].Img + "\"></audio>";
                                         }

                                         htmlTP += "<a href=\"#\"><i class=\"ti-reload\" /></a> </div>";


                                         html += "<div class=\"timeline-row\"><div class=\"timeline-time\"><small>" + dt.Notes[i].OrderDate.substring(0, 10) + "</small>" + GetTimeStr(dt.Notes[i].OrderDate) + " </div><div class=\"timeline-icon\"><div class=\"bg-info\"><i onClick=\"ImgXZ('" + imgList.Notes[0].Img + "');\" class=\"fa fa-camera\"></i></div></div><div class=\"panel timeline-content\"><div class=\"panel-body\"><h2>" + dt.Notes[i].Title + "</h2>" + block + "" + htmlTP + "<p>" + dt.Notes[i].Content + "</p>" + bn + jm + endblock + "</div></div></div>";

                                     }
                                     else { //小视频

                                         var img = "";

                                         $.ajax({
                                             type: "Get",
                                             url: "/ashx/FindMemory.ashx",
                                             async: false,
                                             data: { funType: "GetImg", ID: dt.Notes[i].ID },
                                             success: function (imgRes) {
                                                 img = imgRes;
                                             }
                                         });

                                         html += "<div class=\"timeline-row\"><div class=\"timeline-time\"><small>" + dt.Notes[i].OrderDate.substring(0, 10) + "</small>" + GetTimeStr(dt.Notes[i].OrderDate) + " </div><div class=\"timeline-icon\"><div class=\"bg-info\"><i class=\"fa fa-video-camera\"></i></div></div><div class=\"panel timeline-content\"><div class=\"panel-body\"><h2>" + dt.Notes[i].Title + "</h2>" + block + "<audio id=\"myAudio\" autoplay src=\"\\UploadTimeAxis\\" + img + "\"></audio><p>" + dt.Notes[i].Content + "</p>" + bn + jm + endblock + "</div></div></div>";

                                     }

                                 }

                                 $("#myDiv").append(html);

                                 $(".imgClick").click(function (event) {

                                     $("#imgMain").attr("src", $(this).attr("src"));
                                 });

                             }
                         }
                     });
                      
                 }
             });
     
         });

         function GetTimeStr(time)
         {
             var str = time.substring(11);
             var time = time.substring(11, 13);//截取两位  时间段位
             return str;
         }


        


     </script>
  </head>
  <body>
    <div id="myDiv" class="timeline animated">


      </div>
           <script src="../Script/jquery-1.10.2.min.js"></script>    <script src="../bootstrap-3.3.7/js/bootstrap.min.js"></script>
    <script src="../js/TimeAxis/main.js"></script>
    

  </body>
</html>