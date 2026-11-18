# TipToe — збирає HTML-сторінки статей із articles/*.md і список статей articles.html.
# Запуск із кореня сайту:  powershell -NoProfile -ExecutionPolicy Bypass -File tools/build-articles.ps1
# Підтримується простий Markdown: "# " заголовок, рядок *курсивом* одразу під ним (опис заняття),
# "## " підзаголовки, абзаци, списки "- ", **жирний** і *курсив*. Файли без "# " заголовка пропускаються.
# Сторінки перезаписуються повністю: правте .md і запускайте скрипт ще раз.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$srcDir = Join-Path $root 'articles'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Esc([string]$s) {
  return $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}
function Inline([string]$s) {
  $h = Esc $s
  $h = [regex]::Replace($h, '\*\*(.+?)\*\*', '<strong>$1</strong>')
  $h = [regex]::Replace($h, '(?<![\*\w])\*(?!\s)(.+?)(?<!\s)\*(?![\*\w])', '<em>$1</em>')
  return $h
}
function Plain([string]$s) { return ($s -replace '\*', '').Trim() }

function Head([string]$p, [string]$title, [string]$desc, [string]$page) {
@"
<!DOCTYPE html>
<html lang="uk" data-page="$page">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$(Esc $title)</title>
  <meta name="description" content="$(Esc $desc)">
  <meta property="og:type" content="article">
  <meta property="og:site_name" content="TipToe">
  <meta property="og:title" content="$(Esc $title)">
  <meta property="og:description" content="$(Esc $desc)">
  <meta property="og:locale" content="uk_UA">
  <link rel="icon" href="${p}assets/img/favicon.svg" type="image/svg+xml">
  <link rel="preload" href="${p}assets/fonts/Comfortaa-Bold.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="preload" href="${p}assets/fonts/Nunito-Regular.woff2" as="font" type="font/woff2" crossorigin>
  <link rel="stylesheet" href="${p}assets/css/tokens.css">
  <link rel="stylesheet" href="${p}assets/css/base.css">
  <link rel="stylesheet" href="${p}assets/css/components.css">
  <link rel="stylesheet" href="${p}assets/css/sections.css">
  <script src="${p}assets/js/theme.js"></script>
  <script src="${p}assets/js/i18n.js" defer></script>
  <script src="${p}assets/js/lang.js" defer></script>
  <script src="${p}assets/js/menu.js" defer></script>
</head>
"@
}

function NavItems([string]$p) {
  $items = @(
    @('site.html#about', 'nAbout', 'Про нас'),
    @('site.html#prices', 'nPrices', 'Ціни'),
    @('site.html#schedule', 'nSchedule', 'Розклад'),
    @('site.html#masterclasses', 'nMasters', 'Майстер-класи'),
    @('articles.html', 'nArticles', 'Статті'),
    @('site.html#contacts', 'nContacts', 'Контакти')
  )
  $out = foreach ($i in $items) {
    $cur = ''
    if ($i[1] -eq 'nArticles') { $cur = ' aria-current="page"' }
    "<li><a class=`"nav-link`" href=`"$p$($i[0])`"$cur data-i18n=`"$($i[1])`">$($i[2])</a></li>"
  }
  return $out
}

function Header([string]$p) {
  $nav = NavItems $p
  $d = ($nav | ForEach-Object { "          $_" }) -join "`n"
  $m = ($nav | ForEach-Object { "        $_" }) -join "`n"
@"
<body>
<div id="top" class="page">
  <a class="tt-btn tt-skip" href="#main" data-i18n="skip">Перейти до основного вмісту</a>

  <header class="site-header">
    <div class="wrap hdr-row hdr-row--split">
      <a class="brand" href="${p}site.html" aria-label="TipToe — на головну" data-i18n-attr="aria-label:brandHome">TipToe</a>
      <nav class="nav-desktop" aria-label="Основне меню" data-i18n-attr="aria-label:navLabel">
        <ul>
$d
        </ul>
      </nav>
      <div class="hdr-tools">
        <button class="theme-btn" type="button" aria-pressed="false" aria-label="Темна тема" data-i18n-attr="aria-label:theme">
          <svg class="ico-moon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"/></svg>
          <svg class="ico-sun" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="4"/><path d="M12 3v2M12 19v2M3 12h2M19 12h2M5.6 5.6l1.4 1.4M17 17l1.4 1.4M5.6 18.4L7 17M17 7l1.4-1.4"/></svg>
        </button>
        <div class="tt-lang" role="group" aria-label="Мова сайту" data-i18n-attr="aria-label:langLabel">
          <a href="?lang=uk" data-lang="uk" lang="uk" hreflang="uk" aria-current="true" aria-label="UA — українська" data-i18n-attr="aria-label:uaLabel">UA</a>
          <a href="?lang=en" data-lang="en" lang="en" hreflang="en" aria-current="false" aria-label="EN — English" data-i18n-attr="aria-label:enLabel">EN</a>
        </div>
        <button class="burger" type="button" aria-expanded="false" aria-controls="mobile-menu" aria-label="Меню" data-i18n-attr="aria-label:menu">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true" focusable="false"><path d="M4 7h16M4 12h16M4 17h16"/></svg>
        </button>
      </div>
    </div>
    <nav id="mobile-menu" class="mobile-menu" aria-label="Меню для смартфона" data-i18n-attr="aria-label:mobileNav" hidden>
      <ul class="wrap">
$m
      </ul>
    </nav>
  </header>
"@
}

