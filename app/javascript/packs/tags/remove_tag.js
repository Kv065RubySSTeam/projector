window.sendTagDeleteRequest = function (event) {
  event.preventDefault();
  event.stopPropagation();
  let path = event.target.parentElement.href;
  $.ajax({
    url: path,
    method: 'DELETE',
    headers: {
      'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content
    }
  });
};
