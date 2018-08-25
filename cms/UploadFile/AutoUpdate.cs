using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Runtime.InteropServices;
using System.Xml;
using System.Diagnostics;

namespace AutoUpdate
{
    #region 枚举
    public enum ERROR_ID
    {
        ERROR_SUCCESS = 0,  // Success   
        ERROR_BUSY = 170,
        ERROR_MORE_DATA = 234,
        ERROR_NO_BROWSER_SERVERS_FOUND = 6118,
        ERROR_INVALID_LEVEL = 124,
        ERROR_ACCESS_DENIED = 5,
        ERROR_INVALID_PASSWORD = 86,
        ERROR_INVALID_PARAMETER = 87,
        ERROR_BAD_DEV_TYPE = 66,
        ERROR_NOT_ENOUGH_MEMORY = 8,
        ERROR_NETWORK_BUSY = 54,
        ERROR_BAD_NETPATH = 53,
        ERROR_NO_NETWORK = 1222,
        ERROR_INVALID_HANDLE_STATE = 1609,
        ERROR_EXTENDED_ERROR = 1208,
        ERROR_DEVICE_ALREADY_REMEMBERED = 1202,
        ERROR_NO_NET_OR_BAD_PATH = 1203
    }
    public enum RESOURCE_SCOPE
    {
        RESOURCE_CONNECTED = 1,
        RESOURCE_GLOBALNET = 2,
        RESOURCE_REMEMBERED = 3,
        RESOURCE_RECENT = 4,
        RESOURCE_CONTEXT = 5
    }
    public enum RESOURCE_TYPE
    {
        RESOURCETYPE_ANY = 0,
        RESOURCETYPE_DISK = 1,
        RESOURCETYPE_PRINT = 2,
        RESOURCETYPE_RESERVED = 8,
    }
    public enum RESOURCE_USAGE
    {
        RESOURCEUSAGE_CONNECTABLE = 1,
        RESOURCEUSAGE_CONTAINER = 2,
        RESOURCEUSAGE_NOLOCALDEVICE = 4,
        RESOURCEUSAGE_SIBLING = 8,
        RESOURCEUSAGE_ATTACHED = 16,
        RESOURCEUSAGE_ALL = (RESOURCEUSAGE_CONNECTABLE | RESOURCEUSAGE_CONTAINER | RESOURCEUSAGE_ATTACHED),
    }
    public enum RESOURCE_DISPLAYTYPE
    {
        RESOURCEDISPLAYTYPE_GENERIC = 0,
        RESOURCEDISPLAYTYPE_DOMAIN = 1,
        RESOURCEDISPLAYTYPE_SERVER = 2,
        RESOURCEDISPLAYTYPE_SHARE = 3,
        RESOURCEDISPLAYTYPE_FILE = 4,
        RESOURCEDISPLAYTYPE_GROUP = 5,
        RESOURCEDISPLAYTYPE_NETWORK = 6,
        RESOURCEDISPLAYTYPE_ROOT = 7,
        RESOURCEDISPLAYTYPE_SHAREADMIN = 8,
        RESOURCEDISPLAYTYPE_DIRECTORY = 9,
        RESOURCEDISPLAYTYPE_TREE = 10,
        RESOURCEDISPLAYTYPE_NDSCONTAINER = 11
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct NETRESOURCE
    {
        public RESOURCE_SCOPE dwScope;
        public RESOURCE_TYPE dwType;
        public RESOURCE_DISPLAYTYPE dwDisplayType;
        public RESOURCE_USAGE dwUsage;

        [MarshalAs(UnmanagedType.LPStr)]
        public string lpLocalName;

        [MarshalAs(UnmanagedType.LPStr)]
        public string lpRemoteName;

        [MarshalAs(UnmanagedType.LPStr)]
        public string lpComment;

        [MarshalAs(UnmanagedType.LPStr)]
        public string lpProvider;
    }
    #endregion

    public partial class AutoUpdate : Form
    {
        #region 访问局域网方法
        [DllImport("mpr.dll")]
        public static extern int WNetAddConnection2A(NETRESOURCE[] lpNetResource, string lpPassword, string lpUserName, int dwFlags);

        [DllImport("mpr.dll")]
        public static extern int WNetCancelConnection2A(string sharename, int dwFlags, int fForce);  
        public AutoUpdate()
        {
            InitializeComponent();
        }

