window.updateCouncil = (id) ->
    
    opts = window.opts


    data = []
    data.push party: "3", counsellors: 6 
    data.push party: "4", counsellors: 12 
    data.push party: "5", counsellors: 18
    data.push party: "9", counsellors: 24
    data.push party: "0", counsellors: 34 
    
    data.sort window.partySort("counsellors")

    div = $("#"+id)

    h = div.height()
    w = div.width()
    x = pv.Scale.linear(0, Math.max(window.maxVal(data, "counsellors"), 34)).range(opts.nameSize, w-opts.rightGutter)
    y = pv.Scale.ordinal(pv.range(data.length)).splitBanded(opts.titleSize+10, h-5-opts.footerSize, 4/5);

    vis = new pv.Panel().canvas(id).width(w).height(h)

    vis.anchor("top").add(pv.Label)
        .text("Conseillers de Ville")
        .font("#{opts.titleSize}px sans-serif")

    vis.anchor("bottom").add(pv.Label)
        .text("432/4501")
        .font("#{opts.footerSize}px sans-serif")

    bars = vis.add(pv.Bar)
        .data(data)
        .top( -> y @index)
        .height(y.range().band)
        .fillStyle(  (d) -> window.parties[d.party].color )
        .left(x(0))
        .width( (d) -> x(d.counsellors)-x(0) )

    vis.add(pv.Rule)
        .left(x(33))
        .bottom(y(data.length))
        .top(y(0))
        .strokeStyle("grey")


    bars.anchor("right").add(pv.Label)
        .textStyle("white")
        .text( (d) -> d.counsellors)

    bars.anchor("left").add(pv.Label)
        .textAlign( "right")
        .textStyle("black")
        .text( (d) -> window.parties[d.party].name )

    vis.render()
    