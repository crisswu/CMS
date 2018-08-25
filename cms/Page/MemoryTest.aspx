<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" ValidateRequest="false" CodeBehind="MemoryTest.aspx.cs" Inherits="CMS.Page.MemoryTest" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="/Style/Memory.css" rel="stylesheet" />
 
<style>
    .treeUL {
      list-style:none; 
       
      padding-right:40px;
    }
    .treeUL li {

           border-bottom:1px solid #e4e9ec;
           height:35px;
           padding-top:5px;
           border-radius:1px;
           padding-left:10px;
        }
</style>

    <script>

        $(document).ready(function () {
          //  LoadTree();
         //   LoadTreeOZ();
            $(window).resize(function () {          //当浏览器大小变化时
                var width = $(".card").width();
                $(".divBlack").css("width", width);
            });
        });

        //优化之前的方案 【旧代码】
        function LoadTree()
        {
             $("#<%=SaveID.ClientID%>").val("");

            var MyThree = $("#MyThree");

            $.ajax({
                type: "Get",
                url: "/ashx/Memory.ashx",
                data: { funType: "load" },
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
                                url: "/ashx/Memory.ashx",
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
            $("#<%=SaveID.ClientID%>").val(ID);
        }
        //加载父类
        function AddFatherTree(FatherID, Name) {

            $("#<%=SaveID.ClientID%>").val(FatherID);
            $("#<%=IsFather.ClientID%>").val(FatherID);//判断是否为父类

            var MyThree = $("#MyThree");

            $("#lblHead").html(Name)

            //获取面包屑 
            $.ajax({
                type: "Get",
                url: "/ashx/Memory.ashx",
                data: { funType: "GetMemu", ID: FatherID },
                success: function (result) {
                    $("#MyMemu").html(result);
                }
            })


            $.ajax({
                type: "Get",
                url: "/ashx/Memory.ashx",
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
                                url: "/ashx/Memory.ashx",
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
            $("#<%=SaveID.ClientID%>").val("");
            $("#<%=IsFather.ClientID%>").val("");
            $("#<%=txtContent.ClientID%>").val("");
            LoadTreeOZ();
        }

        //获取内容
        function GetContent(MyID,name)
        {
            $("#lblTitle").html(name);

            $("#<%=SaveID.ClientID%>").val(MyID);
            $.ajax({
                type: "Get",
                url: "/ashx/Memory.ashx",
                data: { funType: "GetContent", ID: MyID },
                success: function (result) {
                    $("#<%=txtContent.ClientID%>").val(result);
                }
            });
 
        }

       

        //删除节点方法
        function ComfirmDel()
        {
            var str = $(".mtree-active a").html();
            var isFather = $("#<%=IsFather.ClientID%>").val();

            if (str == undefined && isFather == "") return false;

            var txt;

            if (str != undefined) {
                if (str.length > 5 && str.substring(0, 5) == "<span")
                    str = str.substring(60);
                txt = "确定要删除吗？\n [" + str + "]";
            }
            else
                txt = "确定要删除吗？";
            
            x0p({
                title: 'Crss++',
                text: txt,
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
                    SubmiterDelete("Delete");
                }
                else {
                    //取消
                    
                }
               
            });
 
            return false;
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
        function SubmiterDelete(obj)
        {
             $("#<%=IsSave.ClientID%>").val(obj);

              form1.submit();
        }
        function Submiter(obj)
        {
            if ($("#<%=SaveID.ClientID%>").val() == "")
                return false;

            var id = $("#<%=SaveID.ClientID%>").val();

            var isKey = false;
            $.ajax({
                type: "Get",
                url: "/ashx/Memory.ashx",
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

                $("#<%=IsSave.ClientID%>").val(obj);

                form1.submit();
            }
            return false;
        }
        //新增
        function CreateNew()
        {
            var str = $(".mtree-active a").html();
            var FatherID = $("#<%=IsFather.ClientID%>").val();//父节点 ID

            //没选中任何节点.. 为增加 祖宗节点
            if (str == undefined && FatherID=="") {

                x0p({
                    title: '创建祖宗节点',
                    type: 'warning',
                    inputType: 'text',
                    inputPlaceholder: '请输入节点名称',
                    inputColor: '#F29F3F',
                    inputValidator: function (button, value) {
                        if (value == "" && button=='info')
                            return "请输入名称！";
                        if (value.length>20)
                            return '祖宗节点不建议过长！';
                        return null;
                    },
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
                }, function (button, text) {
                    if (button == 'info') {

                      
                        $.ajax({
                            type: "Get",
                            url: "/ashx/Memory.ashx",
                            data: { funType: "NewGrand", ID: text },
                            success: function (result) {
                                if (result == "True") {
                                    x0p('创建完成！', '恭喜Criss++又添加新成员！', 'ok', true);
                                    
                                }
                                else {
                                    //出现异常了..
                                    x0p('Error', result, 'ok', false);
                                }
                            }
                        })

                      
                    }
                });

                
            }
            else {

                //如果是增加 某个子节点 则要判断是要 继续增加 子节点 还是 增加 内容

                x0p({
                    title: 'Crss++',
                    text: "请选择新增类型",
                    animationType: 'slideUp',
                    icon: 'custom',
                    iconURL: 'image/thinking.svg',
                    buttons: [
                        {
                            type: 'error',
                            text: '子节点'
                        },
                        {
                            type: 'info',
                            text: '记忆体'
                        }
                    ]
                }, function (button) {

                    //记忆体
                    if (button == "info") {
                        
                        showMask();//设置表单

                    }
                    else {
                        //子节点

                        x0p({
                            title: '创建子节点',
                            type: 'warning',
                            inputType: 'text',
                            inputPlaceholder: '请输入节点名称',
                            inputColor: '#F29F3F',
                            inputValidator: function (button, value) {
                                if (value == "" && button == 'info')
                                    return "请输入名称！";
                                return null;
                            },
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
                        }, function (button, text) {
                            if (button == 'info') {

                                var fatherid = $("#<%=SaveID.ClientID%>").val();
                                

                                $.ajax({
                                    type: "Get",
                                    url: "/ashx/Memory.ashx",
                                    data: { funType: "NewFather", ID:fatherid,Name: text },
                                    success: function (result) {
                                        if (result == "True") {
                                            x0p('创建完成！', '恭喜Criss++又添加新成员！', 'ok', true);

                                        }
                                        else {
                                            //出现异常了..
                                            x0p('Error', result, 'ok', false);
                                        }
                                    }
                                })


                            }
                        });


                    }

                });

            }
            
            return false;
        }

        //显示遮罩层    
        function showMask() {
 
            var width = $(".card").width();
            $(".divBlack").css("width", width);//设置遮罩层宽度
            $(".divBlack").css("display", "block");//开启遮罩层

            $("#btnNew").css("display", "none");//新增按钮隐藏
            $("#btnDelete").css("display", "none");//删除按钮隐藏
            $("#btnSave").css("display", "none");//保存按钮隐藏
            $("#btnCancel").css("display", "block");//取消按钮显示
            $("#btnInsert").css("display", "block");//保存按钮显示

            $("#<%=txtContent.ClientID%>").val("");//内容文本框清空
            $("#lblTitle").css("display", "none");//标题隐藏
            $("#<%=txtTitle.ClientID%>").css("display", "block");//显示标题文本框
            $(".mvs").css("display", "none");//隐藏 副标题

            $("#<%=IsSave.ClientID%>").val("New");//设置提交类型
            $("#lblTitle").focus();//标题设置 焦点

        }
        //隐藏遮罩层  
        function hideMask() {

            $(".divBlack").css("display", "none");//开启遮罩层

            $("#btnNew").css("display", "block");//新增按钮显示
            $("#btnDelete").css("display", "block");//删除按钮显示
            $("#btnSave").css("display", "block");//保存按钮显示
            $("#btnCancel").css("display", "none");//取消按钮隐藏
            $("#btnInsert").css("display", "none");//保存按钮隐藏
            
            $("#<%=txtContent.ClientID%>").val("");//内容文本框清空
            $("#<%=txtTitle.ClientID%>").val("");//清空标题文本
            $("#lblTitle").css("display", "block");//标题显示
            $("#<%=txtTitle.ClientID%>").css("display", "none");//隐藏标题文本框
            $(".mvs").css("display", "block");//显示 副标题
            $("#<%=IsSave.ClientID%>").val("");//设置提交类型

            return false;
        }

        function InsertSet()
        {
            if ($("#<%=txtTitle.ClientID%>").val()=="")
            {
                MessageBoxShowType("请输入标题", "info");
                return false;
            }
            if ($("#<%=txtContent.ClientID%>").val()=="")
            {
                MessageBoxShowType("请输入记忆体内容", "info");
                return false;
            }
             $("#<%=IsSave.ClientID%>").val("New");//设置提交类型
            form1.submit();

            return false;
        }
    </script>

    <script>

        $(document).ready(function () {
            
            $(".treeUL li").mousemove(function () {
                 
                $(this).css("background-color", "#DDDDDD");
                 
            });
            $(".treeUL li").mouseleave(function () {

                $(this).css("background-color", "#ffffff");

            });


            $(".treeUL li").click(function () {

                $("#myid").show();

            });

           
            

        });

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
     
   
       
     <div class="container-fluid">
          <div class="row">
                    <div class="col-md-3">
                        <div class="card" style=" height:800px;">
                            <div class="header">
                                <h4 class="title"><span id="lblHead">C#</span></h4>
                                <p class="category" id="MyMemu">Welcome to my word</p>
                                 <hr>
                            </div>
                            <div class="content" style=" padding:0;">
                                <div id="chartPreferences" class="ct-chart ct-perfect-fourth" style=" height:540px;">

                                   
                                   <%--  <ul id="MyThree" class="mtree bubba mtreeHeight">
                                         
                                      </ul>--%>

                                    
                                    <ul class="treeUL"  >
                                        <li>C#

                                            <ul id="myid" class="treeUL"   >
                                             <li>C#</li>
                                        <li>JAVA</li>
                                        <li>C++</li>
                                    </ul>

                                        </li>
                                        <li>JAVA</li>
                                        <li>C++</li>
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
                        <div class="card " style=" height:800px;">
                            <div class="header">
                                <h4 class="title"><span id="lblTitle">.NET</span>
                                    
                                     <input id="txtTitle" type="text" runat="server" class="form-control border-input" style="display:none;"    />
                   

                                </h4>
                                <p class="category mvs">Microsoft Visual Studio</p>
                                 <hr>
                            </div>
                            <div class="content" style="padding-top: 0px;">
                                <div id="chartActivity" class="ct-chart"  style=" height:600px;margin: 0; ">

                                    <textarea id="txtContent" spellcheck="false" runat="server" class="MyContent" ></textarea>

                                </div>

                                <div class="footer">
                                    <div class="chart-legend">
                                         
                                    </div>
                                    <hr>
                                    <div class="stats">
                                        <button id="btnNew" class="button button--nuka button--round-s button--text-thick btnHome" onclick="return CreateNew();"  >New</button>
                                        <button id="btnDelete" class="button button--nuka button--round-s button--text-thick btnHome"  onclick="return ComfirmDel('Delete');" >Delete</button>
                                        <button id="btnSave" class="button button--nuka button--round-s button--text-thick btnHome"  onclick="return Submiter('Save');">Save</button>

                                        <button id="btnCancel" class="button button--nuka button--round-s button--text-thick btnHome" style="display:none;"  onclick="return hideMask();">Cancel</button>
                                        <button id="btnInsert" class="button button--nuka button--round-s button--text-thick btnHome" style="display:none;"  onclick="return InsertSet();" >Save</button>

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

    <div class="divBlack"></div>
 <script src="/js/Mymtree.js"></script> 
 
 

</asp:Content>
