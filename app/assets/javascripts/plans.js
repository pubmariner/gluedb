$(document).ready(function() {
  $('#plan-years').prop('disabled', true);
  $('#plans').prop('disabled', true);

  $('#carriers').change(function(e) {    
    $('#plans').prop('disabled', true);
    $('#plan-years').prop('disabled', false);
    $('#plans').empty();
    $('#plan-years').empty();
    var id = $('#carriers').val();
    $.getJSON('/carriers/'+ id +'/plan_years', function(data) {
      $.each(data, function(key, value) {
        $('#plan-years').append($('<option/>').attr("value", value).text(value));
      });
      get_carrier_plans();
      $("#plan-years").select2({dropdownCssClass: 'show-select-search'});
    });
  })

  $('#plan-years').change(function(e) {
    get_carrier_plans();
  });

  var get_carrier_plans = function() {
    var carrier_id = $('#carriers').val();
    var year = $('#plan-years').val();
    $('#plans').prop('disabled', false);
    $( "option[value|='']" ).remove();
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
    $.getJSON('/carriers/'+ carrier_id +'/show_plans',{plan_year: year}, function(data) {
      $('#plans').empty();
      $.each(data, function(key, value) {
        $('#plans').append($('<option/>').attr("value", value._id).text(value.name).append(" : " + value.hios_plan_id));
      });
      if($('#plans').is(':empty')) {
        $('#plans').prop('disabled', true);
      }
      $("#plans").select2({dropdownCssClass: 'show-select-search'});
    });
  };

  $('#plans').change(function() {
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
  });

  $('.date_picker').change(function() {
    $(".btn[value='Calculate']").attr('class','btn btn-primary');
  });

  $('.btn[value="Calculate"]').click(function() {
    $(this).attr('class','btn btn-default');
  });
});
