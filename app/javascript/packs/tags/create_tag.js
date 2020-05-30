$('#tagName').on('keypress',function(e) {
  if(e.which == 13) {
    var url = $(".edit-form").attr('action');
    var tagName = $('#tagName').val();
    $('#tagName').val('');
    $('#lastAddedTag').val(tagName);
    $.ajax({
      url: `${url}/tags?tag[name]=${tagName}`,
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content
      },
    })
  }
});
