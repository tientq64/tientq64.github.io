class Pantap
	constructor: (@el, @opts) ->
		@lastX = 0
		@lastY = 0
		@moveX = 0
		@moveY = 0
		@startX = 0
		@startY = 0
		@target = null
		@button = 0
		@container = @opts.container or document.body
		@panState = 0
		@onPanInit = @onPanInit.bind @
		@onPanMove = @onPanMove.bind @
		@onPanEnd = @onPanEnd.bind @

		@el.addEventListener "mousedown", @onPanInit
		window.addEventListener "mousemove", @onPanMove
		window.addEventListener "mouseup", @onPanEnd
		window.addEventListener "blur", @onPanEnd

	onPanInit: (event) ->
		if event.button in [0, 2]
			@lastX = event.clientX
			@lastY = event.clientY
			@target = event.target
			@button = event.button
			@panState = 1
		return

	onPanMove: (event) ->
		if @panState
			if @button is 0
				@moveX = event.clientX - @lastX
				@moveY = event.clientY - @lastY
				switch @panState
					when 1
						{x, y} = @container.getBoundingClientRect()
						@panState = 2
						document.body.dataset.pantapPan = yes
						@opts.panStart? @lastX - x, @lastY - y,
							target: @target
							sx: @lastX
							sy: @lastY
							offsetX: x
							offsetY: y
							button: @button
							el: @el
							event: event
						@startX = @moveX
						@startY = @moveY
					when 2
						@opts.panMove @moveX + @startX, @moveY + @startY
						@panState = 3
					else
						@opts.panMove @moveX, @moveY
				@lastX = event.clientX
				@lastY = event.clientY
		return

	onPanEnd: (event) ->
		switch @panState
			when 3, 2
				if @button is 0
					{x, y} = @container.getBoundingClientRect()
					@panState = 0
					delete document.body.dataset.pantapPan
					@opts.panEnd? @lastX - x, @lastY - y,
						target: @target
						sx: @lastX
						sy: @lastY
						offsetX: x
						offsetY: y
						button: @button
						el: @el
						event: event
			when 1
				if @button is 0 or @button is 2 and @opts.tapRightButton
					@panState = 0
					@opts.tap?(
						target: @target
						el: @el
						event: event
					)
		return

	destroy: ->
		@el.removeEventListener "mousedown", @onPanInit
		window.removeEventListener "mousemove", @onPanMove
		window.removeEventListener "mouseup", @onPanEnd
		window.removeEventListener "blur", @onPanEnd
		return
