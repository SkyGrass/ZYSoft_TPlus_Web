<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.Data;
using Newtonsoft.Json;
using System.Collections.Generic;
using Microsoft.CodeDom.Providers.DotNetCompilerPlatform;
using System.CodeDom;
using System.CodeDom.Compiler;
using System.IO;
using System.Net;
using System.Web.Services.Description;
public class Handler : IHttpHandler
{
    public class Result
    {
        public string status { get; set; }
        public object data { get; set; }
        public string msg { get; set; }
    }

    public class PostForm
    {
        public Form form { get; set; }
        public List<Body> body { get; set; }
    }

    public class Form
    {
        public int FBillID { get; set; }
        public string FBillNo { get; set; }
        public DateTime FDate { get; set; }
        public string FCustCode { get; set; }
        public string FReciveTypeCode { get; set; }
        public string FWarehouseCode { get; set; }
        public int FWarehouseID { get; set; }
        public string FWarehouseName { get; set; }
        public decimal FTaxRate { get; set; }
        public string FMaker { get; set; }
        public string FMemo { get; set; }
        public decimal FAllowances { get; set; }
    }
    public class Body
    {
        public int FEntryID { get; set; }
        public int FMainItemID { get; set; }
        public string FWarehouseCode { get; set; }
        public string FInvCode { get; set; }
        public string FInvName { get; set; }
        public string FInvStd { get; set; }
        public string FUnitName { get; set; }
        public decimal FPrice { get; set; }
        public decimal FQty { get; set; }
        public decimal FPlanQty { get; set; }
        public decimal FSum { get; set; }
        public decimal FTaxRate { get; set; }
        public decimal FTaxPrice { get; set; }
        public decimal FTaxSum { get; set; }
        public string FBatchNo { get; set; }
        public string FDetailMemo { get; set; }
        public string FPriuserdefnvc1 { get; set; }
        public string FPriuserdefnvc2 { get; set; }
        public string FPriuserdefnvc3 { get; set; }
        public string FPriuserdefnvc4 { get; set; }
    }

    public class TResult
    {
        public string Result { get; set; }
        public string Message { get; set; }
        public object Data { get; set; }
    }


    public void ProcessRequest(HttpContext context)
    {
        ZYSoft.DB.Common.Configuration.ConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ToString(); ;// string.Format(@"Data Source=.\SQL2009;Initial Catalog=UFTData697174_000001;User ID=sa;password=123");
        context.Response.ContentType = "text/plain";
        if (context.Request.Form["SelectApi"] != null)
        {
            string result = "";
            switch (context.Request.Form["SelectApi"].ToLower())
            {
                case "getconnect":
                    result = ZYSoft.DB.Common.Configuration.ConnectionString;
                    break;
                case "ws":
                    result = JsonConvert.SerializeObject(new
                    {
                        wsurl = System.Configuration.ConfigurationManager.AppSettings["WsUrl"],
                        method = System.Configuration.ConfigurationManager.AppSettings["Method"]
                    });
                    break;
                case "getwarehoselist":
                    result = GetWareHoseList();
                    break;
                case "getstockinfo":
                    string wareId = context.Request.Form["wareId"] ?? "-1";
                    result = GetStockInfo(wareId);
                    break;
                case "getclient":
                    result = GetClient();
                    break;
                case "getbillno":
                    result = GetBillNo();
                    break;
                case "getbillid":
                    result = GetBillId();
                    break;
                case "savebill":
                    string formData = context.Request.Form["formData"] ?? "";
                    result = SaveBill(JsonConvert.DeserializeObject<PostForm>(formData));
                    break;
                case "deletebill":
                    string billid = context.Request.Form["billid"] ?? "-1";
                    result = DelBill(billid);
                    break;
                case "buildbill":
                    billid = context.Request.Form["billid"] ?? "-1";
                    result = BuildTBill(billid);
                    break;
                default: break;
            }
            context.Response.Write(result);
        }
    }

