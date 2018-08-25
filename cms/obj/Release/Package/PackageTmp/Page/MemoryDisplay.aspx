<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" CodeBehind="MemoryDisplay.aspx.cs" Inherits="CMS.Page.MemoryDisplay" %>
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
 
</style>

    <script>

        $(document).ready(function () {

            LoadTable();
            LoadType();

        });

        function LoadType()
        {
            var MyThree = $("#ddlType");
            $.ajax({
                type: "Get",
                url: "/ashx/Common.ashx",
                async: false,
                data: { funType: "GetType"},
                success: function (result) {

                    if (result != "")
                    {
                        var dt = JSON.parse(result);
                        var html = "<option ></option>";
                        for (var i = 0; i < dt.Notes.length; i++) {
                            if (dt.Notes[i].Type != "")
                            {
                                html += "<option >" + dt.Notes[i].Type + "</option>";
                            }
                        }
                        MyThree.html(html);
                    }
                }
            })
        }

        function LoadTable()
        {
            var MyThree = $("#MyTable");
            $.ajax({
                type: "Get",
                url: "/ashx/OptionDAL.ashx",
                data: { funType: "GetDisplay" },
                success: function (result) {

                    if (result != "") {
                        var dt = JSON.parse(result);
                        var html = "<thead><th  style=\"text-align:center;\">操作</th><th>名称</th><th>状态</th></thead><tbody>";
                        for (var i = 0; i < dt.Notes.length; i++) {


                            html += "<tr><td  style=\"text-align:center;\"><a href=\"#\" onclick=\"OpenViazble('" + dt.Notes[i].ID + "','" + dt.Notes[i].Visble + "')\"  >" + dt.Notes[i].col + "</a></td><td>" + dt.Notes[i].Name + "</td><td>" + dt.Notes[i].Status + "</td></tr>";
                        }
                        html += "</tbody>";
                        MyThree.html(html);
                    }
                }
            })
        }
        function OpenViazble(ID, visble) {

            x0p({
                title: 'Crss++',
                text: '确定要切换吗？',
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
                        url: "/ashx/OptionDAL.ashx",
                        async: false,
                        data: { funType: "Viazble", ID: ID, visble: visble },
                        success: function (result) {

                            LoadTable();
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
        function MessageBoxShow(msg) {
            $.toast({
                heading: 'Crss++',
                text: msg,
                showHideTransition: 'slide',
                position: 'top-center',
                icon: 'success'
            })

            return false;
        }
        function MessageBoxShowType(msg, type) {
            $.toast({
                heading: 'Crss++',
                text: msg,
                showHideTransition: 'slide',
                position: 'top-center',
                icon: type
            })

            return false;
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
