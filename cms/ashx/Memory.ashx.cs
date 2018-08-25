using CMS.App_Code;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;

namespace CMS.ashx
{
    /// <summary>
    /// Memory 的摘要说明
    /// </summary>
    public class Memory : IHttpHandler
    {
        SQLite dal;
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";

            dal = new SQLite(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"));

            if (context.Request.QueryString["funType"] == "load")
            {
                string sql = "Select ID,Name,Type,FatherID,GrandID,OrderBy,IsNet,Visble from Notes where FatherID=0 and Visble=0 Order by OrderBy";
                DataTable dt = dal.ExecuteDataTable(sql);
                context.Response.Write(ConvertDataTableToJson(dt));
            }
            else if (context.Request.QueryString["funType"] == "loadOZ")
            {
                string sql = @" Select ID,Name,Type,FatherID,GrandID,OrderBy,IsNet,Visble from Notes where FatherID=0 and Visble=0  
                                 union all
                                 Select ID, Name, Type, FatherID, GrandID, OrderBy, IsNet, Visble from Notes where FatherID in (Select ID from Notes where FatherID = 0 and Visble = 0 )   ";
                DataTable dt = dal.ExecuteDataTable(sql);
                IEnumerable<DataRow> rows = dt.AsEnumerable().Select(p => p).OrderBy(p => p.Field<int>("OrderBy"));
                DataTable dd = rows.CopyToDataTable();
                dd.TableName = "Notes";

                context.Response.Write(ConvertDataTableToJson(dd));

            }
            else if (context.Request.QueryString["funType"] == "getFather")
            {
                string sql = "Select ID,Name,Type,FatherID,GrandID,OrderBy,IsNet,Visble from Notes where FatherID='" + context.Request.QueryString["ID"] + "' Order by OrderBy";
                DataTable dtDetail = dal.ExecuteDataTable(sql);
                context.Response.Write(ConvertDataTableToJson(dtDetail));
            }
            else if (context.Request.QueryString["funType"] == "GetMemu")
            {
                context.Response.Write(GetMemu(context.Request.QueryString["ID"]));
            }
            else if (context.Request.QueryString["funType"] == "GetContent")
            {
                context.Response.Write(GetContent(context.Request.QueryString["ID"]));
            }
            else if (context.Request.QueryString["funType"] == "GetTitle")
            {
                context.Response.Write(GetTitle(context.Request.QueryString["ID"]));
            }
            else if (context.Request.QueryString["funType"] == "UpdateContent")
            {
                string str = UpdateContent(context.Request.QueryString["ID"], context.Request.QueryString["Content"]);
                context.Response.Write(str);
            }
            else if (context.Request.QueryString["funType"] == "NewGrand")
            {
                string str = SaveGrand(context.Request.QueryString["ID"]);
                context.Response.Write(str);
            }
            else if (context.Request.QueryString["funType"] == "NewFather")
            {
                string str = SaveFather(context.Request.QueryString["ID"], context.Request.QueryString["Name"]);
                context.Response.Write(str);
            }
            else if (context.Request.QueryString["funType"] == "GetType")
            {
                context.Response.Write(GetTypeByID(context.Request.QueryString["ID"]));
            }
            else if (context.Request.QueryString["funType"] == "GetAll")
            {
                string sql = "Select  ID,Name,Type,'' as Content,FatherID,GrandID,OrderBy,IsNet,Visble from Notes Order by ID";
                DataTable dt = dal.ExecuteDataTable(sql);
                context.Response.Write(SetAllJson(dt));
            }
        }

        //返回全部的 JSON格式
        public string SetAllJson(DataTable dt)
        {
            StringBuilder sbs = new StringBuilder();
            if (dt.Rows.Count > 0)
            {
                sbs.Append("[");
                string str = "";
                foreach (DataRow dr in dt.Rows)
                {
                    string result = "";
                    foreach (DataColumn dc in dt.Columns)
                    {
                        result += string.Format(",\"{0}\":\"{1}\"",
                            dc.ColumnName, Filter(dr[dc.ColumnName].ToString()));
                    }
                    result = result.Substring(1);
                    result = ",{" + result + "}";
                    str += result;
                }
                str = str.Substring(1);
                sbs.Append(str);
                sbs.Append("]");
            }
            else
            {
                sbs.Append("");
            }
            return sbs.ToString();
        }

        public string ConvertDataTableToJson(DataTable dt)
        {
            StringBuilder sbs = new StringBuilder();
            if (dt.Rows.Count > 0)
            {
                sbs.Append("{\"" + dt.TableName + "\":[");
                string str = "";
                foreach (DataRow dr in dt.Rows)
                {
                    string result = "";
                    foreach (DataColumn dc in dt.Columns)
                    {
                        result += string.Format(",\"{0}\":\"{1}\"",
                            dc.ColumnName, Filter(dr[dc.ColumnName].ToString()));
                    }
                    result = result.Substring(1);
                    result = ",{" + result + "}";
                    str += result;
                }
                str = str.Substring(1);
                sbs.Append(str);
                sbs.Append("]}");
            }
            else
            {
                sbs.Append("");
            }
            return sbs.ToString();
        }
        public static string Filter(string str)
        {
            if (str.IndexOf("\"") >= 0)
                str = str.Replace("\"", "");
            return str;
        }

