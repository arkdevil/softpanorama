/* Send a user message using SendUserMsg() from MaxUserREXX */

Call RxFuncAdd 'SendUserMsg', 'MaxUser', 'SendUserMsg'

cr = x2c('0d')

msg.msgpath  = 'D:\MAX\MSG\PRIVATE'
/* msg.msgproc = 'D:\Squish\SQ386P out squash link -CD:\Squish\Squish.Cfg' */
msg.msgtype  = 'SQUISH'
msg.msgflag  = 'NORMAL,PRIVATE'
msg.to       = 'Craig Morrison'
msg.toaddr   = '1:201/60.0'
msg.from     = 'Craig Morrison'
msg.fromaddr = '1:201/60.0'
msg.subject  = 'Welcome to the Workplace!'
msg.text     = 'Hello!'cr||cr'Glad to have you aboard!'
msg.origin   = 'The Workplace Connection'

if SendUserMsg('msg') <> 'ERROR' Then
    Say 'Message to 'msg.to' sent okay!'

Call RxFuncDrop 'SendUserMsg'
