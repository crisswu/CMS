using CMS.App_Code;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CMS.Page
{
    public partial class Login : System.Web.UI.Page
    {
        SQLite dal;
        protected void Page_Load(object sender, EventArgs e)
        {
 
            dal = new SQLite(Server.MapPath("\\Bowtech.db"));

            if (Request.QueryString["funType"] != null && Request.QueryString["funType"] == "True")
            {
                if (Request.QueryString["ID"] != null)
                {
                    string password = Request.QueryString["ID"];
                    if (password == AppCode.LoginPassword)
                    {
                        EncryUtil eu = new EncryUtil();
                        HttpCookie cookie = new HttpCookie("ImCrissLoginCookie");
                        cookie.Values.Add("Login", eu.Enc(password));
                        cookie.Expires = DateTime.Now.AddDays(7);

                        Response.Cookies.Add(cookie);

                        Response.Clear();
                        Response.Buffer = false;
                        Response.Write("True");
                        Response.Flush();
                        Response.End();
                    }
                    else
                    {
                        Response.Clear();
                        Response.Buffer = false;
                        Response.Write("False");
                        Response.Flush();
                        Response.End();

                    }
                }
            }
            else if (Request.QueryString["funType"] != null && Request.QueryString["funType"] == "VisitCount")
            {
                string sql = "Select Count(*) From Visit where VisitDate='" + DateTime.Now.ToString("yyyy-MM-dd") + "'";
                if (dal.ExecuteInt(sql) > 0)
                {
                    sql = "Update Visit Set LastTime='" + DateTime.Now.ToString("HH:mm:ss") + "' ,VisitCount=VisitCount+1 where VisitDate='" + DateTime.Now.ToString("yyyy-MM-dd") + "'";
                    dal.ExecuteNonQuery(sql);
                }
                else //当天第一次..
                {
                    sql = "Insert into Visit(VisitDate,LastTime,VisitCount,ComeInCount,ErrorCount) values('" + DateTime.Now.ToString("yyyy-MM-dd") + "','" + DateTime.Now.ToString("HH:mm:ss") + "',1,0,0)";
                    dal.ExecuteNonQuery(sql);
                }
            }
            else if (Request.QueryString["funType"] != null && Request.QueryString["funType"] == "ComeIn")
            {
                string sql = "Update Visit Set LastTime='" + DateTime.Now.ToString("HH:mm:ss") + "' ,ComeInCount=ComeInCount+1 where VisitDate='" + DateTime.Now.ToString("yyyy-MM-dd") + "'";
                dal.ExecuteNonQuery(sql);
            }
            else if (Request.QueryString["funType"] != null && Request.QueryString["funType"] == "Error")
            {
                string sql = "Update Visit Set LastTime='" + DateTime.Now.ToString("HH:mm:ss") + "' ,ErrorCount=ErrorCount+1 where VisitDate='" + DateTime.Now.ToString("yyyy-MM-dd") + "'";
                dal.ExecuteNonQuery(sql);
            }
       }
    }
}