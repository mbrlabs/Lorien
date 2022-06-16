class_name Parser

# -------------------------------------------------------------------------------------------------
class DetectedToken:
	var name: String
	var last_position: int
	var subtokens: Array
	var value
	
	func _init(_name: String, _last_position: int, _subtokens: Array, _value):
		name = _name
		last_position = _last_position
		subtokens = _subtokens
		value = _value
	
	func find_first_subtoken(token_name: String):
		for st in subtokens:
			if st.name == token_name:
				return st
		return null
	
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
	
	func _init(_name: String, _elements: Array = [], _flatten_same_name = false):
		name = _name
		elements = _elements
		flatten_same_name = _flatten_same_name

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
	
	func _init(_name: String, _value = null):
		if _value == null:
			_value = _name
		name = _name
		value = _value
	
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
	
	func _init(_name: String, pattern: String):
		name = _name
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
	
