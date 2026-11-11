/* TipToe — форма заявки (прототип).
   Маска +380, перевірка полів, помилки текстом зі значком через aria-describedby,
   фокус на першому помилковому полі, вибір заняття з кнопки «Записатися», стан «Дякуємо».
   У WordPress надсилання виконує Contact Form 7; тут заявка нікуди не відправляється. */
(function () {
  function tr(key, fallback) {
    var v = window.TT && window.TT.t ? window.TT.t(key) : null;
    return v != null ? v : fallback;
  }

  function fmtPhone(raw) {
    var d = String(raw || '').replace(/\D/g, '');
    if (d.length < 3) d = '380';
    else if (d.indexOf('380') === 0) { /* уже з кодом країни */ }
    else if (d.indexOf('80') === 0) d = '3' + d;   // 80501234567
    else if (d.indexOf('0') === 0) d = '38' + d;   // 0501234567
    else d = '380' + d;                            // 501234567
    d = d.slice(0, 12);
    var r = '+' + d.slice(0, 3);
    if (d.length > 3) r += ' ' + d.slice(3, 5);
    if (d.length > 5) r += ' ' + d.slice(5, 8);
    if (d.length > 8) r += ' ' + d.slice(8, 10);
    if (d.length > 10) r += ' ' + d.slice(10, 12);
    return r;
  }

  document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('request-form');
    if (!form) return;
    var thanks = document.getElementById('thanks');
    var name = document.getElementById('f-name');
    var phone = document.getElementById('f-phone');
    var club = document.getElementById('f-club');
    var consent = document.getElementById('f-consent');

    var checks = [
      { el: name, err: 'e-name', key: 'errName', fb: "Вкажіть ім'я", ok: function () { return name.value.trim() !== ''; } },
      { el: phone, err: 'e-phone', key: 'errPhone', fb: 'Введіть номер у форматі +380 XX XXX XX XX', ok: function () { return phone.value.replace(/\D/g, '').length === 12; } },
      { el: consent, err: 'e-consent', key: 'errConsent', fb: 'Підтвердьте згоду на обробку даних', ok: function () { return consent.checked; } }
    ];

    function show(c, on) {
      var box = document.getElementById(c.err);
      c.el.setAttribute('aria-invalid', on ? 'true' : 'false');
      if (!box) return;
      box.hidden = !on;
      var txt = box.querySelector('span');
      if (txt) txt.textContent = tr(c.key, c.fb);
    }

    // Маска телефону
    phone.addEventListener('focus', function () {
      if (!phone.value) phone.value = '+380';
    });
    phone.addEventListener('input', function () {
      phone.value = fmtPhone(phone.value);
      show(checks[1], false);
    });
    phone.addEventListener('blur', function () {
      if (phone.value.replace(/\D/g, '') === '380') phone.value = '';
    });
    name.addEventListener('input', function () { show(checks[0], false); });
    consent.addEventListener('change', function () { show(checks[2], false); });

    // «Записатися» з розкладу й майстер-класів підставляє заняття у форму
    document.addEventListener('click', function (e) {
      var btn = e.target.closest('[data-pick]');
      if (!btn) return;
      var value = btn.getAttribute('data-pick');
      if (club.querySelector('option[value="' + value + '"]')) club.value = value;
      if (!form.hidden) {
        // Фокус на перше поле після прокручування до форми
        setTimeout(function () { name.focus({ preventScroll: true }); }, 0);
      }
    });

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var first = null;
      checks.forEach(function (c) {
        var bad = !c.ok();
        show(c, bad);
        if (bad && !first) first = c.el;
      });
      if (first) {
        first.focus();
        return;
      }
      form.hidden = true;
      thanks.hidden = false;
      var h = thanks.querySelector('h3');
      if (h) h.focus();
    });

    // Після зміни мови оновити тексти показаних помилок
    document.addEventListener('tt:lang', function () {
      checks.forEach(function (c) {
        var box = document.getElementById(c.err);
        if (box && !box.hidden) show(c, true);
      });
    });
  });
})();
