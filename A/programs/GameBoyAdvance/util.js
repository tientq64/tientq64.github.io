Object.defineProperty(Object.prototype, "inherit", {
	value() {
		for (var v in this) {
			this[v] = this[v];
		}
	}
});
