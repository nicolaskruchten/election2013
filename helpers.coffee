
window.opts = 
    titleSize: 20
    footerSize: 15
    nameSize: 125
    rightGutter: 20

window.maxVal = (objArray, key) -> pv.max( (obj[key] for obj in objArray) )
window.sumVal = (objArray, key) -> pv.sum( (obj[key] for obj in objArray) )

window.percentString = (numElem, denomElem, key) -> 
    num = numElem[key]
    denom = window.sumVal(denomElem, key)
    return "0.0%" if denom == 0 
    (100*num/denom).toFixed(1)+"%"

PROJET = "9"

window.parties =
    9: 
        name: "Projet Montréal"
        leader: "Richard BERGERON"
        color: "#78BE20"
    5: 
        name: "Équipe Denis Coderre"
        leader: "Denis CODERRE"
        color: "#662d91"
    4: 
        name: "Groupe Mélanie Joly"
        leader: "Mélanie JOLY"
        color: "#fdb813"
    3: 
        name: "Coalition Montréal"
        leader: "Marcel CÔTÉ"
        color: "#0098ce"
    0: 
        name: "Autre"
        leader: "Autre"
        color: "#aaaaaa"

window.groupedParty = (x) -> if x not of parties then 0 else x

window.partyName = (x) -> parties[window.groupedParty(x)].name
window.partyColor = (x) -> parties[window.groupedParty(x)].color
window.partyLeader = (x) -> parties[window.groupedParty(x)].leader

window.partySort = (key) -> (a,b) ->
    return -1111111111 if a.party == PROJET
    return 1111111111 if b.party == PROJET
    return b[key]-a[key]

window.racesWithin = (margin) -> (v for k,v of window.races when v.marginPct < margin and v.projetTopTwo)
window.racesAbove = (margin) -> (v for k,v of window.races when v.marginPct > margin and v.leadingParty is parseInt(PROJET))

window.refreshData = (cb) ->
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
            races[r.id] = 
                id: r.id
                name: r.nom
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
        for {parti, nb_voix_obtenues} in mairie.candidats
            mayors.push
                party: parti
                name: c.prenom+" "+c.nom
                votes: parseInt c.nb_voix_obtenues

        window.boroughs = boroughs
        window.districts = districts
        window.races = races
        window.mayors = mayors

        cb()






