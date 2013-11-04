window.updateMayors = (id) ->
    
    opts = window.opts

    dataDict = {}
    for m in window.mayors
        p = window.groupedParty(m.party)
        dataDict[p] ?= 0
        dataDict[p] += m.votes
    data = ( party: k, votes: v for k,v of dataDict)
    data.sort window.partySort("votes")

    div = $("#"+id)

    h = div.height()
    w = div.width()
    x = pv.Scale.linear(0, window.maxVal(data, "votes")).range(opts.nameSize, w-opts.rightGutter)
    y = pv.Scale.ordinal(pv.range(data.length)).splitBanded(opts.titleSize+10, h-5-opts.footerSize, 4/5);

    vis = new pv.Panel().canvas(id).width(w).height(h)

    vis.anchor("top").add(pv.Label)
        .text("Maire de Montréal")
        .font("#{opts.titleSize}px sans-serif")

    vis.anchor("bottom").add(pv.Label)
        .textStyle("grey")
        .text("bureaux de vote: "+window.stats.stationsDone+" / "+window.stats.stationsTotal+" - taux de participation: "+window.stats.participation+"%")
        .font("#{opts.footerSize}px sans-serif")

    bars = vis.add(pv.Bar)
        .data(data)
        .top( -> y @index)
        .height(y.range().band)
        .fillStyle(  (d) -> window.partyColor d.party )
        .left(x(0))
        .width( (d) -> x(d.votes)-x(0) )

    bars.anchor("right").add(pv.Label)
        .textStyle("white")
        .font(opts.numberLabelFont)
        .text( (d) -> window.percentString(d, data, "votes"))

    bars.anchor("left").add(pv.Label)
        .textStyle("white")
        .font(opts.numberLabelFont)
        .text( (d) -> if x(d.votes)-x(0) > 50 then window.addSpaces d.votes else "")

    bars.anchor("left").add(pv.Label)
        .textAlign( "right")
        .textStyle("black")
        .font(opts.nameLabelFont)
        .text( (d) ->  window.partyLeader d.party )

    vis.render()
