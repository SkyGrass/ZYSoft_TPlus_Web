using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ufida.T.EAP.AppBase;
using Ufida.T.BAP.Web.Base;
using System.Web.UI.WebControls;
using Chanjet.ZYSoft.SellOut.Interface;
using Ufida.T.EAP.Aop;
using Ufida.T.EAP.DataStruct.Context;
using System.Web;
using Ufida.T.EAP.Dal;

namespace Chanjet.ZYSoft.SellOut.UIP
{
    public class HelloWorldPage : IAppHandler
    {
        GenericController controller;
        IHelloWorld helloWorldService;
        Label lblHelloWorld;
        public void AppEventHandler(object sender, AppEventArgs e)
        {
            controller = sender as GenericController;

            lblHelloWorld = controller.GetViewControl("lblHelloWorld") as Label;

            helloWorldService = ServiceFactory.getService<IHelloWorld>();

            Page_Load(sender, e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            UserInfo userInfo = HttpContext.Current.Session["UserInfo"] as UserInfo;
            lblHelloWorld.Text += userInfo.PersonName ;
            AjaxPro.Utility.RegisterTypeForAjax(typeof(Actions), lblHelloWorld.Page);
        }
    }
}
