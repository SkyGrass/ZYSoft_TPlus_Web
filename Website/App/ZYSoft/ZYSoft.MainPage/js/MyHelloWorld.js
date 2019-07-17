var vm = new Vue({
    el: "#app",
    data: function () {
        return {
            stockVisible: false,
            clientVisible: false,
            loading: false,
            fullscreenLoading: false,
            actions: [ /*新增  | 勾选库存  |  保存  删除 生单|   清空*/
                    { id: `add`, label: `新增`, action: this.addBill, status: 'ok' },
                    { id: `stock`, label: `勾选库存`, action: this.queryStock, status: 'ok' },
                    //{ id: `edit`, label: `修改`, action: this.editBill , status: 'ok'},
                    { id: `save`, label: `保存`, action: this.saveBill, status: 'ok' },
                    { id: `del`, label: `删除`, action: this.deleteBill, status: 'ok' },
                    { id: `delrow`, label: `删行`, action: this.deleteRow, status: 'ok' },
                    //{ id: `deselect`, label: `取消选中`, action: this.deSelectRow, status: 'ok' },
                    { id: `audit`, label: `生单`, action: this.buildBill, status: 'ok' },
                    { id: `clear`, label: `清空`, action: this.clearTable, status: 'ok' }
            ],
            shortactions: [
                { id: `ahead`, icon: `el-icon-tplus-ahead`, action: function () { } },
                { id: `pre`, icon: `el-icon-tplus-prev`, action: function () { } },
                { id: `next`, icon: `el-icon-tplus-next`, action: function () { } },
                { id: `last`, icon: `el-icon-tplus-last`, action: function () { } }
            ],
            form: {
                FBillID: 0,/*订单ID  默认传0*/
                FBillNo: "",
                FDate: dayjs().format("YYYY-MM-DD"),
                FCustCode: "", /*客户编码*/
                FReciveTypeCode: "05",/*收款方式 编码，（先默认一下编码 ） 05*/
                FMemo: ``,/*订单备注*/
                FWarehouseCode: "",/*仓库*/
                FWarehouseID: "-1",
                FWarehouseName: "",
                FTaxRate: 13,
                FMaker: "",
                FIsBuild: false,
                FAllowances: "0.000"
            },
            queryStockform: {
                keyword: ""
            },
            queryClientform: {
                keyword: ""
            },
            wareHoseList: [],
            wareHoseList_bark: [],
            clientList: [],
            clientList_bark: [],
            stockInfo: [],
            stockInfo_bark: [],
            billstatus: "add",
            maxHeight: 0,
            grid: {},
            tableData: [],
            multipleSelection: [],
            clientSelection: {},
            stockWidth: "50%",
            maxValue: 10
        };
    },
    methods: {
        handleSelectionChange(val) {
            this.multipleSelection = val;
        },
        handleClientSelectionChange(value) {
            this.clientSelection = value
        },
        confirm() {
            var that = this;
            if (this.multipleSelection.length > 0) {
                var currentRowCount = this.tableData.length + 1;
                var temp = $.extend(true, [], this.multipleSelection).map(function (selected, index) {
                    var item = {};
                    item.FIndex = currentRowCount + index;
                    item.FEntryID = 0;
                    item.FWarehouseCode = that.form.FWarehouseCode;
                    item.FInvCode = selected.invcode;
                    item.FInvName = selected.invname;
                    item.FInvStd = selected.invstd;
                    item.FUnitName = selected.unitname;
                    item.FStockQty = selected.iquantity;
                    item.FQty = 0;
                    item.FPrice = selected.iprice;
                    item.FSum = accMul(0, selected.iprice);
                    var FTaxPrice = accMul(selected.iprice, accAdd(1, accDiv(that.form.FTaxRate, 100)));
                    item.FTaxPrice = FTaxPrice
                    item.FTaxSum = accMul(0, FTaxPrice);
                    item.FTaxRate = that.form.FTaxRate;
                    item.FBatchNo = selected.batch;
                    item.FDetailMemo = "";
                    item.FPriuserdefnvc1 = selected.priuserdefnvc1;
                    item.FPriuserdefnvc2 = selected.priuserdefnvc2;
                    item.FPriuserdefnvc3 = selected.priuserdefnvc3;
                    item.FPriuserdefnvc4 = selected.priuserdefnvc4;
                    return item;
                });
                var list = [];
                for (var i = 0; i < temp.length; i++) {
                    var t = temp[i];
                    if (this.tableData.findIndex(function (row) {
                        return row.FInvCode == t.FInvCode
                    }) < 0) {
                        list.push(t);
                    }
                }
                this.tableData = this.tableData.concat(list);
                this.stockVisible = false;
                if (list.length != temp.length) {
                    vm.$message({
                        message: '已添加的存货请修改数量!!',
                        type: 'warning'
                    });
                }
            }
        },
        confirmClient() {
            this.form.FCustCode = this.clientSelection.code;
            this.form.FCusName = this.clientSelection.name;

            var record = this.wareHoseList_bark.find(function (warehose) {
                return warehose.code == vm.clientSelection.code
            });

            this.form.FWarehouseCode = "";
            this.form.FWarehouseName = "";
            this.form.FWarehouseID = "-1";
            this.tableData = [];
            if (record) {
                this.form.FWarehouseCode = record.code;
                this.form.FWarehouseName = record.name;
                this.form.FWarehouseID = record.id;

                localStorage.setItem("clientInfo", JSON.stringify(this.clientSelection));
                localStorage.setItem("stockInfo", JSON.stringify(record));
            }
            this.clientVisible = false;
        },
        queryStock() {
            if (this.form.FWarehouseID != "-1") {
                this.stockVisible = true;
                this.querySockById();
            }
        },
        remoteQueryStock(query) {
            if (query !== '') {
                this.loading = true;
                setTimeout(function () {
                    vm.loading = false;
                    vm.stockInfo = $.extend(true, [], vm.stockInfo_bark).filter(function (item) {
                        return (item.invcode.toLowerCase()
                          .indexOf(query.toLowerCase()) > -1 ||
                            item.invname.toLowerCase()
                          .indexOf(query.toLowerCase()) > -1 ||
                            item.invstd.toLowerCase()
                          .indexOf(query.toLowerCase()) > -1
                            );
                    });
                }, 200);
            } else {
                this.stockInfo = this.stockInfo_bark;
            }
        },
        remoteQueryClient(query) {
            if (query !== '') {
                this.loading = true;
                setTimeout(function () {
                    vm.loading = false;
                    vm.clientList = $.extend(true, [], vm.clientList_bark).filter(function (item) {
                        return (item.name.toLowerCase()
                          .indexOf(query.toLowerCase()) > -1 ||
                            item.code.toLowerCase()
                          .indexOf(query.toLowerCase()) > -1 ||
                            item.shorthand.toLowerCase()
                          .indexOf(query.toLowerCase()) > -1
                            );
                    });
                }, 200);
            } else {
                this.clientList = this.clientList_bark;
            }
        },
        querySockById() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "handler.ashx",
                async: true,
                data: { SelectApi: "GetStockInfo", wareId: this.form.FWarehouseID },
                dataType: "json",
                success: function (result) {
                    that.stockInfo = [];
                    that.stockInfo_bark = [];
                    if (result.status == "success") {
                        that.stockInfo = result.data;
                        that.stockInfo_bark = result.data;
                    }
                }
            });
        },
        queryStockSelect() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "handler.ashx",
                async: true,
                data: { SelectApi: "GetWareHoseList" },
                dataType: "json",
                success: function (result) {
                    that.wareHoseList = [];
                    that.wareHoseList_bark = [];
                    if (result.status == "success") {
                        that.wareHoseList = result.data;
                        that.wareHoseList_bark = result.data;
                    } else {

                    }
                }
            });
        },
        queryClientSelect() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "handler.ashx",
                async: true,
                data: { SelectApi: "GetClient" },
                dataType: "json",
                success: function (result) {
                    that.clientList = [];
                    that.clientList_bark = [];
                    if (result.status == "success") {
                        that.clientList = result.data;
                        that.clientList_bark = result.data;


                        //var historyClient = localStorage.getItem("clientInfo") || JSON.stringify({
                        //    code: "",
                        //    name: ""
                        //});
                        //var historyStock = localStorage.getItem("stockInfo") || JSON.stringify({
                        //    code: "",
                        //    name: "",
                        //    id: "-1"
                        //});
                        //historyClient = JSON.parse(historyClient);
                        //historyStock = JSON.parse(historyStock);
                        //that.form.FCustCode = historyClient.code;
                        //that.form.FCusName = historyClient.name;
                        //that.form.FWarehouseCode = historyStock.code;
                        //that.form.FWarehouseName = historyStock.name;
                        //that.form.FWarehouseID = historyStock.id
                    } else {

                    }
                }
            });
        },
        tableRowGTZero() {
            return this.tableData.length > 0
        },
        calcValue(value) {
            return value;
        },
        clearTable() {
            this.tableData.length > 0 && vm.$confirm('您的操作将清空表格数据!是否继续操作?', '警告', {
                callback: function (action, instance) {
                    if (action == "confirm") {
                        vm.tableData = [];
                    }
                }
            })
        },
        initBill() {
            this.tableData = [];
            this.form.FBillID = 0;/*订单ID  默认传0*/
            this.form.FDate = dayjs().format("YYYY-MM-DD");
            //this.form.FCustCode = ""; /*客户编码*/
            this.form.FReciveTypeCode = "05";/*收款方式 编码，（先默认一下编码 ） 05*/
            this.form.FMemo = ``;/*订单备注*/
            //this.form.FWarehouseCode = "";/*仓库*/
            //this.form.FWarehouseID = "-1";
            //this.form.FWarehouseName = "";
            this.form.FTaxRate = 13;
            this.form.FIsBuild = false
            this.genBillId();
            this.genBillNo();
            this.changBtnStatus("add");
        },
        changBtnStatus(status) {
            this.actions[1].status = status == "read" ? "no" : "ok";
            this.actions[2].status = status == "read" ? "no" : "ok";
            this.actions[3].status = status == "add" ? "no" : "ok";
            this.actions[4].status = status == "read" ? "no" : "ok";
            this.actions[5].status = status == "add" ? "no" : "ok";
            this.actions[6].status = status == "read" ? "no" : "ok";
        },
        deleteRow() {
            this.tableData.length > 0 &&
            this.grid.getSelectedData().length > 0 &&
            vm.$confirm('您的操作将删除表格中选中的行!是否继续操作?', '警告', {
                callback: function (action, instance) {
                    if (action == "confirm") {
                        vm.grid.getSelectedRows().forEach(function (row) {
                            row.delete();
                        })
                        vm.tableData = vm.grid.getData().map(function (row, index) {
                            row.FIndex = index;
                            return row;
                        })
                    }
                }
            })
        },
        deSelectRow() {
            if (this.tableData.length > 0 &&
            this.grid.getSelectedData().length > 0) {
                vm.grid.getSelectedRows().forEach(function (row) {
                    row.deselect();
                })
            }
        },
        addBill() {
            vm.$confirm('您的操作将丢失目前的操作数据, 是否继续?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(function (response) {
                vm.initBill();
            }).catch(function () {

            })
        },
        editBill() { },
        saveBill() {
            if (this.tableData.some(function (row) {
                return row.FQty <= 0
            })) {
                return this.$alert('表体数据不完整,请核查数量!', '错误', {
                    confirmButtonText: '确定'
                });
            }
            if (this.form.FBillID < 0 || this.form.FBillNo.length == 0
                || this.tableData.length == 0) {
                return this.$alert('单据数据不完整,请核查!', '错误', {
                    confirmButtonText: '确定'
                });
            } else {
                var that = this;
                $.ajax({
                    type: "POST",
                    url: "handler.ashx",
                    async: true,
                    data: {
                        SelectApi: "SaveBill", formData: JSON.stringify({
                            form: $.extend({}, this.form, { FDate: dayjs(this.formFDate).format("YYYY-MM-DD hh:mm:ss"), FTaxRate: accDiv(this.form.FTaxRate, 100) }),
                            body: $.extend(true, [], this.tableData).map(function (row) {
                                row.FPlanQty = 0;
                                row.FTaxRate = accDiv(row.FTaxRate, 100)
                                return row;
                            })
                        })
                    },
                    dataType: "json",
                    success: function (result) {
                        if (result.status == "success") {
                            vm.$confirm('保存单据成功, 是否继续生单?', '提示', {
                                confirmButtonText: '确定',
                                cancelButtonText: '取消',
                                type: 'warning'
                            }).then(function (response) {
                                vm.changBtnStatus('read');
                                vm.billstatus = 'read'; //单据只读
                                vm.buildBill();
                            }).catch(function () {
                                vm.changBtnStatus('read');
                                vm.billstatus = 'read'; //单据只读
                            })
                        } else {
                            return vm.$alert(result.message, '错误', {
                                confirmButtonText: '确定'
                            });
                        }
                    }
                });
            }
        },
        deleteBill() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "handler.ashx",
                async: true,
                data: { SelectApi: "deletebill", billid: this.form.FBillID },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        return vm.$alert(result.msg, '成功', {
                            confirmButtonText: '确定'
                        }).then(function (response) {
                            vm.initBill();
                        })
                    } else {
                        return vm.$alert(result.msg, '错误', {
                            confirmButtonText: '确定'
                        });
                    }
                }
            });
        },
        buildBill() {
            var that = this;
            if (this.form.FBillID < 0) {
                return vm.$alert("您尚未保存单据,无法生单!", '错误', {
                    confirmButtonText: '确定'
                });
            } else {
                var loading = this.$loading({
                    lock: true,
                    text: '生单中...',
                    spinner: 'el-icon-loading',
                    background: 'rgba(0, 0, 0, 0.5)'
                });
                $.ajax({
                    type: "POST",
                    url: "handler.ashx",
                    async: true,
                    data: { SelectApi: "buildBill", billid: this.form.FBillID },
                    dataType: "json",
                    beforeSend: function () {
                        //vm.fullscreenLoading = true;
                    },
                    success: function (result) {
                        if (result.status == "success") {
                            return vm.$alert('生成单据成功!', '成功', {
                                confirmButtonText: '确定'
                            }).then(function (response) {
                                if (response == "confirm") {
                                    vm.initBill();
                                }
                            })
                        } else {
                            return vm.$alert(result.msg, '错误', {
                                confirmButtonText: '确定'
                            });
                        }
                    },
                    complete: function () {
                        vm.fullscreenLoading = false;
                        loading.close();
                    }
                });
            }
        },
        genBillNo() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "handler.ashx",
                async: true,
                data: { SelectApi: "GetBillNo" },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        that.form.FBillNo = JSON.parse(result.data).fbillno
                    } else {

                    }
                }
            });
        },
        genBillId() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "handler.ashx",
                async: true,
                data: { SelectApi: "GetBillId" },
                dataType: "json",
                success: function (result) {
                    if (result.status == "success") {
                        that.form.FBillID = JSON.parse(result.data).fbillid
                    } else {

                    }
                }
            });
        },
        lessStockQty (cell, value, parameters) {
            return value <= cell.getData().FStockQty && value > 0;
        },
        canUse(action) {
            return action.status == "no"
        },
        inputance(e) {
            var p1 = e.split('.')[0];
            if (p1 == "") {
                p1 = "0"
            }
            var p2 = e.split('.')[1];
            if (p2) {
                if (p2.length > 3) {
                    this.form.FAllowances = p1 + '.' + p2.substring(0, 3)
                }
            } else {
                this.form.FAllowances = p1 + '.000'
            }

            if (Number(this.form.FAllowances) < 0) {
                this.form.FAllowances = '0.000' //小于0 则置为0
            }

            var temp = $.extend(true, [], this.tableData);
            var sum = "0.000";
            $.each(temp, function (i, n) {
                sum += accAdd(sum, n.FSum)
            });
            if (accSub(this.form.FAllowances, sum) > 0) {
                this.form.FAllowances = sum //超过总金额 则置为总金额
            }
        }
    },
    watch: {
        tableData: {
            handler: function (newData) {
                this.grid.replaceData(newData);
            },
            deep: true
        },
        "form.FTaxRate": {
            handler: function (newData) {
                if (Number(newData) < 0 || Number(newData) > 100) {
                    this.form.FTaxRate = "13"
                } else {
                    var that = this;
                    this.tableData = this.tableData.map(function (item) {
                        item.FTaxRate = newData;
                        var FTaxPrice = accMul(item.FPrice, accAdd(1, accDiv(newData, 100)));
                        item.FTaxPrice = FTaxPrice
                        item.FTaxSum = accMul(item.FQty, FTaxPrice);
                        return item;
                    });
                }
            },
            deep: true
        }
    },
    mounted() {
        this.maxHeight = $(window).height() * 0.5;
        this.form.FMaker = loginName;
        this.grid = new Tabulator("#grid", {
            height: "70vh",
            layout: "fitColumns",
            columnVertAlign: "bottom",
            selectable: true, //make rows selectable
            data: this.tableData, //set initial table data
            columns: [
                {
                    title: "订单分录ID",
                    field: "FEntryID",
                    visible: false,
                    headerSort: false
                },
                {
                    title: "序号",
                    field: "FIndex",
                    align: "center",
                    headerSort: false
                },
                {
                    title: "仓库编码",
                    field: "FWarehouseCode",
                    width: 100,
                    align: "center",
                    headerSort: false
                },
                {
                    title: "存货编码",
                    field: "FInvCode",
                    align: "center",
                    width: 250,
                    headerSort: false
                },
                {
                    title: "存货名称",
                    field: "FInvName",
                    align: "center",
                    headerSort: false,
                    width: 250,
                },
                {
                    title: "规格型号",
                    field: "FInvStd",
                    align: "center",
                    headerSort: false,
                    width: 200,
                    widthGrow: 3
                },
                {
                    title: "单位",
                    field: "FUnitName",
                    align: "center",
                    headerSort: false,
                    width: 100
                },
                {
                    title: "颜色",
                    field: "FPriuserdefnvc1",
                    align: "right",
                    editor: "false",
                    width: 120,
                    headerSort: false
                },
                {
                    title: "冠径",
                    field: "FPriuserdefnvc2",
                    align: "right",
                    editor: "false",
                    width: 120,
                    headerSort: false
                },
                {
                    title: "长度",
                    field: "FPriuserdefnvc3",
                    align: "right",
                    editor: "false",
                    width: 120,
                    headerSort: false
                },
                {
                    title: "高度",
                    field: "FPriuserdefnvc4",
                    align: "right",
                    editor: "false",
                    width: 120,
                    headerSort: false
                },
                {
                    title: "库存量",
                    field: "FStockQty",
                    align: "right",
                    width: 120,
                    headerSort: false,
                    editor: false,
                    bottomCalc: "sum",
                    bottomCalcParams: { precision: 3 }
                },
                {
                    title: "数量",
                    field: "FQty",
                    align: "right",
                    width: 120,
                    headerSort: false,
                    editor: this.billstatus != "read" ? "number" : "false",
                    bottomCalc: "sum",
                    bottomCalcParams: { precision: 3 },
                    validator: {
                        type: this.lessStockQty
                    },
                    cellEdited: function (cell) {
                        var postion = cell.getRow().getPosition();
                        var rowData = cell.getData();
                        rowData.FSum = accMul(cell.getValue(), rowData.FPrice)
                        rowData.FTaxSum = accMul(cell.getValue(), rowData.FTaxPrice)
                    }
                },
                {
                    title: "单价",
                    field: "FPrice",
                    align: "right",
                    width: 120,
                    headerSort: false,
                    editor: "number",
                    validator: "min:1",
                    cellEdited: function (cell) {
                        var postion = cell.getRow().getPosition();
                        var rowData = cell.getData();
                        rowData.FSum = accMul(cell.getValue(), rowData.FQty)
                        rowData.FTaxPrice = accMul(cell.getValue(), accAdd(1, accDiv(rowData.FTaxRate, 100)));
                        rowData.FTaxSum = accMul(rowData.FQty, rowData.FTaxPrice)
                    }
                },
                {
                    title: "金额",
                    field: "FSum",
                    align: "right",
                    width: 120,
                    headerSort: false
                },
                {
                    title: "税率",
                    field: "FTaxRate",
                    align: "right",
                    headerSort: false
                },
                {
                    title: "含税单价",
                    field: "FTaxPrice",
                    align: "right",
                    width: 120,
                    headerSort: false,
                    editor: "number",
                    validator: "min:1",
                    cellEdited: function (cell) {
                        var postion = cell.getRow().getPosition();
                        var rowData = cell.getData();
                        rowData.FTaxSum = accMul(cell.getValue(), rowData.FQty)
                        rowData.FPrice = accDiv(cell.getValue(), accAdd(1, accDiv(rowData.FTaxRate, 100))).toFixed(3);
                        rowData.FSum = accMul(rowData.FPrice, rowData.FQty)
                    }
                },
                {
                    title: "含税金额",
                    field: "FTaxSum",
                    align: "right",
                    width: 120,
                    headerSort: false,
                    bottomCalc: "sum",
                    bottomCalcParams: { precision: 3 }
                },
                {
                    title: "批号",
                    field: "FBatchNo",
                    align: "right",
                    editor: "false",
                    width: 120,
                    headerSort: false
                },
                {
                    title: "明细备注",
                    field: "FDetailMemo",
                    align: "left",
                    editor: "input",
                    width: 160,
                    headerSort: false
                }
            ]
        });
        this.queryStockSelect();
        this.queryClientSelect();
        this.genBillId();
        this.genBillNo();
        this.initBill();
    }
});