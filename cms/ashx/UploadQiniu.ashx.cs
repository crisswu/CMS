using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
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
using CMS.App_Code;

namespace CMS.ashx
{
    /// <summary>
    /// UploadQiniu 的摘要说明
    /// </summary>
    public class UploadQiniu : IHttpHandler
    {
        SQLite dal;
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";

            dal = new SQLite(System.Web.HttpContext.Current.Server.MapPath("\\Bowtech.db"));
            Qiniu.JSON.JsonHelper.JsonSerializer = new AnotherJsonSerializer();
            Qiniu.JSON.JsonHelper.JsonDeserializer = new AnotherJsonDeserializer();

            if (context.Request.QueryString["funType"] == "...")
            {
                HttpFileCollection files = HttpContext.Current.Request.Files;
                int count = files.Count;

                if (count != 0)
                {
                    for (int i = 0; i < count; i++)
                    {
                        HttpPostedFile file = files[i];
                        string tmpPath = HttpContext.Current.Server.MapPath("/UploadTMP/");
                        string fileName = System.IO.Path.GetFileName(file.FileName);
                        try
                        {
                            fileName = fileName + "2";
                            string severlocalpath = tmpPath + fileName;
                            file.SaveAs(severlocalpath);



                        }
                        catch (Exception ex)
                        {

                        }
                    }
                }

                // context.Response.Write(GetToken(context.Request.QueryString["FileName"]));
            }

