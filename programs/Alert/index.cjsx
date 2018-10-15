class Alert extends React.Component
	render: ->
		<div>
			<div className="bp3-dialog-body">
				{@props.message}
			</div>
			<div className="bp3-dialog-footer">
				<div className="bp3-dialog-footer-actions">
					<Button
						text="Cancel"
						onClick={@props.onCancel}
					/>
					<Button
						text="OK"
						intent="primary"
						onClick={=>
							if @props.onConfirm?() isnt no
								@props.task.modal.close()
							return
						}
					/>
				</div>
			</div>
		</div>

	@modal =
		title: "Thông báo"
		style:
			width: 345
