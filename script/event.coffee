window.addEventListener "keydown", (event) =>
	func.setKey event.code
	return

window.addEventListener "keyup", func.onKeyUp
window.addEventListener "touchup", func.onKeyUp
window.addEventListener "touchmove", func.onKeyUp
window.addEventListener "blur", func.onKeyUp
