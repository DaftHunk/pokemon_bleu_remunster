_Route1ViridianMartSampleText::
	text "Salut! Je"
	line "travaille à la"
	cont "Boutique #mon."

	para "Nous avons plein"
	line "d'articles! Viens"
	cont "nous voir à"
	cont "Jadielle."

	para "Prends donc"
	line "ceci comme"
	cont "échantillon!"
	prompt

_Route1Text_1cae8::
	text "<PLAYER> obtient:"
	line "@"
	text_ram wStringBuffer
	text "!@"
	text_end

_Route1Text_1caee::
	text "Nous avons aussi"
	line "des # Ball"
	cont "pour capturer les"
	cont "#mon!"
	done

_Route1Text_1caf3::
	text "Ton inventaire"
	line "est plein!"
	done

_Route1Text2::
	text "Tu vois ces"
	line "rebords le long"
	cont "de la route?"

	para "Tu peux sauter"
	line "par-dessus! C'est"
	cont "dingue, non?"

	para "Tu peux revenir"
	line "plus vite à"
	cont "Bourg Palette de"
	cont "cette façon!"
	done

_Route1Text3::
	text "Route 1"
	line "Bourg Palette -"
	cont "Jadielle"
	done
