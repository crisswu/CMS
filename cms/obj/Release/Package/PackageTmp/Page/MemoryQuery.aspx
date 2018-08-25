<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" ValidateRequest="false"  AutoEventWireup="true" CodeBehind="MemoryQuery.aspx.cs" Inherits="CMS.Page.MemoryQuery" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="/Style/MemoryQuery.css" rel="stylesheet" />
 

    <script>

        $(document).ready(function () {
           // LoadTree();
            LoadTreeOZ();
        });
        //优化之前的方案[旧代码]
        function LoadTree()
        {
             $("#SaveID").val("");

            var MyThree = $("#MyThree");

            var strWhere = $("#demo_value").val();// 取出筛选条件中的ID集合

            $.ajax({
                type: "Get",
                url: "/ashx/MemoryQuery.ashx",
                data: { funType: "load", where: strWhere },
                success: function (result) {

                    var dt = JSON.parse(result);
                    var html = "";
                    for (var i = 0; i < dt.Notes.length; i++) {

                        if (dt.Notes[i].Type == "2")// 类型为2 是 内容页  其他为父节点
                        {
                            html += "<li><a href=\"#\" onclick=\"GetContent('" + dt.Notes[i].ID + "','" + dt.Notes[i].Name + "')\">" + HtmlFilter(dt.Notes[i].Name) + "</a></li>"
                        }
                        else {
                            html += "<li><a href=\"#\" onclick=\"SetID('" + dt.Notes[i].ID + "')\"  >" + dt.Notes[i].Name + "</a><ul>";

                            $.ajax({
                                type: "Get",
                                url: "/ashx/MemoryQuery.ashx",
                                data: { funType: "getFather", ID: dt.Notes[i].ID },
                                async: false,
                                success: function (result) {

                                    if (result != "") {
                                        var dt = JSON.parse(result);

                                        for (var i = 0; i < dt.Notes.length; i++) {

                                            if (dt.Notes[i].Type == "2")// 类型为2 是 内容页  其他为父节点
                                            {
                                                html += "<li><a href=\"#\"  onclick=\"GetContent('" + dt.Notes[i].ID + "','" + dt.Notes[i].Name + "')\">" + HtmlFilter(dt.Notes[i].Name) + "</a></li>"
                                            }
                                            else { //为父节点

                                                html += "<li><a href=\"#\" onclick=\"AddFatherTree('" + dt.Notes[i].ID + "','" + dt.Notes[i].Name + "')\" >" + "<span class=\"glyphicon glyphicon-circle-arrow-down\"></span>&emsp;" + HtmlFilter(dt.Notes[i].Name) + "</a></li>"
                                            }
                                        }
                                    }
                                }
                            });
                            html += "</ul></li>";
                        }

                    }
                    MyThree.html(html);
                    MymtreeClick(jQuery, this, this.document);//加载 li点击事件  在  Mymtree.js中
                }

            })
        }


         //优化后的 方案
        function LoadTreeOZ()
        {
             $("#<%=SaveID.ClientID%>").val("");

            var MyThree = $("#MyThree");

            $.ajax({
                type: "Get",
                url: "/ashx/Memory.ashx",
                data: { funType: "loadOZ" },
                success: function (result) {

                    var dt = JSON.parse(result);
                    var html = "";
                    for (var i = 0; i < dt.Notes.length; i++) {

                        if (dt.Notes[i].FatherID == "0")//从根节点出发
                        {
                                html += "<li><a href=\"#\" onclick=\"SetID('" + dt.Notes[i].ID + "')\"  >" + dt.Notes[i].Name + "</a><ul>";
                                for (var j = 0; j < dt.Notes.length; j++) { //添加每一个

                                    if (dt.Notes[j].FatherID == dt.Notes[i].ID)//为子类时
                                    {
                                        if (dt.Notes[j].Type == "2")// 类型为2 是 内容页  其他为父节点
                                        {
                                            html += "<li><a href=\"#\"  onclick=\"GetContent('" + dt.Notes[j].ID + "','" + dt.Notes[i].Name + "')\">" + HtmlFilter(dt.Notes[j].Name) + "</a></li>"
                                        }
                                        else { //为父节点

                                            html += "<li><a href=\"#\" onclick=\"AddFatherTree('" + dt.Notes[j].ID + "','" + dt.Notes[j].Name + "')\" >" + "<span class=\"glyphicon glyphicon-circle-arrow-down\"></span>&emsp;" + HtmlFilter(dt.Notes[j].Name) + "</a></li>"
                                        }
                                    }
                                }
                                html += "</ul></li>";
                        }
                  
                    }
                    MyThree.html(html);
                    MymtreeClick(jQuery, this, this.document);//加载 li点击事件  在  Mymtree.js中
                }

            })
        }

         function SetID(ID)
        {
            $("#SaveID").val(ID);
        }
        //加载父类
        function AddFatherTree(FatherID, Name) {

            $("#SaveID").val(FatherID);
            $("#IsFather").val(FatherID);//判断是否为父类

            var MyThree = $("#MyThree");

            $("#lblHead").html(Name)

            //获取面包屑 
            $.ajax({
                type: "Get",
                url: "/ashx/MemoryQuery.ashx",
                data: { funType: "GetMemu", ID: FatherID },
                success: function (result) {
                    $("#MyMemu").html(result);
                }
            })


            $.ajax({
                type: "Get",
                url: "/ashx/MemoryQuery.ashx",
                data: { funType: "getFather", ID: FatherID },
                success: function (result) {

                    var dt = JSON.parse(result);
                    var html = "";
                    for (var i = 0; i < dt.Notes.length; i++) {

                        if (dt.Notes[i].Type == "2")// 类型为2 是 内容页  其他为父节点
                        {
                            html += "<li><a href=\"#\" onclick=\"GetContent('" + dt.Notes[i].ID + "','" + dt.Notes[i].Name + "')\">" + HtmlFilter(dt.Notes[i].Name) + "</a></li>"
                        }
                        else {

                            html += "<li><a href=\"#\"  onclick=\"SetID('" + dt.Notes[i].ID + "')\"  >" + "<span class=\"glyphicon glyphicon-circle-arrow-down\"></span>&emsp;" + dt.Notes[i].Name + "</a><ul>";

                            $.ajax({
                                type: "Get",
                                url: "/ashx/MemoryQuery.ashx",
                                data: { funType: "getFather", ID: dt.Notes[i].ID },
                                async: false,
                                success: function (result) {

                                    if (result != "") {
                                        var dt = JSON.parse(result);

                                        for (var i = 0; i < dt.Notes.length; i++) {

                                            if (dt.Notes[i].Type == "2")// 类型为2 是 内容页  其他为父节点
                                            {
                                                html += "<li><a href=\"#\" onclick=\"GetContent('" + dt.Notes[i].ID + "','" + dt.Notes[i].Name + "')\">" + HtmlFilter(dt.Notes[i].Name) + "</a></li>"
                                            }
                                            else { //为父节点

                                                html += "<li><a href=\"#\" onclick=\"AddFatherTree('" + dt.Notes[i].ID + "')\" >" + "<span class=\"glyphicon glyphicon-circle-arrow-down\"></span>&emsp;" + HtmlFilter(dt.Notes[i].Name) + "</a></li>"
                                            }
                                        }
                                    }
                                }
                            });
                        }
                        html += "</ul></li>";

                    }
                    MyThree.html(html);
                    MymtreeClick(jQuery, this, this.document); //加载 li点击事件  在  Mymtree.js中
                }

            })

        }
        //返回主页
        function goHome()
        {
            $("#SaveID").val("");
            $("#IsFather").val("");
            $("#txtContent").val("");
            LoadTreeOZ();
        }

        //获取内容
        function GetContent(MyID,name)
        {
            $("#lblTitle").html(name);

            $("#SaveID").val(MyID);
            $.ajax({
                type: "Get",
                url: "/ashx/MemoryQuery.ashx",
                data: { funType: "GetContent", ID: MyID },
                success: function (result) {
                    $("#txtContent").val(result);
                }
            });
 
        }
        //过滤网页关键字
        function HtmlFilter(str) {
            if (str.indexOf('<') >= 0) {
                str = str.replace("<", "&lt;");
            }
            if (str.indexOf('>') >= 0) {
                str = str.replace(">", "&gt;");
            }
            return str;
        }
         

        //条件查询
        function FindContent()
        {
            var FindWhere = $("#txtFind").val(); //查询条件
            if(FindWhere=="")
            {
                MessageBoxShowType("请输入查询条件!","info");
                return false;
            }

            $("#SaveID").val("");

            var MyThree = $("#MyThree");

            var strWhere = $("#demo_value").val();// 取出筛选条件中的ID集合

            $.ajax({
                type: "Get",
                url: "/ashx/FindMemory.ashx",
                data: { funType: "Find", where: strWhere,AndWhere:FindWhere },
                success: function (result) {

                    if(result!="")
                    {
                        var dt = JSON.parse(result);
                        var html = "";

                        var FatherIDs = new Array();//保存 祖宗ID
                        var FatherNames= new Array();//保存 祖宗名字

                        for (var i = 0; i < dt.Notes.length; i++) {
                            if(contains(FatherIDs,dt.Notes[i].GrandID)== false)//存在
                            {
                                FatherIDs[FatherIDs.length] = dt.Notes[i].GrandID ;
                                FatherNames[FatherNames.length] = dt.Notes[i].GrandName ;
                            }
                        }
                        //先遍历 祖宗, 已祖宗添加 小弟
                        for (var j = 0; j < FatherIDs.length; j++) {

                            html += "<li><a href=\"#\" onclick=\"SetID('" + FatherIDs[j] + "')\"  >" + FatherNames[j] + "</a><ul>";
                            for (var i = 0; i < dt.Notes.length; i++) {

                                if(FatherIDs[j] == dt.Notes[i].GrandID)
                                  html += "<li><a href=\"#\" onclick=\"GetContent('" + dt.Notes[i].ID + "','" + dt.Notes[i].Name + "')\">" + HtmlFilter(dt.Notes[i].Name) + "</a></li>"

                            }
                            html += "</ul></li>";
    
                        }
                        MyThree.html(html);
                        MymtreeClick(jQuery, this, this.document);//加载 li点击事件  在  Mymtree.js中
                    }
                    else{
                        MessageBoxShowType("没有找到结果!","info");
                    }
            }

            })

            return false;
        }

        function contains(arr, obj) {  
            var i = arr.length;  
            while (i--) {  
                if (arr[i] === obj) {  
                    return true;  
                }  
            }  
            return false;  
        }  
        function Submiter(obj)
        {
            if ($("#SaveID").val() == "")
                return false;

            var id = $("#SaveID").val();

            var isKey = false;
            $.ajax({
                type: "Get",
                url: "/ashx/FindMemory.ashx",
                data: { funType: "GetType", ID: id },
                async: false,
                success: function (result) {
                    
                    if (result == "2")
                    {
                        isKey = true;
                    }

                }
            });

            if (isKey) {

                $("#IsSave").val(obj);

                form1.submit();
            }
            return false;
        }
    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server"  ClientIDMode="Static">

    <div class="container-fluid">

          <div class="row">
              <div class="col-md-12">
                   <div class="card" style=" height:200px;">
                       
                       <div class="content" style=" padding:0;">

                           <div class="divFind"> 
                                <table style="width:100%;"   >
                                    <tr>
                                        <td> <input id="txtFind" type="text" class="form-control border-input txtFind" placeholder="搜索" value="" /> </td>
                                        <td  style=" width:120px"><button class="button button--antiman button--text-thick button--text-upper button--size-s button--inverted-alt button--round-s button--border-thick" onclick="return FindContent();" style=" padding-top: 10px; height: 40px;color:#CCC5B9;"><i class="ti-zoom-in"></i><span>搜索</span></button></td>
                                    </tr>
                                </table>
                                
                           </div>
                           <div class="divSerch">
                                <div class="divSerchBorder">
                                     
                                    <div id="divTaoBao" style="height:50px;"></div>
                                    <input id="demo_value" runat="server" type="hidden" value="" />
                                </div>
                           </div>
                            

                            <div class="footer">
                                    <div class="chart-legend">
                                        
                                    </div>
                                    <hr>
 
                                </div>
                         </div>

                   </div>
              </div>
           </div>
          <div class="row">
                    <div class="col-md-3">
                        <div class="card" style=" height:600px;">
                            <div class="header">
                                <h4 class="title"><span id="lblHead">C#</span></h4>
                                <p class="category" id="MyMemu">Welcome to my word</p>
                                 <hr>
                            </div>
                            <div class="content" style=" padding:0;">
                                <div id="chartPreferences" class="ct-chart ct-perfect-fourth" style=" height:340px;">

                                   
                                     <ul id="MyThree" class="mtree bubba mtreeHeight">
                                         
                                      </ul>
                                      
                                    
                                </div>

                                <div class="footer" style="padding-top: 20px;">
                                    <div class="chart-legend">
                                        
                                    </div>
                                    <hr>
                                    <div class="stats">
                                        <button class="button button--nuka button--round-s button--text-thick btnHome" onclick="goHome();" >Home</button>
                                        
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-9">
                        <div class="card " style=" height:600px;">
                            <div class="header">
                                <h4 class="title"><span id="lblTitle">.NET</span>
                                    
                                     <input id="txtTitle" type="text" runat="server" class="form-control border-input" style="display:none;"    />
                   

                                </h4>
                                <p class="category mvs">Microsoft Visual Studio</p>
                                 <hr>
                            </div>
                            <div class="content" style="padding-top: 0px;">
                                <div id="chartActivity" class="ct-chart"  style=" height:400px;margin: 0; ">

                                    <textarea id="txtContent" spellcheck="false" runat="server" class="MyContent" ></textarea>

                                </div>
                                 
                                <div class="footer">
                                    <div class="chart-legend">
                                         
                                    </div>
                                    <hr>
                                    <div class="stats">
                                        <button id="btnSave" class="button button--nuka button--round-s button--text-thick btnHome"  onclick="return Submiter('Save');">Save</button>

                                        <asp:HiddenField ID="SaveID" runat="server" />
                                        <asp:HiddenField ID="IsSave" runat="server" />
                                        <asp:HiddenField ID="IsFather" runat="server" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

     </div>


     <script src="/js/Mymtree.js"></script> 

        <script>

        var data = <%=data %>;

        $('#divTaoBao').comboboxfilter({
            url: '',
            scope: 'FilterQuery2',
            multiple: true,
            data: data,
            onChange: function (newValue) {
                $('#demo_value').val(newValue);
            }
        });


    </script>
</asp:Content>
