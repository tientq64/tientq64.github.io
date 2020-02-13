class App extends React.Component
	constructor: (props) ->
		super props
		autoBind @

		@findWords = []
		@randWord = ""
		@time = 0
		@prob = 0
		@probPerc = 0
		@count = 0
		@startTime = 0
		@maxLengthWord = 0
		@chars = "abcdefghijklmnopqrstuvwxyz"

	setFindWords: (words) ->
		@maxLengthWord = _.maxBy(words, "length").length
		@findWords = words
		@prob = @chars.length ** @maxLengthWord
		@probPerc = _.round 1 / @prob * 100, 4
		@count = 0
		@startTime = Date.now()
		@randomWord()
		@setState {}
		return

	randomWord: ->
		@randWord = _.times(@maxLengthWord, => _.sample @chars).join("")
		@time = (Date.now() - @startTime) // 1000
		@count++
		@setState {}
		requestAnimationFrame @randomWord unless @findWords.includes @randWord
		return

	componentDidMount: ->
		@setFindWords ["love"]
		return

	render: ->
		<div className="column full middle text-center p-3">
			<div className="col-0">
				<h2>Cứ ngồi im đợi, tình yêu sẽ tới &#128522;</h2>
				<p>Xác suất mỗi từ: 1/{@prob} ({@probPerc}%)</p>
			</div>
			<div className="col column center middle">
				<b className="text-rose3">{@findWords.join(", ")}</b>
				<h1>{@randWord}</h1>
				<p>{@count} | {_.round @count / @prob * 100, 2}%</p>
				<span>{@time} giây</span>
			</div>
			<div className="col-">Ngẫu nhiên cho đến khi từ "love" xuất hiện</div>
		</div>
