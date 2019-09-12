window.addEventListener "keydown", (event) =>
	func.setKey event.code
	return

window.addEventListener "keyup", func.onKeyUp
window.addEventListener "pointerup", func.onKeyUp
window.addEventListener "blur", func.onKeyUp
