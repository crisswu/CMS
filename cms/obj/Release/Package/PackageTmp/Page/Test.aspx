<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" ValidateRequest="false" CodeBehind="Test.aspx.cs" Inherits="CMS.Page.Test" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="/Style/Memory.css" rel="stylesheet" />
 
<style>

</style>

    <script>

        $(document).ready(function () {
 

            window.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
            if (!window.indexedDB) {
                console.log("你的浏览器不支持IndexedDB");
            }

           // indexedDB.deleteDatabase("TreeDB");
 
            OpenIndexedDB(myDB.name, myDB.version);//打开数据库 


            $(window).resize(function () {          //当浏览器大小变化时
                var width = $(".card").width();
                $(".divBlack").css("width", width);
            });
        });

        var Trees = {
            ID: 1,
            Content: ""
        };
        
        var myDB = {
            name: 'TreeDB',//数据库名
            version: 1,//版本号
            db: null
        };

         function LoadFive()
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

                        html += "<li><a href=\"#\" onclick=\"SetID('" + dt.Notes[i].ID + "')\"  >" + dt.Notes[i].Name + "</a><ul>";
                        html = LoadDG(dt.Notes[i].ID, html);
                        html += "</ul></li>";
                    }
                    MyThree.html(html);
                    Trees.Content = html;
                    MymtreeClick(jQuery, this, this.document);//加载 li点击事件  在  Mymtree.js中
                }

            })
         }
        //调用IndexedDB 方法
        function OpenIndexedDB(name, version)
        {
            var version = version || 1;
            var request = window.indexedDB.open(name, version);//创建或打开 IndexedDB
            request.onerror = function (e) {
                console.log('OPen Error!');
            };
            request.onsuccess = function (e) {
                myDB.db = e.target.result;
                setTimeout(function () { getDataByIndex(myDB.db, "TreeTable"); }, 1000);
            };
            request.onupgradeneeded = function (e) { //这里版本号不一致 则可以更新
                var db = e.target.result;
                //不存在表 则创建
                if (!db.objectStoreNames.contains('TreeTable')) {
                    var store = db.createObjectStore('TreeTable', { keyPath: "ID" });
                   
                    store.createIndex('IdIndex', 'ID', { unique: true }); //创建索引 IndexedDB 杀器 提高搜索效率  
                    LoadFive();
                    setTimeout(function () { saveTreeData(myDB.name, myDB.version, "TreeTable", Trees); }, 1000);
                    setTimeout(function () { getDataByIndex(myDB.db, "TreeTable"); }, 2000);
                }
            };
        }

        function InitTree()
        {

        }

        function saveTreeData(dbName, version, storeName, data) {
            var idbRequest = indexedDB.open(dbName, version);
           
            idbRequest.onsuccess = function (e) {
                var db = idbRequest.result;
                var transaction = db.transaction(storeName, 'readwrite');//需先创建事务
                var store = transaction.objectStore(storeName); //访问事务中的objectStore
                store.add(data);//保存数据
                console.log('save data done..');
            }
        }
        //利用索引获取数据 （重点 提高搜索效率）
        function getDataByIndex(db, storeName) {
            var transaction = db.transaction(storeName);
            var store = transaction.objectStore(storeName);
            var index = store.index("IdIndex");
            index.get(1).onsuccess = function (e) {
                var Ts = e.target.result;

                var MyThree = $("#MyThree");
                MyThree.html(Ts.Content);
                MymtreeClick(jQuery, this, this.document);//加载 li点击事件  在  Mymtree.js中
            }
        }
         
 

        function OnlyLoadChild(FatherID)
        {

            if ($(".Liid" + FatherID+":has(ul)").length == 0) {

                $(".Liid" + FatherID + " ul").remove();//清空 节点内的 ul 然后重新追加
                var ul = OnlyLoadDG(FatherID, "");
                $(".Liid" + FatherID).append(ul);
                MymtreeClick(jQuery, this, this.document);//加载 li点击事件  在  Mymtree.js中
            }
            else {
 
            }

           
        }

        //递归加载子节点
        function OnlyLoadDG(FatherID,html) {
            $.ajax({
                type: "Get",
                url: "/ashx/Memory.ashx",
                data: { funType: "getFather", ID: FatherID },
                async: false,
                success: function (result) {

                    if (result != "") {
                        var dt = JSON.parse(result);

                        html += "<ul>";
                        for (var i = 0; i < dt.Notes.length; i++) {

                            if (dt.Notes[i].Type == "2")// 类型为2 是 内容页  其他为父节点
                            {
                                html += "<li><a href=\"#\"   onclick=\"GetContent('" + dt.Notes[i].ID + "','" + dt.Notes[i].Name + "')\" >" + HtmlFilter(dt.Notes[i].Name) + "</a></li>"
                            }
                            else { //为父节点

                                html += "<li><a href=\"#\" >" + "<span class=\"glyphicon glyphicon-circle-arrow-down\"></span>&emsp;" + HtmlFilter(dt.Notes[i].Name) + "</a>";
                                html = OnlyLoadDG(dt.Notes[i].ID, html);
                                html += "</li>";
                            }
                        }
                        html += "</ul>";
                    }
                }
            });
            return html;
        }

        //递归加载子节点
        function LoadDG(FatherID,html)
        {
            $.ajax({
                type: "Get",
                url: "/ashx/Memory.ashx",
                data: { funType: "getFather", ID: FatherID },
                async: false,
                success: function (result) {

                    if (result != "") {
                        var dt = JSON.parse(result);

                        for (var i = 0; i < dt.Notes.length; i++) {

                            if (dt.Notes[i].Type == "2")// 类型为2 是 内容页  其他为父节点
                            {
                                html += "<li><a href=\"#\"   onclick=\"GetContent('" + dt.Notes[i].ID + "','" + dt.Notes[i].Name + "')\" >" + HtmlFilter(dt.Notes[i].Name) + "</a></li>"
                            }
                            else { //为父节点

                                html += "<li><a href=\"#\"    >" + "<span class=\"glyphicon glyphicon-circle-arrow-down\"></span>&emsp;" + HtmlFilter(dt.Notes[i].Name) + "</a><ul>";
                                html = LoadDG(dt.Notes[i].ID, html);
                                html += "</ul></li>";
                            }
                        }
                        
                    }
                }
            });
            return html;
        }


        
        function SetID(ID)
        {
            $("#<%=SaveID.ClientID%>").val(ID);


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
