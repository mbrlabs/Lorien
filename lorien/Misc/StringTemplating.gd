class_name StringTemplating

const TEMPLATE_START := "{{"
const TEMPLATE_END := "}}"

var filters: Dictionary

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

# -------------------------------------------------------------------------------------------------
func process_string(s: String) -> String:
	while true:
		var found = _find_template_location(s)
		if found:
			found = found as TemplateLocation
			print("TEMPLATE: ", found)
			var parsed = _parse(found.template_text.strip_edges())
			if parsed == null:
				_log_error("Cannot parse template '%s'" % found.template_text)
				break
			if "ad" in found.template_text:
				print("PARSED: " + str(parsed))
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
class DetectedToken:
	var name: String
	var last_position: int
	var subtokens: Array
	var value
	
	func _init(name: String, last_position: int, subtokens: Array, value):
		self.name = name
		self.last_position = last_position
		self.subtokens = subtokens
		self.value = value
	
	func _to_string():
		var subtoken_strings = PoolStringArray([])
		for st in subtokens:
			subtoken_strings.append(str(st))
		return "<T name={name}{value} [{subtokens}]>".format({
			"name": name,
			"value": (" '%s'" % value) if value else "",
			"subtokens": subtoken_strings.join(", ")
		})

# -------------------------------------------------------------------------------------------------
class GrammarElement:
	func detect(s: String):
		pass
	

# -------------------------------------------------------------------------------------------------
class Grammar:
	extends GrammarElement
	
	var replace_name = null
	var elements: Array = []
	
	func detect(s: String):
		var best = null
		for e in elements:
			var c = e.detect(s)
			if c is DetectedToken:
				if (best == null) || (best.last_position < c.last_position):
					best = c
		return best

# -------------------------------------------------------------------------------------------------
class GrammarSequence:
	extends GrammarElement

	var name: String
	var elements: Array
	var flatten_same_name := false
	
	func _init(name: String, elements: Array = [], flatten_same_name = false):
		self.name = name
		self.elements = elements
		self.flatten_same_name = flatten_same_name

	func detect(s: String):
		var position := 0
		var tokens := []
		
		for e in elements:
			var t = e.detect(s.substr(position))
			if !t:
				return null
			t = t as DetectedToken
			position += t.last_position
			t.last_position = position
			tokens.append(t)
		
		if flatten_same_name:
			var new_tokens := []
			for t in tokens:
				if t.name == name:
					new_tokens.append_array(t.subtokens)
				else:
					new_tokens.append(t)
			tokens = new_tokens
			
		return DetectedToken.new(name, position, tokens, null)

# -------------------------------------------------------------------------------------------------
class GrammarLiteral:
	extends GrammarElement
	
	var name: String
	var value: String
	var ignore_whitespace := true
	
	func _init(name: String, value = null):
		if value == null:
			value = name
		self.name = name
		self.value = value
	
	func detect(s: String):
		var test_in := s
		if ignore_whitespace:
			test_in = test_in.strip_edges(true, false)
		if !test_in.begins_with(self.value):
			return null
		
		return DetectedToken.new(name, s.find(value) + len(value), [], value)
		
# -------------------------------------------------------------------------------------------------
class GrammarRegexMatch:
	extends GrammarElement
	
	var name: String
	var regex := RegEx.new()
	var ignore_whitespace = true
	
	func _init(name: String, pattern: String):
		self.name = name
		regex = RegEx.new()
		regex.compile(pattern)
	
	func detect(s: String):
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
		return DetectedToken.new(name, m.get_end(), [], value)
		
# -------------------------------------------------------------------------------------------------
var GRAMMAR = null
func _grammar() -> GrammarElement:
	if GRAMMAR:
		return GRAMMAR

	var g_string := Grammar.new()
	g_string.elements.append_array([
		GrammarRegexMatch.new("string", "'([^']*)'"),
		GrammarRegexMatch.new("string", '"([^"]*)"')
	])
	
	var g_arg_list := Grammar.new()
	g_arg_list.elements.append(GrammarSequence.new("args", []))
	g_arg_list.elements.append(GrammarSequence.new("args", [g_string]))
	g_arg_list.elements.append(GrammarSequence.new("args", [g_string, GrammarLiteral.new(","), g_arg_list], true))
	
	var g_func_name := GrammarRegexMatch.new("func_name", "[a-zA-Z0-9_]+")
	var g_func_call := GrammarSequence.new(
		"func_call", 
		[g_func_name, GrammarLiteral.new("("), g_arg_list, GrammarLiteral.new(")")]
	)

	var grammar := Grammar.new()
	grammar.elements.append(g_func_call)
	grammar.elements.append(g_string)
	
	GRAMMAR = grammar
	return grammar

# -------------------------------------------------------------------------------------------------
func _parse(s: String):
	var parsed = _grammar().detect(s)
	if parsed is DetectedToken:
		# Check that everything got consumed
		if parsed.last_position != len(s):
			return null
	return parsed

# -------------------------------------------------------------------------------------------------
func _test():
	var grammar = _grammar()
	print(grammar.detect('"Hello world"'))
	print(grammar.detect('call()'))
	print(grammar.detect('call("arg1")'))
	print(grammar.detect('call(  "arg1" , "arg2"  )'))
	print(grammar.detect('call(  "arg1" , "arg2" ,   "arg1" , "arg2",    "arg1" , "arg2"  )'))
