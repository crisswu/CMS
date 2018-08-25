<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" CodeBehind="UpLoadFile.aspx.cs" Inherits="CMS.Page.UpLoadFile" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server"> 
     <script src="/Script/plupload/plupload.full.min.js"></script>
<style>
     .txtFind {

           width:99%;
           border:1px solid #A4C6FD;
             box-shadow: 0 0px 10px #A4C6FD;
            
        }
        .divFind {
          
           padding-top:30px;
           text-align:center;
           padding-left:50px;
           padding-right:65px;
        }

        .divSerch {
            padding-left:50px;
           padding-right:65px;
          padding-top:10px;
          
        }
        .divSerchBorder {
             border-radius:3px;
             border:1px solid #A4C6FD;
             box-shadow: 0 0px 10px #A4C6FD;
           height:100px;
        }
        .spSerch {
            border-radius:3px;
             border:1px solid #A4C6FD;
             box-shadow: 0 0px 10px #A4C6FD;
           height:33px;
           width:50px;
           float:left;
        }
        .inpSerch {
           float:left;
        }
        .btnFind {
            width:90%;
            float:left;
            height:15px;
        }
    .ddlType {
         height:40px;
          border:1px solid #A4C6FD;
         box-shadow: 0 0px 10px #A4C6FD;
         width:200px;
         line-height:5px;
         font-size:18px;
    }
 
