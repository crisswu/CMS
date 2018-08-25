<%@ Page Title="" Language="C#" MasterPageFile="~/Master/PageMaster.Master" AutoEventWireup="true" CodeBehind="DataBaseEdit.aspx.cs" Inherits="CMS.Page.DataBaseEdit" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
 
    <link href="/Style/DataBaseEdit.css" rel="stylesheet" />

  <script>
      //游标获取 标识符
      var A_Z =  new Array("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z");
      var AzIndex = 0;//生成了多少张表的 游标
      var HaveLI = false;//是否已经点击过一个Left or Inner
      var SelAorB = "";//第一次点中名称 A B C等 别名
      var IsHaveTable = false;//是否已经生成过表
      var AllTable;//全部选中的表

 
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
                  data: { funType: "GetDataTableLike", ID: $("#ddlDataBse").val(), DataBase: $("#ddlTables").val(), Like: $('#txtFind').val() },
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
                          //   html += "<option value='" + dt.Notes[i].ID + "'>" + dt.Notes[i].Name + "</option>";
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
                          // html += "<option value='" + dt.Notes[i].Text + "'>" + dt.Notes[i].Text + "</option>";
                          if (DataTableName == dt.Notes[i].Text) {
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
          if (IsHaveTable) return;

          IsHaveTable = true;//如果已经生成过表

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
                          html += "<li><table><tr><td >&nbsp;<input onChange=\"ckbChange(this,'" + OtherName + "','" + dt.Notes[i].Text + "');\" type=\"checkbox\" checked class=\"ck" + TableName + "\" /><span>" + dt.Notes[i].Text + "</span></td>";
                         
                          html += "</tr></table> </li>";
                      }
                      AllTable = Table;
                  }
              }

          });


          html += " </ul> </div> <hr />";
          html += "<div class=\"TableFooter\">";
          html += "<button class=\"TableBtn\" onclick=\"return CheckAll('ck" + TableName + "','" + OtherName + "');\">全选</button><button class=\"TableBtn\" onclick=\"return UnCheckAll('ck" + TableName + "','" + OtherName + "');\">反选</button>";
          html += "</div></div>";

          var mWidth = 250*(AzIndex+1);
        //  Main.css("width", mWidth);
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

              AllTable.SelColums[AllTable.SelColums.length] = ColumnName;
          }
          else { //非选中
              //把选中的列 复制为全部列

                      for (var j = 0; j < AllTable.SelColums.length; j++) {
                          if (AllTable.SelColums[j] == ColumnName)//找到相同列了 则删除
                          {
                              AllTable.SelColums.splice(j, 1);
                          }
                      }

          }
      }

      function CheckAll(obj,OtherName) {
          
          //把选中的列 复制为全部列

                  for (var j = 0; j < AllTable.Colums.length; j++) {
                      AllTable.SelColums[j] = AllTable.Colums[j];
                  }

          $("." + obj).each(function () {
              this.checked = true;
          });
          return false;
      }
      function UnCheckAll(obj, OtherName)
      {
          //把选中的列 清空掉
 
          AllTable.SelColums.length = 0;
 

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


      //生成SQL 方法
      function MakeCode() {
 
          setCookie("DataBaseName", $("#ddlDataBse option:selected").text(), 365);
          setCookie("DataTableName", $("#ddlTables option:selected").text(), 365);

          var code = "";

              if (AllTable.SelColums.length == 0) {
                  MessageBoxShowType("请勾选要生成的列!", "info");
                  return false;
              }

              //生成Insert语句
              code += "Insert Into "+AllTable.TableName+" (";
              for (var i = 0; i < AllTable.SelColums.length; i++) {
                  code += AllTable.SelColums[i] + ",";
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += ") Values(";
              for (var i = 0; i < AllTable.SelColums.length; i++) {
                  code += "'\"+"+AllTable.SelColums[i] + "+\"',";
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += ")";

              code += "\n\n";
              
              //生成Update语句
              code += "Update " + AllTable.TableName + " Set ";
              for (var i = 0; i < AllTable.SelColums.length; i++) {
                  code += AllTable.SelColums[i] + "='\"+" + AllTable.SelColums[i] + "+\"',";
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += " Where 1=1";
              
                
              //生成Insert方法
              code += "\n\n";
              code += "//========== 生成 Insert 方法 =========="
              code += "\n";

              code += "public void Insert" + AllTable.TableName + "(";
              for (var i = 0; i < AllTable.SelColums.length; i++) {
                  code += "string " + AllTable.SelColums[i]+",";
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += ")";
              code += "\n { \n";

              code += "     string sql = @\"Insert Into "+AllTable.TableName+" (";
              for (var i = 0; i < AllTable.SelColums.length; i++) {
                  code += AllTable.SelColums[i] + ",";
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += ") Values(";
              for (var i = 0; i < AllTable.SelColums.length; i++) {

                  if ($(".checkedRadio").find("input").val() == "1") {  //无
                      code += "'\"+" + AllTable.SelColums[i] + "+\"',";
                  }
                  else if ($(".checkedRadio").find("input").val() == "2") { //dt.Rows[0]
                      code += "'\"+dt.Rows[0][\"" + AllTable.SelColums[i] + "\"]+\"',";
                  }
                  else {
                      code += "'\"+dt.Rows[i][\"" + AllTable.SelColums[i] + "\"]+\"',";
                  }

                 
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += ")\"; ";
              code += "\n     dal.ExecuteNonQuery(sql);";

              code += "\n } \n";


             //生成Update方法
              code += "\n\n";
              code += "//========== 生成 Update 方法 =========="
              code += "\n";

              code += "public void Update" + AllTable.TableName + "(";
              for (var i = 0; i < AllTable.SelColums.length; i++) {
                  code += "string " + AllTable.SelColums[i] + ",";
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += ")";
              code += "\n { \n";

              code += "     string sql = @\"Update " + AllTable.TableName + " Set ";
              for (var i = 0; i < AllTable.SelColums.length; i++) {
                  code += AllTable.SelColums[i] + "='\"+" + AllTable.SelColums[i] + "+\"',";
              }
              code = code.substring(0, code.length - 1); //除去最后一个 逗号
              code += " Where 1=1 \"; ";
              code += "\n     dal.ExecuteNonQuery(sql);";

              code += "\n } \n";




              $("#txtCode").val(code);
          
         

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


      function ClearAll() {
          $("#MyThree").html("");
          $("#ContorlsMain").html("");
          $("#txtFind").val("");
          $("#txtCode").val("");
          AzIndex = 0;//生成了多少张表的 游标
          HaveLI = false;//是否已经点击过一个Left or Inner
          SelAorB = "";//第一次点中名称 A B C等 别名
          IsHaveTable = false;//是否已经生成过表
          AllTable.length =0

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
                   <div class="col-md-3">
                        <div class="card" style=" height:700px;">
                            <div class="header">
                                <h4 class="title"><span id="lblHead2">Inser Or Update</span></h4>
                                <p class="category" id="MyMemu2">Table Selection</p>
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
                                        <div id="ContorlsMainFooter" class="container" style="width:300px;">
                                              
                                           <div class="ulRido"><input type="radio" name="radio-btn" value="1" /><span>无</span></div>
                                             <div class="ulRido1"><input type="radio" name="radio-btn"  value="2" /><span>dt.Rows[0]</span></div>
                                             <div class="ulRido2"><input type="radio" name="radio-btn"  value="3" /><span>dt.Rows[i]</span></div>
 

                                        </div>
                                     </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-7">
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
    

  <script src="/js/index.js"></script>
    
    <script>

        $(".ulRido").find(".radio-btn").addClass("checkedRadio");

    </script>
</asp:Content>
