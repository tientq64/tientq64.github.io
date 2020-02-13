class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		{message} = task.params
		message = @filterHTML message if task.params.isSafeHtml
		value = task.params.inputProps.value
		if task.params.options.length
			options = task.params.options.map (option) =>
				if _.isPlainObject option then option else label: option, value: option
			unless _.some options, {value}
				value = options[0].value

		@value = value
		@message = message
		@options = options
		@errorText = ""
		@inputEl = null

	filterHTML: (html) ->
		div = document.createElement "div"
		div.innerHTML = html
		for el from div.querySelectorAll "*"
			if ///^(
				b|strong|i|em|s|del|strike|u|ins|mark|
				code|kbd|samp|var|dfn|tt|abbr|acronym|cite|bdi|bdo|small|sub|sup|ruby|rt|rp|center|
				div|span|p|ul|ol|li|dl|dt|dd|q|blockquote|pre|br|hr|wbr
			)$///i.test el.tagName
				for attr from el.attributes
					unless /^(class|style)$/.test attr.name
						el.removeAttributeNode attr
			else el.remove()
		div.innerHTML

	styleButtons: ->
		gridTemplateColumns: "repeat(#{task.params.cols}, 1fr)"

	onChangeInputGroup: (event) ->
		@value = event.target.value
		if @errorText
			@errorText = ""
			task.setSizeWinFitContent()
		@setState {}
		return

	onValueChangeNumericInput: (num, str) ->
		@value = str
		if @errorText
			@errorText = ""
			task.setSizeWinFitContent()
		@setState {}
		return

	onChangeSelect: (event) ->
		@value = event.target.value
		@setState {}
		return

	onSubmitForm: (event) ->
		event.preventDefault()
		switch task.params.kind
			when "prompt"
				val = @value
				val and= +val if task.params.inputProps.type is "number"
				if task.params.inputProps.validate
					if validate = ap["validate" + _.upperFirst task.params.inputProps.validate]
						val = validate val
						if _.isError val
							@errorText = val.message
							task.setSizeWinFitContent()
							@inputEl.focus()
							@setState {}
							return
				task.close val
			when "select"
				task.close @value
			else
				task.close yes

	onClickCancelBtn: (event) ->
		task.close {alert: yes, confirm: no, prompt: null, select: null}[task.params.kind]
		return

	componentDidMount: ->
		tsk.win.setTitle "Popup #{_.upperFirst task.params.kind}"
		return

	render: ->
		<form className="p-3" onSubmit={@onSubmitForm}>
			<p
				className="bp3-running-text scroll -mt-1 -mx-1 p-1"
				style={maxHeight: 320}
			>
				{if task.params.isSafeHtml
					<div dangerouslySetInnerHTML={__html: @message}/>
				else @message
				}
			</p>
			{switch task.params.kind
				when "prompt", "select"
					<FormGroup
						className="m-0 mb-3"
						helperText={
							<p className="text-red3">{@errorText}</p>
						}
					>
						{
							if task.params.kind is "select"
								<HTMLSelect
									fill
									autoFocus
									required={task.params.inputProps.required}
									options={@options}
									value={@value}
									onChange={@onChangeSelect}
								/>
							else if task.params.inputProps.type is "number"
								<NumericInput
									fill
									autoFocus
									type="number"
									max={task.params.inputProps.max}
									min={task.params.inputProps.min}
									step={task.params.inputProps.step}
									stepSize={task.params.inputProps.step}
									majorStepSize={task.params.inputProps.step*10}
									minorStepSize={task.params.inputProps.step/10}
									required={task.params.inputProps.required}
									inputRef={(@inputEl) =>}
									value={@value}
									onValueChange={@onValueChangeNumericInput}
								/>
							else
								<InputGroup
									autoFocus
									type={task.params.inputProps.type}
									maxLength={task.params.inputProps.maxLength ? task.params.inputProps.max}
									minLength={task.params.inputProps.minLength ? task.params.inputProps.min}
									pattern={task.params.inputProps.pattern}
									required={task.params.inputProps.required}
									inputRef={(@inputEl) =>}
									value={@value}
									onChange={@onChangeInputGroup}
								/>
						}
					</FormGroup>
				when "buttons"
					<div className="Popup__buttons" style={@styleButtons()}>
						{@options.map (option) =>
							<Button
								fill
								text={option.label}
								onClick={=>
									task.close option.value
									return
								}
							/>
						}
					</div>
			}
			{unless task.params.kind in ["buttons"]
				<div className="text-right">
					<ButtonGroup>
						<Button
							style={width: 80}
							text="OK"
							type="submit"
						/>
						{unless task.params.kind is "alert"
							<Button
								style={width: 80}
								text="Hủy"
								onClick={@onClickCancelBtn}
							/>
						}
					</ButtonGroup>
				</div>
			}
		</form>

	@defaultParams =
		kind: "alert"
		options: []
		inputProps:
			type: "text"
			step: 1
			value: ""
		isSafeHtml: no
