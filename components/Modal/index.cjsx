class Modal extends React.Component
	constructor: (props) ->
		super props

		@state =
			isOpen: yes
			tasks: []
			dialogs: []
		@component = null

	close: (event) ->
		app.set.call @, "isOpen", no
		return

	onClosed: ->
		app.appsTaskKill @props.pid
		return

	taskRun: ->
		return

	componentWillMount: ->
		return

	render: ->
		<div>
			<Dialog
				backdropProps={{hidden: yes, ...@props.backdropProps}}
				canEscapeKeyClose={no}
				canOutsideClickClose={no}
				className={@props.className}
				enforceFocus={yes}
				icon={@props.icon}
				isCloseButtonShown={@props.isCloseButtonShown}
				isOpen={@state.isOpen}
				onClose={(event) => @props.onClose? event; @close()}
				onClosed={(el) => @props.onClosed? el; @onClosed()}
				onClosing={@props.onClosing}
				onOpened={@props.onOpened}
				onOpening={@props.onOpening}
				style={@props.style}
				title={@props.title ? @props.name}
				transitionDuration={@props.transitionDuration}
				transitionName={@props.transitionName}
				usePortal={no}
			>
				{if Component = @component or @props.children
					<Component app={@props.app} modal={@}/>
				else
					["body", "footer"].map (v) =>
						if @props[v]
							<div key={v} className="bp3-dialog-#{v}">
								{if typeof @props[v] is "function"
									@props[v] @
								else
									@props[v]
								}
							</div>
				}
			</Dialog>
			{@state.dialogs.map (dialog) => dialog}
		</div>
