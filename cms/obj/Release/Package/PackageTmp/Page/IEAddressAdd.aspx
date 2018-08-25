<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" CodeBehind="IEAddressAdd.aspx.cs" Inherits="CMS.Page.IEAddressAdd" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>

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
            if ($("#txtSort").val() != "" && isNaN($("#txtSort").val()))
            {
                MessageBoxShowType("输入正确的排序值！", "info");
                return false;
            }

            var IsKey = true;
            $.ajax({
                type: "Get",
                url: "/ashx/Common.ashx",
                async: false,
                data: { funType: "IsHaveTitle", Title: $("#txtTitle").val() },
                success: function (result) {
                    if (result == "True")
                    {
                        MessageBoxShowType("该名称已存在了！", "info");
                        IsKey = false;
                    }

                }
            })
            if (IsKey == false) return false;

            $.ajax({
                type: "Get",
                url: "/ashx/Common.ashx",
                data: { funType: "AddIEAddress", Title: $("#txtTitle").val(), Type: $("#txtType").val(), Sort: $("#txtSort").val(), IEAddress: $("#txtURL").val() },
                success: function (result) {
                    $("#txtTitle").val("");
                    $("#txtType").val("");
                    $("#txtSort").val("");
                    $("#txtURL").val("");
                    MessageBoxShow("保存完成!");
                }
            })

            return false;
        }

        $(document).ready(function () {

            LoadType();

            $("#ddlType").change(function () {

                $("#txtType").val( $("#ddlType").val());

            });

        });
        function LoadType() {
            var MyThree = $("#ddlType");
            $.ajax({
                type: "Get",
                url: "/ashx/Common.ashx",
                async: false,
                data: { funType: "GetType" },
                success: function (result) {

                    if (result != "") {
                        var dt = JSON.parse(result);
                        var html = "<option ></option>";
                        for (var i = 0; i < dt.Notes.length; i++) {
                            if (dt.Notes[i].Type != "") {
                                html += "<option >" + dt.Notes[i].Type + "</option>";
                            }
                        }
                        MyThree.html(html);
                    }
                }
            })
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

      <div class="container-fluid">

           <div class="col-md-12">
                        <div class="card">
                            <div class="header">
                                <h4 class="title">Add Website</h4>
                            </div>
                            <div class="content">
                              
 

                                    <div class="row">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label>名称</label>
                                               <input id="txtTitle" type="text" class="form-control border-input" placeholder="个人网站" value="" />
                                            </div>
                                        </div>
                                    </div>
                                <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>类型</label>
                                               <input id="txtType" type="text" class="form-control border-input" placeholder="工作" value="" />
                                            </div>
                                        </div>
                                    <div class="col-md-6">
                                            <div class="form-group">
                                                <label>可选择类型</label>
                                              <select id="ddlType"  class="form-control border-input" >
						                        
					                          </select> 
                                            </div>
                                        </div>
                                    </div>
                                <div class="row">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label>排序</label>
                                               <input id="txtSort" type="text" class="form-control border-input" placeholder="0" value="" />
                                            </div>
                                        </div>
                                    </div>
                                  <div class="row">
                                        <div class="col-md-12">
                                            <div class="form-group">
                                                <label>网址</label>
                                               <input id="txtURL" type="text" class="form-control border-input" placeholder="http://wuxiongjun.com" value="" />
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
