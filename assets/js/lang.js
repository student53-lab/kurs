/* TipToe — перемикач UA / EN на тій самій сторінці.
   Тексти — у assets/js/i18n.js (window.TT_I18N). Українська стоїть у HTML і працює без JavaScript.
   Вибір мови: параметр ?lang=en в адресі, потім збережений у localStorage, інакше українська. */
(function () {
  var KEY = 'tt-lang';
  var LANGS = ['uk', 'en'];
  var dict = window.TT_I18N || {};
  var root = document.documentElement;
  var current = 'uk';

  function t(key) {
    var d = dict[current] || {};
    return Object.prototype.hasOwnProperty.call(d, key) ? d[key] : null;
  }

  function initial() {
    try {
      var q = new URLSearchParams(window.location.search).get('lang');
      if (LANGS.indexOf(q) !== -1) return q;
    } catch (e) { /* без параметра */ }
    try {
      var s = localStorage.getItem(KEY);
      if (LANGS.indexOf(s) !== -1) return s;
    } catch (e) { /* без сховища */ }
    return 'uk';
  }

  function setMeta(selector, value) {
    var el = document.querySelector(selector);
    if (el && value != null) el.setAttribute('content', value);
  }

  // Підписи кнопок «Записатися» з контекстом: «Записатися: Понеділок, 10:00, 2–3 роки».
  function signupLabels() {
    var prefix = t('signup') || 'Записатися';
    var rows = document.querySelectorAll('.row-club');
    for (var i = 0; i < rows.length; i++) {
      var r = rows[i];
      var btn = r.querySelector('.tt-btn');
      if (!btn) continue;
      var parts = ['.row-day', '.row-time', '.row-age'].map(function (s) {
        var n = r.querySelector(s);
        return n ? n.textContent.trim() : '';
      });
      btn.setAttribute('aria-label', prefix + ': ' + parts.join(', '));
    }
    var cards = document.querySelectorAll('.mc-card');
    for (var j = 0; j < cards.length; j++) {
      var b = cards[j].querySelector('.tt-btn');
      var h = cards[j].querySelector('h3');
      if (b && h) b.setAttribute('aria-label', prefix + ': ' + h.textContent.trim());
    }
  }

  function apply(lang) {
    current = LANGS.indexOf(lang) !== -1 ? lang : 'uk';
    root.setAttribute('lang', current);

    var nodes = document.querySelectorAll('[data-i18n]');
    for (var i = 0; i < nodes.length; i++) {
      var v = t(nodes[i].getAttribute('data-i18n'));
      if (v != null) nodes[i].textContent = v;
    }

    var attrs = document.querySelectorAll('[data-i18n-attr]');
    for (var j = 0; j < attrs.length; j++) {
      var pairs = attrs[j].getAttribute('data-i18n-attr').split(';');
      for (var k = 0; k < pairs.length; k++) {
        var p = pairs[k].split(':');
        if (p.length !== 2) continue;
        var val = t(p[1].trim());
        if (val != null) attrs[j].setAttribute(p[0].trim(), val);
      }
    }

    var page = root.getAttribute('data-page');
    if (page) {
      var title = t(page + '.title');
      var desc = t(page + '.desc');
      if (title != null) document.title = title;
      setMeta('meta[name="description"]', desc);
      setMeta('meta[property="og:title"]', title);
      setMeta('meta[property="og:description"]', desc);
      setMeta('meta[property="og:locale"]', current === 'en' ? 'en_GB' : 'uk_UA');
    }

    var links = document.querySelectorAll('.tt-lang a[data-lang]');
    for (var m = 0; m < links.length; m++) {
      links[m].setAttribute('aria-current', links[m].getAttribute('data-lang') === current ? 'true' : 'false');
    }

    signupLabels();
    document.dispatchEvent(new CustomEvent('tt:lang', { detail: { lang: current } }));
  }

  window.TT = {
    t: t,
    lang: function () { return current; },
    setLang: apply
  };

  document.addEventListener('DOMContentLoaded', function () {
    apply(initial());

    document.addEventListener('click', function (e) {
      var a = e.target.closest('.tt-lang a[data-lang]');
      if (!a) return;
      e.preventDefault();
      var lang = a.getAttribute('data-lang');
      try { localStorage.setItem(KEY, lang); } catch (err) { /* вибір не збережеться */ }
      try {
        var url = new URL(window.location.href);
        if (lang === 'uk') url.searchParams.delete('lang');
        else url.searchParams.set('lang', lang);
        history.replaceState(null, '', url.toString());
      } catch (err) { /* адреса не зміниться */ }
      apply(lang);
    });
  });
})();
