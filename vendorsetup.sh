for combo in $(cat vendor/bliss/bliss-device-targets)
do
    add_lunch_combo $combo
done
