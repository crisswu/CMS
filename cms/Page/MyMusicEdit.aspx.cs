using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CMS.Page
{
    public partial class MyMusicEdit : System.Web.UI.Page
    {
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
            ((Label)Master.FindControl("lblMasterTitle")).Text = "编辑音乐";
        }
    }
}