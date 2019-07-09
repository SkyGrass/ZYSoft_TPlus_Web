
!Object.extend && (Object.extend = function (dest, source, replace) {
    for (var prop in source) {
        if (replace == false && dest[prop] != null) { continue; }
        dest[prop] = source[prop];
    }
    return dest;
});

!String.prototype.trim && (String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
});

!Array.prototype.copyFrom && (Array.prototype.copyFrom = function (arr) {
    for (var i = 0; i < arr.length; i++) {
        this.push(arr[i]);
    }
    return this;
});



var global = this;

!global.$Module && (global.$Module = {});
!global.$currentModule && (global.$currentModule = "");


!global.$InstanceCreator && (global.$InstanceCreator = {
    Create: function (typeName, assemblyName, args) {
    },
    Invoke: function (typeName, assemblyName, methodName, args, signature) {
    },
    GetProxyString: function (typeName, assemblyName) {
    }
});

!global.$LoadJS && (global.$LoadJS = function (jsFile) {
    
});

!global.$RootPath && (global.$RootPath = "/");




function define(id, factory) {
    if (arguments.length == 1) {
        factory = id;
        id = $currentModule;
    }

    var module = { exports: {}, id: id, factory: factory };

    define.Add(module);

    factory(require, module.exports, module);

    return module.exports;
}

Object.extend(define, {
    Module: function (name) {

        var m = $Module["m_" + name];

        if (m) return m.exports;

        return null;
    },
    Add: function (module) {

        $Module["m_" + module.id] = module;
    }
});

function require(name) {
    var robj = define.Module(name);

    if (robj != null) {
        //return robj;
    }
    else if (name.indexOf(",") != -1) {

        robj = require.Type(name);
    }
    else {

        robj = require.JS(name);
    }
    return robj;
}

Object.extend(require, {
    Type: function (name) {

        define(name, function (require, exports, module) {

            var proxy = function () {//构造函数。

                return proxy.$create.apply(proxy, new Array().copyFrom(arguments));
            };

            Object.extend(proxy, new require.Type.Proxy(name));

            module.exports = proxy;
        });

        return define.Module(name);
    },
    JS: function (jsFile) {

        $LoadJS(jsFile);

        var m = define.Module(jsFile);

        if (m == null) {//普通文件 

            define.Add({ exports: global, id: jsFile, factory: function () { } });

            m = global;

        } else {
            //define(function(require,exports,module){});的文件
        }

        return m;
    },
    AppEventHandler: function (jsFile) {

        handler = require(jsFile);

        if (handler && handler.AppEventHandler) {

            handler.AppEventHandler(sender, e);
        }
    }
});

Object.extend(require.Type, {
    Proxy: function (name) {
        this.$quilifiedName = name.split(',')[0].trim();

        this.$assemblyName = name.split(',')[1].trim();

        this.$initMemberProxy(this.$quilifiedName, this.$assemblyName);
    }
});

Object.extend(require.Type.Proxy.prototype, {
    $create: function () {

        var args = (arguments.length == 0 ? null : Array().copyFrom(arguments));

        var o = $InstanceCreator.Create(this.$quilifiedName, this.$assemblyName, args);

        return o;
    },
    $invoke: function () {

        var args = (arguments.length == 0 ? null : Array().copyFrom(arguments));

        var method = args.shift();

        var signature = this[method + "_Signature"];

        var o = $InstanceCreator.Invoke(this.$quilifiedName, this.$assemblyName, method, args, signature, false);

        return o;

    },
    $initMemberProxy: function () {

        var proxyObj = $InstanceCreator.GetProxyString(this.$quilifiedName, this.$assemblyName);

        if (proxyObj != null && proxyObj.length > 0) {
            Object.extend(this, Function("return " + proxyObj)());
        }
    },
    prop: function (property, value) {//静态属性读取。

        var args = new Array();

        if (typeof (value) != "undefined") {
            args.push(value);
        }

        var o = $InstanceCreator.Invoke(this.$quilifiedName, this.$assemblyName, property, args, null, true);

        return o;
    }
});

var Debug = require("System.Diagnostics.Debug,System");
