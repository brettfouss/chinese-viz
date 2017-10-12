var ForceDirectedGraph = (function() {

    var data = {};
    var simulation = {};
    var dim = {
        "w": 0,
        "h": 0
    }

    var node = null;
    var link = null;

    function initFrame() {

            dim.w = $(target).width();
            dim.h = $(target).height();

            var selection = d3.select(target).append("svg")
                    .attr("width", dim.w)
                    .attr("height", dim.h);

            selection.append("g")
                    .attr("class", "links")
                    .attr("width", "100%")
                    .attr("height", "100%");

            selection.append("g")
                    .attr("class", "nodes")
                    .attr("width", "100%")
                    .attr("height", "100%");

            node = d3.select(".nodes").selectAll(".node");
            link = d3.select(".links").selectAll(".link");

    }

    function initForce(nodes, links) {
        simulation = d3.forceSimulation(nodes)
            .force("charge", d3.forceManyBody().strength(function(d) {
                if (d.degree == 0) {
                    return -1000;
                } else if (d.degree == 1) {
                    return -60;
                } else {
                    return -20;
                }
            }))
            .force("center", d3.forceCenter().x(dim.w/2).y(dim.h/2))
            .force("collide", d3.forceCollide().radius(function(d) {
                if (d.degree == 0) {
                    return 100;
                } else if (d.degree == 1) {
                    return 60;
                } else {
                    return 20;
                }
            }).iterations(16))
            .on("tick", ticked);
    }

    function update(selected) {

        var maxDepth = 3;
        var maxNum = 15;
        let root = data[selected];
        let nodeSet = new Set();
        let links = new Array();

        function containsLink(l, link) {
            for (var i = 0; i < l.length; i++) {
                if ((l[i].source == link.source && l[i].target == link.target) ||
                   (l[i].source == link.target && l[i].target == link.source)) {
                       return true;
                   }
            }
            return false;
        }

        function sample(arr) {
            if (arr.length < maxNum) {
                return arr;
            }
            let result = new Set();
            while (result.size < maxNum) {
                var randIndex = Math.floor(Math.random(0, 1) * arr.length);
                result.add(arr[randIndex]);
            }
            for (var i = 0; i < arr.length; i++) {
                if (data[arr[i]].type === "radical" || data[arr[i]].type === "character") {
                    result.add(arr[i]);
                }
            }
            return Array.from(result);
        }

        function addAll(parent, depth) {
            if (depth <= 0) {
                return;
            }
            if (!nodeSet.has(parent)) {
                parent["degree"] = maxDepth - depth;
                nodeSet.add(parent);
            }
            var neighbors = sample(parent.neighborhood);
            for (var i = 0; i < neighbors.length; i++) {
                addAll(data[neighbors[i]], depth - 1);
            }
        }

        addAll(root, maxDepth);

        var exists = {}
        let nodes = Array.from(nodeSet);

        for (var i = 0; i < nodes.length; i++) {
            for (var j = 0; j < nodes[i].neighborhood.length; j++) {
                var target = nodes.indexOf(data[nodes[i].neighborhood[j]]);
                if (target === -1) continue;
                var link = {
                    "source": i,
                    "target": target
                }
                if (!containsLink(links, link)) {
                    links.push(link);
                }
            }
        }

        return {
            "nodes": nodes,
            "links": links
        };

    }

    function draw(nodes, links) {

        simulation
        .force("fix", function(alpha) {
            for (var i = 0; i < nodes.length; i++) {
                if (nodes[i].degree == 0) {
                    nodes[i].x = dim.w/2;
                    nodes[i].y = dim.h/2;
                }
            }
        })

        node = node.data(nodes, (d) => d.id);
        node.exit()
            .transition()
            .attr("r", 0)
            .remove();

        node = node.enter()
                   .append("g")
                   .attr("class", "node")
                   .merge(node);

        node.append("circle")
            .attr("class", function(d) {
                return "node-circle " + d.name;
            })
            .call(function(n) { n.transition().attr("r", 20); })
            .style("fill", "#fff")
            .style("stroke", function(d) {
                if (d.type == "radical") {
                    return "red";
                } else if (d.type == "character") {
                    return "orange";
                } else {
                    return "grey";
                }
            })
            .style("stroke-width", "3px")
            .on("click", restart);

        node.append("text")
            .attr("class", "node-text")
            .attr("x", function(d) { return d.x; })
            .attr("y", function(d) { return d.y; })
            .text(function(d) { return d.name; })
            .style("font-size", "14px")
            .style("text-anchor", "middle")
            .on("click", restart);

        link = link.data(links, (d) => d.source.id + "-" + d.target.id);
        link.exit().remove();
        link = link.enter()
                   .append("line")
                   .attr("class", "link")
                   .attr("stroke", "grey")
                   .attr("stroke-width", "1.5px")
                   .merge(link);

        simulation.nodes(nodes);
        simulation.force("link", d3.forceLink(links).distance(50));
        simulation.alpha(1).restart();

    }

    function restart(node) {
        var id = "." + node.name;
        var ticks = 0;
        var next = update(node.id);
        draw(next.nodes, next.links);
    }

    function ticked () {
        link.attr("x1", function(d) { return d.source.x; })
            .attr("y1", function(d) { return d.source.y; })
            .attr("x2", function(d) { return d.target.x; })
            .attr("y2", function(d) { return d.target.y; });
        d3.selectAll(".node-text").attr("x", function(d) { return d.x; })
                                  .attr("y", function(d) { return d.y + 5; });
        d3.selectAll(".node-circle").attr("cx", function(d) { return d.x; })
                                    .attr("cy", function(d) { return d.y; });
    }

    function init(filedata, elem) {
        var d = filedata["node-link"];
        target = elem;
        initFrame();
        data = d;
        var first = update(0);
        initForce(first.nodes, first.links);
        draw(first.nodes, first.links);
        return filedata;
    }

    return {
        "init": init
    };

}());
