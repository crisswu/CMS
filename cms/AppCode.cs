using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.IO;
using System.Security;
using System.Security.Cryptography;

public static class AppCode
    {
 
    //七牛 接口
         public static string AK = "BjSys2_mqjjij_xW_9IROgvkNcssC5qh91Nx9khH";
        public static string SK = "cULYrizgRT432gUWtQO1umAa29Gk1Lntb7vbj-QL";
        public static string LoginPassword = "712171819149138"; //登录密码   

        public static string Filter(this string str)
        {
            if (str.IndexOf("'") >= 0)
                str = str.Replace("'", "''");
            return str;
        }
        public static void Logs(this string Msg)
        {
            try
            {
                string path = AppDomain.CurrentDomain.BaseDirectory + "Logs";
                if (!Directory.Exists(path))//如果日志目录不存在就创建
                {
                    Directory.CreateDirectory(path);
                }

                string time = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");//获取当前系统时间
                string filename = path + "/" + DateTime.Now.ToString("yyyy-MM-dd") + ".log";//用日期对日志文件命名

                //创建或打开日志文件，向日志文件末尾追加记录
                StreamWriter mySw = File.AppendText(filename);

                //向日志文件写入内容
                mySw.WriteLine(Msg);

                //关闭日志文件
                mySw.Close();
            }
            catch (Exception ex)
            {

            }
        }
    //判断是否为数字
    public static bool IsNumber(this string strNumber)
        {
            Regex objNotNumberPattern = new Regex("[^0-9.-]");
            Regex objTwoDotPattern = new Regex("[0-9]*[.][0-9]*[.][0-9]*");
            Regex objTwoMinusPattern = new Regex("[0-9]*[-][0-9]*[-][0-9]*");
            String strValidRealPattern = "^([-]|[.]|[-.]|[0-9])[0-9]*[.]*[0-9]+$";
            String strValidIntegerPattern = "^([-]|[0-9])[0-9]*$";
            Regex objNumberPattern = new Regex("(" + strValidRealPattern + ")|(" + strValidIntegerPattern + ")");

            return !objNotNumberPattern.IsMatch(strNumber) &&
            !objTwoDotPattern.IsMatch(strNumber) &&
            !objTwoMinusPattern.IsMatch(strNumber) &&
            objNumberPattern.IsMatch(strNumber);
        }

        //格式化数字，当小数点后面的值为0时，不显示
        public static string ToNumber(this object obj)
        {
            if (obj == null || obj == DBNull.Value) return "0";
            string[] strArr = obj.ToString().Split('.');
            string str = strArr[0];
            if (strArr.Length == 2)
            {
                string tmp = strArr[1].Replace("0", "");
                if (tmp != "")
                {
                    str += "." + strArr[1].TrimEnd('0');
                }
            }
            return str;
        }
        public static string ToNullString(this object o)
        {
            return (o == null || o == DBNull.Value) ? "" : o.ToString();
        }
        

        public static DataTable ToDataTable(this DataTable dt, string strWhere)
        {
            if (dt.Rows.Count <= 0) return dt;        //当数据为空时返回
            DataTable dtNew = dt.Clone();         //复制数据源的表结构
            DataRow[] drs = dt.Select(strWhere);  //strWhere条件筛选出需要的数据！
            if (drs.Length > 0)                   //判断是否存在符合的数据、为下面copy，不然报错
                dtNew = drs.CopyToDataTable();    //copy到新的datatable中！
            return dtNew;
        }
 
       
    }


public class DecryUtil
{
    private string _IV = "CLASSWU1";
    /// <summary>
    /// DES加密偏移量，必须是>=8位长的字符串
    /// </summary>
    private string IV
    {
        get { return _IV; }
        set { _IV = value; }
    }
    private string _Key = "YOUNGER1";
    /// <summary>
    /// DES加密的私钥，必须是位长的字符串
    /// </summary>
    public string Key
    {
        get { return _Key; }
        set { _Key = value; }
    }
    /// <summary>
    /// 空的构造函数
    /// </summary>
    public DecryUtil()
    {

    }
    /// <summary>
    /// 带参数的构造函数
    /// </summary>
    /// <param name="IV">DES解密偏移量，必须是>=8位长的字符串</param>
    /// <param name="Key">DES解密的私钥，必须是位长的字符串</param>
    public DecryUtil(string IV, string Key)
    {
        this.IV = IV;
        this.Key = Key;
    }
    /// <summary>
    /// 对DES加密后的字符串进行解密
    /// </summary>
    /// <param name="encryptedString">待解密字符串</param>
    /// <param name="sourceString">解密后的字符串</param>
    /// <returns>返回成功或着失败 失败后会有失败原因</returns>
    private bool Decrypt(string encryptedString, ref string sourceString)
    {
        sourceString = string.Empty;

        byte[] btKey = Encoding.Default.GetBytes(Key);
        byte[] btIV = Encoding.Default.GetBytes(IV);

        DESCryptoServiceProvider des = new DESCryptoServiceProvider();
        using (MemoryStream ms = new MemoryStream())
        {
            byte[] inData = null;
            try
            {
                inData = Convert.FromBase64String(encryptedString);
            }
            catch (Exception ex)
            {
                sourceString = ex.Message;
                return false;
            }

            try
            {
                using (CryptoStream cs = new CryptoStream(ms, des.CreateDecryptor(btKey, btIV), CryptoStreamMode.Write))
                {
                    cs.Write(inData, 0, inData.Length);
                    cs.FlushFinalBlock();
                }
                sourceString = Encoding.Default.GetString(ms.ToArray());
            }
            catch (Exception ex)
            {
                sourceString = ex.Message;
                return false;
            }
        }

        return true;
    }
    /// <summary>
    /// 对文件内容进行DES解密
    /// </summary>
    /// <param name="sourceFile">待解密文件绝对路径</param>
    /// <param name="error">错误信息</param>
    /// <returns>返回成功或者失败</returns>
    private bool DecryptFile(string sourceFile, ref string error)
    {
        error = string.Empty;

        if (!File.Exists(sourceFile))
        {
            error = "指定的文件路径不存在！";
            return false;
        }

        //string[] strArray = sourceFile.Split('.');
        //string destFile = string.Empty;
        //for (int i = 0; i < strArray.Length - 1; i++)
        //{
        //    destFile += strArray[i];
        //}
        //destFile += DateTime.Now.ToString() + strArray[strArray.Length - 1];

        byte[] btKey = Encoding.Default.GetBytes(Key);
        byte[] btIV = Encoding.Default.GetBytes(IV);

        DESCryptoServiceProvider des = new DESCryptoServiceProvider();
        byte[] btFile = File.ReadAllBytes(sourceFile);
        using (FileStream fs = new FileStream(sourceFile, FileMode.Create, FileAccess.Write))
        {
            try
            {
                using (CryptoStream cs = new CryptoStream(fs, des.CreateDecryptor(btKey, btIV), CryptoStreamMode.Write))
                {
                    cs.Write(btFile, 0, btFile.Length);
                    cs.FlushFinalBlock();
                }
            }
            catch (Exception ex)
            {
                error = ex.Message;
                fs.Close();
                return false;
            }
        }
        return true;
    }

