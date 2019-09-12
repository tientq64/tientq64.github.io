create = ->
	await firebase.initializeApp
		apiKey: "AIzaSyBbWU8qaFxabXC-AddlqUBjhxDORc4T7eI"
		authDomain: "fakr-caeca.firebaseapp.com"
		databaseURL: "fakr-caeca.firebaseio.com"

	auth = firebase.auth()
	auth.languageCode = "vi"

	db = firebase.database()

	auth.onAuthStateChanged (user) =>
		unless user
			provider = new firebase.auth.GoogleAuthProvider
			{user} = await auth.signInWithPopup provider
		{uid} = user

		usersRef = db.ref "users"
		meRef = usersRef.child uid
		meRef.once "value", (snap) =>
			if snap.exists()
				meData = snap.val()
				meData.online = yes
			else
				meData =
					x: 4
					y: 2
					d: 0
					hair: 13
					face: 6
					coat: 40
					map: "h1"
					online: yes
				await meRef.update meData
			me = new User meData, yes
			await func.loadMap me.data.map
			users.add me
			@camera.follow me
			# import script/event
	return
