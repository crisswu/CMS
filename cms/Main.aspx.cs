using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CMS.App_Code;
using System.Data;
using System.Text;


namespace CMS
{
    public partial class Main : System.Web.UI.Page
    {
        SQLite dal;
        protected void Page_Load(object sender, EventArgs e)
        {

            if (Request.Cookies["ImCrissLoginCookie"] == null)
            {
                Response.Redirect("/Page/Login.aspx");
            }
            else
            {
                EncryUtil eu = new EncryUtil();
                if (Request.Cookies["ImCrissLoginCookie"].Values["Login"] != eu.Enc(AppCode.LoginPassword))
                {
                    Response.Redirect("/Page/Login.aspx");
                }
            }

            dal = new SQLite(Server.MapPath("\\Bowtech.db"));
            Querys();

        }

        //统计访问量
        public void Querys()
        {
            string sql = "Select Count(*) from ConectionCount where AtDay='"+DateTime.Now.ToString("yyyy-MM-dd")+"'";
            int Have = dal.ExecuteInt(sql);
            if (Have > 0)//则今日访问过
            {
                sql = "Update ConectionCount set DayCount=DayCount+1,AllCount= AllCount+1";
            }
            else
            {
                sql = "Update ConectionCount set DayCount=1,AllCount= AllCount+1,AtDay='"+DateTime.Now.ToString("yyyy-MM-dd") + "'";
            }
            dal.ExecuteNonQuery(sql);
        }
    }
}