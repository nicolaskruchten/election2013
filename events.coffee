window.updateEvents = (id) ->
	return window.updateRandomRace(id) if window.events.length == 0

	event = window.events[window.eventPointer]
	window.eventPointer = (window.eventPointer+1)%window.events.length

	#display event!
	if event.type == "race"
		if event.event.evenement == "gagnant"
			verb = "prend les devants"
		else
			verb = "se fair dépasser"
		div = $("#"+id)
		h = div.height()
		w = div.width()
		vis = new pv.Panel().canvas(id).width(w).height(h)

		vis.anchor("top").add(pv.Label)
			.font("#{opts.titleSize}px sans-serif")
			.text(window.races[event.event.poste_id].shortname)

		vis.anchor("top").add(pv.Label)
			.top(30)
			.text(event.event.prenom+" "+event.event.nom+" "+verb)
			.font("#{opts.titleSize}px sans-serif")

		vis.add(pv.Panel).bottom(25).height(200).width(150)
			.add(pv.Image).url("imgs/solo/#{event.event.poste_id}.jpg?"+Math.random())
		vis.render()
	else 
		return window.updateRandomRace(id)
