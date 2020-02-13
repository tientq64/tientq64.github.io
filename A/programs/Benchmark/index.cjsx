await task.import [
	"https://cdn.jsdelivr.net/npm/platform"
	"https://cdn.jsdelivr.net/npm/benchmark"
]

class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@suite = null
		@snippets = []
		@running = no

	addSnippet: ->
		((snippet) =>
			snippet =
				id: _.uniqueId()
				name: ""
				fn: ""
				onCycle: (event) =>
					snippet.target = event.target
					@setState {}
					return
			@snippets.push snippet
			@setState {}
		)()
		return

	runBenchmark: ->
		if @running
			@suite.abort()
		else
			@suite = new Benchmark.Suite
				onComplete: =>
					@running = no
					snippets = _.reject @snippets, (v) => not v.target or v.target.error or v.target.aborted
					if snippets.length > 1
						snippetFastest = _.maxBy snippets, "target.stats.sample.length"
						snippetLowest = _.minBy snippets, "target.stats.sample.length"
						unless snippetFastest is snippetLowest
							snippetFastest.perf = "fastest"
							snippetLowest.perf = "lowest"
					@setState {}
					return
			for snippet from @snippets
				delete snippet.target
				delete snippet.perf
				@suite.add snippet
			@suite.run async: yes, queued: yes
		@running = not @running
		@setState {}
		return

	componentDidMount: ->
		@addSnippet()
		@addSnippet()
		return

	render: ->
		<div className="column full">
			<div className="col scroll p-3">
				{@snippets.map (snippet, i) =>
					<div className="row" key={snippet.id}>
						<div className="row col-9">
							<div className="col-12 row between middle mt-3 mb-2">
								<b>Khối mã {i + 1}</b>
								<Button
									small
									minimal
									disabled={@running}
									icon="cross"
									onClick={=>
										if @snippets.length > 1
											_.pull @snippets, snippet
											@setState {}
										return
									}
								/>
							</div>
							<div className="col-3">Tên:</div>
							<div className="col-9">
								<InputGroup
									className="mb-2"
									readOnly={@running}
									value={snippet.name}
									onChange={(event) =>
										snippet.name = event.target.value
										@setState {}
										return
									}
								/>
							</div>
							<div className="col-3">Mã:</div>
							<div className="col-9">
								<TextArea
									fill
									rows={3}
									readOnly={@running}
									value={snippet.fn}
									onChange={(event) =>
										snippet.fn = event.target.value
										@setState {}
										return
									}
								/>
							</div>
						</div>
						<div className="col-3 row center middle pl-3">
							{if snippet.target
								if snippet.target.error
									<span className="text-red1">Lỗi: {snippet.target.error.message + ""}</span>
								else if snippet.target.aborted
									<span className="text-gold3">Đã hủy</span>
								else
									<div className={(fastest: "text-green3", lowest: "text-red3")[snippet.perf]}>
										{Benchmark.formatNumber Math.round snippet.target.hz} ops/sec
										<br/>
										&plusmn; {snippet.target.stats.rme.toFixed 2}%
										<br/>
										{snippet.target.stats.sample.length} runs sampled
									</div>
							else
								<span className="text-gray3">Chưa có kết quả</span>
							}
						</div>
					</div>
				}
				<div className="mt-3 mb-2"><b>Mã khởi tạo</b></div>
				<TextArea rows={3} fill/>
			</div>
			<div className="px-3 pb-3 text-right">
				<div className="border-top pb-3"></div>
				<Button
					disabled={@running}
					icon="plus"
					text="Thêm khối mã"
					onClick={=> @addSnippet()}
				/>
				<Button
					className="ml-2"
					disabled={@snippets.length < 2}
					intent={"primary" unless @running}
					icon={@running and "stop" or "play"}
					text={@running and "Dừng" or "Chạy"}
					onClick={=> @runBenchmark()}
				/>
			</div>
		</div>
