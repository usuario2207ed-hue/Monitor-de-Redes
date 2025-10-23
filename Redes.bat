@echo off
title Monitor de Rede Pro v2 - Desenvolvido por EdCellTech
color 0a
mode con cols=100 lines=40
setlocal enabledelayedexpansion

set "pastaRelatorios=%~dp0Relatorios"
if not exist "%pastaRelatorios%" mkdir "%pastaRelatorios%"

:MENU
cls
echo ==========================================================
echo             MONITOR DE REDE PRO v2 - EDCELLTECH
echo ==========================================================
echo.
echo [1] Ver conexoes ativas e programas
echo [2] Historico de conexoes Wi-Fi
echo [3] Sites acessados
echo [4] Trafego de rede em tempo real
echo [5] Logs detalhados do sistema
echo [6] Configuracao completa da rede
echo [7] Dispositivos conectados na LAN
echo [8] Gerar relatorio completo
echo [9] Limpar cache DNS
echo [10] Mostrar IP local e publico
echo [11] Escanear rede local
echo [12] Mostrar configuracao TCP global
echo [13] Ativar autotuning
echo [14] Mostrar nome do PC e IP local
echo [15] Mostrar IP publico
echo [16] Listar computadores na rede
echo [17] Mostrar ARP
echo [18] Varredura rapida na subrede /24
echo [19] Abrir interface grafica de desligamento remoto
echo [20] Desligar/reiniciar PC remoto
echo [21] Mostrar adaptadores de rede
echo [22] Testar conexao a um host
echo [0] Sair
echo.
set /p op=Escolha uma opcao: 

if "%op%"=="1" goto CONEXOES
if "%op%"=="2" goto WLAN
if "%op%"=="3" goto DNS
if "%op%"=="4" goto TRAFEGO
if "%op%"=="5" goto LOGS
if "%op%"=="6" goto CONFIG
if "%op%"=="7" goto LAN
if "%op%"=="8" goto RELATORIO
if "%op%"=="9" goto LIMPAR
if "%op%"=="10" goto IP
if "%op%"=="11" goto SCANLAN
if "%op%"=="12" goto TCPSHOW
if "%op%"=="13" goto TCPSET
if "%op%"=="14" goto ADV_show_local
if "%op%"=="15" goto ADV_show_public
if "%op%"=="16" goto ADV_netview
if "%op%"=="17" goto ADV_arp
if "%op%"=="18" goto ADV_pingsweep
if "%op%"=="19" goto ADV_shutdown_gui
if "%op%"=="20" goto ADV_remote_shutdown
if "%op%"=="21" goto ADV_show_ipconfig
if "%op%"=="22" goto ADV_simple_ping
if "%op%"=="0" exit
goto MENU

:CONEXOES
cls
echo ==============================================
echo     CONEXOES ATIVAS E PROGRAMAS (netstat)
echo ==============================================
echo.
netstat -ano | findstr ESTAB
echo.
echo Para descobrir qual programa usa o PID:
echo tasklist ^| findstr [PID]
pause
goto MENU

:WLAN
cls
echo ==============================================
echo     GERANDO RELATORIO DE CONEXOES WI-FI
echo ==============================================
echo.
netsh wlan show wlanreport
echo.
echo Relatorio salvo em:
echo C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html
pause
goto MENU

:DNS
cls
echo ==============================================
echo     SITES ACESSADOS (CACHE DNS)
echo ==============================================
echo.
ipconfig /displaydns
pause
goto MENU

:TRAFEGO
cls
echo ==============================================
echo     TRAFEGO DE REDE EM TEMPO REAL
echo ==============================================
echo Pressione CTRL + C para parar.
echo ==============================================
netstat -b 5
pause
goto MENU

:LOGS
cls
echo ==============================================
echo     LOGS DETALHADOS DO SISTEMA
echo ==============================================
echo.
start eventvwr.msc
echo Abrindo o Visualizador de Eventos...
pause
goto MENU

:CONFIG
cls
echo ==============================================
echo     CONFIGURACAO COMPLETA DA REDE
echo ==============================================
echo.
ipconfig /all
pause
goto MENU

:LAN
cls
echo ==============================================
echo     DISPOSITIVOS CONECTADOS NA REDE LOCAL (ARP)
echo ==============================================
echo.
arp -a
echo.
echo Dica: Cada IP listado representa um dispositivo ativo na rede LAN.
pause
goto MENU

