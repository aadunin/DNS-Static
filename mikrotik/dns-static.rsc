/ip dns static remove [find address-list="autohost"]
/ip dns static add name=Not address=404: ttl=1d address-list=autohost
/ip dns static add name=Found address=404: ttl=1d address-list=autohost
/log info "[update-hosts] Added 2 entries"
