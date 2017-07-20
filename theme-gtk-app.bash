#!/bin/bash
# Licence:  zlib/libpng
# Year::    2017
# Status::  beta
# Description:: Change the theme of a specific application

EXIT_PREREQ_UNAVAILABLE=80

# This doesn't use actual bash arrays, but rather strings separated by arbitrary
# characters. For actual arrays, use https://stackoverflow.com/a/8574392/5389585
# Usage: detect_in_arr $val $arr $sep || echo $val is not in $arr
function detect_in_arr(){
  val="$1"
  arr="$2"
  sep="$3"

  declare -A map
  while IFS= read -r -d "$sep" name; do
    map["$name"]=1
  done <<<"$arr"

  if [[ ${map["$val"]} ]] ; then
    return 0
  else
    return 1
  fi
}

if ! detect_in_arr "$HOME/bin" "$PATH" ":"; then
  echo "$HOME/bin" must be in your \$PATH >&2
  exit $EXIT_PREREQ_UNAVAILABLE
fi


#This will only work if you have $HOME/bin in your $PATH. To do this, add this line anywhere in ~/.bashrc:
#  [ -d ~/bin ] && export PATH=~/bin:$PATH

# You can change this if you want
app_only_theme=Crux

mkdir -p ~/.local/share/applications
sed "s,Exec=firefox,Exec=$HOME/bin/firefox," < /usr/share/applications/firefox.desktop > ~/.local/share/applications/firefox.desktop

# Write a shell script
cat > $HOME/bin/firefox <<EOS
#!/bin/sh
env GTK_THEME=$app_only_theme /usr/bin/firefox
EOS
chmod 555 $HOME/bin/firefox

# Set the priority to a little bit higher than the current browser.
priority=$((10 + $(update-alternatives --query x-www-browser|grep Priority | sed 's/Priority: //' | sort -h |tail -n1) ))
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser $HOME/bin/firefox $priority

sed -i s,/usr/share/applications/firefox.desktop,firefox.desktop, ~/.config/lxpanel/*/panels/panel

# Problem with this solution: There are many ways to launch firefox, application menus, from the command line via firefox or x-www-browser. Changing it via invocation requires changing every method of invocation.
