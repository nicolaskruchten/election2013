window.updateMultiRace = (id, type, margin) ->
    
    opts = window.opts
    voteData = []
    data = []
    projet = [window.PROJET, parseInt(window.PROJET)]
    if type == "within"
        races = window.racesWithin(margin)
        label = "Courses serrées"
    else if type == "above"
        races = window.racesAbove(margin)
        label = "Candidats en voie d'être elus"

    for r in races
        race = []
        for c in r.candidates when c.party in projet
            race.push c
            voteData.push c
        for c in r.candidates when c.party not in projet and c.party in [r.leadingParty, r.secondParty]
            race.push c
            voteData.push c
        data.push race

    div = $("#"+id)

    h = div.height()
    w = div.width()
    x = pv.Scale.linear(0, window.maxVal(voteData, "votes")).range(opts.nameSize, w-opts.rightGutter)
    y = pv.Scale.ordinal(pv.range(data.length)).splitBanded(opts.titleSize+10, h, 4/5);


    vis = new pv.Panel().canvas(id).width(w).height(h)


    vis.anchor("top").add(pv.Label)
        .text(label)
        .font("#{opts.titleSize}px sans-serif")

    #vis.anchor("bottom").add(pv.Label)
    #    .text("432/4501")
    #    .font("#{opts.footerSize}px sans-serif")

    bars = vis.add(pv.Panel)
        .data(data)
        .top(-> y @index)
        .left(x(0))
        .height(y.range().band)
      .add(pv.Bar)
        .data( (d) -> d)
        .top( -> @index * y.range().band / 2)
        .height(y.range().band / 2)
        .left(0)
        .width((d) -> x(d.votes)-x(0))
        .fillStyle(  (d) -> window.partyColor d.party )




    bars.anchor("right").add(pv.Label)
        .textStyle("white")
        .text( (d) -> window.addSpaces d.votes)

    bars.anchor("left").add(pv.Label)
        .textAlign("right")
        .textStyle("black")
        .font(opts.nameLabelFont)
        .text(-> if this.index == 0 then races[this.parent.index].projetCandidate else "" );


    vis.render()