function Footer([string]$p) {
@"
  <footer class="site-footer">
    <div class="wrap stack stack--6">
      <div class="footer-row">
        <div class="stack" style="gap:var(--space-2)">
          <span class="brand">TipToe</span>
          <p class="tt-small" style="color:var(--text)" data-i18n="footerAbout">Центр для дітей 2–6 років, Харків</p>
        </div>
        <div class="footer-links">
          <a class="tt-link" href="tel:+380509100000">+380 50 910 00 00</a>
          <a class="tt-link" href="https://www.instagram.com/" aria-label="TipToe в Instagram" data-i18n-attr="aria-label:instagramLabel">TipToe</a>
          <a class="tt-link" href="${p}privacy.html" data-i18n="privacyLink">Політика конфіденційності</a>
        </div>
        <div class="tt-lang" role="group" aria-label="Мова сайту" data-i18n-attr="aria-label:langLabel">
          <a href="?lang=uk" data-lang="uk" lang="uk" hreflang="uk" aria-current="true" aria-label="UA — українська" data-i18n-attr="aria-label:uaLabel">UA</a>
          <a href="?lang=en" data-lang="en" lang="en" hreflang="en" aria-current="false" aria-label="EN — English" data-i18n-attr="aria-label:enLabel">EN</a>
        </div>
      </div>
      <p class="tt-caption">© 2026 TipToe</p>
    </div>
  </footer>
</div>
</body>
</html>
"@
}

# --- Розбір Markdown ---------------------------------------------------------
function Parse([string]$path) {
  $lines = [System.IO.File]::ReadAllLines($path, $utf8)
  $a = [ordered]@{ title = $null; meta = $null; lead = $null; blocks = New-Object System.Collections.ArrayList }
  $para = New-Object System.Collections.ArrayList
  $list = New-Object System.Collections.ArrayList

  $flushPara = {
    if ($para.Count -gt 0) {
      $text = ($para -join ' ').Trim()
      if ($null -eq $a.meta -and $a.blocks.Count -eq 0 -and $null -eq $a.lead -and $text -match '^\*[^*].*\*$') {
        $a.meta = $text.Trim('*').Trim()
      } elseif ($null -eq $a.lead -and $a.blocks.Count -eq 0) {
        $a.lead = $text
      } else {
        [void]$a.blocks.Add(@{ t = 'p'; v = $text })
      }
      $para.Clear()
    }
  }
  $flushList = {
    if ($list.Count -gt 0) { [void]$a.blocks.Add(@{ t = 'ul'; v = @($list) }); $list.Clear() }
  }

  foreach ($raw in $lines) {
    $l = $raw.TrimEnd()
    if ($l -match '^#\s+(.+)$' -and $null -eq $a.title) { & $flushPara; & $flushList; $a.title = $Matches[1].Trim(); continue }
    if ($l -match '^##\s+(.+)$') { & $flushPara; & $flushList; [void]$a.blocks.Add(@{ t = 'h2'; v = $Matches[1].Trim() }); continue }
    if ($l -match '^[-*]\s+(.+)$') { & $flushPara; [void]$list.Add($Matches[1].Trim()); continue }
    if ($l -eq '') { & $flushPara; & $flushList; continue }
    & $flushList; [void]$para.Add($l.Trim())
  }
  & $flushPara; & $flushList
  return $a
}

