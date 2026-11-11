/* TipToe — меню-«бургер» до 1120 px: відкриття, закриття клавішею Esc і після вибору пункту. */
(function () {
  document.addEventListener('DOMContentLoaded', function () {
    var burger = document.querySelector('.burger');
    var menu = document.getElementById('mobile-menu');
    if (!burger || !menu) return;

    function setOpen(open, returnFocus) {
      menu.hidden = !open;
      burger.setAttribute('aria-expanded', open ? 'true' : 'false');
      if (!open && returnFocus) burger.focus();
    }

    burger.addEventListener('click', function () {
      setOpen(menu.hidden, false);
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && !menu.hidden) setOpen(false, true);
    });

    menu.addEventListener('click', function (e) {
      if (e.target.closest('a')) setOpen(false, false);
    });

    // Якщо екран розширили до ноутбука — закрити меню.
    if (window.matchMedia) {
      var lg = window.matchMedia('(min-width: 1120px)');
      var onChange = function () { if (lg.matches) setOpen(false, false); };
      if (lg.addEventListener) lg.addEventListener('change', onChange);
    }
  });
})();
