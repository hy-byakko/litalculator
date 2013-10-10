define [
	'Dropbox'
	'eventmgr'
], (Dropbox, eventManager) ->
	client = new Dropbox.Client key: 't35la3qyv5bvtry'
	client.authDriver new Dropbox.AuthDriver.Popup
	    receiverUrl: "http://localhost:4000/dropbox-oauth-receiver.html"
	    rememberUser: true

	client.authenticate
		interactive: false
	, (error) ->
        alert('Authentication error: ' + error) if error

	if client.isAuthenticated()
		console.log 'b'
		eventManager.trigger('remotesync')
		datastoreManager = do client.getDatastoreManager
		datastoreManager.openDefaultDatastore (error, datastore) ->
			console.log('Error opening default datastore: ' + error) if error
			taskTable = datastore.getTable('metaData')
			results = taskTable.get '1'

	class DropboxProvider
		@client: client
		@datastoreManager = datastoreManager