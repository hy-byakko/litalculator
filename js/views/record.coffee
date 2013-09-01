define [
	'jquery'
	'underscore'
	'backbone'
	'models/record'
], ($, _, Backbone, Record) ->
	'use strict';

	Backbone.View.extend
		tagName:  'tr'

		indexBarTemplate: _.template "
<td><%= catgroyName() || '-' %></td>
<td><%= name || '-'  %></td>
<td><%= worker || '-'  %></td>
<td><%= num || '-' %> <%= catgroy == 1 ? '桶' : '元' %></td>"

		render: ->
			@