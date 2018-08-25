<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" CodeBehind="MyMusic.aspx.cs" Inherits="CMS.Page.MyMusic" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    	
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
    .MusicDiv {
    
    
    }
        .MusicDiv img {
           width:50px;
           float:left;
           cursor:pointer;
           margin-left:10px;
        }
    .myHead {cursor:pointer;
    }
</style>

    <script>

        $(document).ready(function () {

            LoadTable();
            LoadType();


            $("#ddlType").change(function () {

                var MyThree = $("#MyTable");
                $.ajax({
                    type: "Get",
                    url: "/ashx/Common.ashx",
                    data: { funType: "GetMyMusicWhere",where:$("#ddlType").val() },
                    success: function (result) {

                        if (result != "") {
                            
                            MusicList.length = 0;

                            var dt = JSON.parse(result);
                            var html = "<thead><th  style=\"text-align:center;\">操作</th><th>排序</th><th>歌曲名称</th><th>歌手</th></thead><tbody>";
                            for (var i = 0; i < dt.Notes.length; i++) {

                                html += "<tr><td  style=\"text-align:center;\"><a href=\"MyMusicEdit.aspx?Name=" + dt.Notes[i].Name + "&Sort=" + dt.Notes[i].Sort + "&Address=" + dt.Notes[i].Address + "&Singer=" + dt.Notes[i].Singer + "   \">编辑</a>&emsp;<a href='#' onclick=\"playOn('"+i+"');\" ><i class=\"ti-control-play myHead\"></i></a> </td>";
                                html += "<td>" + dt.Notes[i].Sort + "</td><td>" + dt.Notes[i].Name + "</td><td>" + dt.Notes[i].Singer + "</td></tr>";

                                MusicList[MusicList.length] = dt.Notes[i].Address;
                            }
                            html += "</tbody>";
                            MyThree.html(html);
                        }
                    }
                })

            });

 

        });

        function playOn(index) {

            playIndex = index;
            $("#myAudio").attr("src", MusicList[playIndex]);
            document.getElementById("myAudio").play();
            IsPaly = false;
            $("#btnPaly").attr("src", "/Images/Muisc_puse.png");

            var audio = document.getElementById("myAudio");
            $("#lblJD").html("正在缓冲：0%");
            audio.ontimeupdate = () => {
                if (audio.readyState == 4)
                {
                    $("#lblJD").html("正在缓冲：" + Math.round(audio.buffered.end(0) / audio.duration * 100) + '%');
                }
            }
        }

        var MusicList = new Array();//保存所有音乐地址

            function LoadTable()
            {
                var MyThree = $("#MyTable");
                $.ajax({
                    type: "Get",
                    url: "/ashx/Common.ashx",
                    data: { funType: "GetMyMusic" },
                    success: function (result) {

                        if (result != "") {
                            MusicList.length = 0;
                            var dt = JSON.parse(result);
                            var html = "<thead><th  style=\"text-align:center;\">操作</th><th>排序</th><th>歌曲名称</th><th>歌手</th></thead><tbody>";
                            for (var i = 0; i < dt.Notes.length; i++) {

                                html += "<tr><td  style=\"text-align:center;\"><a href=\"MyMusicEdit.aspx?Name=" + dt.Notes[i].Name + "&Sort=" + dt.Notes[i].Sort + "&Address=" + dt.Notes[i].Address + "&Singer=" + dt.Notes[i].Singer + "   \">编辑</a>&emsp;<a href='#' onclick=\"playOn('" + i + "');\" ><i class=\"ti-control-play myHead\"></i></a> </td>";
                                html += "<td>" + dt.Notes[i].Sort + "</td><td>" + dt.Notes[i].Name + "</td><td>" + dt.Notes[i].Singer + "</td></tr>";
                                MusicList[MusicList.length] = dt.Notes[i].Address;
                            }
                            html += "</tbody>";
                            MyThree.html(html);
                        }
                    }
                })
            }
            function LoadType() {
                var MyThree = $("#ddlType");
                $.ajax({
                    type: "Get",
                    url: "/ashx/Common.ashx",
                    async: false,
                    data: { funType: "GetSinger" },
                    success: function (result) {

                        if (result != "") {
                            var dt = JSON.parse(result);
                            var html = "<option ></option>";
                            for (var i = 0; i < dt.Notes.length; i++) {
                                if (dt.Notes[i].Singer != "") {
                                    html += "<option >" + dt.Notes[i].Singer + "</option>";
                                }
                            }
                            MyThree.html(html);
                        }
                    }
                })
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
                document.location.href = "MyMusicAdd.aspx";
                return false;
            }

            var playIndex = 0; //当前播放索引

            var IsPaly = true; //是否为播放   或 暂停
            function goMusic()
            {
                if (IsPaly) {
                    if ($("#myAudio").attr("src") == "") {
                        $("#myAudio").attr("src", MusicList[playIndex]);
                    }
                    document.getElementById("myAudio").play();
                    IsPaly = false;
                    $("#btnPaly").attr("src", "/Images/Muisc_puse.png");

                    var audio = document.getElementById("myAudio");
                    $("#lblJD").html("正在缓冲：0%");
                    audio.ontimeupdate = () => {
                        if (audio.readyState == 4) {
                            $("#lblJD").html("正在缓冲：" + Math.round(audio.buffered.end(0) / audio.duration * 100) + '%');
                        }
                    }

                }
                else {
                    document.getElementById("myAudio").pause();
                    $("#btnPaly").attr("src", "/Images/Muisc_play.png");
                    IsPaly = true;
                }
                return false;

            }


            function NextMusic() {
                if (playIndex == MusicList.length-1) return;
                playIndex++;
                $("#myAudio").attr("src", MusicList[playIndex]);
                document.getElementById("myAudio").play();
                $("#btnPaly").attr("src", "/Images/Muisc_puse.png");
                IsPaly = false;

                var audio = document.getElementById("myAudio");
                $("#lblJD").html("正在缓冲：0%");
                audio.ontimeupdate = () => {
                    if (audio.readyState == 4) {
                        $("#lblJD").html("正在缓冲：" + Math.round(audio.buffered.end(0) / audio.duration * 100) + '%');
                    }
                }


                return false;

            }

            function UpMusic() {
                if (playIndex == 0) return;
                playIndex--;
                $("#myAudio").attr("src", MusicList[playIndex]);
                document.getElementById("myAudio").play();
                $("#btnPaly").attr("src", "/Images/Muisc_puse.png");
                IsPaly = false;

                var audio = document.getElementById("myAudio");
                $("#lblJD").html("正在缓冲：0%");
                audio.ontimeupdate = () => {
                    if (audio.readyState == 4) {
                        $("#lblJD").html("正在缓冲：" + Math.round(audio.buffered.end(0) / audio.duration * 100) + '%');
                    }
                }

                return false;
            }
            
       

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <audio id="myAudio" autoplay src=""></audio>
       <div class="container-fluid">

          <div class="row">
              <div class="col-md-12">
                   <div class="card" style=" height:100px; background-color: #EEF3FA; ">
                       
                       <div class="content" style=" padding:0;">
                            
                            <div class="divFind"> 
                                <table style="width:100%;"  border="0"  >
                                    <tr>
                                        <td style=" width:250px">
                                           
                                            <div class="MusicDiv">
                                                 <img src="/Images/Muisc_back.png" onclick="UpMusic();" />
                                                 <img src="/Images/Muisc_play.png" id="btnPaly" onclick="goMusic();" />
                                                 <img src="/Images/Muisc_go.png" onclick="NextMusic();" />
                                            </div>
                                        </td>
                                        
                                        <td style=" width:250px">

                                            <span id="lblJD"></span>

                                        </td>

                                        <td style=" width:240px">

                                            <select id="ddlType" class="ddlType">
						                        
					                        </select> 

                                        </td>
                                        <td  style=" width:240px">
                                            <button class="button button--antiman button--text-thick button--text-upper button--size-s button--inverted-alt button--round-s button--border-thick" onclick="return goHref();" style=" padding-top: 10px; height: 40px;color: #CCC5B9"><i class="ti-plus"></i><span>新增</span></button>

                                        </td>
                                        <td></td>
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


</asp:Content>