</style>

    <script>

        $(document).ready(function () {

            LoadTable();

        });
 
        function LoadTable()
        {
            var MyThree = $("#MyTable");
            $.ajax({
                type: "Get",
                url: "/ashx/UploadQiniu.ashx",
                data: { funType: "GetCodeFiles_Cloud" },
                success: function (result) {

                    if (result != "") {
                        var dt = JSON.parse(result);
                        var html = "<thead><th>操作</th><th>文件名称</th><th>文件大小</th></thead><tbody>";
                        for (var i = 0; i < dt.Notes.length; i++) {

                            // html += "<tr><td><a href=\"#\" onclick=\"deleteFile('" + dt.Notes[i].FileName + "');\" >删除</a></td><td><a href=\"http://omwseoozy.bkt.clouddn.com/" + dt.Notes[i].FileName + "\" id=\"AID" + i + "\" target=\"_blank\" >" + dt.Notes[i].FileName + "</a></td><td>" + dt.Notes[i].FileSize + "</td></tr>";
                            html += "<tr><td><a href=\"#\" onclick=\"deleteFile('" + dt.Notes[i].FileName + "');\" >删除</a></td><td><a href='FileDownload_Cloud.aspx?FilesName=" + dt.Notes[i].FileName + "'  id=\"AID" + i + "\" target=\"_blank\" >" + dt.Notes[i].FileName + "</a></td><td>" + dt.Notes[i].FileSize + "</td></tr>";
                        }
                        html += "</tbody>";
                        MyThree.html(html);
                    }
                }
            })
        }

        function deleteFile(FileName)
        {
            x0p({
                title: 'Crss++',
                text: "确定要删除"+FileName+"吗？",
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
                        url: "/ashx/UploadQiniu.ashx",
                        data: { funType: "DeleteCodeFile_Cloud", FileName: FileName },
                        success: function (result) {

                            if (result != "") {
                                MessageBoxShowType(result, "error");
                            }
                            else {
                                LoadTable();
                            }
                        }
                    })
                }
                else {
                    //取消

                }

            });
        }

        function OpenURL(url,title)
        {
            $.ajax({
                type: "Get",
                url: "/ashx/Common.ashx",
                async: false,
                data: { funType: "AddMyClick", Name: title },
                success: function (result) {  }
            })
            LoadTable();
            $("#imHid").attr("href", url);
            document.getElementById("imHid").click();
            
        }

        function goHref()
        {
            document.location.href = "IEAddressAdd.aspx";
            return false;
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

      <a href="" id="imHid" target="_blank" style="display:none;" >hid</a>
       <div class="container-fluid">

          <div class="row">
              <div class="col-md-12">
                   <div class="card" style=" height:100px;">
                       
                       <div class="content" style=" padding:0;">
                            
                            <div class="divFind"> 
                                <table style="width:100%;"  border="0"  >
                                    <tr>
                                        <td style=" width:180px">
                                             <button id="btnMyUpload"  class="button button--antiman button--text-thick button--text-upper button--size-s button--inverted-alt button--round-s button--border-thick"   style=" padding-top: 10px; height: 40px;color: #CCC5B9"><i class="ti-plus"></i><span>选择文件</span></button>
                                        </td>
                                        <td style=" width:180px"><button id="start_upload"  class="button button--antiman button--text-thick button--text-upper button--size-s button--inverted-alt button--round-s button--border-thick"   style=" padding-top: 10px; height: 40px;color: #CCC5B9"><i class="ti-cloud-up"></i><span>开始上传</span></button>
                                           </td>
                                        <td   >
                                           <div style=" position: relative; top: 10px;">
                                            <div class="progress">
                                              <div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width:0%;"></div>
                                            </div>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                                
                           </div>
                        
                         </div>

                   </div>
              </div>
           </div>
          <div class="row">
                    <div class="col-md-12">
                        <div class="card" style=" height:700px;">
                            <div class="content" style=" padding:0;">
                                
                                  <div class="content table-responsive table-full-width">
                                   <table id="MyTable" class="table table-striped" border="0">
                                     
                                   
                                </table>

                            </div>
                                 

<%--                                <div class="footer" style="padding-top: 20px;">
                                    <div class="chart-legend">
                                        
                                    </div>
                                    <hr>
                                    <div class="stats">
                                        <button class="button button--nuka button--round-s button--text-thick btnHome" onclick="goHome();" >Home</button>
                                        
                                    </div>
                                </div>--%>

                            </div>
                        </div>
                    </div>
                  
                </div>

     </div>

       <script>

        //实例化一个plupload上传对象
        var uploader = new plupload.Uploader({
            browse_button: 'btnMyUpload', //触发文件选择对话框的按钮，为那个元素id
            url: '/ashx/UploadQiniu.ashx?funType=UploadCodeFile_Cloud', //服务器端的上传页面地址
            flash_swf_url: 'Script/plupload/Moxie.swf', //swf文件，当需要使用swf方式进行上传时需要配置该参数
            // silverlight_xap_url: 'js/Moxie.xap' //silverlight文件，当需要使用silverlight方式进行上传时需要配置该参数
            max_file_size: '500mb',
           // unique_names: true,     //是否自动生成唯一名称  
            chunk_size:'1mb',
        });

        //在实例对象上调用init()方法进行初始化
        uploader.init();

        //绑定各种事件，并在事件监听函数中做你想做的事
        uploader.bind('FilesAdded', function (uploader, files) {
            //每个事件监听函数都会传入一些很有用的参数，
            //我们可以利用这些参数提供的信息来做比如更新UI，提示上传进度等操作
  
            for (var i = 0; i < files.length; i++) {
                $(".progress-bar").html(files[i].percent + "%");
                $(".progress-bar").css("width", files[i].percent + "%");
            }

        });
       uploader.bind('UploadProgress', function (uploader, file) {
            //每个事件监听函数都会传入一些很有用的参数，
            //我们可以利用这些参数提供的信息来做比如更新UI，提示上传进度等操作

 
 
                $(".progress-bar").html(file.percent + "%");
                $(".progress-bar").css("width", file.percent + "%");
  
            

        });
        //......
           //......

       uploader.bind('UploadComplete', function (up, files) {
           MessageBoxShowType("上传完成", "info");
       });

        //最后给"开始上传"按钮注册事件
        document.getElementById('start_upload').onclick = function () {
            uploader.start(); //调用实例对象的start()方法开始上传文件，当然你也可以在其他地方调用该方法
            return false;
        }


    </script>

</asp:Content>
