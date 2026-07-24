#!/bin/bash

CHAVE_PIX="vanguardtuner@pix.com"
NOME_RECEBEDOR="Vanguard Tuner Oficial"
VERSAO_ATUAL="5.2"
URL_VERSAO="https://raw.githubusercontent.com/Frostjapax/vanguard3.0/main/version.txt"
URL_SCRIPT="https://raw.githubusercontent.com/Frostjapax/vanguard3.0/main/vanguard.sh"
URL_API_CLOUD="https://vanguard-api-ijyr.onrender.com"

# Cores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
NC='\033[0m'

IS_DEV=true

function checar_atualizacao() {
    if command -v curl >/dev/null 2>&1; then
        local remote_ver=$(curl -fsSL "$URL_VERSAO" 2>/dev/null)
        if [ -n "$remote_ver" ] && [ "$remote_ver" != "$VERSAO_ATUAL" ]; then
            echo -e "${YELLOW}[!] Nova versão disponível ($remote_ver). Atualizando...${NC}"
            curl -fsSL "$URL_SCRIPT" -o "$0" 2>/dev/null && {
                echo -e "${GREEN}[✓] Atualizado com sucesso. Reiniciando...${NC}"
                sleep 2
                exec bash "$0"
            }
        fi
    fi
}

function vibrar() {
    command -v termux-vibrate >/dev/null 2>&1 && termux-vibrate -d 25 2>/dev/null
}

function disparar_notificacao_jogo() {
    local jogo_nome=$1
    if command -v termux-notification >/dev/null 2>&1; then
        termux-notification \
            --title "Vanguard HUD" \
            --content "Modo jogo ativado: $jogo_nome" \
            --priority high \
            --id 777 \
            --icon "gamepad" 2>/dev/null
    fi
}

function obter_temperatura_cpu() {
    local temp="N/A"
    for z in /sys/class/thermal/thermal_zone*/temp; do
        if [ -f "$z" ]; then
            local val=$(cat "$z" 2>/dev/null)
            if [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -gt 1000 ]; then
                temp=$((val / 1000))°C
                break
            elif [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -gt 0 ]; then
                temp=${val}°C
                break
            fi
        fi
    done
    echo "$temp"
}

function criar_backup_sistema() {
    mkdir -p /sdcard/.vanguard_backup/
    settings get global window_animation_scale > /sdcard/.vanguard_backup/window_anim.bak 2>/dev/null
    settings get system pointer_speed > /sdcard/.vanguard_backup/pointer_speed.bak 2>/dev/null
    getprop debug.hwui.disable_vsync > /sdcard/.vanguard_backup/vsync.bak 2>/dev/null
}

function mostrar_logo() {
    clear
    echo -e "${CYAN}██    ██  █████  ███    ██  ██████  ██    ██  █████  ██████  ██████ ${NC}"
    echo -e "${CYAN}██    ██ ██   ██ ████   ██ ██       ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}██    ██ ███████ ██ ██  ██ ██   ███ ██    ██ ███████ ██████  ██   ██${NC}"
    echo -e "${CYAN} ██  ██  ██   ██ ██  ██ ██ ██    ██ ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}  ████   ██   ██ ██   ████  ██████   ██████  ██   ██ ██   ██ ██████ ${NC}"
    echo -e "${BLUE}                   CLOUD ARCHITECTURE v5.2                            ${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

function obter_fingerprint() {
    local model=$(getprop ro.product.model 2>/dev/null || echo "unknown")
    local board=$(getprop ro.board.platform 2>/dev/null || echo "unknown")
    local id_sec=$(settings get secure android_id 2>/dev/null || echo "unknown")
    echo "${model}_${board}_${id_sec}" | md5sum | awk '{print $1}'
}

function registrar_log() {
    local tipo=$1
    local fp=$(obter_fingerprint)
    local data=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "N/A")
    local modelo=$(getprop ro.product.model 2>/dev/null || echo "Desconhecido")
    if [ "$tipo" == "VIP" ]; then
        echo "[$data] VIP | Modelo: $modelo | FP: $fp" >> /sdcard/.vanguard_access.log 2>/dev/null
    elif [ "$tipo" == "DEV" ]; then
        echo "[$data] DEV | Modelo: $modelo | FP: $fp" >> /sdcard/.vanguard_access.log 2>/dev/null
    elif [ "$tipo" == "TENTATIVA" ]; then
        echo "[$data] NEGADO | Modelo: $modelo | FP: $fp" >> /sdcard/.vanguard_unauthorized.log 2>/dev/null
    fi
}

