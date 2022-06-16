class_name StringTemplating

const TEMPLATE_START := "{{"
const TEMPLATE_END := "}}"

var filters: Dictionary

var Parser = preload("res://Misc/Parser.gd")
var parse_grammar: Parser.Grammar

# -------------------------------------------------------------------------------------------------
func _log_error(message):
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
func _init_grammar():
	var g_string = Parser.Grammar.new()
	g_string.elements.append_array([
		Parser.GrammarRegexMatch.new("string", "'([^']*)'"),
		Parser.GrammarRegexMatch.new("string", '"([^"]*)"')
	])
	
	var g_arg_list = Parser.Grammar.new()
	g_arg_list.elements.append(Parser.GrammarSequence.new("args", []))
	g_arg_list.elements.append(Parser.GrammarSequence.new("args", [g_string]))
	g_arg_list.elements.append(Parser.GrammarSequence.new(
		"args",
		[g_string, Parser.GrammarLiteral.new(","), g_arg_list],
		true
	))
	
	var g_func_name = Parser.GrammarRegexMatch.new("func_name", "[a-zA-Z0-9_]+")
	var g_func_call = Parser.GrammarSequence.new(
		"func_call", 
		[
			g_func_name,
			Parser.GrammarLiteral.new("("),
			g_arg_list,
			Parser.GrammarLiteral.new(")")
		]
	)

	parse_grammar = Parser.Grammar.new()
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
	var parsed = parse_grammar.detect(s)
	if parsed is Parser.DetectedToken:
		# Check that everything got consumed
		if parsed.last_position != len(s):
			return null
	return parsed

# -------------------------------------------------------------------------------------------------
func _apply_filter(parsed: Parser.DetectedToken):
	if parsed.name == "string":
		return parsed.value
	elif parsed.name == "func_call":
		var func_name: String = parsed.subtokens[0].value
		if ! func_name in filters:
			_log_error("Filter '%s' does not exist" % func_name)
			return null
		
		parsed = parsed as Parser.DetectedToken
		var parsed_args_list: Parser.DetectedToken = parsed.find_first_subtoken("args")
		var arg_values = []
		for a in parsed_args_list.subtokens:
			if a.name in ["(", ")", ","]:
				continue
			arg_values.append(_apply_filter(a))
		return filters[func_name].call_funcv(arg_values)
	else:
		return null

# -------------------------------------------------------------------------------------------------
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
