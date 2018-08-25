using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CMS.App_Code;
using System.Data;
using System.Text;

namespace CMS.ashx
{
    /// <summary>
    /// NewIndex 的摘要说明
    /// </summary>
    public class NewIndex : IHttpHandler
    {
        SQLite dal;
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            dal = new SQLite(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"));

            if (context.Request.QueryString["funType"] == "GetJiYiLiang")//查询记忆量
            {
                string sql = @"Select Count(*) From Notes";
                context.Response.Write(dal.ExecuteString(sql));
            }
           
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