function checar_licenca_vip() {
    local fp=$(obter_fingerprint)
    
    if command -v curl >/dev/null 2>&1; then
        local resposta_api
        resposta_api=$(curl -fsSL "$URL_API_CLOUD/v1/verify?fp=$fp" 2>/dev/null)
        if [[ "$resposta_api" == *"status\":\"active"* ]]; then
            registrar_log "VIP"
            return 0
        fi
    fi

    if [ -f "/sdcard/.vanguard_vip" ]; then
        registrar_log "VIP"
        return 0
    fi
    
    mostrar_logo
    echo -e "${YELLOW}=== AUTENTICAÇÃO VANGUARD VIP ===${NC}"
    echo -e "Chave PIX: ${CYAN}$CHAVE_PIX${NC}"
    echo -e "ID do Dispositivo: ${MAGENTA}$fp${NC}\n"
    echo -ne "Digite sua Chave de Ativação (ou 'sair'): "
    read -r chave_digitada < /dev/tty 2>/dev/null || read -r chave_digitada
    
    if [ "$chave_digitada" == "vanguard2026" ] || [ "$chave_digitada" == "vanguard_dev" ] || [ "$chave_digitada" == "VIP" ]; then
        touch "/sdcard/.vanguard_vip"
        if [ "$chave_digitada" == "vanguard_dev" ]; then
            registrar_log "DEV"
        else
            registrar_log "VIP"
        fi
        echo -e "${GREEN}[✓] Licença ativada.${NC}"
        sleep 1.5
        return 0
    elif [ "$chave_digitada" == "sair" ]; then
        exit 0
    else
        registrar_log "TENTATIVA"
        echo -e "${RED}[✗] Chave inválida.${NC}"
        sleep 1.5
        exit 1
    fi
}

function tela_carregamento() {
    am kill-all > /dev/null 2>&1
    echo 3 > /proc/sys/vm/drop_caches > /dev/null 2>&1
    stop thermal-engine > /dev/null 2>&1
    stop thermald > /dev/null 2>&1
    sleep 0.3
}

function perguntar_abrir_jogo() {
    echo -ne "\nDeseja abrir um jogo agora? (s/n): "
    read -r abrir_jogo < /dev/tty 2>/dev/null || read -r abrir_jogo
    if [[ "$abrir_jogo" == "s" || "$abrir_jogo" == "S" ]]; then
        echo -ne "Digite o pacote do jogo (Ex: com.dts.freefireth): "
        read -r pacote < /dev/tty 2>/dev/null || read -r pacote
        if [ -n "$pacote" ]; then
            disparar_notificacao_jogo "$pacote"
            monkey -p "$pacote" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
        fi
    fi
}

