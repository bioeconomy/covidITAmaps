function legend_choropleth_layer(layer, name, units, id) {
    // Generate a HTML legend for a Leaflet layer created using choropleth.js
    //
    // Arguments:
    // layer: The leaflet Layer object referring to the layer - must be a layer using
    //        choropleth.js
    // name: The name to display in the layer control (will be displayed above the legend, and next
    //       to the checkbox
    // units: A suffix to put after each numerical range in the layer - for example to specify the
    //        units of the values - but could be used for other purposes)
    // id: The id to give the <ul> element that is used to create the legend. Useful to allow the legend
    //     to be shown/hidden programmatically
    //
    // Returns:
    // The HTML ready to be used in the specification of the layers control
    var limits = layer.options.limits;
    var colors = layer.options.colors;
    var labels = [];

    // Start with just the name that you want displayed in the layer selector
    var HTML = name

    // For each limit value, create a string of the form 'X-Y'
    limits.forEach(function (limit, index) {
        if (index === 0) {
            var to = parseFloat(limits[index]).toFixed(0);
            var range_str = "< " + to;
        }
        else {
            var from = parseFloat(limits[index - 1]).toFixed(0);
            var to = parseFloat(limits[index]).toFixed(0);
            var range_str = from + "-" + to;
        }

        // Put together a <li> element with the relevant classes, and the right colour and text
        labels.push('<li class="sublegend-item"><div class="sublegend-color" style="background-color: ' +
            colors[index] + '"> </div> ' + range_str + units + '</li>');
    })

    // Put all the <li> elements together in a <ul> element
    HTML += '<ul id="' + id + '" class="sublegend">' + labels.join('') + '</ul>';

    return HTML;
}
