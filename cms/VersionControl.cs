using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Qiniu;
using Qiniu.Util;
using Qiniu.JSON;
using Qiniu.Http;
using Qiniu.IO;
using Qiniu.IO.Model;
using Qiniu.RS;
using Qiniu.RS.Model;
using System.IO;
using Qiniu.CDN;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Web.Script.Serialization;
using System.Threading;

namespace CMS
{
    public class VersionControl
    {
        CMS.App_Code.SQLite dal;

        public string MapPath = "";
        public string ServerPath = "";
        public VersionControl(string ServerMapPath, string NullPath)
        {
            MapPath = ServerMapPath;
            ServerPath = NullPath;
            dal = new CMS.App_Code.SQLite(MapPath);

            //new Qiniu(Server.MapPath("\\Bowtech.db"),Server.MapPath(""));
        }

        //从七牛 更新数据库文件
        private string DownLoadSQLite()
        {
            try
            {
                Random rd = new Random();
                int dom = rd.Next(0, 999999);
                // 文件URL
                string rawUrl = "http://omt3z8gfa.bkt.clouddn.com/Bowtech.db?id=" + dom;
                // 要保存的文件名，如果已存在则默认覆盖
                string saveFile = MapPath;
                // 可公开访问的url，直接下载
                HttpResult result = DownloadManager.Download(rawUrl, saveFile);
                string res = result.ToString();
                if (res.Substring(0, 8) == "code:200")
                {
                    //下载完成
                    return "更新完成";
                }
                else
                {
                    //下载失败
                    return "下载失败";
                }
            }
            catch (Exception ep)
            {
                return ep.Message;
            }
        }
        /// <summary>
        /// 缓存刷新
        /// </summary>
        private void CdnRefresh()
        {
            // 这个示例单独使用了一个Settings类，其中包含AccessKey和SecretKey
            // 实际应用中，请自行设置您的AccessKey和SecretKey
            Mac mac = new Mac(AppCode.AK, AppCode.SK);
            CdnManager cdnMgr = new CdnManager(mac);
            string[] dirs = new string[] { "http://omt3z8gfa.bkt.clouddn.com/" };
            var result = cdnMgr.RefreshDirs(dirs);
            // 或者使用下面的方法
            //RefreshRequest request = new RefreshRequest();
            //request.AddDirs(dirs);
            //var result = cdnMgr.RefreshUrlsAndDirs(request);
        }
        //检测版本
        private string CheckVersion()
        {
            try
            {
                CdnRefresh();

                // 这个示例单独使用了一个Settings类，其中包含AccessKey和SecretKey
                // 实际应用中，请自行设置您的AccessKey和SecretKey


                Mac mac = new Mac(AppCode.AK, AppCode.SK);
                string bucket = "mydb";
                string marker = ""; // 首次请求时marker必须为空
                string prefix = null; // 按文件名前缀保留搜索结果
                string delimiter = null; // 目录分割字符(比如"/")
                int limit = 100; // 单次列举数量限制(最大值为1000)
                BucketManager bm = new BucketManager(mac);
                List<FileDesc> items = new List<FileDesc>();

                ListResult result = bm.ListFiles(bucket, prefix, marker, limit, delimiter);


                JavaScriptSerializer js = new JavaScriptSerializer();

                object obj = js.DeserializeObject(result.Text);
                Dictionary<string, object> jd = (obj as Dictionary<string, object>);

                object[] dteil = (object[])jd["items"];

                for (int i = 0; i < dteil.Length; i++)
                {
                    Dictionary<string, object> li = dteil[i] as Dictionary<string, object>;

                    FileDesc fd = new FileDesc();
                    fd.Key = li["key"].ToString();
                    fd.Fsize = (int)li["fsize"];
                    fd.Hash = li["hash"].ToString();
                    fd.MimeType = li["mimeType"].ToString();
                    fd.PutTime = (long)li["putTime"];
                    items.Add(fd);
                }

                for (int i = 0; i < items.Count; i++)
                {
                    //判断名称里是否包含 Version  例：Version0
                    if (items[i].Key.IndexOf("version") >= 0)
                    {
                        string Version = items[i].Key.Substring(7);
                        Version = Version.Substring(0, Version.Length - 4);

                        int dbversion = dal.ExecuteInt("Select VersionID From Version");
                        if (Convert.ToInt32(Version) > dbversion)
                        {
                            //需更新版本
                            // DownLoadSQLite();
                            return "需更新版本";
                        }
                        else if (Convert.ToInt32(Version) == dbversion)
                        {
                            //最新版本
                            //Alert("");
                            return "最新版本";
                        }
                        else if (Convert.ToInt32(Version) < dbversion)
                        {
                            //Alert("");
                            return "请上传版本";
                        }
                    }
                }
                return "出现异常,不该访问到的代码！";
            }
            catch (Exception ep)
            {
                return ep.Message;
            }
        }

