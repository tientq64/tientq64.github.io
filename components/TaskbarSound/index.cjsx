class TaskbarSound extends React.Component
	render: ->
		<Popover
			inheritDarkTheme={no}
			position={Position.TOP}
		>
			<Tooltip
				content={"Âm lượng: #{Math.round app.state.system.sound.volume * 100}%"}
				openOnTargetFocus={no}
				position={Position.TOP}
			>
				<Button
					icon={app.systemSoundGetIconName()}
					minimal
				/>
			</Tooltip>
			<div className="bp3-padding">
				<Slider
					max={100}
					labelStepSize={25}
					vertical
					value={app.state.system.sound.volume * 100}
					onChange={(val) =>
						app.systemSoundSetVolume (val / 100).toFixed 2
						return
					}
				/>
			</div>
		</Popover>