:RELATORIO
cls
echo ==============================================
echo     GERANDO RELATORIO COMPLETO DE REDE
echo ==============================================
set "arquivo=%pastaRelatorios%\Relatorio-Rede-%date:/=-%_%time::=-%.txt"
echo Criando relatorio: %arquivo%
(
    echo ===================================================
    echo RELATORIO DE REDE - EDCELLTECH
    echo Data: %date% - Hora: %time%
    echo ===================================================
    echo.
    echo ===== CONEXOES ATIVAS =====
    netstat -ano
    echo.
    echo ===== CONFIGURACAO IP =====
    ipconfig /all
    echo.
    echo ===== DISPOSITIVOS LAN =====
    arp -a
    echo.
    echo ===== CACHE DNS =====
    ipconfig /displaydns
) > "%arquivo%"
echo.
echo Relatorio salvo em: "%arquivo%"
pause
goto MENU

:LIMPAR
cls
echo ==============================================
echo     LIMPANDO CACHE DNS
echo ==============================================
ipconfig /flushdns
pause
goto MENU

:IP
cls
echo ==============================================
echo     IP LOCAL E IP PUBLICO
echo ==============================================
echo.
echo IP LOCAL:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    set "tmp=%%a"
    set "tmp=!tmp: =!"
    echo !tmp!
    goto afteripshow
)
:afteripshow
echo.
echo IP PUBLICO:
curl -s ifconfig.me
echo.
echo ==============================================
pause
goto MENU

:SCANLAN
cls
echo ==============================================
echo     ESCANEAMENTO DA REDE LOCAL (PING SWEEP)
echo ==============================================
echo Detectando IP local...
rem --- detectar o IPv4 principal ---
set "rawip="
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    set "rawip=%%a"
    goto gotip
)
:gotip
if "%rawip%"=="" (
    echo Nao foi possivel detectar o IP local.
    echo Execute o script com permissao de administrador.
    pause
    goto MENU
)
set "rawip=%rawip: =%"
echo IP detectado: %rawip%

rem --- extrair prefixo /24 (remover ultimo octeto) ---
for /f "tokens=1-4 delims=." %%a in ("%rawip%") do (
    set "prefix=%%a.%%b.%%c."
)

echo Prefixo de rede: !prefix!0/24
echo.

set "arquivo=%pastaRelatorios%\Scan-LAN-%date:/=-%_%time::=-%.txt"
echo Scan LAN - %date% %time% > "%arquivo%"
echo IP detectado: %rawip% >> "%arquivo%"
echo Prefixo: !prefix! >> "%arquivo%"
echo. >> "%arquivo%"

echo Iniciando ping sweep (1-254). Isso pode levar alguns minutos...
echo Resultado (hosts ativos) aparecera abaixo e sera salvo em: "%arquivo%"
echo.

rem --- varrer 1 a 254 ---
for /L %%i in (1,1,254) do (
    ping -n 1 -w 80 !prefix!%%i >nul
    if not errorlevel 1 (
        echo Host ativo: !prefix!%%i
        echo !prefix!%%i >> "%arquivo%"
        rem tentar resolver nome
        nslookup !prefix!%%i 2>nul | findstr /R /C:"Name" >> "%arquivo%"
    )
)

echo. >> "%arquivo%"
echo ARP table: >> "%arquivo%"
arp -a >> "%arquivo%"

echo.
echo Escaneamento concluido.
echo Resultados salvos em: "%arquivo%"
pause
goto MENU

:TCPSHOW
cls
echo ==============================================
echo     CONFIGURACAO TCP GLOBAL (netsh interface tcp show global)
echo ==============================================
echo.
netsh interface tcp show global
echo.
pause
goto MENU

:TCPSET
cls
echo ==============================================
echo     ATIVANDO AUTOTUNING (netsh interface tcp set global autotuning=normal)
echo ==============================================
echo.
echo Observacao: Essa operacao pode requerer permissao de administrador.
netsh interface tcp set global autotuning=normal
echo.
echo Comando executado.
pause
goto MENU

:: =========================
:: === MENU AVANCADO (funcionalidades adicionadas) ===
:: =========================

:ADV_show_local
cls
echo ==============================================
echo     NOME DO PC E IP(S) LOCAL(ais)
echo ==============================================
echo Nome do computador:
hostname
echo.
echo IP(s) locais (IPv4):
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /R /C:"IPv4"') do (
  set ipline=%%A
  rem remove espaco inicial
  set ipline=!ipline:~1!
  echo !ipline!
)
echo.
pause
goto MENU