        /// <summary>
        /// 上传版本
        /// </summary>
        private string UploadVersion()
        {
            int dbversion = dal.ExecuteInt("Select VersionID From Version");

            string serverVersion = getVersionName();

            Mac mac = new Mac(AppCode.AK, AppCode.SK);
            string bucket = "mydb";
            string saveKey = "version" + dbversion + ".txt";
            string localFile = ServerPath + "\\" + "version" + dbversion + ".txt";  //Server.MapPath("version" + dbversion + ".txt");

            try
            {
                if (!File.Exists(localFile))
                {
                    FileStream fs = new FileStream(localFile, FileMode.Create);

                    fs.Close();
                }
            }
            catch (Exception ep)
            {
                string sqlLog = "Insert into Logs(Name,CreateDate,Type,Content) values('更新版本号-创建version.txt','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "','版本控制','" + ep.Message.Filter() + "')";
                dal.ExecuteNonQuery(sqlLog);
            }

            try
            {
                PutPolicy putPolicy = new PutPolicy();
                putPolicy.Scope = bucket + ":" + saveKey;
                putPolicy.SetExpires(3600);
                string jstr = "{\"scope\":\"" + putPolicy.Scope + "\",\"deadline\":" + putPolicy.Deadline + "}";  //putPolicy.ToJsonString();
                string token = Auth.CreateUploadToken(mac, jstr);

                UploadManager um = new UploadManager();

                //先删除
                BucketManager bm = new BucketManager(mac);
                bm.Delete(bucket, serverVersion);

                HttpResult result = um.UploadFile(localFile, saveKey, token);
                string res = result.ToString();

                File.Delete(localFile);

                return "Finish";
            }
            catch(Exception ep)
            {
                return ep.Message;
            }
        }

