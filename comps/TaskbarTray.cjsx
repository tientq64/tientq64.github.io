class TaskbarTray extends Reactive
	constructor: (props) ->
		super props

		@actions = [
			icon: <i className="bp3-icon fa fa-wifi"/>
			text: "Wifi"
		,
			icon: <i className="bp3-icon fab fa-bluetooth"/>
			text: "Bluetooth"
		,
			icon: "cog"
			text: "Cài đặt"
		,
			icon: <i className="bp3-icon fa fa-map-marker-alt"/>
			text: "Vị trí"
		,
			icon: "flash"
			text: => "Độ sáng (#{app.getBrightness() * 100})"
			onClick: =>
				brightness = app.getBrightness()
				if brightness < .25
					brightness = .25
				else if brightness < .5
					brightness = .5
				else if brightness < .75
					brightness = .75
				else if brightness < 1
					brightness = 1
				else
					brightness = 0
				app.setBrightness brightness
				return
		,
			icon: <i className="bp3-icon fa fa-eye"/>
			text: "Làm dịu mắt"
			intent: =>
				app.getNightLight() and "primary" or "none"
			onClick: =>
				app.setNightLight()
				return
		,
			icon: <i className="bp3-icon fa fa-adjust"/>
			text: "Giao diện tối"
			intent: =>
				app.getDarkTheme() and "primary" or "none"
			onClick: =>
				app.setDarkTheme()
				return
		]

	handleChangeVolume: (val) ->
		app.setVolume val / 100
		return

	iconVolume: ->
		volume = app.getVolume()
		if volume is 0
			"volume-off"
		else if volume <= .5
			"volume-down"
		else
			"volume-up"

	iconBattery: ->
		battery = app.getBattery()
		"fa-battery-" +
		if battery is 0
			"empty"
		else if battery <= .25
			"quarter"
		else if battery <= .5
			"half"
		else if battery <= .75
			"three-quarters"
		else
			"full"

	render: ->
		volume = app.getVolume()
		<div className="nowrap">
			<Popover
				position="bottom"
				content={
					<div className="p-4">
						<Slider
							min={0}
							max={100}
							labelStepSize={25}
							vertical
							value={Math.round volume * 100}
							onChange={@handleChangeVolume}
						/>
					</div>
				}
			>
				<Tooltip
					position="bottom"
					content={"Âm lượng: " + volume * 100 + "%"}
				>
					<Button icon={@iconVolume()} minimal/>
				</Tooltip>
			</Popover>
			<Tooltip
				position="bottom"
				content={"Pin: " + app.getBattery() * 100 + "%"}
			>
				<Button
					icon={<i className={"bp3-icon fa " + @iconBattery()}/>}
					minimal
				/>
			</Tooltip>
			<Popover
				position="bottom"
				content={
					<div className="p-3">
						<DatePicker
							showActionsBar
							todayButtonText="Hôm nay"
							clearButtonText="Bỏ chọn"
							defaultValue={app.state.moment.toDate()}
						/>
					</div>
				}
			>
				<Popover
					isContextMenu
					position="bottom"
					content={
						<Menu>
							<MenuItem
								icon="calendar"
								text="Mở lịch"
								onClick={=> app.taskRun "C/programs/system/Calendar"}
							/>
						</Menu>
					}
				>
					<Tooltip
						position="bottom"
						content={_.upperFirst app.state.moment.format "LLLL:ss"}
					>
						<Button minimal text={app.state.moment.format "dd, L LT"}/>
					</Tooltip>
				</Popover>
			</Popover>
			<Popover
				position="bottom"
				content={
					<div className="p-4">
						<div className="taskbar-actions row">
							{@actions.map (action, i) =>
								<Button
									key={i}
									className="taskbar-action col-4 row vertical around nowrap"
									minimal
									intent={action.intent?()}
									icon={action.icon}
									text={action.text?() or action.text}
									onClick={action.onClick}
								/>
							}
						</div>
					</div>
				}
			>
				<Button icon="comment" minimal/>
			</Popover>
		</div>
