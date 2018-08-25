using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CMS.App_Code;
using System.Data;
using System.Text;
using Qiniu.Util;
using Qiniu.JSON;
using Qiniu.Http;
using Qiniu.IO;
using Qiniu.IO.Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.Threading;
using Qiniu.RS;
using Qiniu.RS.Model;
using System.IO;
using Qiniu.CDN;

namespace CMS.ashx
{
    /// <summary>
    /// Common 的摘要说明
    /// </summary>
    public class Common : IHttpHandler
    {
        SQLite dal;
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            dal = new SQLite(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"));
            Qiniu.JSON.JsonHelper.JsonSerializer = new AnotherJsonSerializer();
            Qiniu.JSON.JsonHelper.JsonDeserializer = new AnotherJsonDeserializer();

            if (context.Request.QueryString["funType"] == "GetIEAddress")
            {
                string sql = @"Select Title,IEAddress,Type,MyClick,Sort From IEAddress Order by Sort,MyClick desc";
                context.Response.Write(ConvertDataTableToJson(dal.ExecuteDataTable(sql)));
            }
            else if (context.Request.QueryString["funType"] == "AddMyClick")
            {
                string sql = "Update IEAddress Set MyClick = MyClick+1 where Title='" + context.Request.QueryString["Name"] + "'";
                dal.ExecuteNonQuery(sql);
            }
            else if (context.Request.QueryString["funType"] == "GetType")
            {
                string sql = @"select distinct  type from ieaddress Order By type";
                context.Response.Write(ConvertDataTableToJson(dal.ExecuteDataTable(sql)));
            }
            else if (context.Request.QueryString["funType"] == "GetSinger")
            {
                string sql = @"select distinct singer from MyMusic ";
                context.Response.Write(ConvertDataTableToJson(dal.ExecuteDataTable(sql)));
            }
            else if (context.Request.QueryString["funType"] == "FindIEAddress")
            {
                string where = "";
                if (context.Request.QueryString["txtFind"] != "")
                {
                    where += " and Title like '%" + context.Request.QueryString["txtFind"] + "%'";
                }
                if (context.Request.QueryString["ddlType"] != "")
                {
                    where += " and Type ='" + context.Request.QueryString["ddlType"] + "'";
                }
                string sql = @"Select Title,IEAddress,Type,MyClick,Sort From IEAddress where 1=1 " + where + "  Order by Sort,MyClick desc";
                context.Response.Write(ConvertDataTableToJson(dal.ExecuteDataTable(sql)));
            }
            else if (context.Request.QueryString["funType"] == "AddIEAddress")
            {
                try
                {
                    int MaxSort = dal.ExecuteInt("Select Max(Sort) From IEAddress");
                    MaxSort++;
                    if (context.Request.QueryString["Sort"] != "")
                        MaxSort = Convert.ToInt32(context.Request.QueryString["Sort"]);


                    string sql = @"Insert into IEAddress(Title,IEAddress,Type,Sort,MyClick) values('" + context.Request.QueryString["Title"].Filter() + @"',
                    '" + context.Request.QueryString["IEAddress"].Filter() + "','" + context.Request.QueryString["Type"].Filter() + "','" + MaxSort + "','0')";
                    dal.ExecuteNonQuery(sql);
                    UpdateVersion();
                    context.Response.Write("");
                }
                catch (Exception ep)
                {
                    Logs("新增异常","网址收藏",ep.Message);
                    context.Response.Write(ep.Message);
                }
            }
            else if (context.Request.QueryString["funType"] == "AddMyMusic")
            {
                try
                {
                    int MaxSort = dal.ExecuteInt("Select Max(Sort) From MyMusic");
                    MaxSort++;
                    if (context.Request.QueryString["Sort"] != "")
                        MaxSort = Convert.ToInt32(context.Request.QueryString["Sort"]);


                    string sql = @"Insert into MyMusic(Name,Address,Singer,Sort) values('" + context.Request.QueryString["Title"].Filter() + @"',
                    '" + context.Request.QueryString["IEAddress"].Filter() + "','" + context.Request.QueryString["Type"].Filter() + "','" + MaxSort + "')";
                    dal.ExecuteNonQuery(sql);
                    //UpdateVersion();
                    context.Response.Write("");
                }
                catch (Exception ep)
                {
                    Logs("新增音乐", "我的音乐", ep.Message);
                    context.Response.Write(ep.Message);
                }
            }
            else if (context.Request.QueryString["funType"] == "GetMyMusic")
            {
                string sql = @"Select * From MyMusic Order by Sort ";
                context.Response.Write(ConvertDataTableToJson(dal.ExecuteDataTable(sql)));
            }
            else if (context.Request.QueryString["funType"] == "GetMyMusicWhere")
            {
                string where = context.Request.QueryString["where"];
                if (where != "")
                    where = " and Singer='"+ where + "'";
                string sql = @"Select * From MyMusic where 1=1 "+ where + " Order by Sort ";
                context.Response.Write(ConvertDataTableToJson(dal.ExecuteDataTable(sql)));
            }
            else if (context.Request.QueryString["funType"] == "IsHaveTitle")
            {
                string sql = @"Select Count(*) From IEAddress where Title='" + context.Request.QueryString["Title"] + "'";
                if (dal.ExecuteInt(sql) > 0)
                    context.Response.Write("True");
                else
                    context.Response.Write("False");
            }
            else if (context.Request.QueryString["funType"] == "EditIEAddress")
            {
                try
                {
                    int MaxSort = dal.ExecuteInt("Select Max(Sort) From IEAddress");
                    MaxSort++;
                    if (context.Request.QueryString["Sort"] != "")
                        MaxSort = Convert.ToInt32(context.Request.QueryString["Sort"]);


                    string sql = @"Update IEAddress Set IEAddress='" + context.Request.QueryString["IEAddress"].Filter() + "',Type='" + context.Request.QueryString["Type"].Filter() + @"',
                                    Sort='" + MaxSort + "' where Title='" + context.Request.QueryString["Title"].Filter() + "'";

                    dal.ExecuteNonQuery(sql);
                    UpdateVersion();
                    context.Response.Write("");
                }
                catch (Exception ep)
                {
                    Logs("编辑异常", "网址收藏", ep.Message);
                    context.Response.Write(ep.Message);
                }
            }
            else if (context.Request.QueryString["funType"] == "EditMusic")
            {
                try
                {
                    int MaxSort = dal.ExecuteInt("Select Max(Sort) From MyMusic");
                    MaxSort++;
                    if (context.Request.QueryString["Sort"] != "")
                        MaxSort = Convert.ToInt32(context.Request.QueryString["Sort"]);


                    string sql = @"Update MyMusic Set Address='" + context.Request.QueryString["IEAddress"].Filter() + "',Singer='" + context.Request.QueryString["Type"].Filter() + @"',
                                    Sort='" + MaxSort + "' where Name='" + context.Request.QueryString["Title"].Filter() + "'";

                    dal.ExecuteNonQuery(sql);
                    //UpdateVersion();
                    context.Response.Write("");
                }
                catch (Exception ep)
                {
                    Logs("编辑异常", "我的音乐", ep.Message);
                    context.Response.Write(ep.Message);
                }
            }
            else if (context.Request.QueryString["funType"] == "DeleteIEAddress")
            {
                string sql = @"Delete From IEAddress where Title='" + context.Request.QueryString["Title"] + "'";
                dal.ExecuteNonQuery(sql);
                UpdateVersion();
            }
            else if (context.Request.QueryString["funType"] == "DeleteMyMuisc")
            {
                string sql = @"Delete From MyMusic where Name='" + context.Request.QueryString["Title"] + "'";
                dal.ExecuteNonQuery(sql);
                UpdateVersion();
            }
            else if (context.Request.QueryString["funType"] == "GetQiNiuFiles")
            {
                context.Response.Write(ConvertDataTableToJson(ListFiles()));
            }
            else if (context.Request.QueryString["funType"] == "GetToken")
            {
                context.Response.Write(GetToken(context.Request.QueryString["FileName"]));
            }
         }

        public class AnotherJsonSerializer : IJsonSerializer
        {
            // 实现此接口的JSON序列化方法
            public string Serialize<T>(T obj) where T : new()
            {
                var settings = new JsonSerializerSettings();
                settings.ContractResolver = new CamelCasePropertyNamesContractResolver();
                settings.NullValueHandling = NullValueHandling.Ignore;
                return JsonConvert.SerializeObject(obj, settings);
            }
        }
        public class AnotherJsonDeserializer : IJsonDeserializer
        {
            // 实现此接口的JSON反序列化方法
            public bool Deserialize<T>(string str, out T obj) where T : new()
            {
                obj = default(T);
                bool ok = true;
                try
                {
                    obj = JsonConvert.DeserializeObject<T>(str);
                }
                catch (System.Exception)
                {
                    ok = false;
                }
                return ok;
            }
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
        public void UpdateVersion()
        {
            int dbversion = dal.ExecuteInt("Select VersionID From Version");
            dbversion++;
            dal.ExecuteNonQuery("Update Version set VersionID='" + dbversion + "'");

            VersionControl vc = new VersionControl(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"), System.Web.HttpContext.Current.Server.MapPath(""));
            vc.UploadDataBase();
        }
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }


        /// <summary>
        /// 获取空间文件列表          
        /// </summary>
        public DataTable ListFiles()
        {
            try
            {
                CdnRefresh();

                // 这个示例单独使用了一个Settings类，其中包含AccessKey和SecretKey
                // 实际应用中，请自行设置您的AccessKey和SecretKey
                Mac mac = new Mac(AppCode.AK, AppCode.SK);
                string bucket = "allfile";
                string marker = ""; // 首次请求时marker必须为空
                string prefix = null; // 按文件名前缀保留搜索结果
                string delimiter = null; // 目录分割字符(比如"/")
                int limit = 100; // 单次列举数量限制(最大值为1000)
                BucketManager bm = new BucketManager(mac);
                List<FileDesc> items = new List<FileDesc>();
                List<string> commonPrefixes = new List<string>();
                do
                {
                    ListResult result = bm.ListFiles(bucket, prefix, marker, limit, delimiter);
                    Console.WriteLine(result);
                    marker = result.Result.Marker;
                    if (result.Result.Items != null)
                    {
                        items.AddRange(result.Result.Items);
                    }
                    if (result.Result.CommonPrefixes != null)
                    {
                        commonPrefixes.AddRange(result.Result.CommonPrefixes);
                    }
                } while (!string.IsNullOrEmpty(marker));

                foreach (string cp in commonPrefixes)
                {
                    Console.WriteLine(cp);
                }
                foreach (var item in items)
                {
                    Console.WriteLine(item.Key);
                }

                DataTable dt = new DataTable();
                dt.TableName = "Notes";
                dt.Columns.Add("FileName");
                dt.Columns.Add("FileSize");

                for (int i = 0; i < items.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["FileName"] = items[i].Key;
                    long size = items[i].Fsize / 1000;
                    string FS = size > 1000 ? (size / 1000).ToString() + "MB" : size + "KB";
                    dr["FileSize"] = FS;
                    dt.Rows.Add(dr);
                }
                return dt;


            }
            catch (Exception ep)
            {
                return null;
            }
        }

        /// <summary>
        /// 缓存刷新
        /// </summary>
        public void CdnRefresh()
        {
            // 这个示例单独使用了一个Settings类，其中包含AccessKey和SecretKey
            // 实际应用中，请自行设置您的AccessKey和SecretKey
            Mac mac = new Mac(AppCode.AK, AppCode.SK);
            CdnManager cdnMgr = new CdnManager(mac);
            string[] dirs = new string[] { "http://omwseoozy.bkt.clouddn.com/" };
            var result = cdnMgr.RefreshDirs(dirs);
            // 或者使用下面的方法
            //RefreshRequest request = new RefreshRequest();
            //request.AddDirs(dirs);
            //var result = cdnMgr.RefreshUrlsAndDirs(request);
            Console.WriteLine(result);
        }


        public string GetToken(string fileName)
        {
            // 生成(上传)凭证时需要使用此Mac
            // 这个示例单独使用了一个Settings类，其中包含AccessKey和SecretKey
            // 实际应用中，请自行设置您的AccessKey和SecretKey
            Mac mac = new Mac(AppCode.AK, AppCode.SK);
            string bucket = "allfile";
            string saveKey = fileName;
          //  string localFile = Path;
            // 上传策略，参见 
            PutPolicy putPolicy = new PutPolicy();
            // 如果需要设置为"覆盖"上传(如果云端已有同名文件则覆盖)，请使用 SCOPE = "BUCKET:KEY"
            putPolicy.Scope = bucket + ":" + saveKey;
            //putPolicy.Scope = bucket;
            // 上传策略有效期(对应于生成的凭证的有效期)          
            putPolicy.SetExpires(3600);
            // 上传到云端多少天后自动删除该文件，如果不设置（即保持默认默认）则不删除
            // putPolicy.DeleteAfterDays = 1;
            string jstr = putPolicy.ToJsonString();
            string token = Auth.CreateUploadToken(mac, jstr);
            return token;
        }


        public void Logs(string Name,string Type,string Content)
        {
            string sqlLog = "Insert into Logs(Name,CreateDate,Type,Content) values('"+ Name + "','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "','" + Type + "','" + Content.Filter() + "')";
            dal.ExecuteNonQuery(sqlLog);
        }
    }
}