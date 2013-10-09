define [
	'jquery'
	'underscore'
	'backbone'
	'common'
], ($, _, Backbone, Common) ->
	'use strict'

	Backbone.View.extend
		tagName:  'tr'

		events:
			'click td.editable': 'switchToEdit'
			'change select': 'editEnd'
			'blur select': 'editEnd'
			'blur [data-prop="num"] input': 'numEdit'
			'click button.close': 'removeRecord'

		initialize: ->
			@listenTo @model, 'sync', @render
			@listenTo @model, 'destroy', @remove

		indexBarTemplate: _.template '
<td class="editable" data-prop="category"><%= model.categoryName() || "-" %></td>
<td <% if(model.detailEditable()) { %>class="editable"<% } %> data-prop="detail"><%= model.detailName() || "-"  %></td>
<td class="editable" data-prop="worker"><%= model.workerName() || "-"  %></td>
<td class="editable" data-prop="num"><%= model.get("num") || "-" %> <%= model.get("category") == 1 ? "张" : "元" %></td>
<td><button type="button" class="close">&times;</button></td>
', undefined, variable: 'model'

		render: ->
			@$el.html @indexBarTemplate @model
			@

		# TODO Make select expended after click
		# Add delete link
		switchToEdit: ->
			parent = @options.parent
			$element = $(arguments[0].target)
			switch $element.data "prop"
				when "category"
					$element.addClass('editor-wrap').empty().append(parent.getCategorySelect())
					do parent.getCategorySelect().val(@model.get('category')).focus
				when "detail"
					detailSelect = parent.detailSelectBuilder(@model.get('category'))
					return unless detailSelect
					$element.addClass('editor-wrap').empty().append(detailSelect)
					do detailSelect.val(@model.get('detail')).focus
				when "worker"
					$element.addClass('editor-wrap').empty().append(parent.getWorkerSelect())
					do parent.getWorkerSelect().val(@model.get('worker')).focus
				when "num"
					numInput = parent.numberBuilder(unit: if @model.get('category') == 1 then '桶' else '元')
					$element.addClass('editor-wrap').empty().append(numInput)
					do numInput.val(@model.get('num')).focus

		editEnd: ->
			$element = $(arguments[0].target)
			$wrap = $element.parent('td')
			newValue = if _.isNaN parseInt($element.val()) then undefined else parseInt($element.val())
			@model.set $wrap.data("prop"), newValue
			# Do not clean, just rerender it.
			@model.collection.trigger('write')

		numEdit: ->
			$element = $(arguments[0].target)
			$wrap = $element.parent('td')
			return if $wrap.data("prop") != 'num'
			@model.setNum $element.val()
			@model.collection.trigger('write')

		removeRecord: ->
			collection = @model.collection
			collection.remove(@model)
			collection.trigger('write')