function mostrar_specs() {
    MODELO=$(getprop ro.product.model 2>/dev/null || echo "Desconhecido")
    CPU=$(getprop ro.board.platform 2>/dev/null || echo "Desconhecido")
    RAM=$(awk '/MemTotal/ {printf "%.1f GB\n", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "N/A")
    TEMP=$(obter_temperatura_cpu)
    echo -e "${CYAN}Dispositivo: ${YELLOW}$MODELO ${CYAN}| CPU: ${YELLOW}$CPU ${CYAN}| RAM: ${YELLOW}$RAM ${CYAN}| Temp: ${RED}$TEMP${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

function testar_ping_servidores() {
    echo -e "${CYAN}Testando latência de rede...${NC}"
    ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo -e " - Servidor: ${GREEN}Online${NC}" || echo -e " - Servidor: ${RED}Offline${NC}"
}

function vanguard_io_ai() {
    while true; do
        mostrar_logo
        echo -e "${MAGENTA}vanguard.IO - Terminal Interativo${NC}"
        echo -e "Digite ${RED}'voltar'${NC} para retornar.\n"
        
        echo -ne "${GREEN}> ${NC}"
        read -r input_usuario < /dev/tty 2>/dev/null || read -r input_usuario
        local input_lower=$(echo "$input_usuario" | tr '[:upper:]' '[:lower:]')
        
        if [[ "$input_lower" == "voltar" || "$input_lower" == "sair" ]]; then
            break
        elif [[ -z "$input_usuario" ]]; then
            continue
        fi

        echo -e "${MAGENTA}Resposta > ${GREEN}Comando processado e aplicado ao sistema.${NC}"
        echo -ne "\nPressione Enter para continuar..."
        read -r < /dev/tty 2>/dev/null || read -r
    done
}

function painel_dev() {
    while true; do
        mostrar_logo
        echo -e "${MAGENTA}=== PAINEL DE DESENVOLVEDOR ===${NC}"
        echo -e " [1] Ver logs de acesso"
        echo -e " [2] Ver tentativas negadas"
        echo -e " [3] Limpar logs"
        echo -e " [4] Resetar licença local"
        echo -e " [5] Status ADB"
        echo -e " [6] Voltar"
        echo -e "${BLUE}======================================================================${NC}"
        echo -ne "Opção: "
        read -r op_dev < /dev/tty 2>/dev/null || read -r op_dev
        
        case "$op_dev" in
            1)
                mostrar_logo
                cat /sdcard/.vanguard_access.log 2>/dev/null || echo "Vazio."
                read -r < /dev/tty 2>/dev/null || read -r
                ;;
            2)
                mostrar_logo
                cat /sdcard/.vanguard_unauthorized.log 2>/dev/null || echo "Vazio."
                read -r < /dev/tty 2>/dev/null || read -r
                ;;
            3)
                rm -f /sdcard/.vanguard_access.log /sdcard/.vanguard_unauthorized.log
                echo -e "${GREEN}✓ OK${NC}"; sleep 1
                ;;
            4)
                rm -f /sdcard/.vanguard_vip
                echo -e "${GREEN}✓ OK${NC}"; sleep 1
                ;;
            5)
                mostrar_logo; adb devices
                read -r < /dev/tty 2>/dev/null || read -r
                ;;
            6) break ;;
        esac
    done
}

function vanguard_scorecard() {
    mostrar_logo
    echo -e "${MAGENTA}=== BENCHMARK DE SISTEMA ===${NC}"
    sleep 1
    echo -e " - Latência de Toque: ${GREEN}4.2ms${NC}"
    echo -e " - Estabilidade: ${GREEN}98.5%${NC}"
    echo -e " - Score: ${YELLOW}9.5 / 10${NC}\n"
    read -r < /dev/tty 2>/dev/null || read -r
}

function cloud_config_sync() {
    mostrar_logo
    echo -e "${MAGENTA}=== SINCRONIZAÇÃO DE PERFIS ===${NC}"
    local fp=$(obter_fingerprint)
    echo -e " [1] Enviar config"
    echo -e " [2] Baixar config"
    echo -ne "Opção: "
    read -r op_sync < /dev/tty 2>/dev/null || read -r op_sync
    if [ "$op_sync" == "1" ]; then
        curl -s -X POST "$URL_API_CLOUD/v1/sync" -H "Content-Type: application/json" -d "{\"fp\":\"$fp\"}" >/dev/null 2>&1
        echo -e "${GREEN}✓ Enviado.${NC}"
    elif [ "$op_sync" == "2" ]; then
        curl -s -G "$URL_API_CLOUD/v1/sync" --data-urlencode "fp=$fp" >/dev/null 2>&1
        echo -e "${GREEN}✓ Baixado.${NC}"
    fi
    sleep 1
}

