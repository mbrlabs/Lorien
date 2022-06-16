class_name StringTemplating

# This class implements a more advanced, extensible string templating engine
# than Godot natively provides. It is loosely based on the syntax used by the 
# Python library jinja2 (https://jinja.palletsprojects.com/en/2.11.x/templates/)
# but a lot simpler.
# 
# It provides string substitution of templates strings of the form
# > var template = "this {{ filter('param1', 'param2') }} was processed"
#
# The {{ ... }} bit denotes a section of the string that will be processed by
# the StringTemplating engine. filter() is a reference to a filter-list that can
# be provided when a StringTemplating object is created.
# 
# Example:
#
# > func _filter(arg1, arg2):
# > 	return arg1 + "," + arg2
# >
# > var templating = StringTemplating.new({"filter": funcref(self, "_filter")})
# 
# This would define a filter-function called "filter" than when used on the
# example template shown earlier would produce:
#
# > templating.process_string(template)
# >> "this param1,param2 was processed"

const TEMPLATE_START := "{{"
const TEMPLATE_END := "}}"

var filters: Dictionary
var parse_grammar: DSLParser.Grammar

# -------------------------------------------------------------------------------------------------
func _log_error(message: String) -> void:
	printerr("String templating error: %s" % message)

# -------------------------------------------------------------------------------------------------
class TemplateLocation:
	var template_text: String
	var start: int
	var end: int
	
	func _to_string():
		return "<TemplateLocation range={start}:{end} text='{text}'>".format({
			"start": self.start,
			"end": self.end,
			"text": self.template_text
		})

# -------------------------------------------------------------------------------------------------
func _init(_filters: Dictionary):
	filters = _filters
	_init_grammar()
	_selftest()

# -------------------------------------------------------------------------------------------------
func _init_grammar() -> void:
	var g_string = DSLParser.Grammar.new()
	g_string.elements.append_array([
		DSLParser.GrammarRegexMatch.new("string", "'([^']*)'"),
		DSLParser.GrammarRegexMatch.new("string", '"([^"]*)"')
	])
	
	var g_arg_list = DSLParser.Grammar.new()
	g_arg_list.elements.append(DSLParser.GrammarSequence.new("args", []))
	g_arg_list.elements.append(DSLParser.GrammarSequence.new("args", [g_string]))
	g_arg_list.elements.append(DSLParser.GrammarSequence.new(
		"args",
		[g_string, DSLParser.GrammarLiteral.new(","), g_arg_list],
		true
	))
	
	var g_func_name = DSLParser.GrammarRegexMatch.new("func_name", "[a-zA-Z0-9_]+")
	var g_func_call = DSLParser.GrammarSequence.new(
		"func_call", 
		[
			g_func_name,
			DSLParser.GrammarLiteral.new("("),
			g_arg_list,
			DSLParser.GrammarLiteral.new(")")
		]
	)

	parse_grammar = DSLParser.Grammar.new()
	parse_grammar.elements.append(g_func_call)
	parse_grammar.elements.append(g_string)
	
# -------------------------------------------------------------------------------------------------
func process_string(template: String) -> String:
	var offset := 0
	while true:
		var found = _find_template_location(template.substr(offset))
		if not found:
			break
		found = found as TemplateLocation

		var substitution = "TEMPLATE_ERROR"
		var parsed = _parse(found.template_text.strip_edges())
		if parsed == null:
			_log_error("Cannot parse template '%s'" % found.template_text)
		else:
			var s = _apply_filter(parsed)
			if s is String:
				substitution = s

		template = template.substr(0, found.start) + substitution + template.substr(found.end)
		offset = found.start + len(substitution)
	return template

# -------------------------------------------------------------------------------------------------
func _find_template_location(s: String):
	var start = s.find(TEMPLATE_START)
	if start == -1:
		return null
	
	var result := TemplateLocation.new()
	result.start = start

	var in_string = null
	for i in range(start, len(s)):
		if in_string is String:
			if s[i] == in_string:
				in_string = null
		elif s[i] in ["'", '"']:
			in_string = s[i]
		else:
			if s.substr(i).find(TEMPLATE_END) == 0:
				result.end = i + len(TEMPLATE_END)
				result.template_text = s.substr(
					result.start + len(TEMPLATE_START), 
					result.end - result.start - len(TEMPLATE_END) - + len(TEMPLATE_START)
				)
				return result
	_log_error("String '%s' does contain unreadable template" % s)

# -------------------------------------------------------------------------------------------------
func _parse(s: String):
	s = s.strip_edges()
	var parsed = parse_grammar.parse(s)
	if parsed is DSLParser.ParsedSymbol:
		# Check that everything got consumed
		if parsed.last_position != len(s):
			return null
	return parsed

# -------------------------------------------------------------------------------------------------
func _apply_filter(parsed: DSLParser.ParsedSymbol):
	if parsed.name == "string":
		return parsed.value
	elif parsed.name == "func_call":
		var func_name: String = parsed.subsymbols[0].value
		if ! func_name in filters:
			_log_error("Filter '%s' does not exist" % func_name)
			return null
		
		parsed = parsed as DSLParser.ParsedSymbol
		var parsed_args_list: DSLParser.ParsedSymbol = parsed.find_first_subsymbol("args")
		var arg_values = []
		for a in parsed_args_list.subsymbols:
			if a.name in ["(", ")", ","]:
				continue
			arg_values.append(_apply_filter(a))
		return filters[func_name].call_funcv(arg_values)
	else:
		return null

# -------------------------------------------------------------------------------------------------
# TODO: Replace with unittests when available
func _selftest():
	# Test template detection
	var found_template
	found_template = _find_template_location("AAAAAA{{ '{{}}}}{{' }}AAAAAAAAA}}")
	assert(found_template != null)
	assert(found_template.start == 6)
	assert(found_template.template_text == " '{{}}}}{{' ")

	# Test templating language
	var ref: String
	var parsed: String

	ref = "<T name=string 'Hello world' []>"
	parsed = str(_parse('"Hello world"'))
	assert(parsed == ref)
	
	ref = "<T name=func_call [<T name=func_name 'call' []>, <T name=( '(' []>, <T name=args []>, <T name=) ')' []>]>"
	parsed = str(_parse('call()'))
	assert(parsed == ref)

	ref = "<T name=func_call [<T name=func_name 'call' []>, <T name=( '(' []>, <T name=args [<T name=string 'arg1' []>]>, <T name=) ')' []>]>"
	parsed = str(_parse('call("arg1")'))
	assert(parsed == ref)

	ref = "<T name=func_call [<T name=func_name 'call' []>, <T name=( '(' []>, <T name=args [<T name=string 'lots' []>, <T name=, ',' []>, <T name=string 'of' []>, <T name=, ',' []>, <T name=string 'white'space' []>]>, <T name=) ')' []>]>"
	parsed = str(_parse(' call (  "lots", \'of\',    \t"white\'space"\n  )\n\t  '))
	assert(parsed == ref)

	ref = "Null"
	parsed = str(_parse("invalid("))
	assert(parsed == ref)

	ref = "Null"
	parsed = str(_parse("valid() but_now_invalid()"))
	assert(parsed == ref)
