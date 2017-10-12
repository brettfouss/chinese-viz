(function() {

    var CHINESE_VIS_DATA_PATH = "chinese-vis/static/chinese-vis-data.json";
    var PARALLEL_SET_CONTROLLER_TEMPLATE_PATH = "chinese-vis/static/parallel-set-controller.hbs";
    var FORCE_DIRECTED_GRAPH_DATA_PATH = "chinese-vis/static/nodes.json";
    var FORCE_DIRECTED_GRAPH_CONTROLLER_TEMPLATE_PATH = "chinese-vis/static/force-directed-graph-controller.hbs";

    function loadData(path) {
        var deferred = jQuery.Deferred();
        $.getJSON(path).then(function(d) {
            deferred.resolve(d);
        }, function(error) {
            deferred.reject(error);
        })
        return deferred.promise();
    }

    function init() {

        loadData(CHINESE_VIS_DATA_PATH)
        .then(function(d) { return ParallelSetController.init(PARALLEL_SET_CONTROLLER_TEMPLATE_PATH, "#parallelSetControllerTarget", d) })
        .then(function(d) { return ForceDirectedGraphController.init(FORCE_DIRECTED_GRAPH_CONTROLLER_TEMPLATE_PATH, "#forceDirectedGraphControllerTarget", d)})
        .then(function(d) {
            ParallelSet.init(d, "#parallelSetTarget");
            ForceDirectedGraph.init(d, "#forceDirectedGraphTarget");
            bindParallelSetEvents();
            bindForceDirectedGraphEvents();
            ParallelSetController.render({
                "focused": false,
                "characters": Array(10).fill(null)
            });
            ForceDirectedGraphController.render({
                "radicals": []
            });
        }, function(error) {
            console.log("caught an error", error);
        });

    }

    function bindParallelSetEvents(data) {
        function queryString(i, j, k) {
            var query = [{"key":"i","value":i},{"key":"j","value":j}];
            if (k != undefined) {
                query.push({"key":"k","value":k});
            }
            return query;
        }
        function randomN(d, total) {
            var chars = [];
            var n = d.characters.length;
            if (n <= total) {
                chars = d.characters;
            } else {
                var indices = [];
                while (indices.length < total) {
                    var index = Math.floor(Math.random() * n);
                    if (indices.indexOf(index) == -1) {
                        indices.push(index);
                    }
                }
                for (var i = 0; i < indices.length; i++) {
                    chars.push(d.characters[indices[i]]);
                }
            }
            return chars;
        }
        ParallelSetController.bind(ParallelSetController.events.mouseoverSet,
            function(i, j, k) {
                ParallelSet.highlightSets(queryString(i, j, k));
        }, $("#parallelSetTarget"));
        ParallelSetController.bind(ParallelSetController.events.mouseoutSet,
            function(i, j, k, focused) {
                if (focused == "false") {
                    ParallelSet.unhighlightSets(queryString(i, j, k));
                }
        }, $("#parallelSetTarget"));
        ParallelSetController.bind(ParallelSetController.events.clickSet,
            function(d) {
                var chars = randomN(d, 10);
                ParallelSetController.render({
                    "focused": true,
                    "n": chars.length,
                    "length": d.characters.length,
                    "description": {
                        "i": (d.i == 0) ? "low" : ((d.i == 1) ? "medium": "high"),
                        "j": (d.j == 0) ? "early" : ((d.j == 1) ? "moderate": "late"),
                        "k": (d.k != undefined) ? ((d.k == 0) ? "infrequently" : ((d.k == 1) ? "somewhat frequently": "most frequently")) : undefined
                    },
                    "characters": chars
                });
                ParallelSet.unselectAll();
                ParallelSet.unhighlightAll();
                ParallelSet.highlightSets(queryString(d.i, d.j, d.k));
                ParallelSet.selectSets(queryString(d.i, d.j, d.k));
        }, $("#parallelSetTarget"));
    }

    function bindForceDirectedGraphEvents() {
    }

    $(document).ready(function() {
        init();
    });

}());
