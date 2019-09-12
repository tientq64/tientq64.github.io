preload = ->
	# import script/func
	# import script/app

	func[k] = func[k].bind @ for k of func

	@load.path = "asset/"
	@load.image "map", "map/map.png"
	@load.spritesheet "skin", "user/skin.png", 32, 32
	return
