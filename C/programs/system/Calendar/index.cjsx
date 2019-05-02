class extends Reactive
	render: ->
		<div>
			<DatePicker
				defaultValue={app.state.moment.toDate()}
			/>
		</div>
