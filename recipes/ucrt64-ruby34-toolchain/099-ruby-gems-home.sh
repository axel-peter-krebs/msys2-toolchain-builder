# For deveopment of Ruby gems it is fevorable to specify a HOME for the gems.
echo "[/etc/profile.d/099-ruby-gems-home.sh] Setting GEM_PATH and GEM_HOME."

export GEM_HOME="$HOME/.gems"
export GEM_PATH="$HOME/.gems"