using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CMS.App_Code;
using System.Data;
using System.Text;
using System.Data.SqlClient;

namespace CMS.ashx
{
    /// <summary>
    /// DataBaseDAL 的摘要说明
    /// </summary>
    public class DataBaseDAL : IHttpHandler
    {
        SQLite dal;
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            dal = new SQLite(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"));

            if (context.Request.QueryString["funType"] == "GetNames")
            {
                DataTable dt = dal.ExecuteDataTable("Select ID,Name From Sys_dbs Order By ID");

                context.Response.Write(ConvertDataTableToJson(dt));
            }
            else if (context.Request.QueryString["funType"] == "GetDataBase")
            {
                DataTable dt = dal.ExecuteDataTable("Select ID,Name,IP,Types,LoginName,Password From Sys_dbs where ID='" + context.Request.QueryString["ID"] + "'");

                string DbName = ConvertDecry(dt.Rows[0]["IP"].ToString());

                string ConnStr = "Data Source=" + DbName + ";integrated security=true;";
                bool UserLogin = false;//是否 windows身份验证
                string LoginName = ConvertDecry(dt.Rows[0]["LoginName"].ToString());
                string Password = ConvertDecry(dt.Rows[0]["Password"].ToString());
                if (dt.Rows[0]["Types"].ToString() == "SQL Server 身份验证")
                {
                    ConnStr = "Data Source=" + DbName + ";User ID=" + LoginName + ";Password=" + Password + ";";
                    UserLogin = true;
                }

                try
                {
                    ///筛选系统数据库....
                    string[] str = { "tempdb", "model", "AdventureWorksDW", "AdventureWorks", "msdb", "master", "ReportServer", "ReportServerTempDB" };
                    List<string> list = getAllDateBaseName(UserLogin, DbName, LoginName, Password);
                    for (int i = 0; i < str.Length; i++)
                    {
                        for (int j = 0; j < list.Count; j++)
                        {
                            if (list[j].ToString() == str[i].ToString())
                            {
                                list.RemoveAt(j);
                            }
                        }
                    }

                    //  list.Insert(0, "==请选择==");

                    if (list.Count == 1)
                    {
                        context.Response.Write("IsNull");//无数据库数据
                    }
                    else
                    {
                        context.Response.Write(ConvertListToJson(list));//有数据 返回JSON

                    }

                }
                catch (Exception ex)
                {
                    Logs("获取数据库", "数据库", ex.Message);
                    context.Response.Write(ex.Message);
                }
            }
            else if (context.Request.QueryString["funType"] == "GetDataTable")
            {
                DataTable dt = dal.ExecuteDataTable("Select ID,Name,IP,Types,LoginName,Password From Sys_dbs where ID='" + context.Request.QueryString["ID"] + "'");

                string DbName = ConvertDecry(dt.Rows[0]["IP"].ToString());

                string ConnStr = "Data Source=" + DbName + ";integrated security=true;";
                bool UserLogin = false;//是否 windows身份验证
                string LoginName = ConvertDecry(dt.Rows[0]["LoginName"].ToString());
                string Password = ConvertDecry(dt.Rows[0]["Password"].ToString());
                if (dt.Rows[0]["Types"].ToString() == "SQL Server 身份验证")
                {
                    ConnStr = "Data Source=" + DbName + ";User ID=" + LoginName + ";Password=" + Password + ";";
                    UserLogin = true;
                }
                try
                {

                    //打开连接
                    List<string> list = new List<string>();
                    string str = "";

                    if (UserLogin)
                    {
                        str = "Data Source=" + DbName + ";Initial Catalog=" + context.Request.QueryString["DataBase"] + ";User ID=" + LoginName + ";Password=" + Password;
                    }
                    else
                    {
                        str = "Data Source=" + DbName + ";Initial Catalog=" + context.Request.QueryString["DataBase"] + ";Integrated Security=True";
                    }

                    SqlConnection sqlcn = new SqlConnection(str);
                    sqlcn.Open();
                    //使用信息架构视图
                    SqlCommand sqlcmd = new SqlCommand("SELECT OBJECT_NAME (id) as T FROM sysobjects WHERE xtype = 'U' AND OBJECTPROPERTY (id, 'IsMSShipped') = 0 order by T", sqlcn);
                    SqlDataReader dr = sqlcmd.ExecuteReader();
                    while (dr.Read())
                    {
                        list.Add(dr.GetString(0));
                    }
                    dr.Close();
                    context.Response.Write(ConvertListToJson(list));//有数据 返回JSON
                }
                catch (Exception ex)
                {
                    Logs("获取数据表", "数据库", ex.Message);
                    context.Response.Write(ex.Message);
                }
            }
            else if (context.Request.QueryString["funType"] == "GetDataTableLike")
            {
                DataTable dt = dal.ExecuteDataTable("Select ID,Name,IP,Types,LoginName,Password From Sys_dbs where ID='" + context.Request.QueryString["ID"] + "'");

                string DbName = ConvertDecry(dt.Rows[0]["IP"].ToString());

                string ConnStr = "Data Source=" + DbName + ";integrated security=true;";
                bool UserLogin = false;//是否 windows身份验证
                string LoginName = ConvertDecry(dt.Rows[0]["LoginName"].ToString());
                string Password = ConvertDecry(dt.Rows[0]["Password"].ToString());
                if (dt.Rows[0]["Types"].ToString() == "SQL Server 身份验证")
                {
                    ConnStr = "Data Source=" + DbName + ";User ID=" + LoginName + ";Password=" + Password + ";";
                    UserLogin = true;
                }
                try
                {

                    //打开连接
                    List<string> list = new List<string>();
                    string str = "";

                    if (UserLogin)
                    {
                        str = "Data Source=" + DbName + ";Initial Catalog=" + context.Request.QueryString["DataBase"] + ";User ID=" + LoginName + ";Password=" + Password;
                    }
                    else
                    {
                        str = "Data Source=" + DbName + ";Initial Catalog=" + context.Request.QueryString["DataBase"] + ";Integrated Security=True";
                    }

                    SqlConnection sqlcn = new SqlConnection(str);
                    sqlcn.Open();
                    //使用信息架构视图
                    SqlCommand sqlcmd = new SqlCommand("SELECT OBJECT_NAME (id) as T FROM sysobjects WHERE xtype = 'U' AND OBJECTPROPERTY (id, 'IsMSShipped') = 0 and name like '%" + context.Request.QueryString["Like"] + "%'  order by T", sqlcn);
                    SqlDataReader dr = sqlcmd.ExecuteReader();
                    while (dr.Read())
                    {
                        list.Add(dr.GetString(0));
                    }
                    dr.Close();
                    context.Response.Write(ConvertListToJson(list));//有数据 返回JSON
                }
                catch (Exception ex)
                {
                    Logs("查询数据库", "数据库", ex.Message);
                    context.Response.Write(ex.Message);
                }
            }
            else if (context.Request.QueryString["funType"] == "GetColumns")
            {
                DataTable dt = dal.ExecuteDataTable("Select ID,Name,IP,Types,LoginName,Password From Sys_dbs where ID='" + context.Request.QueryString["ID"] + "'");

                string DbName = ConvertDecry(dt.Rows[0]["IP"].ToString());

                string ConnStr = "Data Source=" + DbName + ";integrated security=true;";
                bool UserLogin = false;//是否 windows身份验证
                string LoginName = ConvertDecry(dt.Rows[0]["LoginName"].ToString());
                string Password = ConvertDecry(dt.Rows[0]["Password"].ToString());
                if (dt.Rows[0]["Types"].ToString() == "SQL Server 身份验证")
                {
                    ConnStr = "Data Source=" + DbName + ";User ID=" + LoginName + ";Password=" + Password + ";";
                    UserLogin = true;
                }
                try
                {
                    //打开连接
                    List<string> list = new List<string>();
                    string str = "";

                    if (UserLogin)
                    {
                        str = "Data Source=" + DbName + ";Initial Catalog=" + context.Request.QueryString["DataBase"] + ";User ID=" + LoginName + ";Password=" + Password;
                    }
                    else
                    {
                        str = "Data Source=" + DbName + ";Initial Catalog=" + context.Request.QueryString["DataBase"] + ";Integrated Security=True";
                    }

                    DataSet dateSet = new DataSet();
                    SqlConnection con = new SqlConnection(str);
                    SqlDataAdapter adapter = new SqlDataAdapter("select top 1 * from [" + context.Request.QueryString["Table"] + "]", con);
                    adapter.Fill(dateSet, "table");
                    DataTable dtCol= dateSet.Tables[0];
                    for (int i = 0; i < dtCol.Columns.Count; i++)
                    {
                        list.Add(dtCol.Columns[i].Caption);
                    }

                    context.Response.Write(ConvertListToJson(list));//有数据 返回JSON
                }
                catch (Exception ex)
                {
                    Logs("查询数据列", "数据库", ex.Message);
                    context.Response.Write(ex.Message);
                }
            }

         }
        // 查询所有数据库名
        public List<string> getAllDateBaseName(bool UserLogin,string DbName,string UserName,string UserPass)
        {
            List<string> list = new List<string>();
            string sql = "use master select name from sysdatabases";
            string conn = "";
            if (UserLogin)
            {
                conn = "Data Source=" + DbName + ";User ID=" + UserName + ";Password=" + UserPass;
            }
            else
            {
                conn = "Data Source=" + DbName + ";Integrated Security=True";
            }
            SqlConnection con = new SqlConnection(conn);
            con.Open();
            SqlCommand com = new SqlCommand(sql, con);
            SqlDataReader dr = com.ExecuteReader();
            while (dr.Read())
            {
                list.Add(dr[0].ToString());
            }
            dr.Close();
            con.Close();
            return list;
        }
        public string  ConvertDecry(string str)
        {
            DecryUtil du = new DecryUtil();

            return du.Dec(str);
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
        public string ConvertListToJson(List<string> dt)
        {
            if (dt == null) return "";
            StringBuilder sbs = new StringBuilder();
            if (dt.Count > 0)
            {
                sbs.Append("{\"Notes\":[");
                string str = "";
                foreach (string dr in dt)
                {
                    string result = "";
                        result += string.Format(",\"{0}\":\"{1}\"",
                            "Text", Filter(dr));
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
        public void Logs(string Name, string Type, string Content)
        {
            string sqlLog = "Insert into Logs(Name,CreateDate,Type,Content) values('" + Name + "','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "','" + Type + "','" + Content.Filter() + "')";
            dal.ExecuteNonQuery(sqlLog);
        }
    }
}