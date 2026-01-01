;**
;**		BRIEF -- Basic Reconfigurable Interactive Editing Facility
;**
;**		Written by Dave Nanian and Michael Strickman.
;**
;**		Revision history:
;**		-----------------
;**		15 April 1986			delete_curr_buffer now accepts "w" to write
;**									modified buffer.
;**
;**		6 April 1986			Made environemnt variables case insensitive.
;**
;**		29 December 1985		Fixed bug in support of Microsoft CL (needed .c).
;**
;**		13 December 1985		Added support for MASM v4.0.
;**
;**		31 October 1985		Changed pass strings to allow options before
;**									or after filename.
;**
;**		6 October 1985			Added support for the Microsoft C compiler.
;**

;**
;**		extended.m:
;**
;**		This file contains BRIEF's standard extended definitions.
;**

(macro extended
	(
		;**
		;**	Tell BRIEF where to find the separate extended macros...
		;**

		(autoload "i_search" "i_search")
		(autoload "indent" "init_indent" "indent")
		(autoload "errorfix" "next_error" "errorfix" "previous_error")
		(autoload "key" "key")
		(autoload "cc" "cc")
		(autoload "cm" "cm")
		(autoload "repeat" "repeat")

		;**
		;**	Do the standard extended key assignments.
		;**

		(assign_to_key "#18488" "win_up")				;** Assigned to Shift-Up Arrow.
		(assign_to_key "#19766" "win_right")			;** Assigned to Shift-Right Arrow.
		(assign_to_key "#20530" "win_down")				;** Assigned to Shift-Down Arrow.
		(assign_to_key "#19252" "win_left")				;** Assigned to Shift-Left Arrow.
		(assign_to_key "^c" "center_window_line")		;** Assigned to Ctrl-c.
		(assign_to_key "^t" "to_top")						;** Assigned to Ctrl-t.
		(assign_to_key "^b" "to_bottom")					;** Assigned to Ctrl-b.
		(assign_to_key "^u" "screen_up")					;** Assigned to Ctrl-u.
		(assign_to_key "^d" "screen_down")				;** Assigned to Ctrl-d.
		(assign_to_key "%#130" "delete_curr_buffer")	;** Assigned to Alt-minus.
		(assign_to_key "%#93" "key")						;** Assigned to Shift-F10.
		(assign_to_key "%#113" "compile_it")			;** Assigned to Alt-F10.
		(assign_to_key "%#108" "i_search")				;** Assigned to Alt-F5.
		(assign_to_key "#18745" "left_side")			;** Assigned to Shift-PgUp.
		(assign_to_key "#20787" "right_side")			;** Assigned to Shift-PgDn.
		(assign_to_key "^r" "repeat")						;** Assigned to Ctrl-r.
		(assign_to_key "^n" "next_error")				;** Assigned to Ctrl-n.

		(init_indent)											;** Initialize automatic indenting.
	)
)

;**
;**		This function automatically compiles the file in the current
;**	buffer.  It checks to see if the extension is ".m" or ".c":  if
;**	it is a macro file the "cm" macro is executed, and if it is a C
;**	file, one of the three supported C compilers is executed.  By
;**	creating your own compiler string, another compiler can be
;**	substituted.  The compiler string is of the form:
;**
;**			pass_1 %s >&pass_2 %s >&...pass_n %s >&
;**
;**		Each pass is the name of the program that should be used for
;**	that compilation pass.  That is followed by a space, the special
;**	string "%s", which is replaced by the filename, and the string ">&."
;**	These special characters are very important -- don't forget them!
;**
;**		If you want to pass options to your compiler, you can place them
;**	either before or after the "%s".  Placing them before puts the option
;**	before the filename, and after puts them after the filename.
;**

