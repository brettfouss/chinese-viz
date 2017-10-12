var Popover = (function() {

    var focusRadius = 10;
    var container = "";
    var target = "";
    var template = {};

    function showInfo() {
        $("#popover-info").css("display", "block");
    }

    function moveInfo() {
    }

    function hideInfo() {
        $("#popover-info").css("display", "none");
    }

    function showMouse() {
        d3.select(target)
          .append("circle")
          .attr("class", "popover-focus-point");
    }

    function hideMouse() {
        d3.select(".popover-focus-point").remove();
    }

    function moveMouse(x, y) {
        var elemOffset = $(target).offset();
        d3.select(".popover-focus-point")
          .attr("class", "popover-focus-point")
          .attr("r", 9)
          .attr("fill", "none")
          .attr("stroke", "#000")
          .attr("stroke-width", 3)
          .attr("cx", x - elemOffset.left)
          .attr("cy", y - elemOffset.top);
    }

    function show(state) {
        switch (state.type) {
            case "mouse":
                showMouse();
                break;
        }
    }

    function move(state) {
        switch (state.type) {
            case "mouse":
                moveMouse(state.mouse.x, state.mouse.y);
                break;
        }
    }

    function hide(state) {
        switch (state.type) {
            case "mouse":
                hideMouse();
                break;
        }
    }

    function init(path, c, elem) {
        container = c;
        target = elem;
        $(c).append("<div id='popover-info'></div>");
        $("#popover-info")
          .css("display", "none")
          .css("position", "absolute")
          .css("top", "0")
          .css("left", "0")
          .html("<p>this works!");
    }

    return {
        "init": init,
        "show": show,
        "hide": hide,
        "move": move
    };

})();
