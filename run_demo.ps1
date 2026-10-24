<#
.SYNOPSIS
    Ejecuta la demo de Ansible en WSL Ubuntu desde Windows PowerShell
#>

Write-Host "==========================================================" -ForegroundColor Red
Write-Host "    ANSIBLE DEMO - GESTION DE LA CONFIGURACION            " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Red
Write-Host "Lanzando ejecucion en entorno WSL Ubuntu..." -ForegroundColor Cyan
Write-Host ""

wsl -d Ubuntu -- bash -c "cd '/mnt/c/Visual PJ/Ansible_Demo' && bash ./run_demo.sh"

Write-Host ""
Write-Host "Abriendo http://localhost en tu navegador web..." -ForegroundColor Green
Start-Process "http://localhost"
