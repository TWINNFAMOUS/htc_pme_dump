#!/system/bin/sh

target=`getprop ro.board.platform`

function configure_zram_disksize() {
# Configure different zram size based on real RAM size.
# zram size = RAM size / 2

    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    zram_enable=`getprop ro.config.zram`
    if [ $MemTotal -lt 1048576 ]; then
        echo 536870912 > /sys/block/zram0/disksize
    elif [ $MemTotal -lt 1572864 ]; then
        echo 805306368 > /sys/block/zram0/disksize
    elif [ $MemTotal -lt 2097152 ]; then
        echo 1073741824 > /sys/block/zram0/disksize
    elif [ $MemTotal -lt 3145728 ]; then
        echo 1476395008 > /sys/block/zram0/disksize
    elif [ $MemTotal -lt 4194304 ]; then
        echo 2147483648 > /sys/block/zram0/disksize
    fi

    mkswap /dev/block/zram0
    swapon /dev/block/zram0 -p 32758
}

case "$target" in
    "msm8994")
        setprop  sys.sysctl.extra_free_kbytes 58500
        echo "0,200,300,700,900,906" > /sys/module/lowmemorykiller/parameters/adj
        echo "27648,41472,48384,72378,84375,121875" > /sys/module/lowmemorykiller/parameters/minfree
	#Enable adaptive LMK and set vmpressure_file_min by HTC setting
	echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
	echo 159375 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
        ;;
esac

case "$target" in
    "msm8952")
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi
        case "$soc_id" in
            "264" | "289")
                # 8952
                setprop  sys.sysctl.extra_free_kbytes 72900
                echo "0,200,300,700,900,906" > /sys/module/lowmemorykiller/parameters/adj
                echo "27648,41472,48384,59578,71575,109075" > /sys/module/lowmemorykiller/parameters/minfree
                echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
                echo 146575 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
                ;;
            *)
                # 8976
                setprop  sys.sysctl.extra_free_kbytes 129600
                echo "0,200,300,700,900,906" > /sys/module/lowmemorykiller/parameters/adj
                echo "27648,41472,48384,72378,84375,121875" > /sys/module/lowmemorykiller/parameters/minfree
                echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
                echo 159375 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
                ;;
        esac
        ;;
esac

case "$target" in
    "msm8996")
        setprop  sys.sysctl.extra_free_kbytes 129600
        echo "0,200,300,700,900,906" > /sys/module/lowmemorykiller/parameters/adj
        echo "27648,41472,48384,72378,84375,121875" > /sys/module/lowmemorykiller/parameters/minfree
        # minfree: 27648,41472,48384,72378,84375,121875
        # vmpressure_file_min = 121875+(121875-84375) =  159375
        echo 159375 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
        ;;
esac

case "$target" in
    "msm8909")
        echo "0,100,200,300,900,906" > /sys/module/lowmemorykiller/parameters/adj
        echo "18432,23040,27648,42496,54493,66993" > /sys/module/lowmemorykiller/parameters/minfree
        echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
        echo 79493 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
esac

#common part
case "$target" in
    *)
        echo 1 > /proc/sys/vm/highmem_is_dirtyable
        # Configure zram size
        configure_zram_disksize
        echo 600 > /sys/module/lowmemorykiller/parameters/adj_max_shift
        ;;
esac
