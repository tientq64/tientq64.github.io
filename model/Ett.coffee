class Ett extends Phaser.Sprite
	constructor: (data, key) ->
		super game, data.x * px, data.y * px, key

		@ctor = @constructor
		for k of data
			@data[k] = data[k]
