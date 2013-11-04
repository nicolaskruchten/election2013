window.addSpaces = (nStr) ->
    nStr += ''
    x = nStr.split('.')
    x1 = x[0]
    x2 = if x.length > 1 then  '.' + x[1] else ''
    rgx = /(\d+)(\d{3})/
    x1 = x1.replace(rgx, '$1' + ' ' + '$2') while rgx.test(x1)
    return x1 + x2

window.opts = 
    titleSize: 20
    footerSize: 15
    nameSize: 150
    rightGutter: 20
    numberLabelFont: "15px sans-serif"
    nameLabelFont: "15px sans-serif"

window.labels = 
    CV: "Conseillers de ville"
    CA: "Conseillers d'arrondissement"
    MC: "Maires d'arrondissement"
    0: "Tous les postes"

window.maxVal = (objArray, key) -> pv.max( (obj[key] for obj in objArray) )
window.sumVal = (objArray, key) -> pv.sum( (obj[key] for obj in objArray) )

window.percentString = (numElem, denomElem, key) -> 
    num = numElem[key]
    denom = window.sumVal(denomElem, key)
    return "0.0%" if denom == 0 
    pct = (100*num/denom)
    if pct > 10
        return pct.toFixed(1)+"%"
    else
        return ""

window.PROJET = PROJET = "9" #13

window.parties =
    9: 
    #13:
        name: "Projet Montréal"
        leader: "Richard BERGERON"
        color: "#78BE20"
    5:
    #7: 
        name: "Équipe Denis Coderre"
        leader: "Denis CODERRE"
        color: "#662d91"
    4:
    #14: 
        name: "Groupe Mélanie Joly"
        leader: "Mélanie JOLY"
        color: "#fdb813"
    3:
    #1: 
        name: "Coalition Montréal"
        leader: "Marcel CÔTÉ"
        color: "#0098ce"
    0: 
        name: "Autre"
        leader: "Autre"
        color: "#ffaaaa"
    "-1": 
        name: "Indépendant"
        leader: "Indépendant"
        color: "#aaaaaa"

window.groupedParty = (x) -> if x not of parties then 0 else x

window.partyName = (x) -> parties[window.groupedParty(x)].name
window.partyColor = (x) -> parties[window.groupedParty(x)].color
window.partyLeader = (x) -> parties[window.groupedParty(x)].leader

window.partySort = (key) -> (a,b) ->
    return -1111111111 if a.party in [PROJET, parseInt(PROJET)]
    return 1111111111 if b.party in [PROJET, parseInt(PROJET)]
    return b[key]-a[key]

window.racesWithin = (margin) -> (v for k,v of window.races when v.marginPct < margin and v.projetTopTwo)
window.racesAbove = (margin) -> (v for k,v of window.races when v.marginPct > margin and v.leadingParty is parseInt(PROJET))

window.racesByParty = (type) ->
    races = (v for k,v of window.races when (not type?) or v.type==type)
    dataDict = {}
    for r in races
        p = window.groupedParty(r.leadingParty)
        dataDict[p] ?= 0
        dataDict[p] += 1
    return ( party: k, races: v for k,v of dataDict).sort window.partySort("races")

window.events = []
window.eventPointer = 0

window.refreshData = (cb) ->
    #http://ec2-54-200-15-149.us-west-2.compute.amazonaws.com/events.json
    $.getJSON "events-exemple.json", ({conseil_ville, conseil_arrondissement, postes}) ->
        events = []
        for p in postes when p.parti in [PROJET, parseInt(PROJET)]
            events.push
                type: "race"
                event: p
        for k, v of conseil_arrondissement
            events.push
                type: "borough_council"
                event: 
                    name: k
                    body: v
        window.eventPointer = 0
        window.events = events

    #http://ec2-54-200-15-149.us-west-2.compute.amazonaws.com/media.json
    $.getJSON "media.json", ({arrondissements, districts: districtsIn, mairie, postes}) ->
        boroughs = {}
        districts = {}
        races = {}

        for {id, nom} in arrondissements
            boroughs[id] = 
                id: id
                name: nom
                districtIds: []
                districts: -> (v for k, v of districts when k in @districtIds)
                raceIds: []
                races: -> (v for k, v of races when k in @raceIds)


        for {id, nom} in districtsIn
            districts[id] = 
                id: id
                name: nom
                boroughId: 0
                borough: -> if id == 0  then null else boroughs[@boroughId]
                raceIds: []
                races: -> (v for k, v of races when k in @raceIds)

        for r in postes
            shortname = r.nom
                .replace(" - District électoral", "")
                .replace("de l'arrondissement", "")
                .replace("d'arrondissement", "d'arr.")
                .replace("de la ville", "de ville")
            races[r.id] = 
                id: r.id
                name: r.nom
                shortname: shortname
                type: r.type
                boroughId: r.arrondissement
                borough: -> boroughs[@boroughId]
                districtId: r.district
                district: -> districts[@districtId]
                candidates: []
                leadingParty: null
                leadingVotes: 0
                secondParty: null
                secondVotes: 0
                projetTopTwo: false
                marginPct: 0
                projetCandidate: ""
                participation: parseInt(r.taux_participation)
                stationsDone: parseInt(r.nb_bureaux_depouilles)
                stationsTotal: parseInt(r.nb_bureaux_total)

            boroughs[r.arrondissement].districtIds.push r.district
            boroughs[r.arrondissement].raceIds.push r.id
            districts[r.district].boroughId = r.arrondissement
            districts[r.district].raceIds.push r.id

            for c in r.candidats
                c.nb_voix_obtenues = parseInt c.nb_voix_obtenues
                c.nb_voix_majorite = parseInt c.nb_voix_majorite if c.nb_voix_majorite?
                races[r.id].candidates.push
                    party: c.parti
                    name: c.prenom+" "+c.nom
                    votes: c.nb_voix_obtenues
                    margin: c.nb_voix_majorite

                if c.parti is parseInt(PROJET)
                    races[r.id].projetCandidate = c.prenom+" "+c.nom
                if c.nb_voix_majorite?
                    races[r.id].leadingVotes = c.nb_voix_obtenues
                    races[r.id].leadingParty = c.parti
                else if c.nb_voix_obtenues > races[r.id].secondVotes
                    races[r.id].secondVotes = c.nb_voix_obtenues
                    races[r.id].secondParty = c.parti

            races[r.id].marginPct = (races[r.id].leadingVotes - races[r.id].secondVotes)/races[r.id].leadingVotes

            topTwo = [races[r.id].leadingParty, races[r.id].secondParty]
            if PROJET in topTwo or parseInt(PROJET) in topTwo
                races[r.id].projetTopTwo = true


        mayors = []
        for c in mairie.candidats
            mayors.push
                party: c.parti
                name: c.prenom+" "+c.nom
                votes: c.nb_voix_obtenues

        window.stats = 
            stationsDone: parseInt(mairie.nb_bureaux_depouilles)
            stationsTotal: parseInt(mairie.nb_bureaux_total)
            participation: parseInt(r.taux_participation)

        window.boroughs = boroughs
        window.districts = districts
        window.races = races
        window.mayors = mayors

        cb() if cb?






