using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CMS.App_Code;
using System.Data;
using System.Text;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;

namespace CMS.ashx
{
    /// <summary>
    /// FindMemory 的摘要说明
    /// </summary>
    public class FindMemory : IHttpHandler
    {
        SQLite dal;
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            dal = new SQLite(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"));

            if (context.Request.QueryString["funType"] == "load")
            {
                string where = " and ID in (";
                string strWhere = context.Request.QueryString["Where"];
                if (strWhere != "")
                {
                    string[] sp = strWhere.Split(',');
                    for (int i = 0; i < sp.Length; i++)
                    {
                        where += "'" + sp[i] + "',";
                    }
                    where = where.TrimEnd(',') + ")";
                }
                string sql = "Select ID,Name,Type,FatherID,GrandID,OrderBy,IsNet,Visble from Notes where FatherID=0 and Visble=0 " + where + " Order by OrderBy";
                DataTable dt = dal.ExecuteDataTable(sql);
                context.Response.Write(ConvertDataTableToJson(dt));

            }
            else if (context.Request.QueryString["funType"] == "getFather")
            {
                string sql = "Select ID,Name,Type,FatherID,GrandID,OrderBy,IsNet,Visble from Notes where FatherID='" + context.Request.QueryString["ID"] + "' Order by OrderBy";
                DataTable dtDetail = dal.ExecuteDataTable(sql);
                context.Response.Write(ConvertDataTableToJson(dtDetail));
            }
            else if (context.Request.QueryString["funType"] == "GetMemu")
            {
                context.Response.Write(GetMemu(context.Request.QueryString["ID"]));
            }
            else if (context.Request.QueryString["funType"] == "GetContent")
            {
                context.Response.Write(GetContent(context.Request.QueryString["ID"]));
            }
            else if (context.Request.QueryString["funType"] == "GetTitle")
            {
                context.Response.Write(GetTitle(context.Request.QueryString["ID"]));
            }
            else if (context.Request.QueryString["funType"] == "Find")
            {
                DataTable dt = FindContent(context.Request.QueryString["where"], context.Request.QueryString["AndWhere"]);
                context.Response.Write(ConvertDataTableToJson(FindContent(context.Request.QueryString["where"], context.Request.QueryString["AndWhere"])));

            }
            else if (context.Request.QueryString["funType"] == "GetType")
            {
                context.Response.Write(GetTypeByID(context.Request.QueryString["ID"]));
            }
            else if (context.Request.QueryString["funType"] == "GetFirst")
            {
                string sql = "Select ID,Title,OrderDate,Content,Type,AllBNTime,AllBNDay,AllJMTime,AllJmDay from TimeAxis Order by ID desc  limit 0,5";
                DataTable dt = dal.ExecuteDataTable(sql);
                context.Response.Write(ConvertDataTableToJson(dt));
            }
            else if (context.Request.QueryString["funType"] == "GetImg")
            {
                string sql = "Select Img from TimeAxisIMG where ID='" + context.Request.QueryString["ID"] + "'";
                context.Response.Write(dal.ExecuteString(sql));
            }
            else if (context.Request.QueryString["funType"] == "GetImgList")
            {
                string sql = "Select Img from TimeAxisIMG where ID='" + context.Request.QueryString["ID"] + "'";
                DataTable dt = dal.ExecuteDataTable(sql);
                context.Response.Write(ConvertDataTableToJson(dt));
            }
            else if (context.Request.QueryString["funType"] == "GetTimeAxis")
            {
                string sql = "Select ID,Title,OrderDate,Content,Type,AllBNTime,AllBNDay,AllJMTime,AllJmDay from TimeAxis Order by ID desc  limit " + context.Request.QueryString["Size"] + " offset " + context.Request.QueryString["Size"] + "*" + context.Request.QueryString["index"];
                DataTable dt = dal.ExecuteDataTable(sql);
                context.Response.Write(ConvertDataTableToJson(dt));
            }
            else if (context.Request.QueryString["funType"] == "ImgXZ")
            {
                string img = context.Request.QueryString["Img"];
                string path = System.Web.HttpContext.Current.Server.MapPath("\\UploadTimeAxis\\" + img);
                Image i = Image.FromFile(path);
                Image newImg = RotateImg(i, 90);
                i.Dispose();
                File.Delete(path);
                newImg.Save(path);
              
            }
        }
        // <summary>  
        /// 根据角度旋转图标  
        /// </summary>  
        /// <param name="img"></param>  
        public Image RotateImg(Image img, float angle)
        {
            //通过Png图片设置图片透明，修改旋转图片变黑问题。  
            int width = img.Width;
            int height = img.Height;
            //角度  
            Matrix mtrx = new Matrix();
            mtrx.RotateAt(angle, new PointF((width / 2), (height / 2)), MatrixOrder.Append);
            //得到旋转后的矩形  
            GraphicsPath path = new GraphicsPath();
            path.AddRectangle(new RectangleF(0f, 0f, width, height));
            RectangleF rct = path.GetBounds(mtrx);
            //生成目标位图  
            Bitmap devImage = new Bitmap((int)(rct.Width), (int)(rct.Height));
            Graphics g = Graphics.FromImage(devImage);
            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.Bilinear;
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            //计算偏移量  
            Point Offset = new Point((int)(rct.Width - width) / 2, (int)(rct.Height - height) / 2);
            //构造图像显示区域：让图像的中心与窗口的中心点一致  
            Rectangle rect = new Rectangle(Offset.X, Offset.Y, (int)width, (int)height);
            Point center = new Point((int)(rect.X + rect.Width / 2), (int)(rect.Y + rect.Height / 2));
            g.TranslateTransform(center.X, center.Y);
            g.RotateTransform(angle);
            //恢复图像在水平和垂直方向的平移  
            g.TranslateTransform(-center.X, -center.Y);
            g.DrawImage(img, rect);
            //重至绘图的所有变换  
            g.ResetTransform();
            g.Save();
            g.Dispose();
            path.Dispose();
            return devImage;
        }
        public DataTable FindContent(string sWhere, string txtName)
        {
            string where = " and a.GrandID in (";
            string strWhere = sWhere;//选择根节点
            if (strWhere != "")
            {
                string[] sp = strWhere.Split(',');
                for (int i = 0; i < sp.Length; i++)
                {
                    where += "'" + sp[i] + "',";
                }
                where = where.TrimEnd(',') + ")";
            }
            else
                where = "";

            string sql = "Select  a.ID as ID,a.Name as Name,a.Type as Type,a.FatherID as FatherID,B.ID as GrandID,B.Name as GrandName  From Notes as A inner Join Notes as B on A.GrandID=B.ID Where a.Type!=0 " + where;
            //增加多个 or 的联合查询
            if (txtName.ToLower().IndexOf(" or ") > 0)
            {
                List<string> list = new List<string>();
                GetParamOr(txtName, ref list);

                sql += " and (a.Name like '%" + Filter(list[0]) + "%' or a.Content Like '%" + Filter(list[0]) + "%')";
                for (int i = 1; i < list.Count; i++)
                {
                    sql += " or (a.Name like '%" + Filter(list[i]) + "%' or a.Content Like '%" + Filter(list[i]) + "%')";
                }
            }
            else if (txtName.ToLower().IndexOf(" and ") > 0)//增加 多个 and 的条件查询
            {
                List<string> list = new List<string>();
                GetParamAnd(txtName, ref list);

                for (int i = 0; i < list.Count; i++)
                {
                    sql += " and (a.Name like '%" + Filter(list[i]) + "%' or a.Content Like '%" + Filter(list[i]) + "%')";
                }
            }
            else if (txtName != "")
                sql += " and ( a.Name like '%" + Filter(txtName) + "%' or a.Content Like '%" + Filter(txtName) + "%' )";



            return dal.ExecuteDataTable(sql+" Order By b.ID,a.ID ");
        }
        //把多个or的参数 分割到List中
        public void GetParamOr(string where, ref List<string> list)
        {
            if (where.ToLower().IndexOf(" or ") >= 0)
            {
                string str = where.Substring(0, where.ToLower().IndexOf(" or "));
                list.Add(str);
                string newStr = where.Substring(where.ToLower().IndexOf(" or "));
                if (newStr.Length > 4)
                    newStr = newStr.Substring(4);
                GetParamOr(newStr, ref list);
            }
            else
                list.Add(where);
        }
        //把多个and的参数 分割到List中
        public void GetParamAnd(string where, ref List<string> list)
        {
            if (where.ToLower().IndexOf(" and ") >= 0)
            {
                string str = where.Substring(0, where.ToLower().IndexOf(" and "));
                list.Add(str);
                string newStr = where.Substring(where.ToLower().IndexOf(" and "));
                if (newStr.Length > 5)
                    newStr = newStr.Substring(5);
                GetParamAnd(newStr, ref list);
            }
            else
                list.Add(where);
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
        public static string Filter(string str)
        {
            if (str.IndexOf("\"") >= 0)
                str = str.Replace("\"", "");
            return str;
        }

        public string GetMemu(string ID)
        {
            DataTable dt = dal.ExecuteDataTable("Select Name,FatherID From Notes where ID ='" + ID + "'");
            string name = dt.Rows[0]["Name"].ToString();
            string MyFatherID = dt.Rows[0]["FatherID"].ToString();

            string URL = "<a href=\"#\" onclick=\"AddFatherTree('" + ID + "','" + name + "')\">" + name + "</a>";

            if (MyFatherID == "0")
            {
                return URL;
            }

            return GetDGMemu(dt.Rows[0]["FatherID"].ToString(), URL);
            //return "<a href=\"#\" onclick=\"AddFatherTree('1','C#')\">C#</a>  &emsp;<span class=\"glyphicon glyphicon-circle-arrow-right\"></span> &emsp;<a href=\"#\" onclick=\"AddFatherTree('2','语法')\">语法</a>";
        }
        //递归出父类的信息
        public string GetDGMemu(string FatherID, string URL)
        {
            DataTable dt = dal.ExecuteDataTable("Select ID,Name,FatherID From Notes where ID ='" + FatherID + "'");
            if (dt.Rows.Count > 0)
            {
                string ID = dt.Rows[0]["ID"].ToString();
                string name = dt.Rows[0]["Name"].ToString();
                string MyFatherID = dt.Rows[0]["FatherID"].ToString();

                if (MyFatherID == "0")
                    return URL = "<a href=\"#\" onclick=\"AddFatherTree('" + ID + "','" + name + "')\">" + name + "</a>  &emsp;<span class=\"glyphicon glyphicon-circle-arrow-right\"></span> &emsp;" + URL;
                else
                {
                    URL = "<a href=\"#\" onclick=\"AddFatherTree('" + ID + "','" + name + "')\">" + name + "</a>  &emsp;<span class=\"glyphicon glyphicon-circle-arrow-right\"></span> &emsp;" + URL;
                    return GetDGMemu(MyFatherID, URL);
                }
            }
            else
                return "";
        }
        //获取内容
        public string GetContent(string ID)
        {
            return dal.ExecuteString("Select Content From Notes where ID='" + ID + "'");
        }
        //获取标题
        public string GetTitle(string ID)
        {
            return dal.ExecuteString("Select Name From Notes where ID='" + ID + "'");
        }

        public string GetTypeByID(string ID)
        {
            return dal.ExecuteString("Select Type From Notes where ID='" + ID + "'");
        }

        public string FilterIn(string str)
        {
            if (str.IndexOf("'") >= 0)
                str = str.Replace("'", "''");
            return str;
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