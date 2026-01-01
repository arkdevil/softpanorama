@echo off
if (%1)==() goto usage
set err$msg=

rem > now.
echo ---
dir now. | find "-"
del now.
dir %1 | find "-"
echo ---

fileage %1
if errorlevel 255 set err$msg=255 error
if not (%err$msg%)==() goto report                
if errorlevel 254 set err$msg=254, %1 is over 88 days old
if not (%err$msg%)==() goto report
if errorlevel 253 set err$msg=253, %1 is 88 days old
if not (%err$msg%)==() goto report
if errorlevel 252 set err$msg=252, %1 is 87 days old
if not (%err$msg%)==() goto report
if errorlevel 251 set err$msg=251, %1 is 86 days old
if not (%err$msg%)==() goto report
if errorlevel 250 set err$msg=250, %1 is 85 days old
if not (%err$msg%)==() goto report
if errorlevel 249 set err$msg=249, %1 is 84 days old
if not (%err$msg%)==() goto report
if errorlevel 248 set err$msg=248, %1 is 83 days old
if not (%err$msg%)==() goto report
if errorlevel 247 set err$msg=247, %1 is 82 days old
if not (%err$msg%)==() goto report
if errorlevel 246 set err$msg=246, %1 is 81 days old
if not (%err$msg%)==() goto report
if errorlevel 245 set err$msg=245, %1 is 80 days old
if not (%err$msg%)==() goto report
if errorlevel 244 set err$msg=244, %1 is 79 days old
if not (%err$msg%)==() goto report
if errorlevel 243 set err$msg=243, %1 is 78 days old
if not (%err$msg%)==() goto report
if errorlevel 242 set err$msg=242, %1 is 77 days old
if not (%err$msg%)==() goto report
if errorlevel 241 set err$msg=241, %1 is 76 days old
if not (%err$msg%)==() goto report
if errorlevel 240 set err$msg=240, %1 is 75 days old
if not (%err$msg%)==() goto report
if errorlevel 239 set err$msg=239, %1 is 74 days old
if not (%err$msg%)==() goto report
if errorlevel 238 set err$msg=238, %1 is 73 days old
if not (%err$msg%)==() goto report
if errorlevel 237 set err$msg=237, %1 is 72 days old
if not (%err$msg%)==() goto report
if errorlevel 236 set err$msg=236, %1 is 71 days old
if not (%err$msg%)==() goto report
if errorlevel 235 set err$msg=235, %1 is 70 days old
if not (%err$msg%)==() goto report
if errorlevel 234 set err$msg=234, %1 is 69 days old
if not (%err$msg%)==() goto report
if errorlevel 233 set err$msg=233, %1 is 68 days old
if not (%err$msg%)==() goto report
if errorlevel 232 set err$msg=232, %1 is 67 days old
if not (%err$msg%)==() goto report
if errorlevel 231 set err$msg=231, %1 is 66 days old
if not (%err$msg%)==() goto report
if errorlevel 230 set err$msg=230, %1 is 65 days old
if not (%err$msg%)==() goto report
if errorlevel 229 set err$msg=229, %1 is 64 days old
if not (%err$msg%)==() goto report
if errorlevel 228 set err$msg=228, %1 is 63 days old
if not (%err$msg%)==() goto report
if errorlevel 227 set err$msg=227, %1 is 62 days old
if not (%err$msg%)==() goto report
if errorlevel 226 set err$msg=226, %1 is 61 days old
if not (%err$msg%)==() goto report
if errorlevel 225 set err$msg=225, %1 is 60 days old
if not (%err$msg%)==() goto report
if errorlevel 224 set err$msg=224, %1 is 59 days old
if not (%err$msg%)==() goto report
if errorlevel 223 set err$msg=223, %1 is 58 days old
if not (%err$msg%)==() goto report
if errorlevel 222 set err$msg=222, %1 is 57 days old
if not (%err$msg%)==() goto report
if errorlevel 221 set err$msg=221, %1 is 56 days old
if not (%err$msg%)==() goto report
if errorlevel 220 set err$msg=220, %1 is 55 days old
if not (%err$msg%)==() goto report
if errorlevel 219 set err$msg=219, %1 is 54 days old
if not (%err$msg%)==() goto report
if errorlevel 218 set err$msg=218, %1 is 53 days old
if not (%err$msg%)==() goto report
if errorlevel 217 set err$msg=217, %1 is 52 days old
if not (%err$msg%)==() goto report
if errorlevel 216 set err$msg=216, %1 is 51 days old
if not (%err$msg%)==() goto report
if errorlevel 215 set err$msg=215, %1 is 50 days old
if not (%err$msg%)==() goto report
if errorlevel 214 set err$msg=214, %1 is 49 days old
if not (%err$msg%)==() goto report
if errorlevel 213 set err$msg=213, %1 is 48 days old
if not (%err$msg%)==() goto report
if errorlevel 212 set err$msg=212, %1 is 47 days old
if not (%err$msg%)==() goto report
if errorlevel 211 set err$msg=211, %1 is 46 days old
if not (%err$msg%)==() goto report
if errorlevel 210 set err$msg=210, %1 is 45 days old
if not (%err$msg%)==() goto report
if errorlevel 209 set err$msg=209, %1 is 44 days old
if not (%err$msg%)==() goto report
if errorlevel 208 set err$msg=208, %1 is 43 days old
if not (%err$msg%)==() goto report
if errorlevel 207 set err$msg=207, %1 is 42 days old
if not (%err$msg%)==() goto report
if errorlevel 206 set err$msg=206, %1 is 41 days old
if not (%err$msg%)==() goto report
if errorlevel 205 set err$msg=205, %1 is 40 days old
if not (%err$msg%)==() goto report
if errorlevel 204 set err$msg=204, %1 is 39 days old
if not (%err$msg%)==() goto report
if errorlevel 203 set err$msg=203, %1 is 38 days old
if not (%err$msg%)==() goto report
if errorlevel 202 set err$msg=202, %1 is 37 days old
if not (%err$msg%)==() goto report
if errorlevel 201 set err$msg=201, %1 is 36 days old
if not (%err$msg%)==() goto report
if errorlevel 200 set err$msg=200, %1 is 35 days old
if not (%err$msg%)==() goto report
if errorlevel 199 set err$msg=199, %1 is 34 days old
if not (%err$msg%)==() goto report
if errorlevel 198 set err$msg=198, %1 is 33 days old
if not (%err$msg%)==() goto report
if errorlevel 197 set err$msg=197, %1 is 32 days old
if not (%err$msg%)==() goto report
if errorlevel 196 set err$msg=196, %1 is 31 days old
if not (%err$msg%)==() goto report
if errorlevel 195 set err$msg=195, %1 is 30 days old
if not (%err$msg%)==() goto report
if errorlevel 194 set err$msg=194, %1 is 29 days old
if not (%err$msg%)==() goto report
if errorlevel 193 set err$msg=193, %1 is 28 days old
if not (%err$msg%)==() goto report
if errorlevel 192 set err$msg=192, %1 is 27 days old
if not (%err$msg%)==() goto report
if errorlevel 191 set err$msg=191, %1 is 26 days old
if not (%err$msg%)==() goto report
if errorlevel 190 set err$msg=190, %1 is 25 days old
if not (%err$msg%)==() goto report
if errorlevel 189 set err$msg=189, %1 is 24 days old
if not (%err$msg%)==() goto report
if errorlevel 188 set err$msg=188, %1 is 23 days old
if not (%err$msg%)==() goto report
if errorlevel 187 set err$msg=187, %1 is 22 days old
if not (%err$msg%)==() goto report
if errorlevel 186 set err$msg=186, %1 is 21 days old
if not (%err$msg%)==() goto report
if errorlevel 185 set err$msg=185, %1 is 20 days old
if not (%err$msg%)==() goto report
if errorlevel 184 set err$msg=184, %1 is 19 days old
if not (%err$msg%)==() goto report
if errorlevel 183 set err$msg=183, %1 is 18 days old
if not (%err$msg%)==() goto report
if errorlevel 182 set err$msg=182, %1 is 17 days old
if not (%err$msg%)==() goto report
if errorlevel 181 set err$msg=181, %1 is 16 days old
if not (%err$msg%)==() goto report
if errorlevel 180 set err$msg=180, %1 is 15 days old
if not (%err$msg%)==() goto report
if errorlevel 179 set err$msg=179, %1 is 14 days old
if not (%err$msg%)==() goto report
if errorlevel 178 set err$msg=178, %1 is 13 days old
if not (%err$msg%)==() goto report
if errorlevel 177 set err$msg=177, %1 is 12 days old
if not (%err$msg%)==() goto report
if errorlevel 176 set err$msg=176, %1 is 11 days old
if not (%err$msg%)==() goto report
if errorlevel 175 set err$msg=175, %1 is 10 days old
if not (%err$msg%)==() goto report
if errorlevel 174 set err$msg=174, %1 is 9 days old
if not (%err$msg%)==() goto report
if errorlevel 173 set err$msg=173, %1 is 8 days old
if not (%err$msg%)==() goto report
if errorlevel 172 set err$msg=172, %1 is 7 days old
if not (%err$msg%)==() goto report
if errorlevel 171 set err$msg=171, %1 is 6 days old
if not (%err$msg%)==() goto report
if errorlevel 170 set err$msg=170, %1 is 5 days old
if not (%err$msg%)==() goto report
if errorlevel 169 set err$msg=169, %1 is 4 days old
if not (%err$msg%)==() goto report
if errorlevel 168 set err$msg=168, %1 is 3 days old
if not (%err$msg%)==() goto report
if errorlevel 167 set err$msg=167, %1 is 2 days old
if not (%err$msg%)==() goto report
if errorlevel 166 set err$msg=166, %1 is 48 hours old
if not (%err$msg%)==() goto report
if errorlevel 165 set err$msg=165, %1 is 47 hours old
if not (%err$msg%)==() goto report
if errorlevel 164 set err$msg=164, %1 is 46 hours old
if not (%err$msg%)==() goto report
if errorlevel 163 set err$msg=163, %1 is 45 hours old
if not (%err$msg%)==() goto report
if errorlevel 162 set err$msg=162, %1 is 44 hours old
if not (%err$msg%)==() goto report
if errorlevel 161 set err$msg=161, %1 is 43 hours old
if not (%err$msg%)==() goto report
if errorlevel 160 set err$msg=160, %1 is 42 hours old
if not (%err$msg%)==() goto report
if errorlevel 159 set err$msg=159, %1 is 41 hours old
if not (%err$msg%)==() goto report
if errorlevel 158 set err$msg=158, %1 is 40 hours old
if not (%err$msg%)==() goto report
if errorlevel 157 set err$msg=157, %1 is 39 hours old
if not (%err$msg%)==() goto report
if errorlevel 156 set err$msg=156, %1 is 38 hours old
if not (%err$msg%)==() goto report
if errorlevel 155 set err$msg=155, %1 is 37 hours old
if not (%err$msg%)==() goto report
if errorlevel 154 set err$msg=154, %1 is 36 hours old
if not (%err$msg%)==() goto report
if errorlevel 153 set err$msg=153, %1 is 35 hours old
if not (%err$msg%)==() goto report
if errorlevel 152 set err$msg=152, %1 is 34 hours old
if not (%err$msg%)==() goto report
if errorlevel 151 set err$msg=151, %1 is 33 hours old
if not (%err$msg%)==() goto report
if errorlevel 150 set err$msg=150, %1 is 32 hours old
if not (%err$msg%)==() goto report
if errorlevel 149 set err$msg=149, %1 is 31 hours old
if not (%err$msg%)==() goto report
if errorlevel 148 set err$msg=148, %1 is 30 hours old
if not (%err$msg%)==() goto report
if errorlevel 147 set err$msg=147, %1 is 29 hours old
if not (%err$msg%)==() goto report
if errorlevel 146 set err$msg=146, %1 is 28 hours old
if not (%err$msg%)==() goto report
if errorlevel 145 set err$msg=145, %1 is 27 hours old
if not (%err$msg%)==() goto report
if errorlevel 144 set err$msg=144, %1 is 26 hours old
if not (%err$msg%)==() goto report
if errorlevel 143 set err$msg=143, %1 is 25 hours old
if not (%err$msg%)==() goto report
if errorlevel 142 set err$msg=142, %1 is 24 hours old
if not (%err$msg%)==() goto report
if errorlevel 141 set err$msg=141, %1 is 23 hours old
if not (%err$msg%)==() goto report
if errorlevel 140 set err$msg=140, %1 is 22 hours old
if not (%err$msg%)==() goto report
if errorlevel 139 set err$msg=139, %1 is 21 hours old
if not (%err$msg%)==() goto report
if errorlevel 138 set err$msg=138, %1 is 20 hours old
if not (%err$msg%)==() goto report
if errorlevel 137 set err$msg=137, %1 is 19 hours old
if not (%err$msg%)==() goto report
if errorlevel 136 set err$msg=136, %1 is 18 hours old
if not (%err$msg%)==() goto report
if errorlevel 135 set err$msg=135, %1 is 17 hours old
if not (%err$msg%)==() goto report
if errorlevel 134 set err$msg=134, %1 is 16 hours old
if not (%err$msg%)==() goto report
if errorlevel 133 set err$msg=133, %1 is 15 hours old
if not (%err$msg%)==() goto report
if errorlevel 132 set err$msg=132, %1 is 14 hours old
if not (%err$msg%)==() goto report
if errorlevel 131 set err$msg=131, %1 is 13 hours old
if not (%err$msg%)==() goto report
if errorlevel 130 set err$msg=130, %1 is 12 hours old
if not (%err$msg%)==() goto report
if errorlevel 129 set err$msg=129, %1 is 11 hours old
if not (%err$msg%)==() goto report
if errorlevel 128 set err$msg=128, %1 is 10 hours old
if not (%err$msg%)==() goto report
if errorlevel 127 set err$msg=127, %1 is 9 hours old
if not (%err$msg%)==() goto report
if errorlevel 126 set err$msg=126, %1 is 8 hours old
if not (%err$msg%)==() goto report
if errorlevel 125 set err$msg=125, %1 is 7 hours old
if not (%err$msg%)==() goto report
if errorlevel 124 set err$msg=124, %1 is 6 hours old
if not (%err$msg%)==() goto report
if errorlevel 123 set err$msg=123, %1 is 5 hours old
if not (%err$msg%)==() goto report
if errorlevel 122 set err$msg=122, %1 is 4 hours old
if not (%err$msg%)==() goto report
if errorlevel 121 set err$msg=121, %1 is 3 hours old
if not (%err$msg%)==() goto report
if errorlevel 120 set err$msg=120, %1 is 2 hours old
if not (%err$msg%)==() goto report
if errorlevel 119 set err$msg=119, %1 is 119 minutes old
if not (%err$msg%)==() goto report
if errorlevel 118 set err$msg=118, %1 is 118 minutes old
if not (%err$msg%)==() goto report
if errorlevel 117 set err$msg=117, %1 is 117 minutes old
if not (%err$msg%)==() goto report
if errorlevel 116 set err$msg=116, %1 is 116 minutes old
if not (%err$msg%)==() goto report
if errorlevel 115 set err$msg=115, %1 is 115 minutes old
if not (%err$msg%)==() goto report
if errorlevel 114 set err$msg=114, %1 is 114 minutes old
if not (%err$msg%)==() goto report
if errorlevel 113 set err$msg=113, %1 is 113 minutes old
if not (%err$msg%)==() goto report
if errorlevel 112 set err$msg=112, %1 is 112 minutes old
if not (%err$msg%)==() goto report
if errorlevel 111 set err$msg=111, %1 is 111 minutes old
if not (%err$msg%)==() goto report
if errorlevel 110 set err$msg=110, %1 is 110 minutes old
if not (%err$msg%)==() goto report
if errorlevel 109 set err$msg=109, %1 is 109 minutes old
if not (%err$msg%)==() goto report
if errorlevel 108 set err$msg=108, %1 is 108 minutes old
if not (%err$msg%)==() goto report
if errorlevel 107 set err$msg=107, %1 is 107 minutes old
if not (%err$msg%)==() goto report
if errorlevel 106 set err$msg=106, %1 is 106 minutes old
if not (%err$msg%)==() goto report
if errorlevel 105 set err$msg=105, %1 is 105 minutes old
if not (%err$msg%)==() goto report
if errorlevel 104 set err$msg=104, %1 is 104 minutes old
if not (%err$msg%)==() goto report
if errorlevel 103 set err$msg=103, %1 is 103 minutes old
if not (%err$msg%)==() goto report
if errorlevel 102 set err$msg=102, %1 is 102 minutes old
if not (%err$msg%)==() goto report
if errorlevel 101 set err$msg=101, %1 is 101 minutes old
if not (%err$msg%)==() goto report
if errorlevel 100 set err$msg=100, %1 is 100 minutes old
if not (%err$msg%)==() goto report
if errorlevel 99 set err$msg=99, %1 is 99 minutes old
if not (%err$msg%)==() goto report
if errorlevel 98 set err$msg=98, %1 is 98 minutes old
if not (%err$msg%)==() goto report
if errorlevel 97 set err$msg=97, %1 is 97 minutes old
if not (%err$msg%)==() goto report
if errorlevel 96 set err$msg=96, %1 is 96 minutes old
if not (%err$msg%)==() goto report
if errorlevel 95 set err$msg=95, %1 is 95 minutes old
if not (%err$msg%)==() goto report
if errorlevel 94 set err$msg=94, %1 is 94 minutes old
if not (%err$msg%)==() goto report
if errorlevel 93 set err$msg=93, %1 is 93 minutes old
if not (%err$msg%)==() goto report
if errorlevel 92 set err$msg=92, %1 is 92 minutes old
if not (%err$msg%)==() goto report
if errorlevel 91 set err$msg=91, %1 is 91 minutes old
if not (%err$msg%)==() goto report
if errorlevel 90 set err$msg=90, %1 is 90 minutes old
if not (%err$msg%)==() goto report
if errorlevel 89 set err$msg=89, %1 is 89 minutes old
if not (%err$msg%)==() goto report
if errorlevel 88 set err$msg=88, %1 is 88 minutes old
if not (%err$msg%)==() goto report
if errorlevel 87 set err$msg=87, %1 is 87 minutes old
if not (%err$msg%)==() goto report
if errorlevel 86 set err$msg=86, %1 is 86 minutes old
if not (%err$msg%)==() goto report
if errorlevel 85 set err$msg=85, %1 is 85 minutes old
if not (%err$msg%)==() goto report
if errorlevel 84 set err$msg=84, %1 is 84 minutes old
if not (%err$msg%)==() goto report
if errorlevel 83 set err$msg=83, %1 is 83 minutes old
if not (%err$msg%)==() goto report
if errorlevel 82 set err$msg=82, %1 is 82 minutes old
if not (%err$msg%)==() goto report
if errorlevel 81 set err$msg=81, %1 is 81 minutes old
if not (%err$msg%)==() goto report
if errorlevel 80 set err$msg=80, %1 is 80 minutes old
if not (%err$msg%)==() goto report
if errorlevel 79 set err$msg=79, %1 is 79 minutes old
if not (%err$msg%)==() goto report
if errorlevel 78 set err$msg=78, %1 is 78 minutes old
if not (%err$msg%)==() goto report
if errorlevel 77 set err$msg=77, %1 is 77 minutes old
if not (%err$msg%)==() goto report
if errorlevel 76 set err$msg=76, %1 is 76 minutes old
if not (%err$msg%)==() goto report
if errorlevel 75 set err$msg=75, %1 is 75 minutes old
if not (%err$msg%)==() goto report
if errorlevel 74 set err$msg=74, %1 is 74 minutes old
if not (%err$msg%)==() goto report
if errorlevel 73 set err$msg=73, %1 is 73 minutes old
if not (%err$msg%)==() goto report
if errorlevel 72 set err$msg=72, %1 is 72 minutes old
if not (%err$msg%)==() goto report
if errorlevel 71 set err$msg=71, %1 is 71 minutes old
if not (%err$msg%)==() goto report
if errorlevel 70 set err$msg=70, %1 is 70 minutes old
if not (%err$msg%)==() goto report
if errorlevel 69 set err$msg=69, %1 is 69 minutes old
if not (%err$msg%)==() goto report
if errorlevel 68 set err$msg=68, %1 is 68 minutes old
if not (%err$msg%)==() goto report
if errorlevel 67 set err$msg=67, %1 is 67 minutes old
if not (%err$msg%)==() goto report
if errorlevel 66 set err$msg=66, %1 is 66 minutes old
if not (%err$msg%)==() goto report
if errorlevel 65 set err$msg=65, %1 is 65 minutes old
if not (%err$msg%)==() goto report
if errorlevel 64 set err$msg=64, %1 is 64 minutes old
if not (%err$msg%)==() goto report
if errorlevel 63 set err$msg=63, %1 is 63 minutes old
if not (%err$msg%)==() goto report
if errorlevel 62 set err$msg=62, %1 is 62 minutes old
if not (%err$msg%)==() goto report
if errorlevel 61 set err$msg=61, %1 is 61 minutes old
if not (%err$msg%)==() goto report
if errorlevel 60 set err$msg=60, %1 is 60 minutes old
if not (%err$msg%)==() goto report
if errorlevel 59 set err$msg=59, %1 is 59 minutes old
if not (%err$msg%)==() goto report
if errorlevel 58 set err$msg=58, %1 is 58 minutes old
if not (%err$msg%)==() goto report
if errorlevel 57 set err$msg=57, %1 is 57 minutes old
if not (%err$msg%)==() goto report
if errorlevel 56 set err$msg=56, %1 is 56 minutes old
if not (%err$msg%)==() goto report
if errorlevel 55 set err$msg=55, %1 is 55 minutes old
if not (%err$msg%)==() goto report
if errorlevel 54 set err$msg=54, %1 is 54 minutes old
if not (%err$msg%)==() goto report
if errorlevel 53 set err$msg=53, %1 is 53 minutes old
if not (%err$msg%)==() goto report
if errorlevel 52 set err$msg=52, %1 is 52 minutes old
if not (%err$msg%)==() goto report
if errorlevel 51 set err$msg=51, %1 is 51 minutes old
if not (%err$msg%)==() goto report
if errorlevel 50 set err$msg=50, %1 is 50 minutes old
if not (%err$msg%)==() goto report
if errorlevel 49 set err$msg=49, %1 is 49 minutes old
if not (%err$msg%)==() goto report
if errorlevel 48 set err$msg=48, %1 is 48 minutes old
if not (%err$msg%)==() goto report
if errorlevel 47 set err$msg=47, %1 is 47 minutes old
if not (%err$msg%)==() goto report
if errorlevel 46 set err$msg=46, %1 is 46 minutes old
if not (%err$msg%)==() goto report
if errorlevel 45 set err$msg=45, %1 is 45 minutes old
if not (%err$msg%)==() goto report
if errorlevel 44 set err$msg=44, %1 is 44 minutes old
if not (%err$msg%)==() goto report
if errorlevel 43 set err$msg=43, %1 is 43 minutes old
if not (%err$msg%)==() goto report
if errorlevel 42 set err$msg=42, %1 is 42 minutes old
if not (%err$msg%)==() goto report
if errorlevel 41 set err$msg=41, %1 is 41 minutes old
if not (%err$msg%)==() goto report
if errorlevel 40 set err$msg=40, %1 is 40 minutes old
if not (%err$msg%)==() goto report
if errorlevel 39 set err$msg=39, %1 is 39 minutes old
if not (%err$msg%)==() goto report
if errorlevel 38 set err$msg=38, %1 is 38 minutes old
if not (%err$msg%)==() goto report
if errorlevel 37 set err$msg=37, %1 is 37 minutes old
if not (%err$msg%)==() goto report
if errorlevel 36 set err$msg=36, %1 is 36 minutes old
if not (%err$msg%)==() goto report
if errorlevel 35 set err$msg=35, %1 is 35 minutes old
if not (%err$msg%)==() goto report
if errorlevel 34 set err$msg=34, %1 is 34 minutes old
if not (%err$msg%)==() goto report
if errorlevel 33 set err$msg=33, %1 is 33 minutes old
if not (%err$msg%)==() goto report
if errorlevel 32 set err$msg=32, %1 is 32 minutes old
if not (%err$msg%)==() goto report
if errorlevel 31 set err$msg=31, %1 is 31 minutes old
if not (%err$msg%)==() goto report
if errorlevel 30 set err$msg=30, %1 is 30 minutes old
if not (%err$msg%)==() goto report
if errorlevel 29 set err$msg=29, %1 is 29 minutes old
if not (%err$msg%)==() goto report
if errorlevel 28 set err$msg=28, %1 is 28 minutes old
if not (%err$msg%)==() goto report
if errorlevel 27 set err$msg=27, %1 is 27 minutes old
if not (%err$msg%)==() goto report
if errorlevel 26 set err$msg=26, %1 is 26 minutes old
if not (%err$msg%)==() goto report
if errorlevel 25 set err$msg=25, %1 is 25 minutes old
if not (%err$msg%)==() goto report
if errorlevel 24 set err$msg=24, %1 is 24 minutes old
if not (%err$msg%)==() goto report
if errorlevel 23 set err$msg=23, %1 is 23 minutes old
if not (%err$msg%)==() goto report
if errorlevel 22 set err$msg=22, %1 is 22 minutes old
if not (%err$msg%)==() goto report
if errorlevel 21 set err$msg=21, %1 is 21 minutes old
if not (%err$msg%)==() goto report
if errorlevel 20 set err$msg=20, %1 is 20 minutes old
if not (%err$msg%)==() goto report
if errorlevel 19 set err$msg=19, %1 is 19 minutes old
if not (%err$msg%)==() goto report
if errorlevel 18 set err$msg=18, %1 is 18 minutes old
if not (%err$msg%)==() goto report
if errorlevel 17 set err$msg=17, %1 is 17 minutes old
if not (%err$msg%)==() goto report
if errorlevel 16 set err$msg=16, %1 is 16 minutes old
if not (%err$msg%)==() goto report
if errorlevel 15 set err$msg=15, %1 is 15 minutes old
if not (%err$msg%)==() goto report
if errorlevel 14 set err$msg=14, %1 is 14 minutes old
if not (%err$msg%)==() goto report
if errorlevel 13 set err$msg=13, %1 is 13 minutes old
if not (%err$msg%)==() goto report
if errorlevel 12 set err$msg=12, %1 is 12 minutes old
if not (%err$msg%)==() goto report
if errorlevel 11 set err$msg=11, %1 is 11 minutes old
if not (%err$msg%)==() goto report
if errorlevel 10 set err$msg=10, %1 is 10 minutes old
if not (%err$msg%)==() goto report
if errorlevel 9 set err$msg=9, %1 is 9 minutes old
if not (%err$msg%)==() goto report
if errorlevel 8 set err$msg=8, %1 is 8 minutes old
if not (%err$msg%)==() goto report
if errorlevel 7 set err$msg=7, %1 is 7 minutes old
if not (%err$msg%)==() goto report
if errorlevel 6 set err$msg=6, %1 is 6 minutes old
if not (%err$msg%)==() goto report
if errorlevel 5 set err$msg=5, %1 is 5 minutes old
if not (%err$msg%)==() goto report
if errorlevel 4 set err$msg=4, %1 is 4 minutes old
if not (%err$msg%)==() goto report
if errorlevel 3 set err$msg=3, %1 is 3 minutes old
if not (%err$msg%)==() goto report
if errorlevel 2 set err$msg=2, %1 is 2 minutes old
if not (%err$msg%)==() goto report
if errorlevel 1 set err$msg=1, %1 is 1 minute old
if not (%err$msg%)==() goto report
if errorlevel 0 set err$msg=0, %1 is less than 1 minute old
if not (%err$msg%)==() goto report

:USAGE
ECHO Usage: TEST [[drive:][path]filename[ ...]]
ECHO ---
ECHO This program is used to test the FILEAGE program.  It will report the
ECHO errorlevel that FILEAGE exits and show the meaning of that errorlevel.
ECHO ---
GOTO END

:REPORT
echo Error Level = %ERR$MSG%
SET ERR$MSG=

:END