<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" CodeBehind="DataBaseQuery.aspx.cs" Inherits="CMS.Page.DataBaseQuery" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="/Style/DataBaseQuery.css" rel="stylesheet" />

  <script>
      //游标获取 标识符
      var A_Z =  new Array("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z");
      var AzIndex = 0;//生成了多少张表的 游标
      var HaveLI = false;//是否已经点击过一个Left or Inner
      var SelAorB = "";//第一次点中名称 A B C等 别名
      var SelColName = "";//第一次选中的列命
      var SelTableName = "";//第一次选中的 表面
      var AllModel = new Array();//保存所有已有连接的数据  计算SQL需要使用它  里面包含的是 Contronls_Model类对象
      var AllTable = new Array();//全部选中的表

      //选中连接保存类
      function Contronls_Model(Jn,Js,An,Bn,Aon,Bon,Atn,Btn)
      {
          this.JoinName = Jn;
          this.JoinString = Js;
          this.A_ColumnName = An;
          this.B_ColumnName = Bn;
          this.A_OtherName = Aon;
          this.B_OtherName = Bon;
          this.A_TableName = Atn;
          this.B_TableName = Btn;
      }
      //选中表的类
      function TableClass()
      {
           this.TableName = "";
           this.OtherName = "";
           this.Colums = new Array();//全部选中列
           this.SelColums = new Array();//选中的列
      }


      $(document).ready(function () {
          LoadDataBase();
          $(".ti-layers-alt").click(function () {

              LoadDataTable($("#ddlDataBse").val());
              MessageBoxShowType("加载完成","info");
          });

          $("#ddlDataBse").change(function () {
              LoadDataTable($("#ddlDataBse").val());
              

          });
          //筛选文本框
          $('#txtFind').bind('input propertychange', function () {
             
              var MyThree = $("#MyThree");

              $.ajax({
                  type: "Get",
                  url: "/ashx/DataBaseDAL.ashx",
                  data: { funType: "GetDataTableLike", ID: $("#ddlDataBse").val(), DataBase: $("#ddlTables").val(),Like:$('#txtFind').val() },
                  success: function (result) {

                      if (result != "") {
                          var dt = JSON.parse(result);
                          var html = "";
                          for (var i = 0; i < dt.Notes.length; i++) {
                              html += "<li><a href=\"#\" onclick=\"AddContorls('" + dt.Notes[i].Text + "')\">" + HtmlFilter(dt.Notes[i].Text) + "</a></li>"
                          }
                          MyThree.html(html);
                          MymtreeClick(jQuery, this, this.document);//加载 li点击事件  在  Mymtree.js中
                      }
                  }

              });

          });


      });

      //加载名称
      function LoadDataBase() {
          var MyThree = $("#ddlDataBse");
          $.ajax({
              type: "Get",
              url: "/ashx/DataBaseDAL.ashx",
              async: false,
              data: { funType: "GetNames" },
              success: function (result) {

                  if (result != "") {
                      var dt = JSON.parse(result);
                      var html = "<option ></option>";
                      var dataBaseName = getCookie("DataBaseName");
                      for (var i = 0; i < dt.Notes.length; i++) {
                          if (dataBaseName == dt.Notes[i].Name) {
                              html += "<option selected='selected' value='" + dt.Notes[i].ID + "'>" + dt.Notes[i].Name + "</option>";
                              LoadDataTable(dt.Notes[i].ID);
                          }
                          else
                              html += "<option value='" + dt.Notes[i].ID + "'>" + dt.Notes[i].Name + "</option>";
                      }
                      MyThree.html(html);
                  }
              }
          })
      }
      //加载数据库
      function LoadDataTable(id) {
          var MyThree = $("#ddlTables");
          $.ajax({
              type: "Get",
              url: "/ashx/DataBaseDAL.ashx",
              async: false,
              data: { funType: "GetDataBase", ID: id },
              success: function (result) {

                  if (result != "") {

                      if (result == "IsNull")
                      {
                          MessageBoxShow("没有数据表！", "info");
                          return;
                      }

                      var dt = JSON.parse(result);
                      var html = "<option ></option>";
                      DataTableName = getCookie("DataTableName");
                      for (var i = 0; i < dt.Notes.length; i++) {
                          if (DataTableName == dt.Notes[i].Text)
                          {
                              html += "<option selected='selected'  value='" + dt.Notes[i].Text + "'>" + dt.Notes[i].Text + "</option>";
                          }
                          else
                            html += "<option value='" + dt.Notes[i].Text + "'>" + dt.Notes[i].Text + "</option>";
                      }
                      MyThree.html(html);
                  }
                  else {
                      MessageBoxShow("出现异常！", "error");
                  }
              }
          })
      }
      //加载数据表
      function AddTables()
      {
          var MyThree = $("#MyThree");

          $.ajax({
              type: "Get",
              url: "/ashx/DataBaseDAL.ashx",
              data: { funType: "GetDataTable", ID: $("#ddlDataBse").val(), DataBase: $("#ddlTables").val() },
              success: function (result) {

                  if (result != "") {
                      var dt = JSON.parse(result);
                      var html = "";
                     
                      for (var i = 0; i < dt.Notes.length; i++) {
                          html += "<li><a href=\"#\" onclick=\"AddContorls('" + dt.Notes[i].Text + "')\">" + HtmlFilter(dt.Notes[i].Text) + "</a></li>"
                      }
                      MyThree.html(html);
                      MymtreeClick(jQuery, this, this.document);//加载 li点击事件  在  Mymtree.js中
                  }
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
      //动态追加单张实体表
      function AddContorls(TableName)
      {
          var Main = $("#ContorlsMain");//主DIV
          var OtherName = GetAZ();

          var Table = new TableClass();
          Table.TableName = TableName;
          Table.OtherName = OtherName
          var html = "<div class=\"TablePanel\">";
          html += "<div class=\"TableHead\">" + TableName + "[" + OtherName + "]</div><hr />";
          html += "<div class=\"TableContent\"><ul >";

          $.ajax({
              type: "Get",
              url: "/ashx/DataBaseDAL.ashx",
              data: { funType: "GetColumns", ID: $("#ddlDataBse").val(), DataBase: $("#ddlTables").val(), Table: TableName },
              async: false,
              success: function (result) {

                  if (result != "") {

                      var dt = JSON.parse(result);
                      
                      for (var i = 0; i < dt.Notes.length; i++) {
                          Table.Colums[Table.Colums.length] = dt.Notes[i].Text; 
                          Table.SelColums[Table.SelColums.length] = dt.Notes[i].Text;
                          html += "<li><table><tr><td >&nbsp;<input onChange=\"ckbChange(this,'" + OtherName + "','" + dt.Notes[i].Text + "');\" type=\"checkbox\" checked class=\"ck" + TableName + "\" /><span>" + dt.Notes[i].Text + "</span></td><td align=\"right\" style=\"width:110px;\">";
                          html += "<button onclick=\"return LeftOrInner('" + dt.Notes[i].Text + "','Left Join','" + OtherName + "','" + TableName + "')\" class=\"TableLeftOrInner\">Left</button>&nbsp;";
                          html += "<button onclick=\"return LeftOrInner('" + dt.Notes[i].Text + "','Inner Join','" + OtherName + "','" + TableName + "')\" class=\"TableLeftOrInner\">Inner</button></td></tr></table> </li>";
                      }
                      AllTable[AllTable.length] = Table;
                  }
              }

          });


          html += " </ul> </div> <hr />";
          html += "<div class=\"TableFooter\">";
          html += "<button class=\"TableBtn\" onclick=\"return CheckAll('ck" + TableName + "','" + OtherName + "');\">全选</button><button class=\"TableBtn\" onclick=\"return UnCheckAll('ck" + TableName + "','" + OtherName + "');\">反选</button>";
          html += "</div></div>";

          var mWidth = 250*(AzIndex+1);
          Main.css("width", mWidth);
          Main.append(html);
      }
      //删除数组指定元素
      function removeByValue(arr, val) {
          for(var i=0; i<arr.length; i++) {
              if(arr[i] == val) {
                  arr.splice(i, 1);
                  break;
              }
          }
      }
      //勾选列 改变事件
      function ckbChange(obj,OtherName,ColumnName)
      {
          //选中
          if ($(obj).is(":checked") == true) {
              //把选中的列 复制为全部列
              for (var i = 0; i < AllTable.length; i++) {
                  if (AllTable[i].OtherName == OtherName) { //判断表名是否一致

                      AllTable[i].SelColums[AllTable[i].SelColums.length] = ColumnName;
                  }

              }
          }
          else { //非选中
              //把选中的列 复制为全部列
              for (var i = 0; i < AllTable.length; i++) {
                  if (AllTable[i].OtherName == OtherName) { //判断表名是否一致

                      for (var j = 0; j < AllTable[i].SelColums.length; j++) {
                          if (AllTable[i].SelColums[j] == ColumnName)//找到相同列了 则删除
                          {
                              AllTable[i].SelColums.splice(j, 1);
                          }
                      }
                  }

              }

          }
      }

      function CheckAll(obj,OtherName) {
          
          //把选中的列 复制为全部列
          for (var i = 0; i < AllTable.length; i++) {
              if (AllTable[i].OtherName == OtherName)
              {
                  AllTable[i].SelColums.length = 0;

                  for (var j = 0; j < AllTable[i].Colums.length; j++) {
                      AllTable[i].SelColums[j] = AllTable[i].Colums[j];
                  }
              }

          }

          $("." + obj).each(function () {
              this.checked = true;
          });
          return false;
      }
      function UnCheckAll(obj, OtherName)
      {
          //把选中的列 清空掉
          for (var i = 0; i < AllTable.length; i++) {
              if (AllTable[i].OtherName == OtherName) {
                  AllTable[i].SelColums.length = 0;
              }
          }

          $("." + obj).each(function () {
              this.checked = false;
          });
          return false;
      }
      function GetAZ()
      {
          var tem = A_Z[AzIndex];
          AzIndex++;
          return tem;
      }

      //点击Left或Inner事件
      function LeftOrInner(ColumnName,LeftOrInner,OtherName,TableName)
      {
          if (HaveLI) //已经点击过一个 则可以配对
          {

              var JoinString = "[" + SelAorB + "]." + SelColName + " " + LeftOrInner + " " +"[" + OtherName + "]." + ColumnName; // [A].ID = [B].ID

              var cm = new Contronls_Model(LeftOrInner, JoinString, SelColName, ColumnName, SelAorB, OtherName, SelTableName, TableName);//保存完整的 一次选中 连接对象
              AllModel[AllModel.length] = cm;//保存到总集合当中

              var Main = $("#ContorlsMainFooter");//底部DIV
              var html = "<div class=\"TablePanelFooter\">" + JoinString + "</div>";

              var mWidth = 300 * AllModel.length;
              Main.css("width", mWidth);
              Main.append(html);

              //初始化选中对象
              HaveLI = false;
              SelAorB = "";
              SelColName = "";
              SelTableName = "";
          }
          else { //首次点击

              HaveLI = true;
              SelAorB = OtherName;
              SelColName = ColumnName;
              SelTableName = TableName;
              MessageBoxShowType("已选中"+ColumnName+" "+LeftOrInner,"info");
          }
          
          return false;
      }

      //生成SQL 方法
      function MakeCode() {
          // AllModel  

          setCookie("DataBaseName", $("#ddlDataBse option:selected").text(), 365);
          setCookie("DataTableName",$("#ddlTables option:selected").text(),365);

          if (AllTable.length == 0)
              return false;

          var code = "";
          if (AllTable.length == 1) {  //===== 单表生成 ======

              if (AllTable[0].SelColums.length == 0) {
                  MessageBoxShowType("请勾选要生成的列!", "info");
                  return false;
              }

              //生成SQL语句
              code += "Select ";
              for (var i = 0; i < AllTable[0].SelColums.length; i++) {
                  code += AllTable[0].SelColums[i] + ",";
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += " From " + AllTable[0].TableName + " Where 1=1";

              //生成方法
              code += "\n\n\n";

              code += "public DataTable Query" + AllTable[0].TableName + "()";
              code += "\n { \n";

              code += "     string sql = @\"Select ";
              for (var i = 0; i < AllTable[0].SelColums.length; i++) {
                  code += AllTable[0].SelColums[i] + ",";
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += "\n From " + AllTable[0].TableName + " Where 1=1 \"; ";
              code += "\n     return  dal.ExecuteDataTable(sql);";

              code += "\n } \n";
              $("#txtCode").val(code);
          }
          else { //========== 多表生成 ==========

              var allCol = 0;
              for (var i = 0; i < AllTable.length; i++) {
                  allCol += AllTable[i].SelColums.length
              }
              if (allCol == 0) {
                  MessageBoxShowType("请勾选要生成的列!", "info");
                  return false;
              }

              if (AllModel.length == 0) {
                  MessageBoxShowType("请指定表之间的关联!", "info");
                  return false;
              }
              if (AllTable.length - 1 != AllModel.length) // 例: 4张表 需要3个表关联
              {
                  MessageBoxShowType("错误的表关联!", "info");
                  return false;
              }

              //生成SQL语句
              code += "Select ";
              for (var i = 0; i < AllTable.length; i++) {

                  for (var j = 0; j < AllTable[i].SelColums.length; j++) {
                      code += AllTable[i].OtherName + "." + AllTable[i].SelColums[j] + ",";
                  }
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += "\n From " + AllModel[0].A_TableName + " AS " + AllModel[0].A_OtherName+"\n";
              var others = new Array();
              others[0] = AllModel[0].A_OtherName;


              for (var i = 0; i < AllModel.length; i++) {

                  if (Contains(others, AllModel[i].A_OtherName)) { //判断该表是否 添加过
                      others[i + 1] = AllModel[i].B_OtherName;
                      code += " " + AllModel[i].JoinName + " " + AllModel[i].B_TableName + " AS " + AllModel[i].B_OtherName + " ON " + AllModel[i].A_OtherName + "." + AllModel[i].A_ColumnName + "=" + AllModel[i].B_OtherName + "." + AllModel[i].B_ColumnName + "\n";
                  }
                  else {
                      others[i + 1] = AllModel[i].A_OtherName;
                      code += " " + AllModel[i].JoinName + " " + AllModel[i].A_TableName + " AS " + AllModel[i].A_OtherName + " ON " + AllModel[i].A_OtherName + "." + AllModel[i].A_ColumnName + "=" + AllModel[i].B_OtherName + "." + AllModel[i].B_ColumnName + "\n";
                  }
              }
              code += " Where 1=1";


              //生成方法
              code += "\n\n\n";

              code += "public DataTable Query" + AllTable[0].TableName + "()";
              code += "\n { \n";
              code += "     string sql = @\"Select ";
              for (var i = 0; i < AllTable.length; i++) {

                  for (var j = 0; j < AllTable[i].SelColums.length; j++) {
                      code += AllTable[i].OtherName + "." + AllTable[i].SelColums[j] + ",";
                  }
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += "\n From " + AllModel[0].A_TableName + " AS " + AllModel[0].A_OtherName + "\n";
              var others = new Array();
              others[0] = AllModel[0].A_OtherName;


              for (var i = 0; i < AllModel.length; i++) {

                  if (Contains(others, AllModel[i].A_OtherName)) { //判断该表是否 添加过
                      others[i + 1] = AllModel[i].B_OtherName;
                      code += " " + AllModel[i].JoinName + " " + AllModel[i].B_TableName + " AS " + AllModel[i].B_OtherName + " ON " + AllModel[i].A_OtherName + "." + AllModel[i].A_ColumnName + "=" + AllModel[i].B_OtherName + "." + AllModel[i].B_ColumnName + "\n";
                  }
                  else {
                      others[i + 1] = AllModel[i].A_OtherName;
                      code += " " + AllModel[i].JoinName + " " + AllModel[i].A_TableName + " AS " + AllModel[i].A_OtherName + " ON " + AllModel[i].A_OtherName + "." + AllModel[i].A_ColumnName + "=" + AllModel[i].B_OtherName + "." + AllModel[i].B_ColumnName + "\n";
                  }
              }
              code += " Where 1=1 \";";

              code += "\n     return  dal.ExecuteDataTable(sql);";
              code += "\n } \n";


              $("#txtCode").val(code);

          }

          return false;
      }
      //数组中是否存在
      function Contains(arr, obj) {
          var i = arr.length;
          while (i--) {
              if (arr[i] === obj) {
                  return true;
              }
          }
          return false;
      }

      function ClearAll()
      {
          $("#MyThree").html("");
          $("#ContorlsMain").html("");
          $("#txtFind").val("");
          $("#txtCode").val("");
          AzIndex = 0;//生成了多少张表的 游标
          HaveLI = false;//是否已经点击过一个Left or Inner
          SelAorB = "";//第一次点中名称 A B C等 别名
          SelColName = "";//第一次选中的列命
          SelTableName = "";//第一次选中的 表面
          AllModel.length =0
          AllTable.length = 0
          return false;     
      }

  </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

 <div class="container-fluid">

          <div class="row">
              <div class="col-md-12">
                   <div class="card" style=" height:100px;">
                       
                       <div class="content" style=" padding:0;">

                           <div class="divFind"> 
                                <table style="width:100%;"  border="0"  >
                                    <tr>
                                        <td align="left" style=" width:270px;"> <div style="margin-top:3px; width:40px; float:left;"><i class="ti-server" style="font-size:26px;"></i></div><select id="ddlDataBse" class="ddlType"></select></td>
                                        <td align="left" style=" width:270px;"> <div style="margin-top:3px; width:40px; float:left;"><i class="ti-layers-alt" style="font-size:26px;"></i></div><select id="ddlTables" class="ddlType"></select></td>
                                        <td align="left" style=" width:470px;"> <input id="txtFind" type="text" class="form-control border-input txtFind" placeholder="查询数据表" value="" /> </td>
                                        <td align="left" style=" width:170px;"><button class="button button--antiman button--text-thick button--text-upper button--size-s button--inverted-alt button--round-s button--border-thick" onclick="return ClearAll();" style=" margin-left:10px; padding-top: 10px; height: 40px;color:#CCC5B9;"><i class="ti-zoom-in"></i><span>清空</span></button></td>
                                        <td align="left" style=" width:170px;"><button class="button button--antiman button--text-thick button--text-upper button--size-s button--inverted-alt button--round-s button--border-thick" onclick="return AddTables();" style=" margin-left:10px; padding-top: 10px; height: 40px;color:#CCC5B9;"><i class="ti-zoom-in"></i><span>搜索</span></button></td>
                                        <td ><button class="button button--antiman button--text-thick button--text-upper button--size-s button--inverted-alt button--round-s button--border-thick" onclick="return MakeCode();" style=" margin-left:10px; padding-top: 10px; height: 40px;color:#CCC5B9;"><i class="ti-control-play"></i><span>生成</span></button></td>
                                    </tr>
                                </table>
 
                           </div>
                         </div>

                   </div>
              </div>
           </div>
          <div class="row">
                    <div class="col-md-2">
                        <div class="card" style=" height:700px;">
                            <div class="header">
                                <h4 class="title"><span id="lblHead">DataBaseTable</span></h4>
                                <p class="category" id="MyMemu">Show all Data Tables</p>
                                 <hr>
                            </div>
                            <div class="content" style=" padding:0;">
                                <div id="chartPreferences" class="ct-chart ct-perfect-fourth" style=" height:440px;">

                                   
                                     <ul id="MyThree" class="mtree bubba mtreeHeight">
                                         
                                      </ul>
                                      
                                    
                                </div>

                                <div class="footer" style="padding-top: 20px;">
                                    <div class="chart-legend">
                                        
                                    </div>
                                    <hr>
                                     
                                </div>
                            </div>
                        </div>
                    </div>
                   <div class="col-md-7">
                        <div class="card" style=" height:700px;">
                            <div class="header">
                                <h4 class="title"><span id="lblHead2">Tables Join</span></h4>
                                <p class="category" id="MyMemu2">LeftJoin or InnerJoin </p>
                                 <hr>
                            </div>
                            <div class="content" style=" padding:0;">
                                <div id="TablesJoin" class="ct-chart ct-perfect-fourth" style=" height:530px; margin:0px;  ">
                                     
                                    <div class="containerWrap">
                                        <div id="ContorlsMain" class="container" style="width:300px;">

                                            <!--  动态生成的模板
                                            <div class="TablePanel">
                                                <div class="TableHead">tbUserInfo[A]</div>
                                                <hr />
                                                <div class="TableContent">
                                                   <ul >
                                                       <li><table><tr><td >&nbsp;<input type="checkbox"  /><span>dSDDFFFSDID</span></td><td align="right" style="width:110px;"><button class="TableLeftOrInner">Left</button>&nbsp;<button class="TableLeftOrInner">Inner</button></td></tr></table> </li>
                                                       <li><table><tr><td >&nbsp;<input type="checkbox"  /><span>dSDDFFFSDID</span></td><td align="right" style="width:110px;"><button class="TableLeftOrInner">Left</button>&nbsp;<button class="TableLeftOrInner">Inner</button></td></tr></table> </li>
                                                       <li><table><tr><td >&nbsp;<input type="checkbox"  /><span>dSDDFFFSDID</span></td><td align="right" style="width:110px;"><button class="TableLeftOrInner">Left</button>&nbsp;<button class="TableLeftOrInner">Inner</button></td></tr></table> </li>
                                                   </ul>
                                                </div>
                                                 <hr />
                                                <div class="TableFooter">
                                                    <button class="TableBtn">全选</button>
                                                    <button class="TableBtn">反选</button>
                                                </div>
                                            </div> -->


                                        </div>
                                    </div>
                                    
                                </div>
                                
                                <div class="footer" style="line-height:0px;">
                                    <div class="chart-legend">
                                         
                                    </div>
                                    <hr>
                                     <div class="containerWrapFooter">
                                        <div id="ContorlsMainFooter" class="container" style="width:200px;">
                                          <!--  <div class="TablePanelFooter">[A].ID LeftJoin [B].ID</div> -->

                                        </div>
                                     </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-3">
                        <div class="card " style=" height:700px;">
                            <div class="header">
                                <h4 class="title"><span id="lblTitle">Code</span>
                                </h4>
                                <p class="category mvs">Code Generation</p>
                                 <hr>
                            </div>
                            <div class="content" style="padding-top: 0px;">
                                <div id="chartActivity" class="ct-chart"  style=" height:500px;margin: 0; ">
                                <textarea id="txtCode" style="width:100%; height:500px; border:none;" spellcheck="false"></textarea>

                                    

                                </div>
                                 
                                <div class="footer" >
                                    <div class="chart-legend">
                                         
                                    </div>
                                    <hr>
                                    <div class="stats">
                                         

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
</asp:Content>
