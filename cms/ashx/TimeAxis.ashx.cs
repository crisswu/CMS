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
    public class TimeAxis : IHttpHandler
    {
        SQLite dal;
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";

            dal = new SQLite(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"));

            if (context.Request.QueryString["funType"] == "GetFirst")
            {
                string sql = "Select ID,Title,OrderDate,Content,Type,AllBNTime,AllBNDay,AllJMTime,AllJmDay from TimeAxis where Order by ID desc  limit 0,5";
                DataTable dt = dal.ExecuteDataTable(sql);
                dt.TableName = "Notes";
                context.Response.Write(ConvertDataTableToJson(dt));
            }
            else if (context.Request.QueryString["funType"] == "GetImg")
            {
                string sql = "Select Img from TimeAxisIMG where ID='"+ context.Request.QueryString["ID"] + "'";
                context.Response.Write(dal.ExecuteString(sql));
            }
            else if (context.Request.QueryString["funType"] == "GetAxis")
            {
                string sql = "Select ID,Title,OrderDate,Content,Type,AllBNTime,AllBNDay,AllJMTime,AllJmDay from TimeAxis where Order by ID desc";
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