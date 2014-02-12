class charts.GroupedStackedBarGraph

  constructor: (metadata, mold, dataFun, parentElement) ->
    @parentElement = parentElement
    #padding: internal SVG padding (for axes, etc; use in scales)
    @padding = 50
    @metadata = metadata
    @mold = mold;
    @firstRender = true;
    @dataFun = dataFun
    
    @stack = d3.layout.stack()
      .offset("zero")
      .values((d) ->
        d.values())
    
    #resizing events
    $(window).resize(_.debounce
      (() =>
        @hardRender()), 
      100)
    if @dataFun
      scheduleRefresh = () =>
        @refreshData()
        setTimeout(scheduleRefresh, 10000)
      scheduleRefresh()

    
    

  refreshData: () ->
    @dataFun(((data) => 
      @bindData(data)
      @render()
      ))
  #extract front-end relevant data using rawData (server data) and mold
  bindData: (rawData) ->
    @data = _.map(rawData, (d) => @mold(d))
    @data = _.sortBy(@data, (d) ->
      -d.total())
    _.forEach(@data, (d, i) => 
      _.forEach(d.values(), (v) =>
        v.index = i
        v.numLayers = @data.length
      )
    )
    @stackedData = @stack(@data)

  hardRender: () ->
    @width = $(@parentElement).width()
    @height = $(@parentElement).height()
    
    if @$svg
      @$svg.children().remove()
      @svg = d3.select(@$svg[0])
            .attr(
              "width": @width
              "height": @height)
    else
      @svg = d3.select(@parentElement)
            .append("svg")
            .attr(
              "width": @width
              "height": @height)
      @$svg = $(@parentElement).find('svg')
      @$svg.on("content-in-focus", @inFocus)
      @$svg.on("content-out-of-focus", @outOfFocus)
    
    if(!@data)
      return;
      
    @yMin = 0
    @yMax = d3.max(@stackedData, 
                   (layer) -> (d3.max(layer.values(), (v) ->
                       v.y0 + v.y))
                  )
    @xMin = d3.min(@stackedData, 
                     (layer) ->
                       d3.min(layer.values(), 
                         (v) ->
                           v.x0
                       )
                  )
                   
    @xMax = d3.max @stackedData, 
                     (layer) ->
                       d3.max(layer.values(), 
                         (v) ->
                           v.x1
                       )
    @x = d3.scale.linear()
                 .range([@padding, @width - @padding])
                 #.range([(Math.log(@yMax) * 2.6) + 34, @width - @padding])
                 .domain([@xMin, @xMax])
                 
    @y = d3.scale.linear()
                 .range([@height-@padding, @padding])
                 .domain([0, @yMax])
    
    @layers = @svg.selectAll(".layer")
       .data(@stackedData)
       .enter()
       .append("g")
       .attr
         "class" : "layer"
       .style
         "fill": (d) =>
           d.color()
         "stroke": (d) =>
           (new Color(d.color())).darken(.45).hexString()

    if @firstRender
      @firstRender = false;
      if @metadata.type == "grouped"
        @firstRenderGrouped()
      else
        @firstRenderStacked()
    else
      if @metadata.type == "grouped"
        @renderGrouped()
      else
        @renderStacked()
    
            
    xAxis = d3.svg.axis()
                  .scale(@x)
                  .orient("bottom")
                  .tickFormat((d) -> (new Date(d)).strftime("%I:%M%P %m/%d"))
    yAxis = d3.svg.axis()
                  .scale(@y)
                  .orient("left")

    labelLeading = 9
    @svg.append("g")
       .attr("class", "axis")
       .attr("transform", "translate(0, #{@y(@yMin)})")
       .call(xAxis)
    @svg.append("text")
       .classed("x axis label", true)
       .attr("text-anchor", "end")
       .attr("x", @width- @padding)
       .attr("y", @height - labelLeading)
       .text(@metadata?.xLabel)

    fontSize = parseInt($(".label").css('font-size'));
    yLabelOffset = fontSize

    @svg.append("g")
       .attr("class", "axis")
       .attr("transform", "translate(#{@x(@xMin)}, 0)")
       .call(yAxis)

    @svg.append("text")
        .classed("y axis label", true)
        .attr("class", "y label")
        .attr("text-anchor", "end")
        .attr("y", 9)
        .attr("x", -@padding)
        .attr("dy", ".32em")
        .attr("transform", "rotate(-90) translate(0, 0)")
        .text(@metadata?.yLabel);

    puid = "44"
    widgets.Popovers.create(puid)
    @blocks
      .on("mouseover", (d) ->
        widgets.Popovers.show(puid, d.popover())
        d3.select(this).classed("active", true))
      .on("mousemove", (d) =>
        e = d3.event
        widgets.Popovers.position(puid, e.pageX + 10, e.pageY + 20, @$svg.offset().top + @height - @padding, @$svg.offset().left + @width - @padding))
      .on('mouseout', (d) ->
        widgets.Popovers.hide(puid)
        d3.select(this).classed("active", false))

  render: () ->
    @hardRender()
  
  inFocus: () =>
    @firstRender = true;
    @hardRender()
  outOfFocus: () =>

  firstRenderStacked: () ->
    @blocks = @layers.selectAll(".bar-rect")
                      .data((d) -> d.values())
                      .enter()
                      .append("rect")
                      .attr
                        "class" : "bar-rect"
                        "x" : (d) => @x(d.x)
                        "y" : (d) => @y(0) 
                        "width" : (d) => @x(d.x1) - @x(d.x0)
                        "height" : (d) => 0
    
    @blocks.transition()
           .duration(1000)
           .attr
             "class" : "bar-rect"
             "x" : (d) => @x(d.x)
             "y" : (d) => @y(d.y + d.y0) 
             "width" : (d) => @x(d.x1) - @x(d.x0)
             "height" : (d) => @y(0) - @y(d.y)

  renderStacked: () ->
    @blocks = @layers.selectAll(".bar-rect")
                    .data((d) -> d.values())
                    .enter()
                    .append("rect")
                    .attr
                      "class" : "bar-rect"
                      "x" : (d) => @x(d.x)
                      "y" : (d) => @y(d.y + d.y0) 
                      "width" : (d) => @x(d.x1) - @x(d.x0)
                      "height" : (d) => @y(0) - @y(d.y)


  firstRenderGrouped: () ->
    @blocks = @layers.selectAll(".bar-rect")
                    .data((d) -> d.values())
                    .enter()
                    .append("rect")
                    .attr
                      "class" : "bar-rect"
                      "x" : (d) => @x(d.x) + ((@x(d.x1) - @x(d.x0))/d.numLayers) * d.index
                      "y" : (d) => @y(0) 
                      "width" : (d) => ((@x(d.x1) - @x(d.x0))/d.numLayers)
                      "height" : (d) => 0

    @blocks.transition()
           .duration(1000)
           .attr
             "x" : (d) => @x(d.x) + ((@x(d.x1) - @x(d.x0))/d.numLayers) * d.index
             "y" : (d) => @y(d.y) 
             "width" : (d) => ((@x(d.x1) - @x(d.x0))/d.numLayers)
             "height" : (d) => @y(0) - @y(d.y)

  renderGrouped: () ->
    @blocks = @layers.selectAll(".bar-rect")
                    .data((d) -> d.values())
                    .enter()
                    .append("rect")
                    .attr
                      "class" : "bar-rect"
                      "x" : (d) => @x(d.x) + ((@x(d.x1) - @x(d.x0))/d.numLayers) * d.index
                      "y" : (d) => @y(d.y) 
                      "width" : (d) => ((@x(d.x1) - @x(d.x0))/d.numLayers)
                      "height" : (d) => @y(0) - @y(d.y)

  transitionToStacked: () =>
    if @metadata.type != "stacked"
      @metadata.type = "stacked"
      
      @blocks.transition()
             .duration(500)
             .delay((d, i) -> i * 10)
             .attr("y",  (d) => @y(d.y + d.y0) )
             .transition()
             .attr
               "x" : (d) => @x(d.x)
               "width" : (d) => @x(d.x1) - @x(d.x0)

    
  transitionToGrouped: () =>
    if @metadata.type != "grouped"
      @metadata.type = "grouped"
      
      @blocks.transition()
             .duration(500)
             .delay((d, i) -> i * 10)
             .attr
               "x" : (d) => @x(d.x) + ((@x(d.x1) - @x(d.x0))/d.numLayers) * d.index
               "width" : (d) => ((@x(d.x1) - @x(d.x0))/d.numLayers)
             .transition()
             .attr("y", (d) => @y(d.y) )
             
      