function Body($a) {
  $out = New-Object System.Collections.ArrayList
  $last = $a.blocks.Count - 1
  for ($i = 0; $i -le $last; $i++) {
    $b = $a.blocks[$i]
    switch ($b.t) {
      'h2' { [void]$out.Add("          <h2 class=`"tt-h3`">$(Inline $b.v)</h2>") }
      'ul' {
        [void]$out.Add('          <ul class="tt-body">')
        foreach ($li in $b.v) { [void]$out.Add("            <li>$(Inline $li)</li>") }
        [void]$out.Add('          </ul>')
      }
      'p' {
        # Останній абзац курсивом — службова примітка («Дату, час… уточнюйте»).
        if ($i -eq $last -and $b.v -match '^\*[^*].*\*$') {
          [void]$out.Add("          <p class=`"tt-small`">$(Inline $b.v.Trim('*').Trim())</p>")
        } else {
          [void]$out.Add("          <p class=`"tt-body`">$(Inline $b.v)</p>")
        }
      }
    }
  }
  return ($out -join "`n")
}

# --- Збирання ----------------------------------------------------------------
$articles = New-Object System.Collections.ArrayList
foreach ($f in (Get-ChildItem -Path $srcDir -Filter '*.md' | Sort-Object Name)) {
  $a = Parse $f.FullName
  if (-not $a.title) { Write-Host "Пропущено (немає заголовка # ): $($f.Name)"; continue }
  $slug = [IO.Path]::GetFileNameWithoutExtension($f.Name)
  $desc = if ($a.lead) { Plain $a.lead } else { Plain $a.title }
  if ($desc.Length -gt 160) { $desc = $desc.Substring(0, 157).TrimEnd() + '…' }
  $a['slug'] = $slug; $a['desc'] = $desc
  [void]$articles.Add($a)

  $p = '../'
  $metaHtml = if ($a.meta) { "`n          <p class=`"tt-small`">$(Inline $a.meta)</p>" } else { '' }
  $leadHtml = if ($a.lead) { "`n          <p class=`"tt-lead`">$(Inline $a.lead)</p>" } else { '' }
  $html = (Head $p "$($a.title) — TipToe" $desc 'article') + (Header $p) + @"

  <main id="main" tabindex="-1">
    <section class="sec">
      <div class="wrap">
        <p class="crumbs"><a class="tt-link" href="${p}articles.html"><span aria-hidden="true">← </span><span data-i18n="artAll">Усі статті</span></a></p>
        <article class="doc" lang="uk">
          <h1 class="tt-h1">$(Inline $a.title)</h1>$metaHtml$leadHtml
$(Body $a)
        </article>
        <div class="tt-card art-cta">
          <h2 class="tt-h3" data-i18n="artCtaH">Хочете прийти на майстер-клас?</h2>
          <p class="tt-body" data-i18n="artCtaP">Залиште заявку — адміністратор передзвонить і розповість про найближчу дату.</p>
          <a class="tt-btn" href="${p}site.html#request" data-i18n="signup">Записатися</a>
        </div>
      </div>
    </section>
  </main>

"@ + (Footer $p)
  [System.IO.File]::WriteAllText((Join-Path $srcDir "$slug.html"), $html, $utf8)
  Write-Host "articles/$slug.html"
}

# Список статей
$cards = foreach ($a in $articles) {
  $meta = if ($a.meta) { "`n            <p class=`"tt-small`">$(Inline $a.meta)</p>" } else { '' }
@"
          <li class="tt-card art-card" lang="uk">
            <h2 class="tt-h3"><a class="art-card-link" href="articles/$($a.slug).html">$(Inline $a.title)</a></h2>$meta
            <p class="tt-body">$(Esc $a.desc)</p>
          </li>
"@
}
$list = (Head '' 'Статті — TipToe' 'Статті про майстер-класи TipToe: що роблять діти 2–6 років на заняттях і що це їм дає.' 'articles') + (Header '') + @"

  <main id="main" tabindex="-1">
    <section class="sec">
      <div class="wrap stack stack--6">
        <div class="stack stack--4 narrow">
          <h1 class="tt-h1" data-i18n="artH1">Статті</h1>
          <p class="tt-lead" data-i18n="artIntro">Розповідаємо, як проходять наші майстер-класи і що вони дають дітям різного віку.</p>
        </div>
        <ul class="grid grid--md art-list">
$($cards -join "`n")
        </ul>
      </div>
    </section>
  </main>

"@ + (Footer '')
[System.IO.File]::WriteAllText((Join-Path $root 'articles.html'), $list, $utf8)
Write-Host "articles.html ($($articles.Count) статей)"
