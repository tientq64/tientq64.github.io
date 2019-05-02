class extends Reactive
	constructor: (props) ->
		super props

		{pattern} = state.params

		@state =
			value: state.params.defaultValue

		@closeValue =
			alert: yes
			confirm: no
			prompt: undefined

	onSubmit: (event) ->
		event.preventDefault()
		state.resolve if state.params.popupType is "prompt" then @state.value else yes
		return

	componentDidMount: ->
		state.setCloseValue @closeValue[state.params.popupType]
		@refs.form.elements[0].select() if state.params.popupType is "prompt"
		return

	render: ->
		<form
			ref="form"
			className="p-3"
			onSubmit={@onSubmit}
		>
			<p>{state.params.message}</p>
			{if state.params.popupType is "prompt"
				if state.params.type is "number"
					<NumberInput
						autoFocus
						type="number"
						min={state.params.min}
						max={state.params.max}
						stepSize={state.params.stepSize}
						required={state.params.required}
						placeholder={state.params.placeholder}
						value={@state.value}
						onChange={(event) => @setState value: event.target.value}
					/>
				else
					<InputGroup
						autoFocus
						minLength={state.params.minLength}
						maxLength={state.params.maxLength}
						pattern={state.params.pattern?.source ? state.params.pattern}
						required={state.params.required}
						placeholder={state.params.placeholder}
						value={@state.value}
						onChange={(event) => @setState value: event.target.value}
					/>
			}
			<div className="bp3-dialog-footer-actions">
				<ButtonGroup>
					<Button
						text="OK"
						type="submit"
					/>
					{state.params.popupType isnt "alert" and
						<Button
							text="Hủy"
							onClick={=> state.close @closeValue[state.params.popupType]}
						/>
					}
				</ButtonGroup>
			</div>
		</form>
