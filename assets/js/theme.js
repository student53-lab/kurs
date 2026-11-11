/* TipToe — перемикач теми.
   Підключається в <head> без defer, щоб тема стала до першого малювання.
   Початкова тема — з налаштувань пристрою; вибір користувача зберігається в localStorage. */
(function () {
  var KEY = 'tt-theme';
  var root = document.documentElement;
  var media = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;

  function stored() {
    try {
      var v = localStorage.getItem(KEY);
      return v === 'dark' || v === 'light' ? v : null;
    } catch (e) {
      return null;
    }
  }

  function system() {
    return media && media.matches ? 'dark' : 'light';
  }

  function apply(theme) {
    root.setAttribute('data-theme', theme);
    var btns = document.querySelectorAll('.theme-btn');
    for (var i = 0; i < btns.length; i++) {
      btns[i].setAttribute('aria-pressed', theme === 'dark' ? 'true' : 'false');
    }
  }

  apply(stored() || system());

  if (media && media.addEventListener) {
    media.addEventListener('change', function () {
      if (!stored()) apply(system());
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    apply(root.getAttribute('data-theme'));
    var btns = document.querySelectorAll('.theme-btn');
    for (var i = 0; i < btns.length; i++) {
      btns[i].addEventListener('click', function () {
        var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        try { localStorage.setItem(KEY, next); } catch (e) { /* вибір не збережеться */ }
        apply(next);
      });
    }
  });
})();
