class TaskbarBattery extends React.Component
	render: ->
		<Tooltip
			content={"Pin: #{Math.round app.state.system.battery.level * 100}%"}
			openOnTargetFocus={no}
			disabled={app.state.system.battery.level is undefined}
		>
			<Button
				icon={
					<Icons8
						icon={app.systemBatteryGetIcons8Name app.state.system.battery.level}
						color="bfccd6"
					/>
				}
				minimal
			/>
		</Tooltip>
