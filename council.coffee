window.updateCouncil = (id, type) ->
    
    opts = window.opts
    if type?
        label = window.labels[type]
    else
        label = window.labels[0]


    data = window.racesByParty(type)

    div = $("#"+id)

    h = div.height()
    w = div.width()
    x = pv.Scale.linear(0, window.maxVal(data, "races")).range(opts.nameSize, w-opts.rightGutter)
    y = pv.Scale.ordinal(pv.range(data.length)).splitBanded(opts.titleSize+10, h-5-opts.footerSize, 4/5);

    vis = new pv.Panel().canvas(id).width(w).height(h)

    vis.anchor("top").add(pv.Label)
        .text(label)
        .font("#{opts.titleSize}px sans-serif")

    vis.anchor("bottom").add(pv.Label)
        .textStyle("grey")
        .text("bureaux de vote: "+window.stats.stationsDone+" / "+window.stats.stationsTotal)
        .font("#{opts.footerSize}px sans-serif")

    bars = vis.add(pv.Bar)
        .data(data)
        .top( -> y @index)
        .height(y.range().band)
        .fillStyle(  (d) -> window.parties[d.party].color )
        .left(x(0))
        .width( (d) -> x(d.races)-x(0) )

    bars.anchor("right").add(pv.Label)
        .textStyle("white")
        .text( (d) -> d.races)

    bars.anchor("left").add(pv.Label)
        .textAlign( "right")
        .textStyle("black")
        .text( (d) -> window.parties[d.party].name )

    vis.render()
    