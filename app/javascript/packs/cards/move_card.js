let drake = dragula();

$(document).ready(function () {

  // Dragula setup
  let allColumns = $('.kanban-drag').toArray();
  drake = dragula(allColumns, {
      moves: function (el, source, handle, sibling) {
          if (el.classList.contains('form-group')) {
              return false;
          }
        return true;
      }
  });

  // Sends information to cards#update controller on drop
  drake.on('drop', function (el, target, source, sibling) {
    let cardId = $(el).find(".kanban-item").data("card-id");
    let columnId = $(el).closest(".kanban-board").data("id");
    let boardId = $(el).closest(".card").data("board-id");
    let targetCardsArray = new Array();
    let targetCards = $(target).find(".kanban-item");
    let sourceCardsArray = new Array();
    let sourceCards = $(source).find(".kanban-item");

    createCardsIdArray(target, targetCards, targetCardsArray);

    if(sourceCards.length > 0){
      createCardsIdArray(source, sourceCards, sourceCardsArray);
    };

    console.log(targetCardsArray);
    console.log(sourceCardsArray);
    console.log("card id " + cardId);
    console.log("col id " + columnId);
    console.log("board id " + boardId);

    $.ajax({
      url: `/boards/${boardId}/columns/${columnId}/cards/${cardId}`,
      method: 'PUT',
      headers: {
        'X-CSRF-Token': document.getElementsByName('csrf-token')[0].content
      },
      data : { target_cards_id: JSON.stringify(targetCardsArray),
              source_cards_id: JSON.stringify(sourceCardsArray) }
    });
  });
});

// Resets dragula containers
setInterval(function() {
  let currentDragConteiners = $('.kanban-drag')
  if(drake.containers.length != currentDragConteiners.length){
    drake.containers = currentDragConteiners.toArray();
  }
}, 500);

// Function to create array with cards id
function createCardsIdArray(dragArea, cards, emptyArray) {
  $(dragArea).closest(".kanban-board").find(".badge").text(`${cards.length}`);
  cards.each(function(){
    emptyArray.push($(this).data('card-id'));
  });
}
