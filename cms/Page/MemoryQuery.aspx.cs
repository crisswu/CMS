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
    public partial class MemoryQuery : System.Web.UI.Page
    {
        SQLite dal;

        public string data = "";//筛选条件用的
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
            ((Label)Master.FindControl("lblMasterTitle")).Text = "记忆查询";
            SetData();

            if (IsSave.Value == "Save")
            {
                UpdateContent(SaveID.Value, txtContent.Value);
                IsSave.Value = "";
                txtContent.Value = "";
            }

        }
        public void UpdateContent(string ID, string Content)
        {
            try
            {
                string sql = @"Update Notes Set Content='" + Content.Filter() + "' where ID ='" + ID + "'";
                dal.ExecuteNonQuery(sql);
                UpdateVersion();
                string str = "<script>MessageBoxShow('保存完成！');</script>";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "MyOffic", str);
            }
            catch (Exception ep)
            {
                string str = "<script>MessageBoxShow('" + ep.Message + "');</script>";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "MyOffic", str);
            }
        }
        //更新版本号
        public void UpdateVersion()
        {
            int dbversion = dal.ExecuteInt("Select VersionID From Version");
            dbversion++;
            dal.ExecuteNonQuery("Update Version set VersionID='" + dbversion + "'");

            VersionControl vc = new VersionControl(Server.MapPath("\\Bowtech.db"), Server.MapPath(""));
            vc.UploadDataBase();
        }
        public void SetData()
        {
            string sql = "Select ID,Name From Notes where FatherID=0 and Visble=0 Order by OrderBy";
            DataTable dt = dal.ExecuteDataTable(sql);

            data += "[";
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i == dt.Rows.Count - 1)
                {
                    data += "{ \"id\": " + dt.Rows[i]["ID"] + ",\"text\": \"" + dt.Rows[i]["Name"] + "\"}";
                }
                else
                {
                    data += "{ \"id\": " + dt.Rows[i]["ID"] + ",\"text\": \"" + dt.Rows[i]["Name"] + "\"},";
                }
            }
            data += "]";
        }
    }
}