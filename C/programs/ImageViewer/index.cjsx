class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@imgSrc = ""

	componentDidMount: ->
		if entry = task.env.entries[0]
			@imgSrc = await ap.readFileObj entry.file, "DataURL"
			@setState {}
		return

	render: ->
		<div className="full scroll">
			{if @imgSrc
				<img src={@imgSrc}/>
			}
		</div>