(macro compile_it
	(
		(string	extension)

		(inq_names NULL extension)

               (if (|| (== extension "y") (== extension "pcy"))
                   (pcyacc)
               ;else
		(if (== extension "m")
			(cm)
		;else
			(if (== extension "asm")
				(masm)
			;else

			;**
			;**		The lines that follow call the appropriate macro to compile
			;**	a C program.  This information is retrieved from the 
			;**	environment variable BCC.  If the variable is not set, the
			;**	Wizard C compiler is used.
			;**

				(if (== extension "c")
					(
						(if (== (= extension (lower (inq_environment "BCC"))) "")
							(= extension "mcc")
						)
						(execute_macro extension)
					)
				;else
					(error "Can't compile: not a .c, .m .y .pcy or .asm file.")
				)
			)
		))
	)
)

;**
;**		These macros call the generic "cc" macro with the specific
;**	information needed to support the Computer Innovations, Lattice,
;**	and Wizard C compilers.  See the Macro Usage Guide for information
;**	on how to customize these macros for your compiler setup.
;**

(macro c86cc
	(cc "cc1 %s >&cc2 %s >&cc3 %s >&cc4 %s >&")
)

(macro lcc
	(cc "lc1 %s >&lc2 %s >&")
)

(macro wcc
	(cc "cpp %s >&p1 %s >&p2obj %s >&")
)

(macro mcc
	(cc "cl -c %s.c >&")
)

(macro msc
	(cc "msc %s\; >&")
)

(macro tcc
       (cc "tcc -c %s >&")
)

(macro masm
	(cc "masm %s\; >&" "asm")
)

(macro pcyacc
       (cc "pcyacc %s.y >&" "y")
)

(macro lc3
	(cc "lc %s >&")								;** For Lattice C v3.0.
)

;**
;**		Window switch functions.
;**

(macro win_left
	(
		(if (> (change_window 3) 0)
			(display_file_name)
		)
	)
)

(macro win_right
	(
		(if (> (change_window 1) 0)
			(display_file_name)
		)
	)
)

(macro win_up
	(
		(if (> (change_window 0) 0)
			(display_file_name)
		)
	)
)

(macro win_down
	(
		(if (> (change_window 2) 0)
			(display_file_name)
		)
	)
)

;**
;**		Word deletion functions.
;**

(macro delete_next_word
	(
		(drop_anchor)
		(search_fwd "{[ \\t][~ \\t]}|{\\c[~ \\t]>}")
		(delete_block)
	)
)

(macro delete_previous_word
	(if (previous_word)
		(delete_next_word)
	)
)

;**
;**		delete_curr_buffer:
;**
;**		This function deletes the current buffer, if it is unmodified,
;**	there is another buffer in the list to replace it, and it is only
;**	visible in one window.
;**
;**		If the buffer is modified, the user is asked if he really wants to
;**	delete the buffer.  If he answers yes, the deletion is performed.
;**
;**		If there are no other buffers, or the buffer is in more than one
;**	window, the deletion is not performed.
;**

(macro delete_curr_buffer
	(
		(int			old_buf_id
						new_buf_id
		)
		(string		reply
						file_name
		)
		(= reply "y")
		(= old_buf_id (inq_buffer))
		(= new_buf_id (next_buffer))

		(if (!= old_buf_id new_buf_id)
			(if (== (inq_views) 1)
				(
					(if (inq_modified)
						(
							(keyboard_flush)

							(if (! (get_parm NULL reply "Buffer is modified: are you sure? " 1))
								(= reply "n")
							)
						)
					)
					(if (index "yYwW" reply)
						(
							(int	ret_code)

							(= ret_code 1)

							(if (index "wW" reply)
								(
									(int	old_msg_level)

									(= old_msg_level (inq_msg_level))
									(set_msg_level 0)
									(= ret_code (write_buffer))
									(set_msg_level old_msg_level)
								)
							)
							(if ret_code
								(
									(set_buffer new_buf_id)
									(inq_names file_name NULL)
									(set_buffer old_buf_id)
									(edit_file file_name)
									(display_file_name)
									(delete_buffer old_buf_id)
								)
							)
						)
					;else
						(message "Buffer not deleted.")
					)
				)
			;else
				(error "Can't delete: buffer is in multiple windows.")
			)
		;else
			(error "Can't delete: no other buffers.")
		)
	)
)

