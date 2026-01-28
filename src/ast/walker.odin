package ast

import "core:mem"

Visitor :: struct {
	allocator: mem.Allocator,
	user_data: rawptr,
}

Visitor_VTable :: struct {
	visit_ident:			  proc(v: ^Visitor, node: ^Ident),
	visit_basic_lit:		  proc(v: ^Visitor, node: ^Basic_Lit),
	visit_unary_expr:		  proc(v: ^Visitor, node: ^Unary_Expr),
	visit_binary_expr:	      proc(v: ^Visitor, node: ^Binary_Expr),
	visit_paren_expr:		  proc(v: ^Visitor, node: ^Paren_Expr),
	visit_member_access_expr: proc(v: ^Visitor, node: ^Member_Access_Expr),
	visit_index_expr:	   	  proc(v: ^Visitor, node: ^Index_Expr),
	visit_call_expr:		  proc(v: ^Visitor, node: ^Call_Expr),
	visit_field_value:	      proc(v: ^Visitor, node: ^Field_Value),
	visit_field_access:	      proc(v: ^Visitor, node: ^Field_Access),

	visit_func_stmt:		  proc(v: ^Visitor, node: ^Func_Stmt),
	visit_event_stmt:		  proc(v: ^Visitor, node: ^Event_Stmt),
	visit_expr_stmt:		  proc(v: ^Visitor, node: ^Expr_Stmt),
	visit_assign_stmt:	      proc(v: ^Visitor, node: ^Assign_Stmt),
	visit_block_stmt:	      proc(v: ^Visitor, node: ^Block_Stmt),
	visit_if_stmt:		      proc(v: ^Visitor, node: ^If_Stmt),
	visit_return_stmt:	      proc(v: ^Visitor, node: ^Return_Stmt),
	visit_defer_stmt:		  proc(v: ^Visitor, node: ^Defer_Stmt),
	visit_for_stmt:		      proc(v: ^Visitor, node: ^For_Stmt),
	visit_value_decl:		  proc(v: ^Visitor, node: ^Value_Decl),

	visit_param:			  proc(v: ^Visitor, node: ^Param),
	visit_param_list:	      proc(v: ^Visitor, node: ^Param_List),
	visit_argument:	          proc(v: ^Visitor, node: ^Argument),
	visit_annotation:	      proc(v: ^Visitor, node: ^Annotation),
	visit_file:			      proc(v: ^Visitor, node: ^File),

	before_visit_node:	      proc(v: ^Visitor, node: ^Node) -> bool,
	after_visit_node:	      proc(v: ^Visitor, node: ^Node),
	before_visit_child:	      proc(v: ^Visitor, parent, child: ^Node) -> bool,
	after_visit_child:	      proc(v: ^Visitor, parent, child: ^Node),
}

Walker :: struct {
	using visitor: Visitor,
	vtable: ^Visitor_VTable,
}

walker_init :: proc(w: ^Walker, vtable: ^Visitor_VTable, allocator := context.allocator) {
	w.allocator = allocator
	w.vtable = vtable
}

