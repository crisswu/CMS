using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CMS.Page
{
    public partial class FileDownload : System.Web.UI.Page
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

            string filePath = Server.MapPath("~/UploadFile/" + Request.QueryString["FilesName"]); //文件在服务器上的相对路径
            FileInfo file = new FileInfo(filePath);        //实例一个文件信息类
            Response.ContentEncoding = Encoding.GetEncoding("UTF-8");  //用UTF-8格式编码，解决中文乱码
            Response.AddHeader("Content-Disposition", "attachment;filename=" + Server.UrlEncode(file.Name));
            Response.AddHeader("Content-Length", file.Length.ToString());
            Response.ContentType = "application/octet-stream";
            Response.WriteFile(file.FullName);   //写入文件
            Response.End();
        }
    }
}