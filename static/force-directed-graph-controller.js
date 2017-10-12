var ForceDirectedGraphController = (function() {

    var data = {
        "radicals": []
    };
    var target = {};
    var template = {};

    function initRadicals(d) {
        data.radicals = [];
        for (var i = 0; i < d.length; i++) {
            if (d[i].type == "radical") {
                data.radicals.push(d[i]);
            }
        }
    }

    function render(state) {
        state.radicals = data.radicals;
        $(target).html(template(state));
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
        "render": render
    };

}());
