#!/bin/bash
# Licence:  zlib/libpng
# Year::    2017
# Status::  beta
# Description:: Change the theme of a specific application 

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
