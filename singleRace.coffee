window.updateRandomRace = (id) ->
    
    opts = window.opts
    raceArray = (v for k,v of window.races)
    race = raceArray[Math.floor(Math.random()*raceArray.length)]
    data = race.candidates
    data.sort window.partySort("votes")

    div = $("#"+id)

    h = div.height()
    w = div.width()
    x = pv.Scale.linear(0, window.maxVal(data, "votes")).range(opts.nameSize, w-opts.rightGutter)
    y = pv.Scale.ordinal(pv.range(data.length)).splitBanded(opts.titleSize+10, h-5-opts.footerSize, 4/5);

    vis = new pv.Panel().canvas(id).width(w).height(h)


    vis.anchor("top").add(pv.Label)
        .text(race.shortname)
        .font("#{opts.titleSize}px sans-serif")

    #vis.anchor("bottom").add(pv.Label)
    #    .text("432/4501")
    #    .font("#{opts.footerSize}px sans-serif")

    bars = vis.add(pv.Bar)
        .data(data)
        .top( -> y @index)
        .height(y.range().band)
        .fillStyle(  (d) -> window.partyColor d.party )
        .left(x(0))
        .width( (d) -> x(d.votes)-x(0) )

    bars.anchor("right").add(pv.Label)
        .textStyle("white")
        .text( (d) -> window.percentString(d, data, "votes"))
        
    bars.anchor("left").add(pv.Label)
        .textStyle("white")
        .text( (d) -> window.addSpaces d.votes)

    bars.anchor("left").add(pv.Label)
        .textAlign( "right")
        .textStyle("black")
        .text( (d) ->  d.name )

    vis.render()