            else if (context.Request.QueryString["funType"] == "UploadFile")
            {
                try
                {

                    string message = string.Empty;
                    string filepath = string.Empty;


                    string resourceDirectoryName = "UploadTMP";
                    string path = context.Server.MapPath("~/" + resourceDirectoryName);
                    if (!Directory.Exists(path))
                        Directory.CreateDirectory(path);

                    int chunk = context.Request.Params["chunk"] != null ? int.Parse(context.Request.Params["chunk"]) : 0; //获取当前的块ID，如果不是分块上传的。chunk则为0
                    string fileName = context.Request.Params["name"]; //这里写的比较潦草。判断文件名是否为空。
                    string type = context.Request.Params["type"]; //在前面JS中不是定义了自定义参数multipart_params的值么。其中有个值是type:"misoft"，此处就可以获取到这个值了。获取到的type="misoft";

                    string ext = Path.GetExtension(fileName);
                    //fileName = string.Format("{0}{1}", Guid.NewGuid().ToString(), ext);
                    filepath = resourceDirectoryName + "/" + fileName;
                    fileName = Path.Combine(path, fileName);

                    //对文件流进行存储 需要注意的是 files目录必须存在（此处可以做个判断） 根据上面的chunk来判断是块上传还是普通上传 上传方式不一样 ，导致的保存方式也会不一样
                    FileStream fs = new FileStream(fileName, chunk == 0 ? FileMode.OpenOrCreate : FileMode.Append);
                    //write our input stream to a buffer
                    Byte[] buffer = null;
                    if (context.Request.ContentType == "application/octet-stream" && context.Request.ContentLength > 0)
                    {
                        buffer = new Byte[context.Request.InputStream.Length];
                        context.Request.InputStream.Read(buffer, 0, buffer.Length);
                    }
                    else if (context.Request.ContentType.Contains("multipart/form-data") && context.Request.Files.Count > 0 && context.Request.Files[0].ContentLength > 0)
                    {
                        buffer = new Byte[context.Request.Files[0].InputStream.Length];
                        context.Request.Files[0].InputStream.Read(buffer, 0, buffer.Length);
                    }

                    //write the buffer to a file.
                    if (buffer != null)
                        fs.Write(buffer, 0, buffer.Length);
                    fs.Close();


                    message = "上传成功";

                }
                catch (Exception ex)
                {
                    ex.Message.Logs();
                }
            }
            else if (context.Request.QueryString["funType"] == "DeleteFile")
            {
                context.Response.Write(DeleteFile(context.Request.QueryString["FileName"]));
            }
            else if (context.Request.QueryString["funType"] == "GoFileQiNiu")
            {
                //把切片上传的图片 完成后所调用 七牛云服务 上传
                string resourceDirectoryName = "UploadTMP";
                string fileName = context.Request.QueryString["FileName"];
                string path = context.Server.MapPath("~/" + resourceDirectoryName);
                string filePath = Path.Combine(path, fileName);

                UploadFile(filePath, fileName);

                File.Delete(filePath);
            }
            else if (context.Request.QueryString["funType"] == "UploadCodeFile")//上传 我的文件
            {
                try
                {

                    string message = string.Empty;
                    string filepath = string.Empty;


                    string resourceDirectoryName = "UploadFile";
                    string path = context.Server.MapPath("~/" + resourceDirectoryName);
                    if (!Directory.Exists(path))
                        Directory.CreateDirectory(path);

                    int chunk = context.Request.Params["chunk"] != null ? int.Parse(context.Request.Params["chunk"]) : 0; //获取当前的块ID，如果不是分块上传的。chunk则为0
                    string fileName = context.Request.Params["name"]; //这里写的比较潦草。判断文件名是否为空。
                    string type = context.Request.Params["type"]; //在前面JS中不是定义了自定义参数multipart_params的值么。其中有个值是type:"misoft"，此处就可以获取到这个值了。获取到的type="misoft";

                    string ext = Path.GetExtension(fileName);
                    //fileName = string.Format("{0}{1}", Guid.NewGuid().ToString(), ext);
                    filepath = resourceDirectoryName + "/" + fileName;
                    fileName = Path.Combine(path, fileName);

                    //对文件流进行存储 需要注意的是 files目录必须存在（此处可以做个判断） 根据上面的chunk来判断是块上传还是普通上传 上传方式不一样 ，导致的保存方式也会不一样
                    FileStream fs = new FileStream(fileName, chunk == 0 ? FileMode.OpenOrCreate : FileMode.Append);
                    //write our input stream to a buffer
                    Byte[] buffer = null;
                    if (context.Request.ContentType == "application/octet-stream" && context.Request.ContentLength > 0)
                    {
                        buffer = new Byte[context.Request.InputStream.Length];
                        context.Request.InputStream.Read(buffer, 0, buffer.Length);
                    }
                    else if (context.Request.ContentType.Contains("multipart/form-data") && context.Request.Files.Count > 0 && context.Request.Files[0].ContentLength > 0)
                    {
                        buffer = new Byte[context.Request.Files[0].InputStream.Length];
                        context.Request.Files[0].InputStream.Read(buffer, 0, buffer.Length);
                    }

                    //write the buffer to a file.
                    if (buffer != null)
                        fs.Write(buffer, 0, buffer.Length);
                    fs.Close();




                }
                catch (Exception ex)
                {
                    ex.Message.Logs();
                }
            }
            else if (context.Request.QueryString["funType"] == "UploadCodeFile_Cloud")//上传 我的文件
            {
                try
                {

                    string message = string.Empty;
                    string filepath = string.Empty;


                    string resourceDirectoryName = "UploadCloud";
                    string path = context.Server.MapPath("~/" + resourceDirectoryName);
                    if (!Directory.Exists(path))
                        Directory.CreateDirectory(path);

                    int chunk = context.Request.Params["chunk"] != null ? int.Parse(context.Request.Params["chunk"]) : 0; //获取当前的块ID，如果不是分块上传的。chunk则为0
                    string fileName = context.Request.Params["name"]; //这里写的比较潦草。判断文件名是否为空。
                    string type = context.Request.Params["type"]; //在前面JS中不是定义了自定义参数multipart_params的值么。其中有个值是type:"misoft"，此处就可以获取到这个值了。获取到的type="misoft";

                    string ext = Path.GetExtension(fileName);
                    //fileName = string.Format("{0}{1}", Guid.NewGuid().ToString(), ext);
                    filepath = resourceDirectoryName + "/" + fileName;
                    fileName = Path.Combine(path, fileName);

                    //对文件流进行存储 需要注意的是 files目录必须存在（此处可以做个判断） 根据上面的chunk来判断是块上传还是普通上传 上传方式不一样 ，导致的保存方式也会不一样
                    FileStream fs = new FileStream(fileName, chunk == 0 ? FileMode.OpenOrCreate : FileMode.Append);
                    //write our input stream to a buffer
                    Byte[] buffer = null;
                    if (context.Request.ContentType == "application/octet-stream" && context.Request.ContentLength > 0)
                    {
                        buffer = new Byte[context.Request.InputStream.Length];
                        context.Request.InputStream.Read(buffer, 0, buffer.Length);
                    }
                    else if (context.Request.ContentType.Contains("multipart/form-data") && context.Request.Files.Count > 0 && context.Request.Files[0].ContentLength > 0)
                    {
                        buffer = new Byte[context.Request.Files[0].InputStream.Length];
                        context.Request.Files[0].InputStream.Read(buffer, 0, buffer.Length);
                    }

                    //write the buffer to a file.
                    if (buffer != null)
                        fs.Write(buffer, 0, buffer.Length);
                    fs.Close();
                }
                catch (Exception ex)
                {
                    ex.Message.Logs();
                }
            }
            else if (context.Request.QueryString["funType"] == "GetCodeFiles")
            {
                string Type = context.Request.QueryString["Type"];
                string resourceDirectoryName = "UploadFile";
                string path = context.Server.MapPath("~/" + resourceDirectoryName);

                DataTable dt = new DataTable();
                dt.Columns.Add("FileName");
                dt.Columns.Add("FileSize");
                dt.Columns.Add("FileType");
                dt.TableName = "Notes";

                DirectoryInfo DirInfo = new DirectoryInfo(path);
                FileInfo[] Files = DirInfo.GetFiles(); //文件集合

                foreach (FileInfo file in Files)
                {
                    #region 旧代码
                    //if (file.Extension == Type || Type=="" )//判断类型是否一致    例如：.cs 
                    //{
                    //string name = file.Name;//文件名称
                    //long leng = file.Length;//文件长度
                    //long size = leng / 1000;
                    //string FS = size > 1000 ? (size / 1000).ToString() + "MB" : size + "KB";//转换成 大小
                    //DataRow dr = dt.NewRow();
                    //dr["FileName"] = name;
                    //dr["FileSize"] = FS;
                    //dr["FileType"] = file.Extension;
                    //dt.Rows.Add(dr);
                    // }
                    //else if(Type=="Other")
                    //{
                    //    List<string> list = new List<string>() { ".dll", ".css", ".js", ".cs", ".xml", ".html", ".aspx", ".ashx", ".txt", ".xls", ".xlsx" };
                    //    if (!list.Contains(file.Extension))//如果尾椎不存在与这些里 则添加到 其他当中
                    //    {
                    //        string name = file.Name;//文件名称
                    //        long leng = file.Length;//文件长度
                    //        long size = leng / 1000;
                    //        string FS = size > 1000 ? (size / 1000).ToString() + "MB" : size + "KB";//转换成 大小
                    //        DataRow dr = dt.NewRow();
                    //        dr["FileName"] = name;
                    //        dr["FileSize"] = FS;
                    //        dt.Rows.Add(dr);
                    //    }
                    //}
                    #endregion

                    string name = file.Name;//文件名称
                    long leng = file.Length;//文件长度
                    long size = leng / 1000;
                    string FS = size > 1000 ? (size / 1000).ToString() + "MB" : size + "KB";//转换成 大小
                    DataRow dr = dt.NewRow();
                    dr["FileName"] = name;
                    dr["FileSize"] = FS;
                    dr["FileType"] = file.Extension;
                    dt.Rows.Add(dr);
                }

                context.Response.Write(ConvertDataTableToJson(dt));
            }
            else if (context.Request.QueryString["funType"] == "GetCodeFiles_Cloud")
            {
                string Type = context.Request.QueryString["Type"];
                string resourceDirectoryName = "UploadCloud";
                string path = context.Server.MapPath("~/" + resourceDirectoryName);

                DataTable dt = new DataTable();
                dt.Columns.Add("FileName");
                dt.Columns.Add("FileSize");
                dt.Columns.Add("FileType");
                dt.TableName = "Notes";

                DirectoryInfo DirInfo = new DirectoryInfo(path);
                FileInfo[] Files = DirInfo.GetFiles(); //文件集合

                foreach (FileInfo file in Files)
                {
                    string name = file.Name;//文件名称
                    long leng = file.Length;//文件长度
                    long size = leng / 1000;
                    string FS = size > 1000 ? (size / 1000).ToString() + "MB" : size + "KB";//转换成 大小
                    DataRow dr = dt.NewRow();
                    dr["FileName"] = name;
                    dr["FileSize"] = FS;
                    dr["FileType"] = file.Extension;
                    dt.Rows.Add(dr);
                }

                context.Response.Write(ConvertDataTableToJson(dt));
            }
            else if (context.Request.QueryString["funType"] == "DeleteCodeFile")//删 除
            {
                string resourceDirectoryName = "UploadFile";
                string path = context.Server.MapPath("~/" + resourceDirectoryName);
                DirectoryInfo DirInfo = new DirectoryInfo(path);
                FileInfo[] Files = DirInfo.GetFiles(); //文件集合
                foreach (FileInfo file in Files)
                {
                    if (file.Name == context.Request.QueryString["FileName"])
                    {
                        file.Delete();
                    } 
                }
            }
            else if (context.Request.QueryString["funType"] == "DeleteCodeFile_Cloud")//删 除
            {
                string resourceDirectoryName = "UploadCloud";
                string path = context.Server.MapPath("~/" + resourceDirectoryName);
                DirectoryInfo DirInfo = new DirectoryInfo(path);
                FileInfo[] Files = DirInfo.GetFiles(); //文件集合
                foreach (FileInfo file in Files)
                {
                    if (file.Name == context.Request.QueryString["FileName"])
                    {
                        file.Delete();
                    }
                }
            }
        }

