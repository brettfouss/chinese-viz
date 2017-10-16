var ForceDirectedGraphController = (function() {

    var data = {
        "radicals": [],
        "active": 0
    };
    var target = {};
    var template = {};
    var events = {};

    Handlebars.registerHelper("isActive", function(id, block) {
        if (id == data.active) {
            return block.fn(this);
        } else {
            return block.inverse(this);
        }
    });

    events.mouseoverNode = function(t, fn) {
        $(t).on("mouseover", ".node", function(d) {
              fn(this);
        });
    }

    events.mouseoutNode = function(t, fn) {
        $(t).on("mouseout", ".node", function(d) {
              fn(this);
        });
    }

    events.selectRadical = function(t, fn) {
        $(t).on("click", ".radical-selector", function(d) {
              fn($(this).attr("name"));
        });
    }

    events.clickNode = function(t, fn) {
        $(t).on("click", ".node", function(d) {
              fn($(this).attr("name"));
        });
    }

    function initRadicals(d) {
        data.radicals = [];
        for (var i = 0; i < d.length; i++) {
            if (d[i].type == "radical") {
                data.radicals.push(d[i]);
            }
        }
    }

    function setActive(id) {
        data.active = parseInt(id);
    }

    function bind(e, fn, t) {
            e(t, fn);
    }

    function render() {
        $(target).html(template(data));
    }

    function init(path, elem, data) {
            var deferred = jQuery.Deferred();
            $.get(path).then(function(t) {
                    initRadicals(data["node-link"]);
                    target = elem;
                    template = Handlebars.compile(t);
                    deferred.resolve(data);
            }, function(error) {
                    deferred.reject(error);
            });
            return deferred.promise();
    }

    return {
        "init": init,
        "render": render,
        "bind": bind,
        "events": events,
        "setActive": setActive
    };

}());
