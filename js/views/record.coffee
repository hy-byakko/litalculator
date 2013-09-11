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
			'click td': 'switchToEdit'
			'mouseup select': 'editEnd'
			'blur select': 'cleanEditor'
			'blur input': 'editEnd'

		indexBarTemplate: _.template "
<td data-prop='category'><%= model.categoryName() || '-' %></td>
<td data-prop='detail'><%= model.detailName() || '-'  %></td>
<td data-prop='worker'><%= model.workerName() || '-'  %></td>
<td data-prop='num'><%= model.get('num') || '-' %> <%= model.get('category') == 1 ? '张' : '元' %></td>", undefined, variable: 'model'

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
					$element.addClass('editor-wrap').empty().append(parent.$categorySelect)
					do parent.$categorySelect.val(@model.get('category')).focus
				when "detail"
					detailSelect = parent.detailSelectBuilder(@model.get('category'))
					return unless detailSelect
					$element.addClass('editor-wrap').empty().append(detailSelect)
					do detailSelect.val(@model.get('detail')).focus
				when "worker"
					$element.addClass('editor-wrap').empty().append(parent.$workerSelect)
					do parent.$workerSelect.val(@model.get('worker')).focus
				when "num"
					numInput = parent.numberBuilder(unit: if @model.get('category') == 1 then '桶' else '元')
					$element.addClass('editor-wrap').empty().append(numInput)
					do numInput.val(@model.get('num')).focus

		editEnd: ->
			$element = $(arguments[0].target)
			$wrap = $element.parent('td')
			newValue = if _.isNaN parseInt($element.val()) then undefined else parseInt($element.val())
			@model.set $wrap.data("prop"), newValue
			do @model.save
			@cleanEditor.call @, arguments

		cleanEditor: ->
			$element = $(arguments[0].target)
			$wrap = $element.parent('td').removeClass('editor-wrap')
			do @render
