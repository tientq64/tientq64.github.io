# import script/var
# import model/Ett
# import model/User
# import script/preload
# import script/create
# import script/update
# import script/render

game = new Phaser.Game
	width: 200
	height: 200
	renderer: Phaser.AUTO
	parent: "game"
	antialias: no
	scaleMode: Phaser.ScaleManager.SHOW_ALL
	crisp: yes
	alignH: yes
	alignV: yes
	enableDebug: yes
	roundPixels: yes
	state: {preload, create, update, render}