walk_node :: proc(w: ^Walker, node: ^Node) {
	if node == nil {
		return
	}

	if w.vtable.before_visit_node != nil {
		if !w.vtable.before_visit_node(&w.visitor, node) {
			return
		}
	}

	#partial switch n in node.derived {
	case ^Ident:
		if w.vtable.visit_ident != nil {
			w.vtable.visit_ident(&w.visitor, n)
		}

	case ^Basic_Lit:
		if w.vtable.visit_basic_lit != nil {
			w.vtable.visit_basic_lit(&w.visitor, n)
		}

	case ^Unary_Expr:
		if w.vtable.visit_unary_expr != nil {
			w.vtable.visit_unary_expr(&w.visitor, n)
		}
		walk_child_expr(w, node, n.expr)

	case ^Binary_Expr:
		if w.vtable.visit_binary_expr != nil {
			w.vtable.visit_binary_expr(&w.visitor, n)
		}
		walk_child_expr(w, node, n.left)
		walk_child_expr(w, node, n.right)

	case ^Paren_Expr:
		if w.vtable.visit_paren_expr != nil {
			w.vtable.visit_paren_expr(&w.visitor, n)
		}
		walk_child_expr(w, node, n.expr)

	case ^Member_Access_Expr:
		if w.vtable.visit_member_access_expr != nil {
			w.vtable.visit_member_access_expr(&w.visitor, n)
		}
		walk_child_expr(w, node, n.expr)
		walk_child_node(w, node, n.field)

	case ^Index_Expr:
		if w.vtable.visit_index_expr != nil {
			w.vtable.visit_index_expr(&w.visitor, n)
		}
		walk_child_expr(w, node, n.expr)
		walk_child_expr(w, node, n.index)

	case ^Call_Expr:
		if w.vtable.visit_call_expr != nil {
			w.vtable.visit_call_expr(&w.visitor, n)
		}
		walk_child_expr(w, node, n.expr)
		for arg in n.args {
			walk_child_node(w, node, arg)
		}

	case ^Field_Value:
		if w.vtable.visit_field_value != nil {
			w.vtable.visit_field_value(&w.visitor, n)
		}
		walk_child_expr(w, node, n.field)
		walk_child_expr(w, node, n.value)

	case ^Field_Access:
		if w.vtable.visit_field_access != nil {
			w.vtable.visit_field_access(&w.visitor, n)
		}
		walk_child_expr(w, node, n.expr)

	case ^Func_Stmt:
		if w.vtable.visit_func_stmt != nil {
			w.vtable.visit_func_stmt(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		walk_child_node(w, node, n.params)
		walk_child_node(w, node, n.body)

	case ^Event_Stmt:
		if w.vtable.visit_event_stmt != nil {
			w.vtable.visit_event_stmt(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		walk_child_node(w, node, n.params)
		walk_child_node(w, node, n.body)

	case ^Expr_Stmt:
		if w.vtable.visit_expr_stmt != nil {
			w.vtable.visit_expr_stmt(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		walk_child_expr(w, node, n.expr)

	case ^Assign_Stmt:
		if w.vtable.visit_assign_stmt != nil {
			w.vtable.visit_assign_stmt(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		walk_child_expr(w, node, n.expr)

	case ^Block_Stmt:
		if w.vtable.visit_block_stmt != nil {
			w.vtable.visit_block_stmt(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		for stmt in n.stmts {
			walk_child_node(w, node, stmt)
		}

	case ^If_Stmt:
		if w.vtable.visit_if_stmt != nil {
			w.vtable.visit_if_stmt(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		walk_child_node(w, node, n.init)
		walk_child_expr(w, node, n.cond)
		walk_child_node(w, node, n.body)
		walk_child_node(w, node, n.else_stmt)

	case ^Return_Stmt:
		if w.vtable.visit_return_stmt != nil {
			w.vtable.visit_return_stmt(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		walk_child_expr(w, node, n.result)

	case ^Defer_Stmt:
		if w.vtable.visit_defer_stmt != nil {
			w.vtable.visit_defer_stmt(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		walk_child_node(w, node, n.stmt)

	case ^For_Stmt:
		if w.vtable.visit_for_stmt != nil {
			w.vtable.visit_for_stmt(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		if n.init != nil {
			for ident in n.init {
				walk_child_node(w, node, ident)
			}
		}
		walk_child_expr(w, node, n.cond)
		walk_child_expr(w, node, n.second_cond)
		walk_child_node(w, node, n.post)
		walk_child_node(w, node, n.body)

	case ^Value_Decl:
		if w.vtable.visit_value_decl != nil {
			w.vtable.visit_value_decl(&w.visitor, n)
		}
		for &anno in n.annotations {
			walk_child_node(w, node, &anno)
		}
		walk_child_expr(w, node, n.value)

	case ^Param:
		if w.vtable.visit_param != nil {
			w.vtable.visit_param(&w.visitor, n)
		}

	case ^Param_List:
		if w.vtable.visit_param_list != nil {
			w.vtable.visit_param_list(&w.visitor, n)
		}
		for param in n.list {
			walk_child_node(w, node, param)
		}

	case ^Argument:
		if w.vtable.visit_argument != nil {
			w.vtable.visit_argument(&w.visitor, n)
		}
		walk_child_expr(w, node, n.value)

	case ^Annotation:
		if w.vtable.visit_annotation != nil {
			w.vtable.visit_annotation(&w.visitor, n)
		}
		walk_child_expr(w, node, n.value)

	case ^File:
		if w.vtable.visit_file != nil {
			w.vtable.visit_file(&w.visitor, n)
		}
		for decl in n.decls {
			walk_child_node(w, node, decl)
		}
	}

	if w.vtable.after_visit_node != nil {
		w.vtable.after_visit_node(&w.visitor, node)
	}
}

walk_child_node :: proc(w: ^Walker, parent, child: ^Node) {
	if child == nil {
		return
	}

	if w.vtable.before_visit_child != nil {
		if !w.vtable.before_visit_child(&w.visitor, parent, child) {
			return
		}
	}

	walk_node(w, child)

	if w.vtable.after_visit_child != nil {
		w.vtable.after_visit_child(&w.visitor, parent, child)
	}
}

walk_child_expr :: proc(w: ^Walker, parent: ^Node, expr: ^Expr) {
	walk_child_node(w, parent, expr)
}

walk_child_stmt :: proc(w: ^Walker, parent: ^Node, stmt: ^Stmt) {
	walk_child_node(w, parent, stmt)
}

walk_expr :: proc(w: ^Walker, expr: ^Expr) {
	walk_node(w, expr)
}

walk_stmt :: proc(w: ^Walker, stmt: ^Stmt) {
	walk_node(w, stmt)
}

walk_file :: proc(w: ^Walker, file: ^File) {
	walk_node(w, file)
}
