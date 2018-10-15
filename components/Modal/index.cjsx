class Modal extends React.Component
	constructor: (props) ->
		super props

		@state =
			isOpen: yes
			apps:
				app:
					env:
						tasks: []
		@children = null
		@props.task.modal = @

	close: ->
		app.appsAppKill @props.task
		return

	render: ->
		Component = @props.children
		propsModal = Component.modal ? {}
		<div className="Modal">
			<Dialog
				backdropClassName={propsModal.backdropClassName}
				backdropProps={{hidden: yes, ...propsModal.backdropProps}}
				canEscapeKeyClose={propsModal.canEscapeKeyClose ? no}
				canOutsideClickClose={propsModal.canOutsideClickClose ? no}
				className={propsModal.className}
				icon={propsModal.icon}
				isCloseButtonShown={propsModal.isCloseButtonShown}
				isOpen={@state.isOpen}
				onClose={(event) => propsModal.onClose? event; @close()}
				style={propsModal.style}
				title={propsModal.title ? propsModal.name ? propsModal.path}
				usePortal={no}
			>
				<Component task={@props.task} {...@props.propsData}/>
			</Dialog>
			{@state.apps.app.env.tasks.map (task) => task.jsx}
		</div>