:ADV_show_public
cls
echo ==============================================
echo     IP PUBLICO
echo ==============================================
echo Obtendo IP publico...
rem Usa curl (Windows 11 tem curl). Se nao, usa powershell fallback.
set "ippub="
for /f "usebackq delims=" %%A in (`curl -s ifconfig.me 2^>nul`) do set "ippub=%%A"
if "%ippub%"=="" (
  for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "(Invoke-WebRequest -UseBasicParsing -Uri 'https://api.ipify.org').Content" 2^>nul`) do set "ippub=%%A"
)
if "%ippub%"=="" (
  echo Nao foi possivel obter IP publico automaticamente.
) else (
  echo IP publico: %ippub%
)
echo.
pause
goto MENU

:ADV_netview
cls
echo ==============================================
echo     LISTAR COMPUTADORES NA REDE (net view)
echo ==============================================
echo Listando computadores visiveis no dominio/grupo de trabalho (net view)...
echo (pode demorar alguns segundos)
echo.
net view
echo.
pause
goto MENU

:ADV_arp
cls
echo ==============================================
echo     TABELA ARP (DISPOSITIVOS DETECTADOS)
echo ==============================================
echo Tabela ARP (IPs ja vistos na rede):
arp -a
echo.
pause
goto MENU

:ADV_pingsweep
cls
echo ==============================================
echo     VARREDURA RAPIDA NA SUBREDE /24 (PING SWEEP)
echo ==============================================
echo Isto tenta pingar: mesma rede local (usa o primeiro IPv4 encontrado).
echo Pode demorar dependendo da rede.
echo.

:: pega o primeiro IPv4
set "myip="
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /R /C:"IPv4"') do (
  set ipline=%%A
  set ipline=!ipline:~1!
  if "!myip!"=="" set "myip=!ipline!"
)
if "%myip%"=="" (
  echo Nao foi possivel detectar o IP local. Abortando varredura.
  pause
  goto MENU
)

echo IP local detectado: %myip%
for /f "tokens=1-4 delims=." %%a in ("%myip%") do (
  set A=%%a
  set B=%%b
  set C=%%c
  set D=%%d
)
set "subnet=%A%.%B%.%C%"

echo Sub-rede detectada: %subnet%.0/24
echo Iniciando ping sweep (responde somente se o firewall permitir)...
echo Dispositivos online serao salvos em "%~dp0tmp_hosts.txt"
> "%~dp0tmp_hosts.txt" (echo Hosts online na subrede %subnet%.0/24)

for /L %%i in (1,1,254) do (
  set "target=%subnet%.%%i"
  rem ping 1 pacote com timeout 200ms
  ping -n 1 -w 200 !target! >nul
  if !errorlevel! == 0 (
    echo !target! >> "%~dp0tmp_hosts.txt"
    echo Host encontrado: !target!
  )
)
echo.
echo Varredura concluida.
echo Conteudo do arquivo tmp_hosts.txt:
type "%~dp0tmp_hosts.txt"
echo.
pause
goto MENU

:ADV_shutdown_gui
cls
echo ==============================================
echo     INTERFACE GRAFICA DE SHUTDOWN REMOTO
echo ==============================================
echo Abrindo a interface grafica de Shutdown remoto...
echo (requer privilegios para operar em outros PCs)
shutdown -i
echo.
pause
goto MENU

:ADV_remote_shutdown
cls
echo ==============================================
echo     DESLIGAR/REINICIAR PC REMOTO (via \\NOME ou \\IP)
echo ==============================================
echo ATENCAO: para desligar/reiniciar remoto voce precisa de permissao/credenciais no PC alvo.
echo Se a rede/Firewall bloqueia, pode nao funcionar.
echo.
set /p target="Digite \\\\NOMEou\\\\IP (ex: \\\\MEU-PC ou \\\\192.168.1.50): "
if "%target%"=="" (
  echo Nenhum alvo informado. Voltando ao menu.
  pause
  goto MENU
)
echo.
echo Escolha acao para %target%:
echo 1. Desligar agora
echo 2. Reiniciar agora
echo 3. Cancelar acao remota (abort)
set /p act="Opcao: "
if "%act%"=="1" (
  echo Enviando comando de desligamento para %target% ...
  shutdown /m %target% /s /t 0
  echo Comando enviado.
  pause
  goto MENU
)
if "%act%"=="2" (
  echo Enviando comando de reinicio para %target% ...
  shutdown /m %target% /r /t 0
  echo Comando enviado.
  pause
  goto MENU
)
if "%act%"=="3" (
  echo Enviando cancelamento de shutdown para %target% ...
  shutdown /m %target% /a
  echo Comando de abort enviado.
  pause
  goto MENU
)
echo Opcao invalida.
pause
goto MENU

:ADV_show_ipconfig
cls
echo ==============================================
echo     ADAPTADORES DE REDE (ipconfig /all) - AVANCADO
echo ==============================================
ipconfig /all
echo.
pause
goto MENU

:ADV_simple_ping
cls
echo ==============================================
echo     TESTAR CONEXAO A UM HOST (PING SIMPLES)
echo ==============================================
set /p host="Digite host ou IP para testar (ex: google.com ou 192.168.1.1): "
if "%host%"=="" (
  echo Nenhum host informado.
  pause
  goto MENU
)
echo Testando ping para %host% (4 pacotes)...
ping %host% -n 4
echo.
pause
goto MENU