;**
;**		Line in window functions:
;**
;**		The following functions manipulate lines in windows, moving them in
;**	relation to the window.
;**

;**		to_top:
;**
;**		This function moves a file line to the top of the window.
;**	Note that this does a number of strange things with the window and
;**	refreshing -- these are necessary since a window's cursor coordinates
;**	are not altered until the window is refreshed.
;**

(macro to_top
	(
		(int			curr_line
						top_line
						diff
		)
		(inq_position curr_line)
		(top_of_window)
		(inq_position top_line)

		(if (= diff (- curr_line top_line))
			(
				(end_of_window)
				(refresh)
				(move_rel diff 0)
				(refresh)
			)
		)
		(move_abs curr_line 0)
	)
)

;**		to_bottom:
;**
;**		This function moves a file line to the bottom of the window.
;**	Note that this does a number of strange things with the window and
;**	refreshing -- these are necessary since a window's cursor coordinates
;**	are not altered until the window is refreshed.
;**

(macro to_bottom
	(
		(int			curr_line
						end_line
						diff
		)
		(inq_position curr_line)
		(end_of_window)
		(inq_position end_line)

		(if (= diff (- curr_line end_line))
			(
				(top_of_window)
				(refresh)
				(move_rel diff 0)
				(refresh)
			)
		)
		(move_abs curr_line 0)
	)
)

;**
;**		screen_up:
;**
;**		This macro scrolls the screen up by one line.
;**

(macro screen_up
	(
		(int		curr_line
					test_line
		)
		(inq_position curr_line)
		(top_of_window)
		(inq_position test_line)

		(if (== test_line curr_line)
			(++ curr_line)
		)
		(end_of_window)
		(refresh)
		(move_rel 1 0)
		(refresh)
		(move_abs curr_line 0)
	)
)

;**
;**		screen_down:
;**
;**		This macro scrolls the screen down by one line.
;**

(macro screen_down
	(
		(int		curr_line
					test_line
		)
		(inq_position curr_line)
		(end_of_window)
		(inq_position test_line)

		(if (== test_line curr_line)
			(-- curr_line)
		)
		(top_of_window)
		(refresh)
		(move_rel -1 0)
		(refresh)
		(move_abs curr_line 0)
	)
)

;**
;**		center_window_line:
;**
;**		This macro attempts to center the given line in the current window.
;**	If the line cannot be centered because it is too close to the top of
;**	the window, it is left in the same place.
;**

(macro center_window_line
	(
		(int		num_lines
					num_cols
					curr_line
					curr_col
					test_line
					test_col
					diff
		)
		(inq_position curr_line curr_col)
		(inq_window_size num_lines num_cols)
		(top_of_window)
		(inq_position test_line test_col)
		(/= num_lines 2)

		(if (= diff (- curr_line (+ num_lines test_line)))
			(
				(if (> diff 0)
					(end_of_window)
				)
				(refresh)
				(move_rel diff 0)
				(refresh)
				(move_abs curr_line curr_col)
			)
		;else
			(move_abs curr_line curr_col)
		)
	)
)

;**
;**		left_side:
;**
;**		This macro moves the cursor to the left side of the window.
;**

(macro left_side
	(
		(int		shift)

		(inq_window_size NULL NULL shift)
		(move_abs 0 (+ shift 1))
	)
)

;**
;**		right_side:
;**
;**		This macro moves the cursor to the left side of the window.
;**

(macro right_side
	(
		(int		num_cols
					shift
		)
		(inq_window_size NULL num_cols shift)
		(move_abs 0 (+ num_cols shift))
	)
)
