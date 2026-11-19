# TipToe — локальний статичний сервер для перегляду прототипу (без Python і Node.js).
# Запуск із папки проєкту:  powershell -NoProfile -ExecutionPolicy Bypass -File tools/serve.ps1
# Сайт: http://localhost:8765/site.html. Працює лише на цьому комп'ютері (localhost).
# Невідомі адреси повертають 404.html. Зупинка: Ctrl+C.
param([string]$Root = (Split-Path -Parent $PSScriptRoot), [int]$Port = 8765)
$types = @{ '.html'='text/html; charset=utf-8'; '.css'='text/css; charset=utf-8'; '.js'='text/javascript; charset=utf-8'; '.svg'='image/svg+xml'; '.woff2'='font/woff2'; '.png'='image/png'; '.json'='application/json'; '.txt'='text/plain; charset=utf-8'; '.md'='text/plain; charset=utf-8' }
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
Write-Output "Serving $Root on http://localhost:$Port/"
while ($l.IsListening) {
  $c = $l.GetContext()
  $p = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath.TrimStart('/'))
  if ($p -eq '') { $p = 'index.html' }
  $f = Join-Path $Root $p
  $full = [IO.Path]::GetFullPath($f)
  if ($full.StartsWith([IO.Path]::GetFullPath($Root)) -and (Test-Path $full -PathType Leaf)) {
    $b = [IO.File]::ReadAllBytes($full); $c.Response.StatusCode = 200
    $ext = [IO.Path]::GetExtension($full).ToLower()
    $c.Response.ContentType = if ($types[$ext]) { $types[$ext] } else { 'application/octet-stream' }
  } else {
    $nf = Join-Path $Root '404.html'
    $b = [IO.File]::ReadAllBytes($nf); $c.Response.StatusCode = 404; $c.Response.ContentType = 'text/html; charset=utf-8'
  }
  $c.Response.Headers.Add('Cache-Control', 'no-store')
  $c.Response.OutputStream.Write($b, 0, $b.Length)
  $c.Response.Close()
  Write-Output "$($c.Response.StatusCode) /$p"
}
