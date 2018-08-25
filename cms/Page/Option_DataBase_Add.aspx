<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" CodeBehind="Option_DataBase_Add.aspx.cs" Inherits="CMS.Page.Option_DataBase_Add" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
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
        function FindContent()
        {
            if ($("#txtTitle").val() == "")
            {
                MessageBoxShowType("输入名称!", "info");
                return false;
            }
            if ($("#txtIP").val() == "") {
                MessageBoxShowType("输入IP!", "info");
                return false;
            }
            if ($("#txtSa").val() == "") {
                MessageBoxShowType("输入登录名!", "info");
                return false;
            }

            var IsKey = true;
            $.ajax({
                type: "Get",
                url: "/ashx/OptionDAL.ashx",
                async: false,
                data: { funType: "SaveDataBase", name: $("#txtTitle").val(), ip: $("#txtIP").val(), loginName: $("#txtSa").val(), passWord: $("#txtPWD").val() },
                success: function (result) {
                    MessageBoxShow("保存完成！");

                }
            })
             

            return false;
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

      <div class="container-fluid">

           <div class="col-md-12">
                        <div class="card">
                            <div class="header">
                                <h4 class="title">添加数据库</h4>
                            </div>
                            <div class="content">
                              
 

                                    <div class="row">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label>名称</label>
                                               <input id="txtTitle" type="text" class="form-control border-input" placeholder="本地数据库" value="" />
                                            </div>
                                        </div>
                                    </div>
                                <div class="row">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label>IP</label>
                                               <input id="txtIP" type="text" class="form-control border-input" placeholder="192.168.1.110" value="" />
                                            </div>
                                        </div>
                                    </div>
                                <div class="row">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label>登录名</label>
                                               <input id="txtSa" type="text" class="form-control border-input" placeholder="sa" value="" />
                                            </div>
                                        </div>
                                    </div>
                                  <div class="row">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label>登录密码</label>
                                               <input id="txtPWD" type="text" class="form-control border-input" placeholder="" value="" />
                                            </div>
                                        </div>
                                    </div>


                                    <div class="text-center">
                                        <%--<button type="submit" class="btn btn-info btn-fill btn-wd">Update Profile</button>--%>
                                         <button class="button button--antiman button--text-thick button--text-upper button--size-s button--inverted-alt button--round-s button--border-thick" onclick="return FindContent();" style=" padding-top: 10px; height: 40px;color: #CCC5B9; padding-left:30px; padding-right:30px; width:100%;"><i class="ti-plus"></i><span>保存</span></button>
                                    </div>
                                    <div class="clearfix"></div>
                                
                            </div>
                        </div>
                    </div>
          
     </div>

</asp:Content>
