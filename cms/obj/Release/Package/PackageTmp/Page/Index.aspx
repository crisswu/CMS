<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="CMS.Page.Index" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>

        $(document).ready(function () {

            $("#mylove").width(document.body.clientWidth);
            $("#mylove").height(document.body.clientHeight);

        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
 <iframe src="../Index.html"   id="mylove" name="mylove" ></iframe>

</asp:Content>
