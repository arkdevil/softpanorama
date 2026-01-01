%ok = [load $number]
%ok = [load $password]
%ok = [load $username]

if [query $number "Enter your phone number"]
  save $number
end
if [username "Enter your login username"]
  save $username
end
if [password "Enter your login password"]
  save $password
end
