$(document).ready(function() {
  $('#Plans').prop('disabled', true);
  $('#Carriers').change(function(e) {
    $('#Plans').prop('disabled', false);
    $( "option[value|='']" ).remove();
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
    var id = $(e.target).val();
    $.getJSON('/carriers/'+id+'/show_plans', function(data) {
      $('#Plans').empty();
      $.each(data, function(key, value) {
        $('#Plans').append($('<option/>').attr("value", value._id).text(value.name).append(" : "+value.hios_plan_id));
      });
      if($('#Plans').is(':empty')) {
        $('#Plans').prop('disabled', true);
      }
      $("#Plans").select2({dropdownCssClass: 'show-select-search'});
    });
  });

  $('#Plans').change(function() {
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
  });

  $('.date_picker').change(function() {
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
  });

  $('.btn[value="Calculate"]').click(function() {
    $(this).attr('class','btn btn-default');
  });
});
