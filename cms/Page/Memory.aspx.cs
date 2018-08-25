using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CMS.App_Code;
using System.Data;
using System.Text;

namespace CMS.Page
{
    public partial class Memory : System.Web.UI.Page
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
            ((Label)Master.FindControl("lblMasterTitle")).Text = "Criss++";

            if (IsSave.Value == "Save")
            {
                UpdateContent(SaveID.Value, txtContent.Value);
                IsSave.Value = "";
                txtContent.Value = "";
            }
            else if (IsSave.Value == "Delete")
            {
                Delete(SaveID.Value);
                IsSave.Value = "";
                txtContent.Value = "";
            }
            else if (IsSave.Value == "New")
            {
                Save(SaveID.Value, txtTitle.Value, txtContent.Value);
                IsSave.Value = "";
                SaveID.Value = "";
                txtTitle.Value = "";
                txtContent.Value = "";
            }
        }
        //保存内容
        public void Save(string FatherID,string Name,string Content)
        {
            try
            {
                int maxID = dal.ExecuteInt("Select Max(ID) from Notes");
                maxID++;
                string GrandID = dal.ExecuteString("Select GrandID from Notes where ID=" + FatherID + "");
                string sql = "Insert into Notes(ID,Name,Type,Content,FatherID,GrandID,OrderBy) values(" + maxID + ",'" + Name.Filter() + "',2,'" + Content.Filter() + "'," + FatherID + "," + GrandID + "," + maxID + ")";
                dal.ExecuteNonQuery(sql);

                UpdateVersion();

                string str = "<script>hideMask();MessageBoxShow('保存完成！');</script>";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "MyOffic", str);
            }
            catch (Exception ep)
            {
                string str = "<script>MessageBoxShow('" + ep.Message + "');</script>";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "MyOffic", str);
            }
        }
        public void UpdateContent(string ID, string Content)
        {
            try
            {
                string sql = @"Update Notes Set Content='" +  Content.Filter() + "' where ID ='" + ID + "'";
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

        public void Delete(string ID)
        {
            DeleteChiled(ID);
            string sql = "Delete From Notes where id='" + ID + "'";
            dal.ExecuteNonQuery(sql);

            UpdateVersion();
        }
        //递归删除子节点
        public void DeleteChiled(string FatherID)
        {
            string sql = "Select * From Notes where FatherID='" + FatherID + "'";
            DataTable dt = dal.ExecuteDataTable(sql);
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (dt.Rows[i]["Type"].ToString() != "2")
                {
                    DeleteChiled(dt.Rows[i]["ID"].ToString());
                    sql = "Delete From Notes where id='" + dt.Rows[i]["ID"].ToString() + "'";
                    dal.ExecuteNonQuery(sql);
                }
                else
                {
                    sql = "Delete From Notes where id='" + dt.Rows[i]["ID"].ToString() + "'";
                    dal.ExecuteNonQuery(sql);
                }
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
    }
}