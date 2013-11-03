define [
	'jquery'
	'underscore'
	'backbone'
	'models/record'
	'models/recordcontainer'
	'collections/recordcontainers'
	'views/record'
	'common'
	'eventmgr'
], ($, _, Backbone, Record, RecordContainer, RecordContainers, RecordView, Common, eventManager) ->
	'use strict'

	Backbone.View.extend
		el: '#app'

		events:
			'click #add-record': 'addRecord'

		initialize: ->
			@$recordsView = @$('#records')
			@$recordsBody = @$recordsView.find('tbody')

			@$resultBody = @$('#result ul.list-group')

			@recordContainers = new RecordContainers
			@records = @recordContainers.records

			calculateWarp = _.debounce(@calculateRender, 5, false)

			@recordContainers.fetch().done ->
				eventManager.trigger('reccntrsready')

			@listenTo @records, 'add', @renderOne
			@listenTo @records, 'all', calculateWarp
			@listenTo @records, 'reset', @render

		render: ->
			do @$recordsBody.empty
			@records.chain()
			.each (record) =>
				@renderOne (record)
			.value()
			@

		getCategorySelect: ->
			return @$categorySelect if @$categorySelect
			@$categorySelect = $(@selectBuilder data: Common.getCategories())

		getWorkerSelect: ->
			return @$workerSelect if @$workerSelect
			@$workerSelect = $(@selectBuilder data: Common.getWorkers())

		resultTemplate: _.template '
<% _.each(result, function(worker) { %>
<li class="list-group-item">
    <h4 class="list-group-item-heading"><%= worker.name %> ( <% _.each(worker.counts, function(count) { %><%= count.name %>: <%= count.num %> <% }); %> ) </h4>
    <% _.each(worker.sub, function(category) { %>
    <p class="list-group-item-text"><%= category.name %> ( <% _.each(category.sub, function(detail) { %><%= detail.name %>: <%= detail.num %> <% }); %> ) </p>
    <% }); %>
</li>
<% }); %>', undefined, variable: 'result'

		calculateRender: ->
			@$resultBody.html $ @resultTemplate @calculate()

		calculate: ->
			records = @records.filter (record) ->
				record.isValid()

			groupedRecords = _.groupBy records, (record) ->
				record.get('worker')

			groupedRecords["总计"] = records if records.length > 0
			_.chain(groupedRecords).map (records, worker) ->
				_.object [
					'name'
					'sub'
					'counts'
				], [
					if _.isNaN(parseInt(worker)) then worker else Common.getWorker(parseInt(worker)).text
					_.chain(records)
					.groupBy (record) ->
						record.get('category')
					.map (records, category) ->
						_.object [
							'name'
							'sub'
						], [
							Common.getCategory(parseInt(category)).text
							_.chain(records)
							.groupBy (record) ->
								record.get('detail')
							.map (records, detail) ->
								_.object [
									'name'
									'num'
								], [
									Common.getDetail(parseInt(category), parseInt(detail)).text
									_.reduce records, (memo, record) ->
										memo + record.getNum()
									, 0
								]
							.value()
						]
					.value()
					[]
				]
			.map (worker) ->
				_.reduce worker.sub, (counts, category) ->
					counts.push _.object [
						'name'
						'num'
					], [
						category.name
						_.reduce category.sub, (count, detail) ->
							count + detail.num
						, 0
					]
					counts
				, worker.counts
				worker
			.value()

		# Render new record will not rerender list
		addRecord: ->
			@records.add new Record

		renderOne: (instance) ->
			recordView = new RecordView model: instance, parent: @
			@$recordsBody.append recordView.render().el

		selectTemplate: _.template "
<select class='form-control fit-table'>
	<% _.each(options.data, function(item) { %>
	<option value=<%= item.value %>><%= item.text %></option>
	<% }); %>
</select>", undefined, variable: 'options'

		selectBuilder: (options = {}) ->
			@selectTemplate options

		detailSelectBuilder: (categoryValue) ->
			details = Common.getDetails(categoryValue)
			if details then $(@selectBuilder data: details) else undefined

		numberTemplate: _.template '
<input type="text" class="form-control fit-table strict-width" autocomplete="off">
', undefined, variable: 'options'

		numberBuilder: (options = {}) ->
			$(@numberTemplate options)