    /*查询仓库数据*/
    public string GetWareHoseList()
    {
        try
        {
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"select id,code ,name from AA_Warehouse"));
            return JsonConvert.SerializeObject(new Result
            {
                status = dt != null && dt.Rows.Count > 0 ? "success" : "error",
                data = dt,
                msg = ""
            });
        }
        catch (Exception ex)
        {
            return JsonConvert.SerializeObject(new Result
            {
                status = "error",
                data = new List<string>(),
                msg = ex.Message
            });
        }
    }

    /*查询库存数据*/
    public string GetStockInfo(string wareId)
    {
        var list = new List<Result>();
        try
        {
            //DBSession db = DBSessionFactory.getDBSession();
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable
            (string.Format(@"SELECT t1.idwarehouse, t1.idinventory, t2.code invcode,t2.name invname,
                        t2.specification invstd,t2.idunit,t21.code unitcode,
                        t21.name unitname,
                        t1.basequantity iquantity, t1.batch,t2.priuserdefnvc1 
                        ,t2.priuserdefnvc2,t2.priuserdefnvc3,t2.priuserdefnvc4,
                        ISNULL((SELECT TOP 1 inPrice FROM ST_TransVoucher u1 JOIN dbo.ST_TransVoucher_b u2 ON u1.id=u2.idTransVoucherDTO
                        WHERE u1.idinwarehouse=t1.idwarehouse AND u2.idinventory =t1.idinventory ORDER BY t2.id DESC ),0) iprice
                        from st_currentstock t1
                        left join dbo.aa_inventory t2 on t1.idinventory=t2.id
                        left join dbo.aa_unit t21 on t2.idunit=t21.id
                        where t1.basequantity>0  and t1.idwarehouse={0}", wareId));
            return JsonConvert.SerializeObject(new
            {
                status = dt.Rows.Count > 0 ? "success" : "error",
                data = dt,
                msg = ""
            });
        }
        catch (Exception ex)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = new List<string>(),
                msg = ex.Message
            });
        }
    }

    /*查询客户*/
    public string GetClient()
    {
        try
        {
            //DBSession db = DBSessionFactory.getDBSession();
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"select code   ,name  ,shorthand  from AA_Partner where partnerType in(211, 228)  order by code"));
            return JsonConvert.SerializeObject(new Result
            {
                status = dt != null && dt.Rows.Count > 0 ? "success" : "error",
                data = dt,
                msg = ""
            });
        }
        catch (Exception e)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = "",
                msg = e.Message
            });
        }
    }

    /*获取单号*/
    public string GetBillNo()
    {
        //DBSession db = DBSessionFactory.getDBSession();
        //DataTable dt = db.findDataTable("select id as value ,code ,name as label from AA_Warehouse");
        //return JsonConvert.SerializeObject(dt);
        try
        {
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"exec zysoft_buildbillno"));
            return JsonConvert.SerializeObject(new
            {
                status = "success",
                data = JsonConvert.SerializeObject(new
                {
                    fbillno = dt.Rows[0]["FBillNo"].ToString()
                }),
                msg = ""
            });
        }
        catch (Exception)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = "",
                msg = "生成单据号发生异常!"
            });
        }
    }
    /*获取单据ID*/
    public string GetBillId()
    {
        //DBSession db = DBSessionFactory.getDBSession();
        //DataTable dt = db.findDataTable("select id as value ,code ,name as label from AA_Warehouse");
        //return JsonConvert.SerializeObject(dt);
        try
        {
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"exec dbo.zysoft_l_p_getmaxid 'zysoft_record'"));
            return JsonConvert.SerializeObject(new
            {
                status = "success",
                data = JsonConvert.SerializeObject(new
                {
                    fbillid = dt.Rows[0]["FMaxId"].ToString()
                }),
                msg = ""
            });
        }
        catch (Exception)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = "",
                msg = "生成单据ID发生异常!"
            });
        }
    }

    /*删除单据ID*/
    public string DelBill(string billid)
    {
        //DBSession db = DBSessionFactory.getDBSession();
        //DataTable dt = db.findDataTable("select id as value ,code ,name as label from AA_Warehouse");
        //return JsonConvert.SerializeObject(dt);
        try
        {
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"select * from zysoft_record where fbillid  ='{0}'", billid));
            if (dt != null && dt.Rows.Count > 0)
            {
                if (ZYSoft.DB.BLL.Common.ExecuteNonQuery(string.Format(@"delete from zysoft_record where fbillid ='{0}'", billid)) > -1)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        status = "success",
                        data = "",
                        msg = "删除单据成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        status = "error",
                        data = "",
                        msg = "删除单据失败!"
                    });
                }
            }
            else
            {
                return JsonConvert.SerializeObject(new
                {
                    status = "error",
                    data = "",
                    msg = "没有发现单据信息!"
                });
            }
        }
        catch (Exception)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = "",
                msg = "删除单据异常!"
            });
        }
    }

    /*保存单据*/
    public string SaveBill(PostForm formData)
    {
        //DBSession db = DBSessionFactory.getDBSession();
        //DataTable dt = db.findDataTable("select id as value ,code ,name as label from AA_Warehouse");
        //return JsonConvert.SerializeObject(dt);
        try
        {
            Form form = formData.form;
            List<Body> bodys = formData.body;

            List<string> ls_sql = new List<string>();

            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"exec zysoft_buildbillno 1"));

            var billNo = dt.Rows[0]["FBillNo"].ToString();
            form.FBillNo = billNo;
            ls_sql.Add(string.Format(@"INSERT INTO [ZYSoft_Record] ([FBillID] ,[FBillNo] ,[FDate] ,[FCustCode] ,[FReciveTypeCode] ,[FWarehouseCode] ,
                                        [FWarehouseID] ,[FWarehouseName] ,[FTaxRate] ,[FMaker] ,[FMemo] ,[FAllowances]) VALUES ({0} ,'{1}' ,'{2}' ,'{3}' ,'{4}' ,'{5}' ,{6} ,'{7}' ,{8} ,'{9}' ,'{10}' ,'{11}')",
                                        form.FBillID, form.FBillNo, form.FDate, form.FCustCode, form.FReciveTypeCode, form.FWarehouseCode, form.FWarehouseID,
                                       form.FWarehouseName, form.FTaxRate, form.FMaker, form.FMemo, form.FAllowances));

            foreach (Body body in bodys)
            {
                ls_sql.Add(string.Format(@"INSERT INTO [ZYSoft_RecordEntry] ([FMainItemID] ,[FWarehouseCode] ,[FInvCode] ,[FInvName] ,[FInvStd] ,
                                        [FUnitName] ,[FPrice] ,[FQty] ,[FSum] ,[FTaxRate] ,[FTaxPrice] ,[FTaxSum] ,[FBatchNo] ,[FDetailMemo],[FPlanQty],
                                        [FPriuserdefnvc1],[FPriuserdefnvc2],[FPriuserdefnvc3],[FPriuserdefnvc4]) 
                                        VALUES ({0},'{1}','{2}','{3}','{4}','{5}',{6},{7},{8},{9},{10},{11},'{12}','{13}',{14},'{15}','{16}','{17}','{18}')",
                                         form.FBillID, body.FWarehouseCode, body.FInvCode, body.FInvName, body.FInvStd, body.FUnitName, body.FPrice,
                                         body.FQty, body.FSum, body.FTaxRate, body.FTaxPrice, body.FTaxSum,
                                         body.FBatchNo, body.FDetailMemo, body.FPlanQty, body.FPriuserdefnvc1, body.FPriuserdefnvc2, body.FPriuserdefnvc3, body.FPriuserdefnvc4));
            }

            if (ls_sql.Count > 0)
            {
                return JsonConvert.SerializeObject(new
                {
                    status = ZYSoft.DB.BLL.Common.ExecuteSQLTran(ls_sql) > -1 ? "success" : "error",
                    data = JsonConvert.SerializeObject(new
                    {
                        fbillid = form.FBillID
                    }),
                    msg = ""
                });
            }
            else
            {
                return JsonConvert.SerializeObject(new
                {
                    status = "error",
                    data = "",
                    msg = "保存单据失败!"
                });
            }
        }
        catch (Exception)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = "",
                msg = "保存单据发生异常!"
            });
        }
    }

    public string BuildTBill(string billId)
    {
        //DBSession db = DBSessionFactory.getDBSession();
        //DataTable dt = db.findDataTable("select id as value ,code ,name as label from AA_Warehouse");
        //return JsonConvert.SerializeObject(dt);

        TResult result = new TResult();
        try
        {
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"exec zysoft_buildtbill '{0}'", billId));

            if (dt != null && dt.Rows.Count > 0)
            {
                var WsUrl = System.Configuration.ConfigurationManager.AppSettings["WsUrl"];
                var Method = System.Configuration.ConfigurationManager.AppSettings["Method"];
                var args = new object[] { JsonConvert.SerializeObject(dt) };
                object json = InvokeWebService(WsUrl, Method, args);
                result = JsonConvert.DeserializeObject<TResult>(json.ToString());
                if (result.Result == "Y")
                {
                    ZYSoft.DB.BLL.Common.ExecuteNonQuery(string.Format(@"update zysoft_record set fisbuild = 1,fbuilddate = getdate() where fbillid  = '{0}'", billId));
                }
                return JsonConvert.SerializeObject(new
                {
                    status = result.Result == "Y" ? "success" : "error",
                    data = "",
                    msg = result.Result == "Y" ? "生成单据成功!" : result.Message
                });
            }
            else
            {
                return JsonConvert.SerializeObject(new
                {
                    status = "error",
                    data = "",
                    msg = "未查询到单据信息!"
                });
            }
        }
        catch (Exception ex)
        {
            return JsonConvert.SerializeObject(new
            {
                status = "error",
                data = "",
                msg = ex.Message
            });
        }
    }

    /// <summary>
    /// 实例化WebServices
    /// </summary>
    /// <param name="url">WebServices地址</param>
    /// <param name="methodname">调用的方法</param>
    /// <param name="args">把webservices里需要的参数按顺序放到这个object[]里</param>
    public static object InvokeWebService(string url, string methodname, object[] args)
    {
        //这里的namespace是需引用的webservices的命名空间，我没有改过，也可以使用。也可以加一个参数从外面传进来。
        string @namespace = "client";

        try
        {
            //获取WSDL
            WebClient wc = new WebClient();
            Stream stream = wc.OpenRead(url + "?WSDL");
            ServiceDescription sd = ServiceDescription.Read(stream);
            string classname = sd.Services[0].Name;
            ServiceDescriptionImporter sdi = new ServiceDescriptionImporter();
            sdi.AddServiceDescription(sd, "", "");
            CodeNamespace cn = new CodeNamespace(@namespace);

            //生成客户端代理类代码
            CodeCompileUnit ccu = new CodeCompileUnit();
            ccu.Namespaces.Add(cn);
            sdi.Import(cn, ccu);
            Microsoft.CodeDom.Providers.DotNetCompilerPlatform.CSharpCodeProvider csc = new CSharpCodeProvider();
            //ICodeCompiler icc = csc.CreateCompiler();

            //设定编译参数
            CompilerParameters cplist = new CompilerParameters();
            cplist.GenerateExecutable = false;//动态编译后的程序集不生成可执行文件
            cplist.GenerateInMemory = true;//动态编译后的程序集只存在于内存中，不在硬盘的文件上
            cplist.ReferencedAssemblies.Add("System.dll");
            cplist.ReferencedAssemblies.Add("System.XML.dll");
            cplist.ReferencedAssemblies.Add("System.Web.Services.dll");
            cplist.ReferencedAssemblies.Add("System.Data.dll");

            //编译代理类
            CompilerResults cr = csc.CompileAssemblyFromDom(cplist, ccu);
            if (true == cr.Errors.HasErrors)
            {
                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                foreach (System.CodeDom.Compiler.CompilerError ce in cr.Errors)
                {
                    sb.Append(ce.ToString());
                    sb.Append(System.Environment.NewLine);
                }

                throw new Exception(sb.ToString());
            }

            //生成代理实例，并调用方法
            System.Reflection.Assembly assembly = cr.CompiledAssembly;
            Type t = assembly.GetType(@namespace + "." + classname, true, true);
            object obj = Activator.CreateInstance(t);
            System.Reflection.MethodInfo mi = t.GetMethod(methodname);

            //注：method.Invoke(o, null)返回的是一个Object,如果你服务端返回的是DataSet,这里也是用(DataSet)method.Invoke(o, null)转一下就行了,method.Invoke(0,null)这里的null可以传调用方法需要的参数,string[]形式的
            return mi.Invoke(obj, args);
        }
        catch (Exception e)
        {
            return e.Message;
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