        public string GetMemu(string ID)
        {
            DataTable dt = dal.ExecuteDataTable("Select Name,FatherID From Notes where ID ='" + ID + "'");
            string name = dt.Rows[0]["Name"].ToString();
            string MyFatherID = dt.Rows[0]["FatherID"].ToString();

            string URL = "<a href=\"#\" onclick=\"AddFatherTree('" + ID + "','" + name + "')\">" + name + "</a>";

            if (MyFatherID == "0")
            {
                return URL;
            }

            return GetDGMemu(dt.Rows[0]["FatherID"].ToString(), URL);
            //return "<a href=\"#\" onclick=\"AddFatherTree('1','C#')\">C#</a>  &emsp;<span class=\"glyphicon glyphicon-circle-arrow-right\"></span> &emsp;<a href=\"#\" onclick=\"AddFatherTree('2','语法')\">语法</a>";
        }
        //递归出父类的信息
        public string GetDGMemu(string FatherID, string URL)
        {
            DataTable dt = dal.ExecuteDataTable("Select ID,Name,FatherID From Notes where ID ='" + FatherID + "'");
            if (dt.Rows.Count > 0)
            {
                string ID = dt.Rows[0]["ID"].ToString();
                string name = dt.Rows[0]["Name"].ToString();
                string MyFatherID = dt.Rows[0]["FatherID"].ToString();

                if (MyFatherID == "0")
                    return URL = "<a href=\"#\" onclick=\"AddFatherTree('" + ID + "','" + name + "')\">" + name + "</a>  &emsp;<span class=\"glyphicon glyphicon-circle-arrow-right\"></span> &emsp;" + URL;
                else
                {
                    URL = "<a href=\"#\" onclick=\"AddFatherTree('" + ID + "','" + name + "')\">" + name + "</a>  &emsp;<span class=\"glyphicon glyphicon-circle-arrow-right\"></span> &emsp;" + URL;
                    return GetDGMemu(MyFatherID, URL);
                }
            }
            else
                return "";
        }
        //获取内容
        public string GetContent(string ID)
        {
           return dal.ExecuteString("Select Content From Notes where ID='"+ID+"'");
        }
        //获取标题
        public string GetTitle(string ID)
        {
            return dal.ExecuteString("Select Name From Notes where ID='" + ID + "'");
        }

        public string UpdateContent(string ID, string Content)
        {
            try
            {
                string sql = @"Update Notes Set Content='" + FilterIn(Content) + "' where ID ='" + ID + "'";
                dal.ExecuteNonQuery(sql);

                UpdateVersion();

                return "True";
            }
            catch (Exception ep)
            {
                return ep.Message;
            }


        }
        //保存内容
        public string SaveGrand(string Content)
        {
            try
            {
                int maxID = dal.ExecuteInt("Select Max(ID) from Notes");
                maxID++;
                string sql = "Insert into Notes(ID,Name,Type,Content,FatherID,GrandID,OrderBy) values(" + maxID + ",'" + Content + "',0,'',0,0," + maxID + ")";
                dal.ExecuteNonQuery(sql);

                UpdateVersion();

                return "True";
            }
            catch (Exception ep)
            {
                return ep.Message;
            }

        }
        //保存内容
        public string SaveFather(string ID,string Name)
        {
            try
            {
                int maxID = dal.ExecuteInt("Select Max(ID) from Notes");
                maxID++;
                string GrandID = dal.ExecuteString("Select GrandID from Notes where ID=" + ID + "");
                if (GrandID == "0")
                    GrandID = ID;
                string sql = "Insert into Notes(ID,Name,Type,Content,FatherID,GrandID,OrderBy) values(" + maxID + ",'" + Name + "',1,''," + ID + "," + GrandID + "," + maxID + ")";
                dal.ExecuteNonQuery(sql);

                UpdateVersion();
                return "True";
            }
            catch (Exception ep)
            {
                return ep.Message;
            }

        }
        //更新版本号
        public void UpdateVersion()
        {
            int dbversion = dal.ExecuteInt("Select VersionID From Version");
            dbversion++;
            dal.ExecuteNonQuery("Update Version set VersionID='" + dbversion + "'");

            VersionControl vc = new VersionControl(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"), System.Web.HttpContext.Current.Server.MapPath(""));
            vc.UploadDataBase();
        }

        public string GetTypeByID(string ID)
        {
            return dal.ExecuteString("Select Type From Notes where ID='"+ID+"'");
        }

        public  string FilterIn(string str)
        {
            if (str.IndexOf("'") >= 0)
                str = str.Replace("'", "''");
            return str;
        }
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}