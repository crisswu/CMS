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
    /// OptionDAL 的摘要说明
    /// </summary>
    public class OptionDAL : IHttpHandler
    {
        SQLite dal;
        public void ProcessRequest(HttpContext context)
        {
            dal = new SQLite(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"));
            context.Response.ContentType = "text/plain";
            if (context.Request.QueryString["funType"] == "GetBase")
            {
                string sql = @"select ID,Name from Sys_dbs";
                context.Response.Write(ConvertDataTableToJson(dal.ExecuteDataTable(sql)));
            }
            else if (context.Request.QueryString["funType"] == "DeleteDataBase")
            {
                string sql = @"Delete From Sys_dbs where ID ='" + context.Request.QueryString["ID"] + "'";
                context.Response.Write(ConvertDataTableToJson(dal.ExecuteDataTable(sql)));
            }
            else if (context.Request.QueryString["funType"] == "SaveDataBase")
            {
                EncryUtil eu = new EncryUtil();
                string ip = eu.Enc(context.Request.QueryString["ip"]);
                string LoginName = eu.Enc(context.Request.QueryString["loginName"]);
                string Password = eu.Enc(context.Request.QueryString["passWord"]);

                string sql = @"Insert into Sys_dbs(Name,IP,Types,LoginName,Password) values('" + context.Request.QueryString["name"] + "','" + ip + "','SQL Server 身份验证','" + LoginName + "','" + Password + "')";
                dal.ExecuteNonQuery(sql);
                context.Response.Write("OK");
            }
            else if (context.Request.QueryString["funType"] == "GetDisplay")
            {
                string sql = " select ID,Name,visble,case visble when 0 then '显示中' else '隐藏中' end as Status,case visble when 0 then '切换至隐藏' else '切换至显示' end as col from Notes where type=0";
                context.Response.Write(ConvertDataTableToJson(dal.ExecuteDataTable(sql)));
            }
            else if (context.Request.QueryString["funType"] == "Viazble")
            {
                string vizble = context.Request.QueryString["visble"] == "0" ? "1" : "0";

                string sql = "Update Notes Set Visble="+vizble+" where ID="+ context.Request.QueryString["ID"];
                dal.ExecuteNonQuery(sql);
            }
        }

        public string ConvertDataTableToJson(DataTable dt)
        {
            if (dt == null) return "";
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
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}