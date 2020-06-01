window.stopPropagationToButtons = function(event) {
  event.preventDefault();
  event.stopPropagation();

  var el = event.target.closest("form.button_to");
  let path = el.action;

  if (el.children.length === 3) {
    var method = el.children[0].value;
  } else {
    var method = el.method;
  }
  
  $.ajax({
    url: path,
    method: method,
    headers: {
      'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content
    }
  });  
};