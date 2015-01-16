#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require turbolinks
#= require jquery.sparkline
#

ready = ->
  for sparkline in $('.sparkline')
    sparkline = $(sparkline)
    sparkline.sparkline sparkline.data('commits').split(','), type: 'line'

$(document).ready ready
$(document).on 'page:load', ready
