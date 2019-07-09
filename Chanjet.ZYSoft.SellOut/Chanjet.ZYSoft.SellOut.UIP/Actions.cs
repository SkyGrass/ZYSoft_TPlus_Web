using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Chanjet.ZYSoft.SellOut.Interface;
using Ufida.T.EAP.Aop;

namespace Chanjet.ZYSoft.SellOut.UIP
{
    public class Actions
    {
        [AjaxPro.AjaxMethod()]
        public string GetWareHoseList()
        {
            string value = ServiceFactory.getService<IHelloWorld>().GetWareHoseList();
            return value;
        }
        
    }
}
