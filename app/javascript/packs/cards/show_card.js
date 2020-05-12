$(document).ready(function(){
  $("body").find(".kanban-item").click(function() {
    var cardId = $(this).data("card-id");
    var columnId = $(this).closest(".kanban-board").data("id");
    var boardId = $(this).closest(".card").data("board-id");

    showCard(boardId, columnId, cardId);
  });
});

function showCard(boardId, columnId, cardId) {

  $.ajax({
    url: `/boards/${boardId}/columns/${columnId}/cards/${cardId}/edit`,
    method: 'GET',
    headers: {
      'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content
    },
  });
};
