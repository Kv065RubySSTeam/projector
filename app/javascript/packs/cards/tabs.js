$(document).ready(function () {

    $('ul.tabs li').click(function () {
        $('ul.tabs a').removeClass('active');
        $(this).children().first().addClass('active');

        $('ul.tabs a').attr('aria-selected', false);
        $(this).children().first().attr('aria-selected', true);

        $('.tab-pane').removeClass('active');

        if ($(this).children().first().attr("id") === 'comments-tab'){
          $('#comments-just').addClass('active');
        } else {
          $('#history-just').addClass('active');
        }
    })

});
