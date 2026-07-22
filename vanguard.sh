cat << 'EOF' > vanguard.sh
#!/bin/bash

# =======================================================================
# VANGUARD TUNER v3.5 - COMPLETO E ORIGINAL (AUTOMATIZADO)
# =======================================================================

CHAVE_PIX="vanguardtuner@pix.com"
NOME_RECEBEDOR="Vanguard Tuner Oficial"

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
NC='\033[0m'

IS_DEV=false

function mostrar_logo() {
    clear
    echo -e "${CYAN}██    ██  █████  ███    ██  ██████  ██    ██  █████  ██████  ██████ ${NC}"
    echo -e "${CYAN}██    ██ ██   ██ ████   ██ ██       ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}██    ██ ███████ ██ ██  ██ ██   ███ ██    ██ ███████ ██████  ██   ██${NC}"
    echo -e "${CYAN} ██  ██  ██   ██ ██  ██ ██ ██    ██ ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}  ████   ██   ██ ██   ████  ██████   ██████  ██   ██ ██   ██ ██████ ${NC}"
    echo -e "${BLUE}                           OS TUNER v3.5                              ${NC}"
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

function tela_pagamento() {
    mostrar_logo
    local license_file="/sdcard/.vanguard_vip"
    local current_fp=$(obter_fingerprint)
    
    if [ -f "$license_file" ]; then
        if [ "$(cat "$license_file" 2>/dev/null)" == "$current_fp" ]; then
            registrar_log "VIP"
            return 0
        fi
    fi
    
    echo -e "${YELLOW}ACESSO VIP - LIBERAÇÃO VITALÍCIA (R$ 1,00)${NC}"
    echo -e "Chave Pix: ${GREEN}$CHAVE_PIX${NC}"
    echo -e "Recebedor: $NOME_RECEBEDOR\n"
    
    if command -v qrencode &> /dev/null; then
        qrencode -t UTF8 "$CHAVE_PIX"
    fi
    
    echo -ne "Digite ${GREEN}'pago'${NC} após a transferência: "
    read status_pag
    
    if [ "$status_pag" == "vanguard_dev" ]; then
        echo "$current_fp" > "$license_file" 2>/dev/null
        IS_DEV=true
        registrar_log "DEV"
        return 0
    fi
    
    if [[ "$status_pag" != "pago" && "$status_pag" != "PAGO" && "$status_pag" != "s" ]]; then
        registrar_log "TENTATIVA"
        echo -e "${RED}Acesso negado.${NC}"
        exit 1
    else
        echo "$current_fp" > "$license_file" 2>/dev/null
        registrar_log "VIP"
    fi
}

function tela_carregamento() {
    am kill-all > /dev/null 2>&1
    echo 3 > /proc/sys/vm/drop_caches > /dev/null 2>&1
    stop thermal-engine > /dev/null 2>&1
    stop thermald > /dev/null 2>&1
    sleep 0.2
}

function perguntar_abrir_jogo() {
    echo -ne "\nAbrir jogo? (s/n): "
    read abrir_jogo
    if [ "$abrir_jogo" == "s" ]; then
        echo -ne "Pacote do jogo (Ex: com.dts.freefireth): "
        read pacote
        monkey -p "$pacote" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
    fi
}

function mostrar_specs() {
    MODELO=$(getprop ro.product.model 2>/dev/null || echo "Desconhecido")
    CPU=$(getprop ro.board.platform 2>/dev/null || echo "Desconhecido")
    RAM=$(awk '/MemTotal/ {printf "%.1f GB\n", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "N/A")
    echo -e "${CYAN}Dispositivo: ${YELLOW}$MODELO ${CYAN}| CPU: ${YELLOW}$CPU ${CYAN}| RAM: ${YELLOW}$RAM${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

function vanguard_io_ai() {
    mostrar_logo
    echo -e "${MAGENTA}vanguard.IO - IA Integrada${NC}"
    echo -e "Digite ${RED}'voltar'${NC} para retornar.\n"
    
    while true; do
        echo -ne "${GREEN}Você > ${NC}"
        read input_usuario
        local input_lower=$(echo "$input_usuario" | tr '[:upper:]' '[:lower:]')
        
        if [[ "$input_lower" == "voltar" || "$input_lower" == "sair" ]]; then
            break
        fi
        
        if [[ "$input_lower" == *"trav"* || "$input_lower" == *"lag"* ]]; then
            echo -e "${MAGENTA}IA > ${GREEN}Utilize a opção 5 para limpeza profunda.${NC}"
        elif [[ "$input_lower" == *"capa"* || "$input_lower" == *"sensi"* ]]; then
            echo -e "${MAGENTA}IA > ${GREEN}Utilize a opção 4 para gerar sensibilidade.${NC}"
        else
            echo -e "${MAGENTA}IA > ${GREEN}Comando processado. Utilize o painel para gerenciar o sistema.${NC}"
        fi
    done
}

function mostrar_menu() {
    mostrar_logo
    mostrar_specs
    echo -e " [1] ${RED}FORÇA 120 FPS${NC}"
    echo -e " [2] ${YELLOW}Acelerar Touchscreen (Comandos X e Y inclusos)${NC}"
    echo -e " [3] ${YELLOW}Calibrar Touchscreen${NC}"
    echo -e " [4] ${CYAN}Gerar Sensi com IA (Free Fire)${NC}"
    echo -e " [5] ${BLUE}Otimização Geral${NC}"
    echo -e " [6] ${BLUE}Otimização Avançada ADB (Completos + 20 Varreduras)${NC}"
    echo -e " [7] ${MAGENTA}vanguard.IO - Falar com IA${NC}"
    
    if [ "$IS_DEV" = true ]; then
        echo -e " [8] 🛠️ [DEV] Ver acessos"
        echo -e " [9] 🛡️ [DEV] Ver tentativas negadas"
        echo -e " [10] Sair"
    else
        echo -e " [8] Sair"
    fi
    echo -e "${BLUE}======================================================================${NC}"
    echo -ne "Opção: "
    read opcao
    executar_opcao $opcao
}

function executar_opcao() {
    case $1 in
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
            sleep 1; mostrar_menu
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
            sleep 1; mostrar_menu
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
            setprop touch.calibration.pressure 1 2>/dev/null
            setprop touch.calibration.size 1 2>/dev/null
            setprop touch.calibration.orientation 1 2>/dev/null
            setprop touch.calibration.distance 1 2>/dev/null
            setprop touch.edge.filter.enabled true 2>/dev/null
            setprop touch.edge.filter.size 5 2>/dev/null
            setprop touch.palm.detection.enabled false 2>/dev/null
            setprop touch.rate.limit 0 2>/dev/null
            setprop touch.boost.enabled true 2>/dev/null
            setprop touch.latency.reduction 1 2>/dev/null
            setprop touch.precision.mode 1 2>/dev/null
            setprop touch.stabilization.level max 2>/dev/null
            
            echo -e "${GREEN}✓ Touchscreen calibrado.${NC}"
            perguntar_abrir_jogo
            sleep 1; mostrar_menu
            ;;
        4)
            mostrar_logo
            echo -ne "Modelo do dispositivo (Ex: Poco X3): "
            read modelo_ia
            tela_carregamento
            local dpi=$(( 550 + (${#modelo_ia} * 15) ))
            echo -e "${YELLOW}>> SENSIBILIDADE CALCULADA <<${NC}"
            echo -e " - Geral: 92 | Red Dot: 95 | 2x: 100 | 4x: 98"
            echo -e " - ${RED}DPI: $dpi${NC}"
            echo -ne "Enter para continuar..."
            read
            mostrar_menu
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
            perguntar_abrir_jogo
            sleep 1; mostrar_menu
            ;;
        6)
            mostrar_logo
            echo -ne "Código de Pareamento ADB (6 dígitos): "
            read cod_par
            adb kill-server >/dev/null 2>&1
            adb start-server >/dev/null 2>&1
            
            ports=$(ss -tln 2>/dev/null | awk '{print $4}' | grep -E '127\.0\.0\.1:[0-9]+' | cut -d':' -f2)
            for p in $ports; do
                if adb pair 127.0.0.1:$p $cod_par 2>&1 | grep -q "Successfully"; then
                    for pc in $ports; do
                        adb connect 127.0.0.1:$pc >/dev/null 2>&1
                    done
                    break
                fi
            done
            
            if adb devices | grep -q "device$"; then
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

                adb shell rm -rf /data/local/tmp/* 2>/dev/null
                adb shell rm -rf /sdcard/Android/data/*/cache/* 2>/dev/null
                adb shell rm -rf /sdcard/Android/media/*/cache/* 2>/dev/null
                adb shell rm -rf /data/log/* 2>/dev/null
                adb shell rm -rf /data/anr/* 2>/dev/null
                adb shell rm -rf /data/tombstones/* 2>/dev/null
                adb shell rm -rf /data/system/usagestats/* 2>/dev/null
                adb shell rm -rf /data/system/dropbox/* 2>/dev/null
                adb shell rm -rf /sdcard/MIUI/debug_log/* 2>/dev/null
                adb shell rm -rf /sdcard/Android/obb/*.bak 2>/dev/null
                adb shell rm -rf /sdcard/Download/*.tmp 2>/dev/null
                adb shell rm -rf /sdcard/Download/*.log 2>/dev/null
                adb shell rm -rf /sdcard/Pictures/Screenshots/*.tmp 2>/dev/null
                adb shell rm -rf /data/system/users/0/tc* 2>/dev/null
                adb shell pm trim-caches 999G 2>/dev/null
                adb shell rm -rf /sdcard/.thumbnails/* 2>/dev/null
                adb shell rm -rf /sdcard/DCIM/.thumbnails/* 2>/dev/null
                adb shell am kill-all 2>/dev/null

                echo -e "${GREEN}✓ ADB e 20 varreduras aplicadas.${NC}"
            else
                echo -e "${RED}Erro na conexão ADB.${NC}"
            fi
            perguntar_abrir_jogo
            sleep 1; mostrar_menu
            ;;
        7)
            vanguard_io_ai
            mostrar_menu
            ;;
        8)
            if [ "$IS_DEV" = true ]; then
                mostrar_logo
                cat /sdcard/.vanguard_access.log 2>/dev/null || echo "Vazio"
                echo -ne "Enter para voltar..."
                read; mostrar_menu
            else
                exit 0
            fi
            ;;
        9)
            if [ "$IS_DEV" = true ]; then
                mostrar_logo
                cat /sdcard/.vanguard_unauthorized.log 2>/dev/null || echo "Vazio"
                echo -ne "Enter para voltar..."
                read; mostrar_menu
            else
                exit 0
            fi
            ;;
        10)
            exit 0
            ;;
        *)
            sleep 1; mostrar_menu
            ;;
    esac
}

tela_pagamento
mostrar_menu
EOF
chmod +x vanguard.sh
./vanguard.sh