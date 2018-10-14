class TaskbarAction extends React.Component
	constructor: (props) ->
		super props

		@state =
			grid: [{
				label: "Wifi"
				icon: <Icons8 icon="wifi"/>
			}, {
				label: "Bluetooth"
				icon: <Icons8 icon="bluetooth"/>
			}, {
				label: "Cài đặt"
				icon: "cog"
			}, {
				label: "Định vị"
				icon: <Icons8 icon="place-marker"/>
			}, {
				label: "Độ sáng"
				icon: "flash"
			}, {
				label: "Làm dịu mắt"
				icon: <Icons8 icon="eye"/>
			}, {
				label: "Không làm phiền"
				icon: "moon"
			}, {
				label: "Chế độ máy bay"
				icon: "airplane"
			}]

	render: ->
		<Popover
			inheritDarkTheme={no}
			position={Position.TOP}
		>
			<Button minimal icon="menu"/>
			<div className="bp3-padding">
				<ButtonGroup
					className="TaskbarAction-grid"
					minimal
				>
					{@state.grid.map (item, i) ->
						<Button key={i} icon={item.icon}>{item.label}</Button>
					}
				</ButtonGroup>
			</div>
		</Popover>
