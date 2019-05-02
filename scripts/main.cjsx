ContextMenu.show = (menu, onClose, isDarkTheme = app.state.darkTheme) =>
	ContextMenu.show2 menu, left: app.mx, top: app.my, onClose, isDarkTheme

Toaster.toast = Toaster.create
	position: "bottom-right"
Toaster.show = (message, props) =>
	Toaster.toast.show {message, ...props}
Toaster.clear = =>
	Toaster.toast.clear()

window.ContextMenu = ContextMenu
window.Toaster = Toaster

window.app = ReactDOM.render <App/>, document.getElementById "app"
