define [
	'jquery'
	'underscore'
	'backbone'
], ($, _, Backbone) ->
	eventManager = new class EventManager
		triggerEvent: undefined
		startTrigger: (event, time) ->
			triggerEvent = setInterval =>
				@trigger event
			, time
		stopTrigger: ->
			clearInterval(triggerEvent)

	_.extend eventManager, Backbone.Events

	$(window).on 'online', ->
		eventManager.trigger 'online'
	$(window).on 'offline', ->
		eventManager.trigger 'offline'

	pendingList = [
		'metaready'
		'reccntrsready'
	]

	ready = (event) ->
		pendingList = _.reject pendingList, (pendingEvent) ->
			pendingEvent == event
		eventManager.trigger('appready') if pendingList.length == 0

	eventManager.on('metaready', ->
		ready('metaready')
	)

	eventManager.on('reccntrsready', ->
		ready('reccntrsready')
	)

	eventManager