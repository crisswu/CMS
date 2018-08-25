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
    public partial class WatchIndex : System.Web.UI.Page
    {
        SQLite dal;
        public string YJL = "";//记忆量
        public string JRL = "";//今日访问量
        public string ZGL = "";//总访问量

        public string YJL_Full = "";//记忆量最大值
        public string JRL_Full = "";//今日访问量最大值
        public string ZGL_Full = "";//总访问量最大值

        public string YJL_Fgcolor = "";//记忆量等级色
        public string JRL_Fgcolor = "";//今日访问量最大值
        public string ZGL_Fgcolor = "";//总访问量最大值

        public string BackUp = "";//数据库备份
        public string ErrorStr = "";//异常情况
        public string VisitStr = "";//访问登录情况

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

            if (txtType.Value == "Submit")
            {
               
            }

            Querys();
            QueryBackUp();
            QueryRemind();
            QueryError();
            QueryVisit();


        }

        public void Querys()
        {
            //查询记忆量
            string sql = @"Select Count(*) From Notes  where type =2";
            YJL = dal.ExecuteString(sql);
            //今日访问量
            sql = "Select DayCount from ConectionCount";
            JRL = dal.ExecuteString(sql);
            //一共访问量
            sql = "Select AllCount from ConectionCount";
            ZGL = dal.ExecuteString(sql);

            #region 设置记忆量等级颜色
            if (Convert.ToInt32(YJL) < 500)
            {
                YJL_Fgcolor = "#009900";//绿色
            }
            else if (Convert.ToInt32(YJL) >= 500 && Convert.ToInt32(YJL) < 1000)
            {
                YJL_Fgcolor = "#61a9dc";//蓝色 
            }
            else if (Convert.ToInt32(YJL) >= 1000 && Convert.ToInt32(YJL) < 1500)
            {
                YJL_Fgcolor = "#660066";//紫色 
            }
            else if (Convert.ToInt32(YJL) >= 1500 && Convert.ToInt32(YJL) < 2000)
            {
                YJL_Fgcolor = "#CC6600";//橙色 
            }
            else
            {
                YJL_Fgcolor = "#FFFF00";//金色 
            }
            #endregion

            #region 设置记忆量最大值
            if (Convert.ToInt32(YJL) < 1000)
            {
                YJL_Full = (Convert.ToDouble(YJL)/1000*100).ToString();
            }
            else if (Convert.ToInt32(YJL) >= 1000 && Convert.ToInt32(YJL) < 1500)
            {
                YJL_Full = (Convert.ToDouble(YJL) / 1500 * 100).ToString();
            }
            else if (Convert.ToInt32(YJL) >= 1500 && Convert.ToInt32(YJL) < 2000)
            {
                YJL_Full = (Convert.ToDouble(YJL) / 2000 * 100).ToString();
            }
            else if (Convert.ToInt32(YJL) >= 2000 && Convert.ToInt32(YJL) < 3000)
            {
                YJL_Full = (Convert.ToDouble(YJL) / 3000 * 100).ToString();
            }
            else if (Convert.ToInt32(YJL) >= 3000 && Convert.ToInt32(YJL) < 4000)
            {
                YJL_Full = (Convert.ToDouble(YJL) / 4000 * 100).ToString();
            }
            else if (Convert.ToInt32(YJL) >= 4000 && Convert.ToInt32(YJL) < 5000)
            {
                YJL_Full = (Convert.ToDouble(YJL) / 5000 * 100).ToString();
            }
            #endregion

            #region 设置今日访问量颜色
            if (Convert.ToInt32(JRL) < 5)
            {
                JRL_Fgcolor = "#009900";//绿色
            }
            else if (Convert.ToInt32(JRL) >= 5 && Convert.ToInt32(JRL) < 10)
            {
                JRL_Fgcolor = "#61a9dc";//蓝色 
            }
            else if (Convert.ToInt32(JRL) >= 10 && Convert.ToInt32(JRL) < 15)
            {
                JRL_Fgcolor = "#660066";//紫色 
            }
            else if (Convert.ToInt32(JRL) >= 15 && Convert.ToInt32(JRL) < 20)
            {
                JRL_Fgcolor = "#CC6600";//橙色 
            }
            else
            {
                JRL_Fgcolor = "#FFFF00";//金色 
            }
            #endregion

            #region 设置今日访问量最大值
            JRL_Full = (Convert.ToDouble(JRL) / 30 * 100).ToString();
            #endregion

            #region 设置总共访问量等级颜色
            if (Convert.ToInt32(ZGL) < 500)
            {
                ZGL_Fgcolor = "#009900";//绿色
            }
            else if (Convert.ToInt32(ZGL) >= 500 && Convert.ToInt32(ZGL) < 1000)
            {
                ZGL_Fgcolor = "#61a9dc";//蓝色 
            }
            else if (Convert.ToInt32(ZGL) >= 1000 && Convert.ToInt32(ZGL) < 1500)
            {
                ZGL_Fgcolor = "#660066";//紫色 
            }
            else if (Convert.ToInt32(ZGL) >= 1500 && Convert.ToInt32(ZGL) < 2000)
            {
                ZGL_Fgcolor = "#CC6600";//橙色 
            }
            else
            {
                ZGL_Fgcolor = "#FFFF00";//金色 
            }
            #endregion

            #region 设置记忆量最大值
            if (Convert.ToInt32(ZGL) < 1000)
            {
                ZGL_Full = (Convert.ToDouble(ZGL) / 1000 * 100).ToString();
            }
            else if (Convert.ToInt32(ZGL) >= 1000 && Convert.ToInt32(ZGL) < 1500)
            {
                ZGL_Full = (Convert.ToDouble(ZGL) / 1500 * 100).ToString();
            }
            else if (Convert.ToInt32(ZGL) >= 1500 && Convert.ToInt32(ZGL) < 2000)
            {
                ZGL_Full = (Convert.ToDouble(ZGL) / 2000 * 100).ToString();
            }
            else if (Convert.ToInt32(ZGL) >= 2000 && Convert.ToInt32(ZGL) < 3000)
            {
                ZGL_Full = (Convert.ToDouble(ZGL) / 3000 * 100).ToString();
            }
            else if (Convert.ToInt32(ZGL) >= 3000 && Convert.ToInt32(ZGL) < 4000)
            {
                ZGL_Full = (Convert.ToDouble(ZGL) / 4000 * 100).ToString();
            }
            else if (Convert.ToInt32(ZGL) >= 4000 && Convert.ToInt32(ZGL) < 5000)
            {
                ZGL_Full = (Convert.ToDouble(ZGL) / 5000 * 100).ToString();
            }
            else
            {
                ZGL_Full = (Convert.ToDouble(ZGL) / 10000 * 100).ToString();
            }
            #endregion

        }

        public void QueryBackUp()
        {
            string sql = "Select * From BackUp order by BackTime desc ";
            DataTable dt = dal.ExecuteDataTable(sql);
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i == 4) return;
                BackUp += "<tr><td align=\"center\">" + dt.Rows[i]["BackTime"] + "</td><td  align=\"center\">" + dt.Rows[i]["BackType"] + "</td><td  align=\"center\">" + dt.Rows[i]["BackStatus"] +"</td></tr>";
            }
        }


        public void QueryRemind()
        {
            
        }

        public void QueryError()
        {
            string sql = "Select * From Logs order by CreateDate desc ";
            DataTable dt = dal.ExecuteDataTable(sql);
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i == 4) return;
                ErrorStr += "<tr><td align=\"center\">" + dt.Rows[i]["name"] + "</td><td  align=\"center\">" + dt.Rows[i]["CreateDate"] + "</td><td  align=\"center\">" + dt.Rows[i]["Content"] + "</td><td  align=\"center\">" + dt.Rows[i]["Type"] + "</td></tr>";
            }
        }

        public void QueryVisit()
        {
            string sql = "Select * From Visit order by ID desc ";
            DataTable dt = dal.ExecuteDataTable(sql);
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i == 10) return;
                VisitStr += "<tr><td align=\"center\">" + dt.Rows[i]["VisitDate"] + "</td><td  align=\"center\">" + dt.Rows[i]["LastTime"] + "</td><td  align=\"center\">" + dt.Rows[i]["VisitCount"] + "</td><td  align=\"center\">" + dt.Rows[i]["ComeInCount"] + "</td><td  align=\"center\">" + dt.Rows[i]["ErrorCount"] + "</td></tr>";
            }
        }
    }
}