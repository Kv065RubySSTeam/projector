$(document).ready(function() {
  var allColumns = $('.kanban-title-board').length;

  for (let i = 0; i < allColumns; i++) {
    let col = $('.kanban-title-board')[i];

     // find column id, columnTitle, board_id
    col.addEventListener('blur', function(event) {
      var columnTitle = event.srcElement.textContent.trim();
      var board_id = Number(
        event.srcElement.closest('.card').getAttribute('data-board-id')
      );
      var column_id = Number(
        event.srcElement.closest('.kanban-board').getAttribute('data-id')
      );

      updateColumn(board_id, column_id, columnTitle);
    });

    function updateColumn(board_id, column_id, columnTitle) {
      // update column at the database
      $.ajax({
        url: board_id + '/columns/' + column_id,
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content
        },
        data: {
          'column[name]': columnTitle
        }
      });
    }
   }
});