        public int Connect(string remotePath, string localPath, string username, string password)
        {
            NETRESOURCE[] share_driver = new NETRESOURCE[1];
            share_driver[0].dwScope = RESOURCE_SCOPE.RESOURCE_GLOBALNET;
            share_driver[0].dwType = RESOURCE_TYPE.RESOURCETYPE_DISK;
            share_driver[0].dwDisplayType = RESOURCE_DISPLAYTYPE.RESOURCEDISPLAYTYPE_SHARE;
            share_driver[0].dwUsage = RESOURCE_USAGE.RESOURCEUSAGE_CONNECTABLE;
            share_driver[0].lpLocalName = localPath;
            share_driver[0].lpRemoteName = remotePath;

            Disconnect(localPath);
            int ret = WNetAddConnection2A(share_driver, password, username,1);

            return ret;
        }

        public  int Disconnect(string localpath)
        {
            return WNetCancelConnection2A(localpath,1,1);
        }
        #endregion

        double SizeNow = 0;
        string ServerIP = "";
        string ServerID = "";
        string ServerPWD = "";
        string StartEXE = "";
        string ServerDIR = "";

        //加载
        private void AutoUpdate_Load(object sender, EventArgs e)
        {
               string path = System.Environment.CurrentDirectory + "\\AutoUpdateConfig.xml";
               XmlDocument xmlDocument = new XmlDocument();
               xmlDocument.Load(path);
               XmlNode xmlNode = xmlDocument.DocumentElement;
               foreach (XmlNode node in xmlNode)
               {
                   if (node.Name == "ServerIP")
                   {
                       ServerIP = node.InnerText;
                   }
                   if (node.Name == "ServerID")
                   {
                       ServerID = node.InnerText;
                   }
                   if (node.Name == "ServerPWD")
                   {
                       ServerPWD = node.InnerText;
                   }
                   if (node.Name == "StartEXE")
                   {
                       StartEXE = node.InnerText;
                   }
                   if (node.Name == "ServerDIR")
                   {
                       ServerDIR = node.InnerText;
                   }
               }
             
        }
        //自动更新
        public void GoUpdate()
        {
            string path = System.Environment.CurrentDirectory;//本地工作路径
            string localpath = @"X:";
            int status = Connect(@"\\" + ServerIP + @"\" + ServerDIR, localpath, ServerID, ServerPWD);
            if (status == (int)ERROR_ID.ERROR_SUCCESS)
            {
                DirectoryInfo DirInfo = new DirectoryInfo(localpath);
                double SizeSum = GetSize(DirInfo, path, localpath);
                proLogin.Maximum = Convert.ToInt32(SizeSum);
                lblAll.Text = "总大小：" + Convert.ToDouble(proLogin.Maximum/1024).ToString("n") + " KB";
                lblNow.Text = "已下载：" + Convert.ToDouble(proLogin.Value).ToString("n") + " KB";
                Application.DoEvents();
                MoveAll(DirInfo, path, localpath);
                proLogin.Value = Convert.ToInt32(SizeSum);
                Application.DoEvents();
                Process p = new Process();
                p.StartInfo.FileName = StartEXE;
                p.StartInfo.WindowStyle = ProcessWindowStyle.Normal;
                try
                {
                    p.Start();
                    Application.Exit();
                }
                catch(Exception ep)
                {
                    MessageBox.Show(ep.Message, "程序启动失败");
                    Application.Exit();
                }
            }
            else if (status == 1219)
            {
                MessageBox.Show("活动连接过多,请注销Windows或重新启动计算机！");
                Application.Exit();
            }
            else
            {
                MessageBox.Show("连接服务器失败！");
                Application.Exit();
            }
            Disconnect(localpath);  
        }
        //计算文件夹中的文件大小
        public double CountSizeFile(FileInfo[] Files,string path,string localpath)
        {
            double SizeSum = 0;//获取文件大小
            for (int i = 0; i < Files.Length; i++)
            {
                //判断服务器文件是否存在于本地
                if (File.Exists(path + @"\" + Files[i].Name))
                {
                    if (File.GetLastWriteTime(path + @"\" + Files[i].Name).ToString("yyyy-MM-dd HH:mm:ss") !=
                        File.GetLastWriteTime(localpath + @"\" + Files[i].Name).ToString("yyyy-MM-dd HH:mm:ss"))//判断最后更新日期是否相等
                    {
                        SizeSum += Files[i].Length;
                    }
                }
                else //发现新文件
                {
                    SizeSum += Files[i].Length;
                }
            }
            return SizeSum;
        }
        //递归返回文件夹大小
        public double GetSize(DirectoryInfo DirInfo, string path, string localpath)
        {
            DirectoryInfo[] Dirs = DirInfo.GetDirectories();//文件夹集合
            FileInfo[] Files = DirInfo.GetFiles(); //文件集合
            // 获取单个文件大小
            double SizeSum = 0;//获取文件大小
            SizeSum = CountSizeFile(Files, path, localpath);

             //获取文件夹中的文件大小
            for (int i = 0; i < Dirs.Length; i++)
            {
                //判断服务器文件夹是否存在于本地
                if (Directory.Exists(path + @"\" + Dirs[i].Name))
                {
                    SizeSum += GetSize(Dirs[i], path + @"\" + Dirs[i].Name, Dirs[i].FullName);
                }
                else
                {
                    SizeSum += GetSize(Dirs[i], path, localpath);
                }
            }
            return SizeSum;
        }
        //递归移动文件夹
        public void MoveAll(DirectoryInfo DirInfo, string path, string localpath)
        {
            DirectoryInfo[] Dirs = DirInfo.GetDirectories();//文件夹集合
            FileInfo[] Files = DirInfo.GetFiles(); //文件集合
            MoveFiles(Files, path, localpath);
            for (int i = 0; i < Dirs.Length; i++)
            {
                //判断服务器文件夹是否存在于本地
                if (Directory.Exists(path + @"\" + Dirs[i].Name))
                {
                    MoveAll(Dirs[i], path + @"\" + Dirs[i].Name, Dirs[i].FullName);
                }
                else
                {
                    CopyDirectory(Dirs[i].FullName, path + @"\");
                    Application.DoEvents();                                            
                }
                
            }
        }
        //移动更新的文件以及新文件
        public void MoveFiles(FileInfo[] Files, string path, string localpath)
        {
            try
            {
                for (int i = 0; i < Files.Length; i++)
                {
                    //判断服务器文件是否存在于本地
                    if (File.Exists(path + @"\" + Files[i].Name))
                    {
                        if (File.GetLastWriteTime(path + @"\" + Files[i].Name).ToString("yyyy-MM-dd HH:mm:ss") !=
                            File.GetLastWriteTime(localpath + @"\" + Files[i].Name).ToString("yyyy-MM-dd HH:mm:ss"))//判断最后更新日期是否相等
                        {
                            File.Copy(localpath + @"\" + Files[i].Name, path + @"\" + Files[i].Name, true);
                            SizeNow += Files[i].Length;
                            proLogin.Value = Convert.ToInt32(SizeNow);
                            lblAll.Text = "总大小：" + Convert.ToDouble(proLogin.Maximum/1024).ToString("n") + " KB";
                            lblNow.Text = "已下载：" + Convert.ToDouble(proLogin.Value / 1024).ToString("n") + " KB";
                            Application.DoEvents();
                        }
                    }
                    else //发现新文件
                    {
                        File.Copy(localpath + @"\" + Files[i].Name, path + @"\" + Files[i].Name, true);
                        SizeNow += Files[i].Length;
                        proLogin.Value = Convert.ToInt32(SizeNow);
                        lblAll.Text = "总大小：" + Convert.ToDouble(proLogin.Maximum / 1024).ToString("n") + " KB";
                        lblNow.Text = "已下载：" + Convert.ToDouble(proLogin.Value / 1024).ToString("n") + " KB";
                        Application.DoEvents();
                    }
                }
            }
            catch (Exception ep)
            {
                MessageBox.Show(ep.Message);
                return;
            }
        }
        // 拷贝文件夹
        private void CopyDirectory(string srcdir, string desdir)
        {
            string folderName = srcdir.Substring(srcdir.LastIndexOf("\\") + 1);

            string desfolderdir = desdir + "\\" + folderName;

            if (desdir.LastIndexOf("\\") == (desdir.Length - 1))
            {
                desfolderdir = desdir + folderName;
            }
            string[] filenames = Directory.GetFileSystemEntries(srcdir);

            foreach (string file in filenames)// 遍历所有的文件和目录
            {
                if (Directory.Exists(file))// 先当作目录处理如果存在这个目录就递归Copy该目录下面的文件
                {

                    string currentdir = desfolderdir + "\\" + file.Substring(file.LastIndexOf("\\") + 1);
                    if (!Directory.Exists(currentdir))
                    {
                        Directory.CreateDirectory(currentdir);
                    }

                    CopyDirectory(file, desfolderdir);
                }

                else // 否则直接copy文件
                {
                    string srcfileName = file.Substring(file.LastIndexOf("\\") + 1);

                    srcfileName = desfolderdir + "\\" + srcfileName;

                    if (!Directory.Exists(desfolderdir))
                    {
                        Directory.CreateDirectory(desfolderdir);
                    }

                    File.Copy(file, srcfileName);
                }
            }//foreach
        }
        //执行
        private void AutoUpdate_Shown(object sender, EventArgs e)
        {
            GoUpdate();
        }

    }
}
