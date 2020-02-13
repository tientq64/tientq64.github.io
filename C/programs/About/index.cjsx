class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

	render: ->
		<div className="p-3 select">
			<h1 className="text-center">ThwOS <small>1.0</small></h1>
			<HTMLTable bordered fill fixed small>
				<tbody>
					<tr>
						<td className="col-5">Tên</td>
						<td className="col-7">ThwOS</td>
					</tr>
					<tr>
						<td className="col-5">Phiên bản</td>
						<td className="col-7">1.0</td>
					</tr>
					<tr>
						<td className="col-5">Tác giả</td>
						<td className="col-7">TienCoffee</td>
					</tr>
				</tbody>
			</HTMLTable>
		</div>