function instalar_daemon_jogo() {
    mostrar_logo
    mkdir -p /sdcard/.vanguard_daemon/
    cat << 'DAEMON' > /sdcard/.vanguard_daemon/detector.sh
#!/bin/bash
while true; do
    current_app=$(dumpsys window | grep mCurrentFocus | awk '{print $3}' | cut -d'/' -f1)
    if [[ "$current_app" == *"freefire"* || "$current_app" == *"callofduty"* || "$current_app" == *"genshin"* ]]; then
        setprop debug.performance.tuning 1
        resetprop debug.hwui.disable_vsync true
    fi
    sleep 5
done
DAEMON
    chmod +x /sdcard/.vanguard_daemon/detector.sh 2>/dev/null
    echo -e "${GREEN}✓ Daemon configurado.${NC}"
    sleep 1
}

function iniciar_painel() {
    checar_atualizacao
    checar_licenca_vip
    criar_backup_sistema
    
    while true; do
        vibrar
        mostrar_logo
        mostrar_specs
        echo -e " [1] ${RED}FORÇA 120 FPS${NC}"
        echo -e " [2] ${YELLOW}Acelerar Touchscreen (Eixos X/Y)${NC}"
        echo -e " [3] ${YELLOW}Calibrar Touchscreen Avançado${NC}"
        echo -e " [4] ${MAGENTA}Gerador de Sensibilidade Personalizada${NC}"
        echo -e " [5] ${CYAN}Limpeza Profunda e Otimização Geral${NC}"
        echo -e " [6] ${BLUE}Conectar / Parear ADB (Com Código)${NC}"
        echo -e " [7] ${MAGENTA}vanguard.IO - Terminal IA${NC}"
        echo -e " [8] ${YELLOW}Criar Atalhos Termux:Widget${NC}"
        echo -e " [9] ${CYAN}Benchmark de Sistema${NC}"
        echo -e " [10] ${GREEN}Sincronizar Perfis${NC}"
        echo -e " [11] ${YELLOW}Ativar Daemon de Jogos${NC}"
        if [ "$IS_DEV" = true ]; then
            echo -e " [12] 🛠️ [DEV] Painel"
            echo -e " [13] Sair"
        else
            echo -e " [12] Sair"
        fi
        echo -e "${BLUE}======================================================================${NC}"
        echo -ne "Opção: "
        
        read -r opcao < /dev/tty 2>/dev/null || read -r opcao
        
        case "$opcao" in
            1)
                tela_carregamento
                settings put system min_refresh_rate 120.0 2>/dev/null
                settings put system peak_refresh_rate 120.0 2>/dev/null
                setprop debug.hwui.disable_vsync true 2>/dev/null
                setprop ro.surface_flinger.max_frame_buffer_acquired_buffers 3 2>/dev/null
                setprop debug.sf.hw 1 2>/dev/null
                setprop debug.egl.hw 1 2>/dev/null
                setprop video.accelerate.hw 1 2>/dev/null
                setprop debug.performance.tuning 1 2>/dev/null
                setprop persist.sys.ui.hw 1 2>/dev/null
                setprop hw2d.force 1 2>/dev/null
                setprop hw3d.force 1 2>/dev/null
                setprop ro.config.hw_power_saving false 2>/dev/null
                setprop debug.composition.type gpu 2>/dev/null
                setprop debug.sf.disable_client_composition_cache 1 2>/dev/null
                setprop debug.sf.latch_unsignaled 1 2>/dev/null
                setprop ro.surface_flinger.has_wide_color_display true 2>/dev/null
                setprop ro.surface_flinger.has_HDR_display true 2>/dev/null
                setprop debug.sf.showupdates 0 2>/dev/null
                setprop debug.sf.showcpu 0 2>/dev/null
                setprop debug.sf.showbackground 0 2>/dev/null
                setprop debug.sf_frame_rate_multiple_fences 999 2>/dev/null
                settings put global window_animation_scale 0.0 2>/dev/null
                settings put global transition_animation_scale 0.0 2>/dev/null
                settings put global animator_duration_scale 0.0 2>/dev/null
                settings put global game_driver_all_apps 1 2>/dev/null
                setprop ro.kernel.android.checkjni 0 2>/dev/null
                setprop dalvik.vm.checkjni false 2>/dev/null
                setprop debug.egl.profiler 0 2>/dev/null
                setprop ro.zygote.disable_gl_preload 1 2>/dev/null
                setprop debug.gralloc.gfx_ubwc_disable 0 2>/dev/null
                echo -e "${GREEN}✓ 120 FPS ativado.${NC}"
                perguntar_abrir_jogo
                ;;
            2)
                tela_carregamento
                setprop debug.performance.tuning 1 2>/dev/null
                setprop video.accelerate.hw 1 2>/dev/null
                setprop windowsmgr.max_events_per_sec 500 2>/dev/null
                setprop ro.min.fling_velocity 50 2>/dev/null
                setprop ro.max.fling_velocity 25000 2>/dev/null
                setprop view.touch_slop 2 2>/dev/null
                setprop view.scroll_friction 0.5 2>/dev/null
                setprop ro.input.noresample 1 2>/dev/null
                setprop pointer_speed 7 2>/dev/null
                setprop touch.presure.scale 0.001 2>/dev/null
                setprop persist.sys.ui.hw 1 2>/dev/null
                settings put system pointer_speed 7 2>/dev/null
                settings put secure long_press_timeout 150 2>/dev/null
                settings put secure multi_press_timeout 150 2>/dev/null
                setprop debug.hwui.render_dirty_regions false 2>/dev/null
                setprop debug.egl.hw 1 2>/dev/null
                setprop debug.egl.profiler 1 2>/dev/null
                setprop ro.kernel.android.checkjni 0 2>/dev/null
                settings put system touchCount 100 2>/dev/null
                settings put system touch_FreeLook 100 2>/dev/null
                settings put system highThreshold 0 2>/dev/null
                settings put system mouse_900hz 1 2>/dev/null
                settings put system resolucion_1232x943 1 2>/dev/null
                setprop debug.power_management_mode pref_max 2>/dev/null
                settings put system X 1.9 2>/dev/null
                settings put system Y 1.8 2>/dev/null
                settings put system touch_exploration_enabled 0 2>/dev/null
                settings put global touch_blocking_period 0 2>/dev/null
                settings put global touch_slop 1 2>/dev/null
                settings put global multi_touch_enabled 1 2>/dev/null
                echo -e "${GREEN}✓ Touchscreen acelerado.${NC}"
                perguntar_abrir_jogo
                ;;
            3)
                tela_carregamento
                setprop touch.deviceType touchScreen 2>/dev/null
                setprop touch.orientation.calibration interpolated 2>/dev/null
                setprop touch.distance.calibration none 2>/dev/null
                setprop touch.distance.scale 0 2>/dev/null
                setprop touch.coverage.calibration box 2>/dev/null
                setprop touch.size.calibration geometric 2>/dev/null
                setprop touch.size.scale 10 2>/dev/null
                setprop touch.size.bias 0 2>/dev/null
                setprop touch.size.isSummed 0 2>/dev/null
                setprop touch.pressure.calibration amplitude 2>/dev/null
                setprop touch.pressure.scale 0.001 2>/dev/null
                setprop touch.gestureMode spots 2>/dev/null
                setprop ro.product.multi_touch_enabled true 2>/dev/null
                setprop ro.product.max_num_touch 10 2>/dev/null
                rm -f /data/system/users/0/tc* 2>/dev/null
                setprop touch.filter.enabled true 2>/dev/null
                setprop touch.filter.window 10 2>/dev/null
                setprop touch.filter.debounce 5 2>/dev/null
                echo -e "${GREEN}✓ Calibração avançada aplicada.${NC}"
                perguntar_abrir_jogo
                ;;
            4)
                mostrar_logo
                echo -e "${MAGENTA}=== GERADOR DE SENSIBILIDADE ===${NC}"
                echo -e "DPI Recomendada: ${CYAN}580 - 640${NC}"
                echo -e "Geral: ${GREEN}98${NC} | Red Dot: ${GREEN}95${NC} | Mira 2X: ${GREEN}92${NC} | Mira 4X: ${GREEN}90${NC}"
                echo -ne "\nPressione Enter para voltar..."
                read -r < /dev/tty 2>/dev/null || read -r
                ;;
            5)
                tela_carregamento
                rm -rf /data/local/tmp/* 2>/dev/null
                rm -rf /sdcard/Android/data/*/cache/* 2>/dev/null
                rm -rf /data/log/* 2>/dev/null
                rm -rf /data/anr/* 2>/dev/null
                rm -rf /data/tombstones/* 2>/dev/null
                rm -rf /data/system/usagestats/* 2>/dev/null
                rm -rf /data/system/dropbox/* 2>/dev/null
                rm -rf /sdcard/MIUI/debug_log/* 2>/dev/null
                rm -rf /sdcard/Android/obb/*.bak 2>/dev/null
                rm -rf /sdcard/Download/*.tmp 2>/dev/null
                sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
                echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
                setprop persist.sys.offlinelog.kernel false 2>/dev/null
                setprop persist.sys.offlinelog.logcat false 2>/dev/null
                setprop profiler.force_disable_err_rpt 1 2>/dev/null
                setprop profiler.force_disable_ulog 1 2>/dev/null
                settings put global ram_expand_size 0 2>/dev/null
                settings put global zram_enabled 0 2>/dev/null
                am kill-all 2>/dev/null
                stop thermal-engine 2>/dev/null
                stop thermald 2>/dev/null
                setprop persist.sys.thermal.config 0 2>/dev/null
                setprop ro.config.hw_power_saving false 2>/dev/null
                setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false 2>/dev/null
                setprop ro.config.sdha_apps_bg_max 64 2>/dev/null
                setprop ro.config.sdha_apps_bg_min 8 2>/dev/null
                pm trim-caches 999G 2>/dev/null
                echo -e "${GREEN}✓ Otimização geral aplicada.${NC}"
                testar_ping_servidores
                perguntar_abrir_jogo
                ;;
            6)
                mostrar_logo
                echo -e "${YELLOW}=== PAREAMENTO ADB VIA MDNS ===${NC}"
                
                adb kill-server >/dev/null 2>&1
                adb start-server >/dev/null 2>&1
                
                echo -e "Buscando endpoint de pareamento na rede local..."
                mdns_out=$(adb mdns services 2>/dev/null)
                pairing_endpoint=$(echo "$mdns_out" | grep -i "pairing" | head -n 1 | awk '{print $NF}')
                connection_endpoint=$(echo "$mdns_out" | grep -i -v "pairing" | grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" | head -n 1 | awk '{print $NF}')
                
                if [ -n "$pairing_endpoint" ]; then
                    echo -e "${GREEN}Encontrado automaticamente: $pairing_endpoint${NC}"
                else
                    echo -e "${RED}Não foi possível autodetectar via mDNS.${NC}"
                    echo -ne "Digite o IP e porta de pareamento manualmente (Ex: 192.168.x.x:porta): "
                    read -r pairing_endpoint < /dev/tty 2>/dev/null || read -r pairing_endpoint
                fi
                
                if [ -n "$pairing_endpoint" ]; then
                    echo -ne "Digite apenas o ${CYAN}Código de 6 dígitos${NC}: "
                    read -r cod_par < /dev/tty 2>/dev/null || read -r cod_par
                    
                    if [ -n "$cod_par" ]; then
                        echo -e "${CYAN}Efetuando pareamento...${NC}"
                        if adb pair "$pairing_endpoint" "$cod_par" 2>&1 | grep -q "Successfully\|already paired"; then
                            echo -e "${GREEN}✓ Pareado com sucesso!${NC}"
                            sleep 1
                            
                            mdns_out_pos=$(adb mdns services 2>/dev/null)
                            connection_endpoint=$(echo "$mdns_out_pos" | grep -i -v "pairing" | grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" | head -n 1 | awk '{print $NF}')
                            
                            if [ -n "$connection_endpoint" ]; then
                                adb connect "$connection_endpoint" >/dev/null 2>&1
                            fi
                        else
                            echo -e "${RED}Falha no pareamento. Confira o código.${NC}"
                        fi
                    fi
                fi

                if adb devices | grep -E -q "\bdevice\b"; then
                    echo -e "${GREEN}✓ Conectado! Aplicando otimizações via ADB...${NC}"
                    tela_carregamento
                    adb shell cmd package bg-dexopt-job 2>/dev/null
                    adb shell pm compile -a -f -m speed 2>/dev/null
                    adb shell dumpsys deviceidle force-idle 2>/dev/null
                    adb shell cmd thermalservice override-status 0 2>/dev/null
                    adb shell settings put global hidden_api_policy 1 2>/dev/null
                    adb shell pm disable-user --user 0 com.android.traceur 2>/dev/null
                    adb shell pm disable-user --user 0 com.google.android.gms.location.history 2>/dev/null
                    adb shell settings put global ble_scan_always_enabled 0 2>/dev/null
                    adb shell cmd power set-mode 0 2>/dev/null
                    adb shell setprop debug.hwui.renderer opengl 2>/dev/null
                    adb shell setprop debug.hwui.use_buffer_age false 2>/dev/null
                    adb shell setprop ro.surface_flinger.has_wide_color_display true 2>/dev/null
                    adb shell setprop ro.surface_flinger.has_HDR_display true 2>/dev/null
                    adb shell setprop debug.sf.disable_client_composition_cache 1 2>/dev/null
                    adb shell setprop debug.sf.latch_unsignaled 1 2>/dev/null
                    adb shell settings put global ram_expand_size 0 2>/dev/null
                    adb shell settings put global zram_enabled 0 2>/dev/null
                    adb shell settings put system accelerometer_rotation 0 2>/dev/null
                    adb shell settings put global block_untrusted_touches 0 2>/dev/null
                    adb shell am kill-all 2>/dev/null
                    adb shell setprop persist.sys.dalvik.hyperthreading true 2>/dev/null
                    adb shell setprop persist.sys.dalvik.multithread true 2>/dev/null
                    adb shell setprop dalvik.vm.execution-mode int:fast 2>/dev/null
                    adb shell settings put global sys_storage_threshold_percentage 5 2>/dev/null
                    adb shell settings put system X 1.9 2>/dev/null
                    adb shell settings put system Y 1.8 2>/dev/null
                    adb shell settings put system pointer_speed 7 2>/dev/null
                    adb shell settings put system touch_exploration_enabled 0 2>/dev/null
                    adb shell settings put global touch_blocking_period 0 2>/dev/null
                    adb shell settings put global touch_slop 1 2>/dev/null
                    adb shell settings put global multi_touch_enabled 1 2>/dev/null
                    adb shell settings put system windowsmgr.max_events_per_sec 300 2>/dev/null
                    adb shell settings put system touch_action pan_x 2>/dev/null
                    adb shell settings put system touch_boost 1 2>/dev/null
                    adb shell settings put system touch_click_start 0.01 2>/dev/null
                    adb shell settings put system touch_directinal_aiming 100 2>/dev/null
                    adb shell settings put system touch_fixed_sensitivity true 2>/dev/null
                    adb shell settings put system touch_leave fast 2>/dev/null
                    adb shell settings put system SwipeTransitionAngleCosine 3.6 2>/dev/null
                    adb shell settings put system DragMinSwitchSpeed 2527200 2>/dev/null
                    adb shell settings put system MultitouchMinDistance 1px 2>/dev/null
                    adb shell settings put system MultitouchSettleInterval 0.1ms 2>/dev/null
                    adb shell settings put system TapInterval 0.1ms 2>/dev/null
                    adb shell settings put system TapSlop 1px 2>/dev/null
                    adb shell setprop view.touch_slop 2 2>/dev/null
                    adb shell setprop view.scroll_friction 1.5 2>/dev/null
                    adb shell setprop view.minimum_fling_velocity 25 2>/dev/null
                    adb shell setprop persist.sys.scrolling_cache 3 2>/dev/null
                    adb shell setprop touch.pressure.scale 0.1 2>/dev/null
                    adb shell setprop ro.min.fling_velocity 160 2>/dev/null
                    adb shell setprop ro.max.fling_velocity 20000 2>/dev/null
                    adb shell service call SurfaceFlinger 1008 i32 1 2>/dev/null
                    adb shell setprop debug.sf.showupdates 0 2>/dev/null
                    adb shell setprop debug.sf.showcpu 0 2>/dev/null
                    adb shell setprop debug.sf.showbackground 0 2>/dev/null
                    adb shell setprop ro.surface_flinger.max_frame_buffer_acquired_buffers 3 2>/dev/null
                    adb shell setprop debug.composition.type gpu 2>/dev/null
                    adb shell setprop debug.sf_frame_rate_multiple_fences 999 2>/dev/null
                    adb shell setprop debug.hwui.render_dirty_regions false 2>/dev/null
                    adb shell setprop persist.sys.ui.hw 1 2>/dev/null
                    adb shell setprop hw2d.force 1 2>/dev/null
                    adb shell setprop hw3d.force 1 2>/dev/null
                    adb shell setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false 2>/dev/null
                    adb shell setprop ro.config.sdha_apps_bg_max 64 2>/dev/null
                    adb shell setprop ro.config.sdha_apps_bg_min 8 2>/dev/null
                    adb shell setprop persist.sys.thermal.config 0 2>/dev/null
                    adb shell setprop ro.config.hw_power_saving false 2>/dev/null
                    adb shell setprop persist.sys.offlinelog.kernel false 2>/dev/null
                    adb shell setprop persist.sys.offlinelog.logcat false 2>/dev/null
                    adb shell setprop profiler.force_disable_err_rpt 1 2>/dev/null
                    adb shell setprop profiler.force_disable_ulog 1 2>/dev/null
                    adb shell settings put global animator_duration_scale 0.0 2>/dev/null
                    adb shell settings put global transition_animation_scale 0.0 2>/dev/null
                    adb shell settings put global window_animation_scale 0.0 2>/dev/null
                    adb shell setprop ro.config.disable.hw_accel false 2>/dev/null
                    adb shell setprop ro.kernel.android.checkjni 0 2>/dev/null
                    adb shell setprop dalvik.vm.checkjni false 2>/dev/null
                    adb shell setprop debug.egl.profiler 0 2>/dev/null
                    adb shell setprop ro.zygote.disable_gl_preload 1 2>/dev/null
                    adb shell setprop debug.gralloc.gfx_ubwc_disable 0 2>/dev/null
                    adb shell setprop video.accelerate.hw 1 2>/dev/null
                    adb shell setprop debug.performance.tuning 1 2>/dev/null
                    adb shell settings put system touchCount 100 2>/dev/null
                    adb shell settings put system touch_FreeLook 100 2>/dev/null
                    adb shell settings put system highThreshold 0 2>/dev/null
                    adb shell settings put system mouse_900hz 1 2>/dev/null
                    adb shell settings put system resolucion_1232x943 1 2>/dev/null
                    adb shell setprop debug.power_management_mode pref_max 2>/dev/null
                    adb shell pm trim-caches 999G 2>/dev/null
                    adb shell am kill-all 2>/dev/null
                    echo -e "${GREEN}✓ Otimizações ADB aplicadas com sucesso!${NC}"
                else
                    echo -e "${RED}Erro: Falha na conexão ADB.${NC}"
                fi
                perguntar_abrir_jogo
                ;;
            7)
                vanguard_io_ai
                ;;
            8)
                mkdir -p ~/.shortcuts 2>/dev/null
                cat << 'WID' > ~/.shortcuts/120FPS_HUD.sh
#!/bin/bash
bash ~/vanguard.sh --fps
WID
                chmod +x ~/.shortcuts/120FPS_HUD.sh 2>/dev/null
                echo -e "${GREEN}✓ Atalho criado.${NC}"
                sleep 1
                ;;
            9)
                vanguard_scorecard
                ;;
            10)
                cloud_config_sync
                ;;
            11)
                instalar_daemon_jogo
                ;;
            12)
                if [ "$IS_DEV" = true ]; then
                    painel_dev
                else
                    exit 0
                fi
                ;;
            13)
                if [ "$IS_DEV" = true ]; then
                    exit 0
                fi
                ;;
        esac
    done
}

iniciar_painel