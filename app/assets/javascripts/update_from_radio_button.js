jQuery.fn.updateFromRadioButton = function(radioSelector) {
  var $el = $(this); // our element

  var rad = $(radioSelector);
  console.log("In updateFromRadioButton");

  var currRadio = null;
  for(var i = 0; i < rad.length; i++) {
    currRadio = rad[i];
    rad[i].onclick = function() { handleClick(this) };
  }

  function handleClick(myRadio) {
    var radioSel = $(myRadio);
//    var currValue = myRadio.value;
    var api_key = radioSel.data("api_token");
    $el.val(api_key);
  }

  return $el;
};
//$(document).ready(ready);
//$(document).on('page:load', ready);