    //解密
    public string Dec(string strMess)
    {
        string decMess = string.Empty;
        Decrypt(strMess, ref decMess);
        return decMess;
    }


}

/// <summary>
/// 加密工具
/// </summary>
public class EncryUtil
{
    private string _IV = "CLASSWU1";
    /// <summary>
    /// DES加密偏移量，必须是>=8位长的字符串
    /// </summary>
    private string IV
    {
        get { return _IV; }
        set { _IV = value; }
    }
    private string _Key = "YOUNGER1";
    /// <summary>
    /// DES加密的私钥，必须是8位长的字符串
    /// </summary>
    public string Key
    {
        get { return _Key; }
        set { _Key = value; }
    }
    /// <summary>
    /// 构造函数
    /// </summary>
    public  EncryUtil()
    {

    }
    /// <summary>
    /// 带参数构造函数
    /// </summary>
    /// <param name="IV">DES加密偏移量，必须是>=8位长的字符串</param>
    /// <param name="Key">DES加密的私钥，必须是8位长的字符串</param>
    private  EncryUtil(string IV, string Key)
    {
        this.IV = IV;
        this.Key = Key;
    }
    /// <summary>
    /// 对字符串进行DES加密
    /// </summary>
    /// <param name="sourceString">待加密字符串</param>
    /// <param name="encString">加密后字符串</param>
    /// <returns>返回加密成功或者失败</returns>
    private bool Encrypt(string sourceString, ref string encString)
    {
        encString = string.Empty;

        byte[] btKey = Encoding.Default.GetBytes(Key);
        byte[] btIV = Encoding.Default.GetBytes(IV);

        DESCryptoServiceProvider des = new DESCryptoServiceProvider();

        using (MemoryStream ms = new MemoryStream())
        {
            byte[] inData = Encoding.Default.GetBytes(sourceString);
            try
            {
                using (CryptoStream cs = new CryptoStream(ms, des.CreateEncryptor(btKey, btIV), CryptoStreamMode.Write))
                {
                    cs.Write(inData, 0, inData.Length);
                    cs.FlushFinalBlock();
                }
                encString = Convert.ToBase64String(ms.ToArray());
            }
            catch (Exception ex)
            {
                encString = ex.Message;
                return false;
            }
        }
        return true;
    }
    /// <summary>
    /// 对文件内容进行DES加密
    /// </summary>
    /// <param name="sourceFile">待加密文件绝对路径</param>
    /// <param name="error">错误信息</param>
    /// <returns>返回加密成功或失败  加密文件会写在原文件目录下</returns>
    private bool EncryptFile(string sourceFile, ref string error)
    {
        error = string.Empty;

        if (!File.Exists(sourceFile))
        {
            error = "指定的文件路径不存在！";
            return false;
        }

        //string[] strArray = sourceFile.Split('.');
        //string destFile = string.Empty;
        //for (int i = 0; i < strArray.Length-1; i++)
        //{
        //    destFile += "." + strArray[i];
        //}
        //destFile += DateTime.Now.ToFileTime() + "." + strArray[strArray.Length - 1];

        byte[] btKey = Encoding.Default.GetBytes(Key);
        byte[] btIV = Encoding.Default.GetBytes(IV);

        DESCryptoServiceProvider des = new DESCryptoServiceProvider();

        byte[] btFile = File.ReadAllBytes(sourceFile);

        using (FileStream fs = new FileStream(sourceFile, FileMode.Create, FileAccess.Write))
        {
            try
            {
                using (CryptoStream cs = new CryptoStream(fs, des.CreateEncryptor(btKey, btIV), CryptoStreamMode.Write))
                {
                    cs.Write(btFile, 0, btFile.Length);
                    cs.FlushFinalBlock();
                }
            }
            catch (Exception ex)
            {
                error = ex.Message;
                fs.Close();
                return false;
            }
            return true;
        }
    }

    //加密
    public string Enc(string strMess)
    {
        string encMess = string.Empty;
        Encrypt(strMess, ref encMess);
        return encMess;
    }
}