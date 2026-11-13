Add-Type -AssemblyName System.Web

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://127.0.0.1:8088/')
$listener.Start()
Write-Output "HTTP Server listening on 8088"

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $raw = $ctx.Request.RawUrl.Split('?')[0].TrimStart('/')
    $decoded = [System.Web.HttpUtility]::UrlDecode($raw)
    if ([string]::IsNullOrWhiteSpace($decoded)) { $decoded = 'index.html' }
    
    $fullPath = Join-Path 'C:\Users\sjsj9\Desktop\test2' $decoded
    if (Test-Path $fullPath -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($fullPath)
        $ctx.Response.StatusCode = 200
        $ctx.Response.ContentLength64 = $bytes.Length
        if ($fullPath.EndsWith('.html')) {
            $ctx.Response.ContentType = 'text/html; charset=utf-8'
        } elseif ($fullPath.EndsWith('.xlsx')) {
            $ctx.Response.ContentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        } else {
            $ctx.Response.ContentType = 'application/octet-stream'
        }
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $ctx.Response.StatusCode = 404
    }
    $ctx.Response.OutputStream.Close()
}
