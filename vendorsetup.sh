for combo in $(curl -s https://raw.github.com/CyanogenMod/hudson/master/cm-build-targets | sed -e 's/#.*$//' | grep cm-11.0 | awk {'print $1'})
do
    add_lunch_combo cm_d710-userdebug
    add_lunch_combo cm_m7spr-userdebug
    add_lunch_combo $combo
done
