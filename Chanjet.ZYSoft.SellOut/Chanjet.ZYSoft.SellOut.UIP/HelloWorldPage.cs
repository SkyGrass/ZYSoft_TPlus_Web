using System;
using Ufida.T.EAP.AppBase;
using Ufida.T.BAP.Web.Base;
using System.Web.UI.WebControls;
using Chanjet.ZYSoft.SellOut.Interface;
using Ufida.T.EAP.Aop;
using Ufida.T.EAP.DataStruct.Context;
using System.Web;

namespace Chanjet.ZYSoft.SellOut.UIP
{
    public class HelloWorldPage : IAppHandler
    {
        GenericController controller;
        IHelloWorld helloWorldService;
        Label lblHelloWorld;
        Label lbConnect;
        public void AppEventHandler(object sender, AppEventArgs e)
        {
            controller = sender as GenericController;

            lblHelloWorld = controller.GetViewControl("lblHelloWorld") as Label;
            lbConnect = controller.GetViewControl("lbConnect") as Label;
            helloWorldService = ServiceFactory.getService<IHelloWorld>();

            Page_Load(sender, e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            var re = "456";
            try
            {
                re = helloWorldService.GetConnect();
            }
            catch (Exception ex)
            {
                re = ex.Message;
            }
            UserInfo userInfo = HttpContext.Current.Session["UserInfo"] as UserInfo;
            lblHelloWorld.Text += userInfo.PersonName;
            lbConnect.Text += re;
            AjaxPro.Utility.RegisterTypeForAjax(typeof(Actions), lblHelloWorld.Page);
        }
    }
}
