class_name StringTemplating

const TEMPLATE_START := "{{"
const TEMPLATE_END := "}}"

var filters: Dictionary

var Parser = preload("res://Misc/Parser.gd")
var parse_grammar: Parser.Grammar

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
	_init_parser()

# -------------------------------------------------------------------------------------------------
func _init_parser():
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
	
	_selftest()
	
# -------------------------------------------------------------------------------------------------
func process_string(s: String) -> String:
	while true:
		var found = _find_template_location(s)
		if found:
			found = found as TemplateLocation
			var parsed = _parse(found.template_text.strip_edges())
			if parsed == null:
				_log_error("Cannot parse template '%s'" % found.template_text)
				break
		break
	return s
	
# -------------------------------------------------------------------------------------------------
func _find_template_location(s: String):
	var start = s.find(TEMPLATE_START)
	if start == -1:
		return null
	
	var result := TemplateLocation.new()
	result.start = start

	var end = null
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
func _log_error(message):
	print("{class_name} error: {message}".format({
		"class_name": get_class(),
		"message": message,
	}))

# -------------------------------------------------------------------------------------------------
func _parse(s: String):
	var parsed = parse_grammar.detect(s)
	if parsed is Parser.DetectedToken:
		# Check that everything got consumed
		if s.substr(parsed.last_position).strip_edges() != "":
			return null
	return parsed

# -------------------------------------------------------------------------------------------------
func _selftest():
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
