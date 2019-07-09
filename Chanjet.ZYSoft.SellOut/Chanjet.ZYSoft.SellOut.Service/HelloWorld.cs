using System;
using System.Collections.Generic;
using System.Data;
using Chanjet.ZYSoft.SellOut.Interface;
using Ufida.T.EAP.Dal;
using Newtonsoft.Json;

namespace Chanjet.ZYSoft.SellOut.Service
{
    public class HelloWorld : IHelloWorld
    {
        public string GetConnect()
        {
            return "123";
        }

        public string GetWareHoseList()
        {
            try
            {
                var list = new List<dynamic>();
                DBSession db = DBSessionFactory.getDBSession();
                DataTable dt = db.findDataTable(string.Format(@"select id as value ,code ,name as label from AA_Warehouse"));
                foreach (DataRow dr in dt.Rows)
                {
                    list.Add(new
                    {
                        value = dr["value"].ToString(),
                        code = dr["code"].ToString(),
                        label = dr["label"].ToString()
                    });
                }

                return JsonConvert.SerializeObject(new
                {
                    status = list.Count > 0 ? "success" : "error",
                    data = list,
                    msg = db.Conn.ConnectionString
                });
            }
            catch (Exception e)
            {
                return JsonConvert.SerializeObject(new
                {
                    status = "error",
                    data = new List<string>(),
                    msg = e.Message
                });
            }
        }
    }
}
