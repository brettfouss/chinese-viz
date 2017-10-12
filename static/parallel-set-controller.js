var ParallelSetController = (function() {

        var target = {};
        var template = {};
        var events = {};

        Handlebars.registerHelper("plus", function(i, j) {
            return i + j;
        });

        events.clickSet = function(t, fn) {
            d3.selectAll(".set")
              .on("click", function(d) {
                  fn(d);
              });
        }

        events.mouseoverSet = function(t, fn) {
                $(t).on("mouseover", ".set", function() {
                        var i = $(this).attr("i");
                        var j = $(this).attr("j");
                        var k = $(this).attr("k");

                        fn(i, j, k);
                });
        }

        events.mousemoveSet = function(t, fn) {
                $(t).on("mousemove", ".set", function(e) {
                        fn(e.pageX, e.pageY);
                });
        }

        events.mouseoutSet = function(t, fn) {
                $(t).on("mouseout", ".set", function() {
                        var i = $(this).attr("i");
                        var j = $(this).attr("j");
                        var k = $(this).attr("k");
                        var focused = $(this).attr("focused");
                        fn(i, j, k, focused);
                });
        }

        function bind(e, fn, t) {
                e(t, fn);
        }

        function render(state) {
            $(target).html(template(state));
        }

        function init(path, elem, data) {
            var deferred = jQuery.Deferred();
            $.get(path).then(function(t) {
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
                "events": events,
                "bind": bind
        };

}());
