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
  var regexp, time;
  time = new Date().getTime();
  regexp = new RegExp($(this).data('id'), 'g');
  $(this).before($(this).data('fields').replace(regexp, time));
  return event.preventDefault();
});
