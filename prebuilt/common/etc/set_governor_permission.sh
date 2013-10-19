#!/system/bin/sh

BASE_PATH="/sys/devices/system/cpu/cpufreq"
INTERACTIVE_NODES="boostpulse min_sample_time io_is_busy hispeed_freq above_hispeed_delay timer_rate"
ONDEMAND_NODES="boostpulse up_threshold io_is_busy sampling_down_factor down_differential up_threshold_multi_core down_differential_multi_core optimal_freq sync_freq up_threshold_any_cpu_load sampling_rate"

governor_name=`getprop sys.cpufreq.governor`
case "$governor_name" in
    "interactive")
        nodes=$INTERACTIVE_NODES
    ;;
    "ondemand")
        nodes=$ONDEMAND_NODES
    ;;
esac

for node in $nodes
do
    node=$BASE_PATH/$governor_name/$node
    if [ -e $node ]; then
        chown system:root $node
        chmod 0664 $node
    fi
done

exit 0
