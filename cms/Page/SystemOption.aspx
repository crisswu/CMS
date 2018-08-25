<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" CodeBehind="SystemOption.aspx.cs" Inherits="CMS.Page.SystemOption" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>

        .MyButtion {
           width:95%;
           margin-top:30px;
           margin-left:50px;
           border-radius: 5px;   
           
        }
    </style>
    <script>

        function GoURL(url)
        {
            document.location.href = url;

            return false;
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="container-fluid">

          <div class="row">
              <div class="col-md-12">
                   <div class="card" style=" height:450px;">
                       
                       <div class="content" style=" padding:0;">

                           
                            <div class="row">
                                <button class="button button--tamaya button--border-thick MyButtion" onclick="return GoURL('MemoryDisplay.aspx')" data-text="记忆项显示切换">开启</button>
                            </div>
                           <div class="row">
                                <button class="button button--tamaya button--border-thick MyButtion"  onclick="return GoURL('MemoryMove.aspx')" data-text="记忆项整理">开启</button>

                            </div>
                             <div class="row">
                                <button class="button button--tamaya button--border-thick MyButtion" onclick="return GoURL('Option_DataBase.aspx')" data-text="数据库设定">开启</button>
                            </div>
                             
                           <div class="row">
                                <button class="button button--tamaya button--border-thick MyButtion"  data-text="Loading">等待开发</button>

                            </div>
                           <div class="row">
                                <button class="button button--tamaya button--border-thick MyButtion"  data-text="Loading">等待开发</button>

                            </div>
                           
                         </div>

                   </div>
              </div>
           </div>
        

     </div>
</asp:Content>
