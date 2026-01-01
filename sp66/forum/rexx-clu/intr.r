/* interrupt test */
/* print msg via int 21, ah = 9 */
msg = "This is an interrupt test. Prints this message",
      "using Dos int 21, ah=9." || "0A0D"x || "$"
seg = d2x(addr('msg') % 16)
ofs = d2x(addr('msg') // 16)
regs = intr( x2d("21"), "ax=0900 dx="ofs "ds="seg )
say regs
