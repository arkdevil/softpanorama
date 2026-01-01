/* Routines to build and evaluate the expression tree.
   Copyright (C) 1987, 1990 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 1, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.

   $Header: e:/gnu/find/RCS/tree.c 1.2.0.3 90/09/23 16:09:57 tho Exp $
 */

#include <stdio.h>
#include <sys/types.h>
#include "defs.h"

#ifdef MSDOS
struct pred_struct *scan_rest (struct pred_struct **input,\
			       struct pred_struct *head, short prev_prec);
#else /* not MSDOS */
struct pred_struct *scan_rest ();
#endif /* not MSDOS */


/* Return a pointer to a tree that represents the
   expression prior to non-unary operator *INPUT.
   Set *INPUT to point at the next input predicate node.

   Only accepts the following:
   
   <victim>
   expression		[operators of higher precedence]
   <uni_op><victim>
   (arbitrary expression)
   <uni_op>(arbitrary expression)
   
   In other words, you can not start out with a bi_op or close_paren.

   If the following operator (if any) is of a higher precedence than
   PREV_PREC, the expression just nabbed is part of a following
   expression, which really is the expression that should be handed to
   our caller, so get_expr recurses. */

struct pred_struct *
get_expr (input, prev_prec)
     struct pred_struct **input;
     short prev_prec;
{
  struct pred_struct *next;

  if (*input == NULL)
    error (1, 0, "invalid expression");
  switch ((*input)->p_type)
    {
    case NO_TYPE:
    case BI_OP:
    case CLOSE_PAREN:
      error (1, 0, "invalid expression");
      break;

    case VICTIM_TYPE:
      next = *input;
      *input = (*input)->pred_next;
      break;

    case UNI_OP:
      next = *input;
      *input = (*input)->pred_next;
      next->pred_left = get_expr (input, NEGATE_PREC);
      break;

    case OPEN_PAREN:
      *input = (*input)->pred_next;
      next = get_expr (input, NO_PREC);
      if ((*input == NULL)
	  || ((*input)->p_type != CLOSE_PAREN))
	error (1, 0, "invalid expression");
      *input = (*input)->pred_next;	/* move over close */
      break;

    default:
      error (1, 0, "oops -- invalid expression type!");
      break;
    }

  /* We now have the first expression and are positioned to check
     out the next operator.  If NULL, all done.  Otherwise, if
     PREV_PREC < the current node precedence, we must continue;
     the expression we just nabbed is more tightly bound to the
     following expression than to the previous one. */
  if (*input == NULL)
    return (next);
  if ((int) (*input)->p_prec > (int) prev_prec)
    {
      next = scan_rest (input, next, prev_prec);
      if (next == NULL)
	error (1, 0, "invalid expression");
    }
  return (next);
}

/* Scan across the remainder of a predicate input list starting
   at *INPUT, building the rest of the expression tree to return.
   Stop at the first close parenthesis or the end of the input list.
   Assumes that get_expr has been called to nab the first element
   of the expression tree.
   
   *INPUT points to the current input predicate list element.
   It is updated as we move along the list to point to the
   terminating input element.
   HEAD points to the predicate element that was obtained
   by the call to get_expr.
   PREV_PREC is the precedence of the previous predicate element. */

struct pred_struct *
scan_rest (input, head, prev_prec)
     struct pred_struct **input;
     struct pred_struct *head;
     short prev_prec;
{
  struct pred_struct *tree;	/* The new tree we are building. */

  if ((*input == NULL) || ((*input)->p_type == CLOSE_PAREN))
    return (NULL);
  tree = head;
  while ((*input != NULL) && ((int) (*input)->p_prec > (int) prev_prec))
    {
      switch ((*input)->p_type)
	{
	case NO_TYPE:
	case VICTIM_TYPE:
	case UNI_OP:
	case OPEN_PAREN:
	  error (1, 0, "invalid expression");
	  break;

	case BI_OP:
	  (*input)->pred_left = tree;
	  tree = *input;
	  *input = (*input)->pred_next;
	  tree->pred_right = get_expr (input, tree->p_prec);
	  break;

	case CLOSE_PAREN:
	  return (tree);

	default:
	  error (1, 0, "oops -- invalid expression type!");
	  break;
	}
    }
  return (tree);
}
