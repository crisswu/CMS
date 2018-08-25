using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CMS.App_Code;
using System.Data;

namespace CMS.Page
{
    public partial class DataBaseEdit : System.Web.UI.Page
    {
        SQLite dal;
        protected void Page_Load(object sender, EventArgs e)
        {

            if (Request.Cookies["ImCrissLoginCookie"] == null)
            {
                Response.Redirect("Login.aspx");
            }
            else
            {
                EncryUtil eu = new EncryUtil();
                if (Request.Cookies["ImCrissLoginCookie"].Values["Login"] != eu.Enc(AppCode.LoginPassword))
                {
                    Response.Redirect("Login.aspx");
                }
            }

            dal = new SQLite(Server.MapPath("\\Bowtech.db"));
            ((Label)Master.FindControl("lblMasterTitle")).Text = "数据库编辑";
        }
    }
}