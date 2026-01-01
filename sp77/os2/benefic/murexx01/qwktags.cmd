/* MaxUserREXX Example */
Call RxFuncAdd 'QueryQWKTags', 'MaxUser', 'QueryQWKTags'
Call RxFuncAdd 'SetQWKTags', 'MaxUser', 'SetQWKTags'

Say QueryQWKTags('D:\Max\MTAG.BBS', 'Craig Morrison')

/* Say SetQWKTags('D:\Max\MTAG.BBS', 'Craig Morrison', ' 1 OS2BBS NET') */

Call RxFuncDrop 'SetQWKTags'
Call RxFuncDrop 'QueryQWKTags'
