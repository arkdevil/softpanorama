#trace on
#
# set up some strings for dialling up
#
if ![load $number]
  if [query $number "Enter your dial up phone number"]
    save $number
  end
end
if ![load $username]
  if [username "Enter your login username"]
    save $username
  end
end
if ![load $password]
  if [password "Enter your login password"]
    save $password
  end
end
$modemsetup = "&c1&k3"
$prompt = ">"
$userprompt = "sername:"
$passprompt = "assword:"
$slipcmd = "slip"
$addrtarg = "Your address is"
$pppcmd = "ppp"

%attempts = 10
#
#
#----------------------------------------------------------
#
# initialize modem
#
output "atz"\13
if ! [input 10 OK\n]
  display "Modem is not responding"\n
  abort
end
#
# setup our modem commands
#
output "at"$modemsetup\13
input 10 OK\n
#
# send phone number
#
%n = 0
repeat
  if %n = %attempts
    display "Too many dial attempts"\n
    abort
  end
  output "atdt"$number\13
  %ok = [input 60 CONNECT]
  %n = %n + 1
until %ok
input 10 \n
#
#  wait till it's safe to send because some modem's hang up
#  if you transmit during the connection phase
#
wait 30 dcd
#
# now prod the terminal server
#
output \13
#
#  wait for the username prompt
#
input 30 $userprompt
output $username\13
#
# and the password
#
input 30 $passprompt
output $password\13
#
# we are now logged in
#
input 30 $prompt
if %ppp
  #
  # jump into ppp mode
  #
  output $pppcmd\13
  #
  input 30 \n
  #
  display "PPP mode selected.  Will try to negotiate IP address."\n
  #
else
  #
  # jump into slip mode
  #
  output $slipcmd\13
  #
  # wait for the address string
  #
  input 30 $addrtarg
  #
  # parse address
  #
  address 30
  input 30 \n
  #
  # we are now connected, logged in and in slip mode.
  #
  display \n
  display Connected.  Your IP address is \i.\n
end
#
# now we are finished.
#