        //获取服务器版本名称
        private string getVersionName()
        {
            try
            {
                CdnRefresh();

                // 这个示例单独使用了一个Settings类，其中包含AccessKey和SecretKey
                // 实际应用中，请自行设置您的AccessKey和SecretKey
                Mac mac = new Mac(AppCode.AK, AppCode.SK);
                string bucket = "mydb";
                string marker = ""; // 首次请求时marker必须为空
                string prefix = null; // 按文件名前缀保留搜索结果
                string delimiter = null; // 目录分割字符(比如"/")
                int limit = 100; // 单次列举数量限制(最大值为1000)
                BucketManager bm = new BucketManager(mac);
                List<FileDesc> items = new List<FileDesc>();

                ListResult result = bm.ListFiles(bucket, prefix, marker, limit, delimiter);

                JavaScriptSerializer js = new JavaScriptSerializer();

                object obj = js.DeserializeObject(result.Text);
                Dictionary<string, object> jd = (obj as Dictionary<string, object>);

                object[] dteil = (object[])jd["items"];

                for (int i = 0; i < dteil.Length; i++)
                {
                    Dictionary<string, object> li = dteil[i] as Dictionary<string, object>;

                    FileDesc fd = new FileDesc();
                    fd.Key = li["key"].ToString();
                    fd.Fsize = (int)li["fsize"];
                    fd.Hash = li["hash"].ToString();
                    fd.MimeType = li["mimeType"].ToString();
                    fd.PutTime = (long)li["putTime"];
                    items.Add(fd);
                }

                for (int i = 0; i < items.Count; i++)
                {
                    //判断名称里是否包含 Version  例：Version0
                    if (items[i].Key.IndexOf("version") >= 0)
                    {
                        return items[i].Key;
                    }
                }

                return "";
            }
            catch (Exception ep)
            {
                return "";
            }
        }
        /// <summary>
        /// 上传库文件
        /// </summary>
        /// <returns></returns>
        private string UploadFile()
        {

            try
            {
                // 生成(上传)凭证时需要使用此Mac
                // 这个示例单独使用了一个Settings类，其中包含AccessKey和SecretKey
                // 实际应用中，请自行设置您的AccessKey和SecretKey
                Mac mac = new Mac(AppCode.AK, AppCode.SK);
                string bucket = "mydb";
                string saveKey = "Bowtech.db";
                string localFile = MapPath;// Server.MapPath("Bowtech.db");
                                           // 上传策略，参见 
                                           // https://developer.qiniu.com/kodo/manual/put-policy
                PutPolicy putPolicy = new PutPolicy();
                // 如果需要设置为"覆盖"上传(如果云端已有同名文件则覆盖)，请使用 SCOPE = "BUCKET:KEY"
                putPolicy.Scope = bucket + ":" + saveKey;
                //putPolicy.Scope = bucket;
                // 上传策略有效期(对应于生成的凭证的有效期)          
                putPolicy.SetExpires(3600);
                // 上传到云端多少天后自动删除该文件，如果不设置（即保持默认默认）则不删除
                // putPolicy.DeleteAfterDays = 1;
                string jstr = "{\"scope\":\"" + putPolicy.Scope + "\",\"deadline\":" + putPolicy.Deadline + "}"; //putPolicy.ToJsonString();
                string token = Auth.CreateUploadToken(mac, jstr);

                UploadManager um = new UploadManager();

                //先删除
                BucketManager bm = new BucketManager(mac);
                bm.Delete(bucket, saveKey);

                HttpResult result = um.UploadFile(localFile, saveKey, token);
                string res = result.ToString();
                if (res.Substring(0, 8) == "code:200")
                {
                    return "上传完成";
                }
                else
                {

                    return "上传异常";
                }
            }
            catch (Exception ep)
            {
                return ep.Message;
            }

        }


        public void UploadDataBase()
        {
            Thread st = new Thread(new ThreadStart(ExecuteUpload));
            st.Start();
        }

        //执行版本上传
        private void ExecuteUpload()
        {
            string checkVersion = CheckVersion();
            if (checkVersion == "最新版本")
            {
                //这里几乎进不来...
                string sqlLog = "Insert into Logs(Name,CreateDate,Type,Content) values('检测版本','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "','版本控制','代码进入了“最新版本”')";
                dal.ExecuteNonQuery(sqlLog);
            }
            else if (checkVersion == "请上传版本")
            {
                string ret = UploadVersion();//上传版本控制
                if (ret != "Finish")
                {
                    string sqlLog = "Insert into Logs(Name,CreateDate,Type,Content) values('更新版本号','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "','版本控制','" + checkVersion.Filter() + "')";
                    dal.ExecuteNonQuery(sqlLog);
                }
                string upStr = UploadFile();//上传数据库文件
                if (upStr == "上传完成")
                {
                    //这里是安全代码 也是必经之路.. 如果不然则进入 错误日志系统..
                }
                else if (upStr == "上传异常")
                {
                    string sqlLog = "Insert into Logs(Name,CreateDate,Type,Content) values('上传库文件','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "','版本控制','上传异常')";
                    dal.ExecuteNonQuery(sqlLog);
                }
                else
                {
                    string sqlLog = "Insert into Logs(Name,CreateDate,Type,Content) values('上传库文件','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "','版本控制','" + upStr.Filter() + "')";
                    dal.ExecuteNonQuery(sqlLog);
                }
            }
            else if (checkVersion == "需更新版本")
            {
                //这里几乎进不来...
                string sqlLog = "Insert into Logs(Name,CreateDate,Type,Content) values('检测版本','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "','版本控制','代码进入了“需要更新版本”')";
                dal.ExecuteNonQuery(sqlLog);
            }
            else //出现了异常
            {
                string sqlLog = "Insert into Logs(Name,CreateDate,Type,Content) values('检测版本','" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "','版本控制','" + checkVersion.Filter() + "')";
                dal.ExecuteNonQuery(sqlLog);
            }
        }
    }
}