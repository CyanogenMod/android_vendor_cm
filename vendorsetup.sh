for combo in $(curl -s https://gist.github.com/spottech/47d7433a0f124622ce77f9e6dfb34fd8 | sed -e 's/#.*$//' | grep cm-13.0 | awk '{printf "cm_%s-%s\n", $1, $2}')
do
    add_lunch_combo $combo
done
