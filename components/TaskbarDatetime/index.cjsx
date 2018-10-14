class TaskbarDatetime extends React.Component
	constructor: (props) ->
		super props

		@state =
			moment: moment()
		@timeout = undefined

	componentDidMount: ->
		tick = =>
			app.set.call @, "moment", moment()
			@timeout = setTimer 60000, =>
				tick()
				return
			return
		setTimer (60 - @state.moment.second()) * 1000, =>
			tick()
			return
		return

	componentWillUnmount: ->
		clearTimeout @timeout
		return

	render: ->
		<Popover
			inheritDarkTheme={no}
			position={Position.TOP}
		>
			<Tooltip
				tooltipClassName="bp3-capitalize"
				content={@state.moment.format "dddd, DD MMMM YYYY"}
				openOnTargetFocus={no}
				position={Position.TOP}
			>
				<Button minimal>
					{@state.moment.format "HH:mm DD/MM/YYYY"}
				</Button>
			</Tooltip>
			<DatePicker
				showActionsBar
				defaultValue={@state.moment.toDate()}
			/>
		</Popover>
