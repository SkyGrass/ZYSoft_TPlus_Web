<%@ Page Language="C#" AutoEventWireup="true" %>

<%-- CodeFile="MainPage.aspx.cs" Inherits="App_ZYSoft_ZYSoft_MainPage_MainPage" --%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>销货单</title>
    <!-- 引入样式 -->
    <link rel="stylesheet" href="./css/element-ui-index.css" />
    <link rel="stylesheet" href="./css/index.css" />
    <!-- 引入组件库 -->
    <link rel="stylesheet" href="./assets/icon/iconfont.css" />
    <link href="./css/tabulator.min.css" rel="stylesheet" />
    <style>
        .el-dialog__body {
            padding: 10px 10px;
        }

        .tabulator .tabulator-header .tabulator-col {
            text-align: center;
        }

        .tabulator-tableHolder {
            background-color: #fff;
        }

        .underline {
            width: 160px !important;
        }

        .tabulator-row {
            border-bottom: 1px solid #bbb;
        }
       .el-table__body tr:hover>td{
    background-color: rgb(254,247,210)!important;
  }
 
  .el-table__body tr.current-row>td{
    background-color: rgb(254,247,210)!important;
        }
    </style>
</head>

<body>
    <asp:Label ID="lbConnect" runat="server" Visible="false"></asp:Label>
    <asp:Label ID="lblHelloWorld" runat="server" Visible="false"></asp:Label>
    <div id="app">
        <el-container>
            <el-header class="header">
                <div style="display: inline-flex">
                    <el-button class="action" type="text" v-for="(action, index) in actions" :key="action.id" @click="action.action" :disabled="canUse(action)" v-loading.fullscreen.lock="fullscreenLoading">
                        {{ action.label }}</el-button>
                </div>
                <div style="display: none">
                    <el-button class="shortaction" type="text" :icon="action.icon"
                        v-for="(action, index) in shortactions" :key="action.id">
                    </el-button>
                </div>
            </el-header>
            <el-main class="manin">
                <el-container class="contain">
                    <el-header>
                        <el-form label-position="right" :model="form" inline>
                           <el-form-item label="客户">
                                <el-input class="underline" v-model="form.FCusName" :disabled="tableRowGTZero()"  placeholder="客户名称、客户编码"  @focus ="clientVisible = true "></el-input>
                            </el-form-item>
                            <el-form-item label="仓库">
                                <el-input class="underline" v-model="form.FWarehouseName" placeholder="仓库名称、仓库编码"   readOnly></el-input>
                            </el-form-item>
                            <el-form-item label="单据日期">
                                <el-date-picker v-model="form.FDate" placeholder=""></el-date-picker>
                            </el-form-item>
                            <el-form-item label="单据编号">
                                <el-input class="underline" v-model="form.FBillNo" readOnly></el-input>
                            </el-form-item> <br />
                            <el-form-item label="税率">
                                <el-input class="underline" v-model="form.FTaxRate" type="number" min="0" max="100">
                                </el-input>
                            </el-form-item>
                            <el-form-item label="抹零">
                                <el-input class="underline" v-model="form.FAllowances" type="number"  step="0.01" @change="inputance">
                                </el-input>
                            </el-form-item>
                        </el-form>
                    </el-header>
                    <el-main style="'height':maxHeight">
                        <div id="grid" style="margin-top:50px"></div>
                    </el-main>
                </el-container>
            </el-main>
            <el-footer>
                <el-form label-position="right" label-width="80px" :model="form">
                    <el-row>
                        <el-col :span="12">
                            <el-form-item label="备注">
                                <el-input class="underline" v-model="form.FMemo" placeholder="请在此输入备注"></el-input>
                            </el-form-item>
                        </el-col>
                         <el-col :span="4">
                            <el-form-item label="制单人">
                                <el-input class="underline" v-model="form.FMaker" readOnly></el-input>
                            </el-form-item>
                        </el-col>
                    </el-row>
                </el-form>
            </el-footer>
           </el-container>
       <el-dialog :title="'库存查询：'+form.FWarehouseName" :visible.sync="stockVisible"  :width="stockWidth">
              <el-input placeholder="存货名称、存货档案、存货规格型号" focus v-model="queryStockform.keyword" @change="remoteQueryStock">
              </el-input>  
           <el-table
                ref="multipleTable"
                :data="stockInfo"
                tooltip-effect="dark"
                :height="maxHeight"
                style="width: 100%"
                border
                stripe
                @selection-change="handleSelectionChange">
                <el-table-column
                  type="selection"
                  width="55">
                </el-table-column>
                <el-table-column
                  prop="invcode"
                  label="存货编码"
                  width="120">
                </el-table-column>
                <el-table-column
                  prop="invname"
                  label="存货名称"
                  width="200"
                  show-overflow-tooltip>
                </el-table-column>
                <el-table-column
                  prop="invstd"
                  label="规格型号"
                  width="200"
                  show-overflow-tooltip>
                </el-table-column>
               <el-table-column
                  prop="unitname"
                  label="单位"
                  width="80">
                </el-table-column>
               <el-table-column
                  prop="priuserdefnvc1"
                  label="颜色"
                   width="100">
                </el-table-column>
               <el-table-column
                  prop="priuserdefnvc2"
                  label="冠劲"
                   width="100">
                </el-table-column>
               <el-table-column
                  prop="priuserdefnvc3"
                  label="长度"
                   width="100">
                </el-table-column>
               <el-table-column
                  prop="priuserdefnvc4"
                  label="高度"
                   width="100">
                </el-table-column>
               <el-table-column
                  prop="iquantity"
                  label="数量"
                  width="80">
                </el-table-column>
                <el-table-column
                  prop="iprice"
                  label="单价"
                   width="80">
                </el-table-column>
               <el-table-column
                  prop="batch"
                  label="批号"
                   width="100">
                </el-table-column>
              </el-table>
            <div slot="footer" class="dialog-footer">
                <el-button @click="stockVisible = false">取 消</el-button>
                <el-button type="primary" @click="confirm">确定</el-button>
            </div>
        </el-dialog>
             <el-dialog :title="'客户查询(双击确认)：'+form.FWarehouseName" :visible.sync="clientVisible">
              <el-input placeholder="客户名称、客户编码" focus  v-model="queryClientform.keyword" @change="remoteQueryClient">
              </el-input>  
           <el-table
                ref="clientTable"
                :data="clientList"
                tooltip-effect="dark"
                :height="maxHeight"
                style="width: 100%"
                 highlight-current-row
                border
               @row-dblclick ="confirmClient"
                @row-click="handleClientSelectionChange">
                <el-table-column
                  prop="code"
                  label="客户编码">
                </el-table-column>
                <el-table-column
                  prop="name"
                  label="客户名称"
                  show-overflow-tooltip>
                </el-table-column>
              </el-table>
            <div slot="footer" class="dialog-footer">
                <el-button @click="clientVisible = false">取 消</el-button>
                <el-button type="primary" @click="confirmClient">确定</el-button>
            </div>
        </el-dialog>
    </div>
    <!-- import Vue before Element -->
    <script src="./js/vue.js"></script>
    <script src="./js/element-ui-index.js"></script>
    <script src="./js/tabulator.js"></script>
    <script src="./js/jquery.min.js"></script>
    <script src="./js/calc.js"></script>
    <script src="./js/dayjs.min.js"></script>
    <script>
        var loginName = "<%=lblHelloWorld.Text%>"
        var connect = "<%=lbConnect.Text%>"
    </script>

    <script src="js/MyHelloWorld.js"></script>
</body>

</html>
