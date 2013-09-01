define [
	'jquery'
	'underscore'
	'backbone'
	'models/record'
	'collections/records'
	'views/record'
], ($, _, Backbone, Record, Records, RecordView) ->
	'use strict'

	Backbone.View.extend
		el: '#app'

		events: 
			'click #add-record': 'addRecord'

		initialize: ->
			@$recordsView = @$('records')

			@records = new Records

		render: ->
			@

		# Render new record will not rerender list
		addRecord: ->
			recordView = new RecordView model: new Record
			@$recordsView.append recordView.render().el

		addAll: ->
