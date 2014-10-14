# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
	$('.date_picker').datepicker
    showOtherMonths: true,
    selectOtherMonths: true,
    changeYear: true,
    changeMonth: true,
    dateFormat: "mm/dd/yy",
    yearRange: '-80:+1'
    onChangeMonthYear: (year, month, inst) -> 
      selectedDate = $(this).datepicker("getDate")
      if(selectedDate == null)
        return
      selectedDate.setMonth month - 1 # 0-11
      selectedDate.setFullYear year
      $(this).datepicker "setDate", selectedDate

  $('.input-group-btn button').click ->
    $('.date_picker').datepicker("show")

  $("select").select2()

  $('.nav.nav-list .disabled a').removeAttr('href')

  update_delete_buttons()
  $('#setAuthorityLink').click ->
    $('#authorityIDModal').modal({})

  $('#save-authority-button').click ->
    $('#select_authority_id').submit()
