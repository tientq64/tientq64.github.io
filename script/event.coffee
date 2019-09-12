window.addEventListener "keydown", (event) =>
	func.setKey event.code
	return

window.addEventListener "keyup", func.onKeyUp
window.addEventListener "mouseup", func.onKeyUp
window.addEventListener "blur", func.onKeyUp
