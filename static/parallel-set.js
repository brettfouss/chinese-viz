var ParallelSet = (function() {

        var ORDER = 3;
        var MARGIN = 50;
        var dim = {
                "w": 0,
                "h": 0,
        };
        var template = {};
        var target = {};

        function initFrame() {

                dim.w = $(target).width();
                dim.h = $(target).height();

                var selection = d3.select(target).append("svg")
                        .attr("width", dim.w)
                        .attr("height", dim.h);

                selection.append("g")
                        .attr("class", "sets")
                        .attr("width", "100%")
                        .attr("height", "100%");

                selection.append("g")
                        .attr("class", "axes")
                        .attr("width", "100%")
                        .attr("height", "100%");

        }

        function computeWidths(data) {

                var ifreqs = Array(ORDER).fill(0);
                var jfreqs = Array(ORDER).fill(0);
                var kfreqs = Array(ORDER).fill(0);

                var iwidths = [];
                var jwidths = [];
                var kwidths = [];

                var total = 0;
                var linewidth = dim.w - (2*MARGIN);

                for (var i = 0; i < ORDER; i++) {
                        for (var j = 0; j < ORDER; j++) {
                                for (var k = 0; k < ORDER; k++) {
                                        ifreqs[i] += data[i][j][k].length;
                                        jfreqs[j] += data[i][j][k].length;
                                        kfreqs[k] += data[i][j][k].length;
                                        total += data[i][j][k].length;
                                }
                        }
                }

                var dx = linewidth/total;

                for (var z = 0; z < ORDER; z++) {
                        iwidths.push(dx * ifreqs[z]);
                        jwidths.push(dx * jfreqs[z]);
                        kwidths.push(dx * kfreqs[z]);
                }

                return {
                        "i": iwidths,
                        "j": jwidths,
                        "k": kwidths,
                        "dx": dx
                };

        }

        function drawSets(widths, ys, data) {

                function addPrev(xs) {
                        var result = [];
                        var prev = 0;
                        for (var z = 0; z < xs.length; z++) {
                                result.push(prev);
                                prev += xs[z];
                        }
                        return result;
                }

                var ixs = addPrev(widths.i);
                var jxs = addPrev(widths.j);
                var kxs = addPrev(widths.k);

                for (var i = 0; i < ORDER; i++) {
                        for (var j = 0; j < ORDER; j++) {
                                var jwidth = 0;
                                var jchars = [];
                                for (var k = 0; k < ORDER; k++) {
                                        var kwidth = data[i][j][k].length * widths.dx;
                                        drawPolygon(MARGIN + jxs[j], MARGIN + ys[1],
                                                        MARGIN + jxs[j] + kwidth, MARGIN + ys[1],
                                                        MARGIN + kxs[k], MARGIN + ys[2],
                                                        MARGIN + kxs[k] + kwidth, MARGIN + ys[2], i, j, k, data[i][j][k]);
                                        kxs[k] += kwidth;
                                        jxs[j] += kwidth;
                                        jwidth += kwidth;
                                        jchars = jchars.concat(data[i][j][k]);
                                }
                                drawPolygon(MARGIN + ixs[i], MARGIN + ys[0],
                                                MARGIN + ixs[i] + jwidth, MARGIN + ys[0],
                                                MARGIN + jxs[j] - jwidth, MARGIN + ys[1],
                                                MARGIN + jxs[j], MARGIN + ys[1], i, j, undefined, jchars);
                                ixs[i] += jwidth;
                        }
                }
        }

        function drawAxes(widths, ys, labels) {

                var selection = d3.select(".axes");

                function drawText(text, x, y) {
                        selection.append("text")
                                 .attr("x", MARGIN + x + 5)
                                 .attr("y", MARGIN + y - 5)
                                 .attr("fill", "#000")
                                 .text(text);
                }

                function drawTick(x, y) {
                        selection.append("line")
                                .style("stroke", "#000")
                                .style("stroke-width", "2.5px")
                                .attr("x1", MARGIN + x)
                                .attr("y1", MARGIN + y + 5)
                                .attr("x2", MARGIN + x)
                                .attr("y2", MARGIN + y - 5);
                }

                function drawOneLine(ws, label, y) {
                        var prev = 0;
                        drawText(label.label, 0, y - 20)
                        for (var z = 0; z < ws.length; z++) {
                                selection.append("line")
                                        .style("stroke", "#000")
                                        .style("stroke-width", "2.5px")
                                        .attr("x1", MARGIN + prev)
                                        .attr("y1", MARGIN + y)
                                        .attr("x2", MARGIN + prev + ws[z])
                                        .attr("y2", MARGIN + y);
                                drawTick(prev, y);
                                drawText(label.sets[z], prev, y);
                                prev = prev + ws[z];
                        }
                        drawTick(prev, y);
                }

                drawOneLine(widths.i, labels[0], ys[0]);
                drawOneLine(widths.j, labels[1], ys[1]);
                drawOneLine(widths.k, labels[2], ys[2]);

        }

        function drawPolygon(x1, y1, x2, y2, x3, y3, x4, y4, i, j, k, d) {

                var topleft = x1.toString() + "," + y1.toString();
                var topright = x2.toString() + "," + y2.toString();
                var bottomleft = x3.toString() + "," + y3.toString();
                var bottomright = x4.toString() + "," + y4.toString();
                var string = topleft + " " + topright + " " + bottomright + " " + bottomleft;

                var selection = d3.select(".sets")
                        .datum({
                                "string": string,
                                "i": i,
                                "j": j,
                                "k": k,
                                "characters": d
                        })
                        .append("polygon")
                        .attr("class", "set")
                        .attr("i", (d) => d.i)
                        .attr("j", (d) => d.j)
                        .attr("k", (d) => d.k)
                        .attr("focused", "false")
                        .attr("points", (d) => d.string)
                        .style("fill", function(d) {
                                if (d.i == 0) {
                                        return "red";
                                } else if (d.i == 1) {
                                        return "orange";
                                } else {
                                        return "yellow";
                                }
                        })
                        .style("opacity", 0.5);

        }

        function highlightSets(queries) {
                var query = ""
                for (var z = 0; z < queries.length; z++) {
                        query += "[" + queries[z].key + "='" + queries[z].value + "']";
                }
                d3.selectAll(".set" + query)
                  .style("opacity", 1.0);
        }

        function unhighlightSets(queries) {
                var query = ""
                for (var z = 0; z < queries.length; z++) {
                        query += "[" + queries[z].key + "='" + queries[z].value + "']";
                }
                d3.selectAll(".set" + query)
                  .style("opacity", 0.5);
        }

        function unhighlightAll() {
            d3.selectAll(".set").style("opacity", 0.5);
        }

        function selectSets(queries) {
                var query = ""
                for (var z = 0; z < queries.length; z++) {
                        query += "[" + queries[z].key + "='" + queries[z].value + "']";
                }
                d3.selectAll(".set" + query)
                  .attr("focused", true);
        }

        function unselectSets(queries) {
                var query = ""
                for (var z = 0; z < queries.length; z++) {
                        query += "[" + queries[z].key + "='" + queries[z].value + "']";
                }
                d3.selectAll(".set" + query)
                  .attr("focused", false);
        }

        function unselectAll() {
            d3.selectAll(".set").attr("focused", false);
        }

        function update(data, labels) {

                var ys = [];
                var dy = (dim.h - (2*MARGIN))/(ORDER-1);
                var widths = computeWidths(data);

                for (var z = 0; z < ORDER; z++) {
                        ys.push(z * dy);
                }

                drawSets(widths, ys, data);
                drawAxes(widths, ys, labels);
        }

        function init(filedata, elem) {
            var d = filedata["parallel-set"];
            target = elem;
            initFrame();
            update(d.matrix, d.labels);
            return filedata;
        }

        return {
                "init": init,
                "highlightSets": highlightSets,
                "unhighlightSets": unhighlightSets,
                "unhighlightAll": unhighlightAll,
                "selectSets": selectSets,
                "unselectSets": unselectSets,
                "unselectAll": unselectAll
        };

}());
