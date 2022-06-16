class_name Parser

# This class provides a set of inner subclasses that allow the definition
# of a parser for a custom language. The language is defined through the means
# of GrammarElement. Calling GrammarElement.parse("str") on a string will
# either produce a ParsedSymbol on success, or return null if the parsing 
# failed.
#
# The main Grammar elements:
#
# Grammar
# 	Used to add a set of other GrammarElement objects which all are tried
# 	to produce a valid parsing for a given string. The longest parse will be
# 	returned as the parse of a Grammar object (Top-Down parsing). They
#	typically form the root-element of any defined Grammar.
#
#	Grammar objects are initialized without arguments, and require the user
#	to add sub-objects to their Gramar.elements array one-by-one. This is
#	done to facilitate recursive parser elements.
#
#
# GrammarSequence
#	This class takes a list of other GrammarElement objects and tries to
#	apply all of them in the defined sequence. A parse is considered
#	successful only if all elements where mached successfully.
#
#	A GrammarSequence object takes three arguments, one optional:
#	- The name of the symbol this GrammarSequence represents
#	- The sequence of elements to match as an Array.
#	- (optional) Boolean indicating a match should be "flattened" after
#		successful parsing. Flatting means that direct symbols ancestors with
#		the same name as the GrammarSequence will be inlined, allowing for
#		easier definition of recursive sequence parsers
#		(See arglist parser of the StringTemplating class for an example). 
#
#
# GrammarLiteral
# 	Class matching literal strings. Needs to be an exact match, but whitespace
#	can be ignored through the flag GrammarLiteral.ignore_whitespace.
#
#
# GrammarRegex
# 	Same as GrammarLiteral, but uses a regex to perform the matching. If the
#   regex contains a capture-group, the capture group will be used as the
#	Symbol-value. Also can ignore whitespace through the 
#	GrammarRegex.ignore_whitespace option.
#
#
# ParsedSymbol
#	If a parse was successful, this object will be return the parse-tree.
#	The most important attributes are:
#	- name: The symbol name that is assigned GrammarElement that was used for
#		this node.
#	- subsymbols: The list of symbols that are contained in this symbol. Only
#		relevant for a GrammarSequence which will contain a list of other
#		symbols.
#	- value: The data that was matched by the Grammar rule.

# -------------------------------------------------------------------------------------------------
class ParsedSymbol:
	extends Reference

	var name: String
	var last_position: int
	var subsymbols: Array
	var value
	
	func _init(_name: String, _last_position: int, _subsymbols: Array, _value).():
		name = _name
		last_position = _last_position
		subsymbols = _subsymbols
		value = _value
	
	func find_first_subsymbol(symbol_name: String):
		for st in subsymbols:
			if st.name == symbol_name:
				return st
		return null
	
	func _to_string():
		var subsymbol_strings = PoolStringArray([])
		for st in subsymbols:
			subsymbol_strings.append(str(st))
		return "<T name={name}{value} [{subsymbols}]>".format({
			"name": name,
			"value": (" '%s'" % value) if value else "",
			"subsymbols": subsymbol_strings.join(", ")
		})

# -------------------------------------------------------------------------------------------------
class GrammarElement:
	func parse(s: String):
		pass
	

# -------------------------------------------------------------------------------------------------
class Grammar:
	extends GrammarElement
	
	var replace_name = null
	var elements: Array = []
	
	func parse(s: String):
		var best = null
		for e in elements:
			var c = e.parse(s)
			if c is ParsedSymbol:
				if (best == null) || (best.last_position < c.last_position):
					best = c
		return best

# -------------------------------------------------------------------------------------------------
class GrammarSequence:
	extends GrammarElement

	var name: String
	var elements: Array
	var flatten_same_name := false
	
	func _init(_name: String, _elements: Array = [], _flatten_same_name = false):
		name = _name
		elements = _elements
		flatten_same_name = _flatten_same_name

	func parse(s: String):
		var position := 0
		var symbols := []
		
		for e in elements:
			var t = e.parse(s.substr(position))
			if !t:
				return null
			t = t as ParsedSymbol
			position += t.last_position
			t.last_position = position
			symbols.append(t)
		
		if flatten_same_name:
			var new_symbols := []
			for t in symbols:
				if t.name == name:
					new_symbols.append_array(t.subsymbols)
				else:
					new_symbols.append(t)
			symbols = new_symbols
			
		return ParsedSymbol.new(name, position, symbols, null)

# -------------------------------------------------------------------------------------------------
class GrammarLiteral:
	extends GrammarElement
	
	var name: String
	var value: String
	var ignore_whitespace := true
	
	func _init(_name: String, _value = null):
		if _value == null:
			_value = _name
		name = _name
		value = _value
	
	func parse(s: String):
		var test_in := s
		if ignore_whitespace:
			test_in = test_in.strip_edges(true, false)
		if !test_in.begins_with(self.value):
			return null
		
		return ParsedSymbol.new(name, s.find(value) + len(value), [], value)
		
# -------------------------------------------------------------------------------------------------
class GrammarRegexMatch:
	extends GrammarElement
	
	var name: String
	var regex := RegEx.new()
	var ignore_whitespace = true
	
	func _init(_name: String, pattern: String):
		name = _name
		regex = RegEx.new()
		regex.compile(pattern)
	
	func parse(s: String):
		var test_in := s
		if ignore_whitespace:
			test_in = test_in.strip_edges(true, false)
		var m = regex.search(test_in)
		if !m || m.get_start() > 0:
			return null
		m = regex.search(s) as RegExMatch
		var value = m.get_string()
		if m.get_group_count() > 0:
			value = m.get_string(1)
		return ParsedSymbol.new(name, m.get_end(), [], value)
	
