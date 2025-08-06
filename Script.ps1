# Verificar que tengamos docker
docker --version 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker no esta instalado"
    exit 1
}

#Verificar si docker esta ejecutandose
docker info 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker no esta ejecutandose"
    exit 1
}else{
    Write-Host "Docker esta ejecutandose"
}

# Construccion de imagen
docker build -t devops-app .
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Fallo construccion imagen"
    exit 1
}else{
    Write-Host "Imagen construida"
}

# Verificar si el contenedor ya existe y eliminarlo
docker rm -f devops-container 2>$null | Out-Null
docker run -d -p 8080:3000 -e "NODE_ENV=production" --name devops-container devops-app
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Fallo ejecucion contenedor"
    exit 1
}else{
    Write-Host "Contenedor ejecutado"
}


# Probar servicio
Start-Sleep 5
try {
    $response = Invoke-WebRequest "http://localhost:8080" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "EXITO: Servicio responde correctamente"
    } else {
        Write-Host "ERROR: Servicio no responde"
        exit 1
    }
} catch {
    Write-Host "ERROR: No se pudo conectar al servicio"
    exit 1
}