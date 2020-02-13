class TaskbarHome extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@applsQuery = ""
		@applsItems = []
		@applsIndex = 0
		@applsEl = null

	resetAppls: ->
		@applsQuery = ""
		@applsItems = []
		@setState {}
		return

	handleClickApplsItem: (item) ->
		app.runTask item.obj.path + "/app.yml"
		@resetAppls()
		return

	onChangeAppls: (event) ->
		{value} = event.target
		@applsQuery = value
		@applsItems = fuzzysort.go value, Object.values(app.appls), key: "name"
		@applsIndex = 0
		@setState {}
		return

	onKeyDownAppls: (event) ->
		switch event.key
			when "ArrowDown", "ArrowUp"
				event.preventDefault()
				@applsIndex = (@applsIndex + (event.key is "ArrowDown" and 1 or -1)) %% @applsItems.length
				@setState {}, =>
					@applsEl.children[@applsIndex].scrollIntoView
						behavior: "smooth"
						block: "nearest"
					return
			when "Enter"
				document.querySelectorAll(".TaskbarHome__applsItem")[@applsIndex].click()
		return

	render: ->
		<Popover
			minimal
			position="top"
			onClosed={=> @resetAppls()}
			content={
				<div className="column p-3" style={width: 260, maxHeight: "50vh"}>
					<h1 className="pl-3">ThwOS <small>1.0</small></h1>
					{if @applsItems.length
						<Menu className="col scroll p-0 mb-3" ulRef={(@applsEl) =>}>
							{@applsItems.map (item, i) =>
								<MenuItem
									key={i}
									className="TaskbarHome__applsItem"
									active={@applsIndex is i}
									icon={item.obj.icon}
									text={
										<span dangerouslySetInnerHTML={__html: fuzzysort.highlight item, "<b>", "</b>"}/>
									}
									onClick={=> @handleClickApplsItem item}
								/>
							}
						</Menu>
					}
					<InputGroup
						autoFocus
						value={@applsQuery}
						onChange={@onChangeAppls}
						onKeyDown={@onKeyDownAppls}
					/>
				</div>
			}
		>
			<Button id="TaskbarHome__btn" minimal icon="key-command"/>
		</Popover>
