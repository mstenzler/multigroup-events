$(document).on('click', 'form .remove_fields', function(event) {
  console.log("Cliked .remove_fields");
//  var fs = $(this).closest('fieldset');
//  console.log("fs macthed obj =");
//  console.log(fs);
//  var inp = fs.find('input[type=hidden]');
//  console.log("fs input =");
//  console.log(inp);

 //$(this).prev('input[type=hidden]').val('1');
 var inputelm = $(this).closest('fieldset').find('input[type=hidden]');
 console.log("inputelm =");
 console.log(inputelm)
 inputelm.val('true');
 console.log("inputelm.val = ");
 console.log(inputelm.val());

 // $(this).closest('fieldset')
  $(this).closest('fieldset').hide();
  return event.preventDefault();
});

$(document).on('click', 'form .add_fields', function(event) {
  var regexp, regext2, time, new_rank, last_rank_input, new_rank_marker, txt;
  last_rank_input = $(this).data('last-rank-input');
  new_rank_marker = $(this).data('new-rank-marker');
  console.log("** Cliicked .add_fields. last_rank_input = '" + last_rank_input + "'");
  console.log("* new_rank_marker = '" + new_rank_marker + "'");
  time = new Date().getTime();
  regexp = new RegExp($(this).data('id'), 'g');
  txt = $(this).data('fields').replace(regexp, time)
  if (last_rank_input && new_rank_marker) {
    console.log("*** Got last_rank_input and new_rank_marker: " + last_rank_input + "," + new_rank_marker);
    new_rank = getHighestValue(last_rank_input);
    new_rank += 1;
    regexp2 = new RegExp(new_rank_marker, 'g');
    txt = txt.replace(regexp2, new_rank);
  }
  $(this).before(txt);
//  $(this).before($(this).data('fields').replace(regexp, time));
  return event.preventDefault();
});

$(document).on('change', "input[name$='[is_primary_event]']", function(event) {
  var selected = $(this);
// var curr_val = $(this).val();
 // var checked_status = selected.prop("checked");
//  console.log("** Clicked is_primary_event. value =" + curr_val);
 // console.log("** checked_status = " + checked_status);
  $("input[name$='[is_primary_event]']").each(function() {
    $(this).prop("checked", false);
  });
  selected.prop("checked", true);
//  return event.preventDefault();
}).change();

function getHighestValue(sel) {
  console.log("In getHighestValue, sel = '" + sel + "'");
  var high_val = 0;
  var curr_int_val = 0;
  $(sel).each(function() {
    console.log("GOT A SELECTION. value =" + $(this).val());
    curr_int_val = parseInt($(this).val());
    console.log(curr_int_val);
    if (curr_int_val > high_val) {
      high_val = curr_int_val;
    }
  });
  console.log("** High_val = '" + high_val + "'");
  return high_val;
  //console.log("** In initAvatarFormFields **");
  //obj = $("input[name='user[avatar_type]']");
};