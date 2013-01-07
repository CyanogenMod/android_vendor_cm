for combo in $(wget -o /dev/null -O - https://raw.github.com/CyanogenMod/hudson/master/cm-build-targets | grep jellybean | awk {'print $1'})
do
    add_lunch_combo $combo
done