        //计算文件夹中的文件大小
        public double CountSizeFile(FileInfo[] Files)
        {
            double SizeSum = 0;//获取文件大小
            for (int i = 0; i < Files.Length; i++)
            {
                 SizeSum += Files[i].Length;
            }
            return SizeSum;
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
        //上传文件
        public string UploadFile(string Path, string fileName)
        {

            // 生成(上传)凭证时需要使用此Mac
            // 这个示例单独使用了一个Settings类，其中包含AccessKey和SecretKey
            // 实际应用中，请自行设置您的AccessKey和SecretKey
            Mac mac = new Mac(AppCode.AK, AppCode.SK);
            string bucket = "allfile";
            string saveKey = fileName;
            string localFile = Path;
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

            UploadManager um = new UploadManager();

            //先删除
            BucketManager bm = new BucketManager(mac);
            bm.Delete(bucket, saveKey);

            HttpResult result = um.UploadFile(localFile, saveKey, token);
            string res = result.ToString();
            if (res.Substring(0, 8) == "code:200")
            {
                return "";
            }
            else
            {
                res.Logs();
                return res;
            }



        }

        public string DeleteFile(string Name)
        {
            // 生成(上传)凭证时需要使用此Mac
            // 这个示例单独使用了一个Settings类，其中包含AccessKey和SecretKey
            // 实际应用中，请自行设置您的AccessKey和SecretKey
            Mac mac = new Mac(AppCode.AK, AppCode.SK);
            string bucket = "allfile";
            string fileName = Name;
            string saveKey = fileName;


            PutPolicy putPolicy = new PutPolicy();
            putPolicy.Scope = bucket + ":" + saveKey;

            putPolicy.SetExpires(3600);

            string jstr = putPolicy.ToJsonString();
            string token = Auth.CreateUploadToken(mac, jstr);

            //先删除
            BucketManager bm = new BucketManager(mac);
            HttpResult result = bm.Delete(bucket, saveKey);
            string res = result.ToString();
            if (res.Substring(0, 8) == "code:200")
            {
                return "";
            }
            else
            {
                return res;
            }
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