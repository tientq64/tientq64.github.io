class User extends Ett
	constructor: (data, isMe) ->
		super data, "skin"

		@isMe = isMe
		@tween = null
		@isMoving = no

		@anchor.set .25, .5
		@animations.add "walk-0", [0, 1, 2, 1], 12, yes
		@animations.add "walk-1", [3, 4, 5, 4], 12, yes
		@animations.add "walk-2", [6, 7, 8, 7], 12, yes
		@animations.add "walk-3", [9, 10, 11, 10], 12, yes

		game.physics.arcade.enableBody @
		@body.setSize px, px, px / 2, px
		@body.allowGravity = no
		@body.friction.set 0

		@setFrame2()

	setFrame2: (d = @data.d) ->
		@frame = d * 3 + 1
		return

	updateDb: (data) ->
		meRef.update data if @isMe

	setD: (d = @data.d) ->
		if d isnt @data.d
			@data.d = d
			@setFrame2 d
			@updateDb {d}
		return

	moveBy: ({x = 0, y = 0}) ->
		@moveTo x: @data.x + x, y: @data.y + y
		return

	moveTo: ({x = @data.x, y = @data.y}) ->
		if x isnt @data.x or y isnt @data.y
			@data.x = x
			@data.y = y
			@isMoving = yes
			@animations.play "walk-#{@data.d}"
			@tween?.stop()
			@tween = game.add.tween @
				.to
					x: x * px
					y: y * px
					250
			@tween.onComplete.add =>
				@isMoving = no
				@animations.stop()
				@setFrame2()
				return
			@tween.start()
			@updateDb {x, y}
		return

	@w = 1
	@h = 1
