func =
	loadMap: (name) ->
		playing = no
		loader = new Phaser.Loader @
		loader.tilemapTiledJSON "tilemap", "asset/map/#{name}.json"
		loader.start()

		new Promise (resolve) =>
			loader.onLoadComplete.add =>
				playing = yes
				map = @add.tilemap "tilemap", 16, 16
				map.addTilesetImage "map"
				ground = map.createLayer "ground"
				floor = map.createLayer "floor"
				wall = map.createLayer "wall"
				users = @add.group()
				ceil = map.createLayer "ceil"
				w_2 = @width / 2
				h_2 = @height / 2
				@world.setBounds w_2, h_2, map.widthInPixels + w_2, map.heightInPixels + h_2
				@camera.setBoundsToWorld()
				resolve()
				return
			return

	keyDown: ->
		unless me.isMoving
			switch key
				when "KeyS"
					me.setD 0
					me.moveBy y: 1

				when "KeyA"
					me.setD 1
					me.moveBy x: -1

				when "KeyW"
					me.setD 2
					me.moveBy y: -1

				when "KeyD"
					me.setD 3
					me.moveBy x: 1
		return

	setKey: (code) ->
		key = code
		return

	onKeyUp: ->
		key = undefined
		return
