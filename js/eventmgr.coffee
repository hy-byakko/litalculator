define [
	'underscore'
	'backbone'
], (_, Backbone) ->
	eventManager = new class EventManager

	_.extend eventManager, Backbone.Events

	$(window).on 'online', ->
		eventManager.trigger 'online'
	$(window).on 'offline', ->
		eventManager.trigger 'offline'

	eventManager