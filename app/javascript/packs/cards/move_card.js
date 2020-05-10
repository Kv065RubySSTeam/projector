$(document).ready(function () {
  let allColumns = [].slice.call(document.querySelectorAll('.kanban-drag'));
  let drake = dragula(allColumns, {
    moves: function (el,source, handle, sibling) {
          if (el.classList.contains('form-group')) {
              return false;
          }
          return true;
      }
    });

  drake.on('drop', function (el, target, source, sibling) {
    let cardId = $(el).find(".kanban-item").data("card-id");
    let columnId = $(el).closest(".kanban-board").data("id");
    let boardId = $(el).closest(".card").data("board-id");
    let targetCardsArray = new Array();
    let targetCards = $(target).find(".kanban-item");
    let sourceCardsArray = new Array();
    let sourceCards = $(source).find(".kanban-item");
    let sourceId = $(source).closest(".kanban-board").data("id");;

    targetCards.each(function(){
      targetCardsArray.push($(this).data('card-id'));
    });

    if(sourceCards.length > 0){
      sourceCards.each(function(){
        sourceCardsArray.push($(this).data('card-id'));
      });
    };

    console.log(targetCardsArray);
    console.log(sourceCardsArray);
    console.log("card id " + cardId);
    console.log("col id " + columnId);
    console.log("board id " + boardId);
    console.log("source id " + sourceId);

    $.ajax({
      url: `/boards/${boardId}/columns/${columnId}/cards/${cardId}?source_id=${sourceId}`,
      method: 'PUT',
      headers: {
        'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content
      },
      data : { target_cards_id: JSON.stringify(targetCardsArray),
              source_cards_id: JSON.stringify(sourceCardsArray) }
    });
  });
});
