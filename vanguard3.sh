pkg update -y && pkg upgrade -y
pkg install android-tools shc clang -y
termux-setup-storage

cat << 'EOF' > ~/vanguard.sh
#!/bin/bash

# =======================================================================
# VANGUARD TUNER v3.5
# =======================================================================

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

function mostrar_logo() {
    echo -e "${CYAN}██    ██  █████  ███    ██  ██████  ██    ██  █████  ██████  ██████ ${NC}"
    echo -e "${CYAN}██    ██ ██   ██ ████   ██ ██       ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}██    ██ ███████ ██ ██  ██ ██   ███ ██    ██ ███████ ██████  ██   ██${NC}"
    echo -e "${CYAN} ██  ██  ██   ██ ██  ██ ██ ██    ██ ██    ██ ██   ██ ██   ██ ██   ██${NC}"
    echo -e "${CYAN}  ████   ██   ██ ██   ████  ██████   ██████  ██   ██ ██   ██ ██████ ${NC}"
    echo -e "${BLUE}                           OS TUNER v3.5                              ${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

function tela_carregamento() {
    am kill-all > /dev/null 2>&1
    echo 3 > /proc/sys/vm/drop_caches > /dev/null 2>&1
    stop thermal-engine > /dev/null 2>&1
    stop thermald > /dev/null 2>&1
    
    for i in 10 20 30 40 50 60 70 80 90 100; do
        clear
        echo -e "\n\n\n\n\n\n"
        echo -e "${CYAN}           ████████████████████████████████████${NC}"
        echo -e "${CYAN}           █                                  █${NC}"
        if [ $i -eq 100 ]; then
            echo -e "${CYAN}           █          ${GREEN}${i}% COMPLETO          ${CYAN}█${NC}"
        elif [ $i -lt 100 ]; then
            echo -e "${CYAN}           █             ${YELLOW}${i}%                 ${CYAN}█${NC}"
        fi
        echo -e "${CYAN}           █                                  █${NC}"
        echo -e "${CYAN}           ████████████████████████████████████${NC}"
        sleep 0.3
    done
    clear
    mostrar_logo
}

function perguntar_abrir_jogo() {
    echo -ne "\n${CYAN}Deseja abrir algum jogo agora? (s/n): ${NC}"
    read abrir_jogo
    if [ "$abrir_jogo" == "s" ]; then
        echo -ne "Digite o pacote do jogo (Ex: com.dts.freefireth): "
        read pacote
        monkey -p "$pacote" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Jogo iniciado com prioridade!${NC}"
        else
            echo -e "${RED}Erro: Pacote não encontrado.${NC}"
        fi
    fi
}

function mostrar_specs() {
    MODELO=$(getprop ro.product.model 2>/dev/null || echo "Desconhecido")
    CPU=$(getprop ro.board.platform 2>/dev/null || echo "Desconhecido")
    RAM=$(awk '/MemTotal/ {printf "%.1f GB\n", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo "N/A")
    
    echo -e "${CYAN}Dispositivo: ${YELLOW}$MODELO ${CYAN}| CPU: ${YELLOW}$CPU ${CYAN}| RAM: ${YELLOW}$RAM${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

function mostrar_menu() {
    clear
    mostrar_logo
    mostrar_specs
    echo -e " [1] ${RED}FORÇA 120 FPS${NC}"
    echo -e " [2] ${YELLOW}Acelerar Touchscreen${NC}"
    echo -e " [3] ${YELLOW}Calibrar Touchscreen${NC}"
    echo -e " [4] ${CYAN}Gerar Sensi com IA (Free Fire)${NC} (sensibilidade e dpi de acordo com seu celular)"
    echo -e " [5] ${BLUE}Otimização Geral (Sem Depuração Wi-Fi)${NC}"
    echo -e " [6] ${BLUE}Otimização Geral (Depuração Wi-Fi)${NC}"
    echo -e " [7] Sair"
    echo -e "${BLUE}======================================================================${NC}"
    echo -ne " Escolha uma opção: "
    read opcao
    executar_opcao $opcao
}

function executar_opcao() {
    case $1 in
        1)
            clear
            mostrar_logo
            echo -e "${RED}[!] AVISO: Ativar esta opção pode deixar o celular mais quente.${NC}"
            echo -ne "Deseja continuar? (s/n): "
            read confirma
            if [ "$confirma" == "s" ]; then
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
                setprop ro.config.hw_quickpoweron true 2>/dev/null
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
                
                echo -e "${GREEN}✓ Força 120 FPS ativada!${NC}"
                perguntar_abrir_jogo
            fi
            sleep 3; mostrar_menu
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
            
            echo -e "${GREEN}✓ Touchscreen acelerado com taxa de resposta de 1ms!${NC}"
            perguntar_abrir_jogo
            sleep 3; mostrar_menu
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
            
            echo -e "${GREEN}✓ Sensores de toque calibrados!${NC}"
            perguntar_abrir_jogo
            sleep 3; mostrar_menu
            ;;
        4)
            clear
            mostrar_logo
            echo -ne "Digite o modelo exato do seu celular (Ex: Poco X3, Moto G30): "
            read modelo_ia
            
            if [ ${#modelo_ia} -lt 3 ]; then
                echo -e "${RED}Erro: Nome do celular inválido.${NC}"
                sleep 2; mostrar_menu; return
            fi
            
            tela_carregamento
            
            setprop persist.sys.dalvik.hyperthreading true 2>/dev/null
            setprop persist.sys.dalvik.multithread true 2>/dev/null
            setprop dalvik.vm.execution-mode int:fast 2>/dev/null
            settings put global sys_storage_threshold_percentage 5 2>/dev/null
            settings put system pointer_speed 7 2>/dev/null
            settings put secure long_press_timeout 150 2>/dev/null
            settings put secure multi_press_timeout 150 2>/dev/null
            settings put global animator_duration_scale 0.0 2>/dev/null
            settings put global transition_animation_scale 0.0 2>/dev/null
            settings put global window_animation_scale 0.0 2>/dev/null
            setprop debug.performance.tuning 1 2>/dev/null
            setprop video.accelerate.hw 1 2>/dev/null
            setprop windowsmgr.max_events_per_sec 500 2>/dev/null
            setprop ro.min.fling_velocity 50 2>/dev/null
            setprop ro.max.fling_velocity 25000 2>/dev/null
            setprop view.touch_slop 2 2>/dev/null
            setprop view.scroll_friction 0.5 2>/dev/null
            setprop ro.input.noresample 1 2>/dev/null
            setprop touch.presure.scale 0.001 2>/dev/null
            setprop persist.sys.ui.hw 1 2>/dev/null
            setprop debug.hwui.render_dirty_regions false 2>/dev/null
            setprop debug.egl.hw 1 2>/dev/null
            setprop debug.egl.profiler 1 2>/dev/null
            setprop ro.kernel.android.checkjni 0 2>/dev/null
            setprop touch.deviceType touchScreen 2>/dev/null
            setprop touch.orientation.calibration interpolated 2>/dev/null
            setprop touch.distance.calibration none 2>/dev/null
            setprop touch.distance.scale 0 2>/dev/null
            setprop touch.coverage.calibration box 2>/dev/null
            setprop touch.size.calibration geometric 2>/dev/null
            
            basico=$(( 85 + (${#modelo_ia} % 15) ))
            reddot=$(( 90 + (${#modelo_ia} % 10) ))
            dpi=$(( 550 + (${#modelo_ia} * 15) ))
            
            echo -e "${YELLOW}>> SENSIBILIDADE GERADA PARA: $modelo_ia <<${NC}"
            echo -e " - Geral: ${GREEN}$basico${NC}"
            echo -e " - Red Dot: ${GREEN}$reddot${NC}"
            echo -e " - Mira 2x: ${GREEN}100${NC}"
            echo -e " - Mira 4x: ${GREEN}98${NC}"
            echo -e " - AWM: ${GREEN}50${NC}"
            echo -e " - Olhadinha: ${GREEN}65${NC}"
            echo -e " - ${RED}DPI RECOMENDADA: $dpi${NC}"
            echo -e "${BLUE}======================================================================${NC}"
            echo -ne "Não sabe ativar a DPI? Digite 's' para tutorial ou 'n' para voltar: "
            read tuto_dpi
            if [ "$tuto_dpi" == "s" ]; then
                echo -e "\n${CYAN}[COMO ATIVAR A DPI]${NC}"
                echo "1. Vá em Configurações > Sobre o Telefone."
                echo "2. Toque 7 vezes em 'Número da Versão'."
                echo "3. Volte, vá em Sistema > Opções do Desenvolvedor."
                echo "4. Procure por 'Menor Largura' ou 'Largura Mínima'."
                echo "5. Altere para o valor recomendado ($dpi)."
                echo -e "${YELLOW}Pressione Enter para voltar ao menu...${NC}"
                read
            fi
            mostrar_menu
            ;;
        5)
            clear
            mostrar_logo
            echo -ne "Digite o modelo do seu celular para varredura: "
            read modelo_ot
            
            if [ -z "$modelo_ot" ] || [ ${#modelo_ot} -lt 3 ]; then
                echo -e "${RED}Dispositivo não encontrado!${NC}"
                sleep 3; mostrar_menu; return
            fi
            
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
            
            echo -e "${GREEN}✓ Lixo oculto liberado! Celular otimizado.${NC}"
            perguntar_abrir_jogo
            sleep 3; mostrar_menu
            ;;
        6)
            clear
            mostrar_logo
            echo -e "${RED}  [!] ATENÇÃO: NECESSÁRIO PAREAMENTO ADB VIA WI-FI [!]${NC}"
            echo -e "${YELLOW}1. Divida a tela do seu celular (Split Screen).${NC}"
            echo -e "${YELLOW}2. Abra Configurações > Opções do Desenvolvedor > Depuração por Wi-Fi.${NC}"
            echo -e "${YELLOW}3. Clique em 'Parear dispositivo com código de pareamento'.${NC}"
            echo -e "${BLUE}======================================================================${NC}"
            
            echo -ne "Digite a ${GREEN}Porta de Pareamento${NC}: "
            read porta_par
            echo -ne "Digite o ${GREEN}Código de Pareamento${NC} de 6 dígitos: "
            read cod_par
            
            adb kill-server >/dev/null 2>&1
            adb start-server >/dev/null 2>&1
            
            echo -e "\n${CYAN}Executando pareamento ADB...${NC}"
            adb pair 127.0.0.1:$porta_par $cod_par
            
            echo -e "\n${YELLOW}Agora digite a ${GREEN}Porta de Conexão${NC} principal da Depuração por Wi-Fi: "
            read porta_con
            
            echo -e "${CYAN}Conectando em 127.0.0.1:$porta_con...${NC}"
            adb connect 127.0.0.1:$porta_con
            
            if adb devices | grep -q "device$"; then
                echo -e "${GREEN}✓ Pareado e Conectado com Sucesso! Aplicando otimizações...${NC}"
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
                
                echo -e "${GREEN}✓ Payload injetado com sucesso!${NC}"
            else
                echo -e "${RED}Erro ao parear/conectar. Verifique as portas e o código.${NC}"
            fi
            
            perguntar_abrir_jogo
            sleep 3; mostrar_menu
            ;;
        7)
            clear
            mostrar_logo
            echo -e "${CYAN}Obrigado por usar o Vanguard Tuner. Siga @VanguardTuner no TikTok!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida!${NC}"
            sleep 2; mostrar_menu
            ;;
    esac
}

# Inicia o script
mostrar_menu
EOF

cd ~
shc -f vanguard.sh -r
rm -f vanguard.sh.x.c vanguard.sh
mv vanguard.sh.x vanguard
chmod +x vanguard

clear
./vanguard