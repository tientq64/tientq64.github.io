class extends Reactive
	constructor: (props) ->
		super props

		@state =
			path: ""

	onChangePath: ->
		if path = await app.pickPath "dir"
			@setState {path}
		return

	componentDidMount: ->
		@setState
			path: state.params.path
		return

	render: ->
		<form className="p-3" onSubmit={@onSubmit}>
			<FormGroup>
				<InputGroup
					value={@state.path}
					onClick={@onChangePath}
				/>
			</FormGroup>
		</form>
