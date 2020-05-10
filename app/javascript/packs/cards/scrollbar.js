import 'perfect-scrollbar'
$(() => {
  if($(".kanban-sidebar").length > 0) {
    var sidebarMenuList = new PerfectScrollbar(".kanban-sidebar", {
    wheelPropagation: false
  });
}
});
