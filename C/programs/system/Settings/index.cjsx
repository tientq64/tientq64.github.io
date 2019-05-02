class extends Reactive
	render: ->
		<div className="p-2">
			<Tabs vertical large>
				<Tab
					id={1}
					title="Hệ thống"
					panel={
						<div>ok</div>
					}
				/>
				<Tab
					id={2}
					title="Giao diện"
					panel={
						<div>:) asd</div>
					}
				/>
				<Tab
					id={3}
					title="Ứng dụng"
					panel={
						<div>:) asd</div>
					}
				/>
				<Tab
					id={4}
					title="Tài khoản"
					panel={
						<div>:) asd</div>
					}
				/>
				<Tab
					id={5}
					title="Bảo mật"
					panel={
						<div>:) asd</div>
					}
				/>
				<Tab
					id={6}
					title="Hỗ trợ truy cập"
					panel={
						<div>:) asd</div>
					}
				/>
			</Tabs>
		</div>
