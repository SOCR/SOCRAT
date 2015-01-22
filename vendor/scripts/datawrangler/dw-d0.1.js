(function(){dw = {};dw.wrangle = function(){
	var w = [];

	w.apply = function(tables){
		if(typeOf(tables)==='string'){
			tables = dv.table(tables)
		}
		if(typeOf(tables)!='array'){
			tables = [tables]
		}
		w.forEach(function(t){

			if(t.active() || t.invalid()){
				var status = t.check_validity(tables);
				if(status.valid){
					t.sample_apply(tables);








					t.validate();
				}
				else{
					t.invalidate(status.errors);
				}
			}


		})


		return w;
	}

  w.translate = function(table_name, schema, toDelete) {
    var table_query = undefined;

    w.forEach(function(t){
      result = t.translate_wrapper(table_name, schema, table_query, toDelete);
      table_query = result.query;
      schema = result.schema;
    })
    return table_query;
  }

	w.add = function(t){
		w.push(t)
		return w;
	}

	return w;
}
/* Controls logic of a wrangler app
* Options
* initial_transforms: transforms to run immediately when controller starts.
* backend: the backend to use ('pg' for postgres, 'js' for javascript.)
*/
dw.controller = function(options){
		options = options || {};
		var controller = {},
		    table = options.data,
		    originalTable = table.slice(),
		    wrangler = dw.wrangle(), script,
		    engine = dw.engine().table(table), selected_suggestion_index,
		    tableSelection, backend = options.backend || 'js';

	if(options.initial_transforms){
		options.initial_transforms.forEach(function(t){
			wrangler.add(t);
		})
		wrangler.apply([table], {backend:backend, success:on_transform_complete});
	}

  controller.execute_transform = function(transform) {




		wrangler.add(transform)
    transform.apply([table]);


	  var after_execute = function() {
      infer_schema()
  		tableSelection.clear()
  		interaction({type:dw.engine.execute, transform:transform})
    }
    clear_suggestions();
  }

  function clear_suggestions() {
    suggestions = [];
    selected_suggestion_index = undefined;
  }

	controller.suggestions = function() {
	  return suggestions;
	}

  controller.selected_suggestion_index = function(x) {
    if (!arguments.length) return selected_suggestion_index;
    selected_suggestion_index = x;
    return controller;
  }

  controller.increment_selected_suggestion_index = function() {
    if (!suggestions.length) return controller;
    if (selected_suggestion_index === undefined) {
      selected_suggestion_index = 0;
    }
    else if (selected_suggestion_index === suggestions.length - 1) {
      selected_suggestion_index = 0;
    } else {
      selected_suggestion_index = selected_suggestion_index + 1;
    }
    return controller;
  }

  controller.decrement_selected_suggestion_index = function() {
    if (!suggestions.length) return controller;
    if (selected_suggestion_index === undefined) {
      selected_suggestion_index = suggestions.length - 1;
    }
    else if (selected_suggestion_index === 0) {
      selected_suggestion_index = suggestions.length - 1;
    } else {
      selected_suggestion_index = selected_suggestion_index - 1;
    }
    return controller;
  }

	controller.table = function() {
	  return table;
	}

	controller.wrangler = function() {
	  return wrangler;
	}

	controller.interaction = function(params){
		var selection = tableSelection.add(params);
		params.rows = selection.rows();
		params.cols = selection.cols();
		suggestions = engine.table(table).input(params).run(13);
		selected_suggestion_index = suggestions.length ? 0 : undefined;
		return controller;
	}

	function infer_schema(){





	}

	var warned = false;
	function confirmation(options){
		if(!warned){
			warned = true;
			alert('Wrangler only supports up to 40 columns and 1000 rows.  We will preview only the first 40 columns and 1000 rows of data.')
		}
	}

	function clear_editor(){
		tableSelection.clear()
		interaction({type:dw.engine.clear})
	}

	function promote_transform(transform, params){
		tableSelection.clear()
		interaction({type:dw.engine.promote, transform:transform})
	}

	tableSelection = dw.table_selection();

	jQuery(document).bind('keydown', function(event){
		var type = event && event.srcElement && event.srcElement.type
		if(type!='text'){
			switch(event.which){
		          	case 8:
		 				/*Backspace*/
		           	break
		        case 9:
					editor.promote()


					if(type!='textarea'){
		                event.preventDefault()
		            }
		            break
      case 27:

					break
		    }

		}
	})
	infer_schema();
	return controller;
}
/*
 * Options
 * table_container: container to draw table
 * after_table_container: container to draw the after table in before-after previews
 * suggestion_container: container to draw suggestions
*/
dw.view = function(opt) {
  var view= {},
      table_container = opt.table_container,
      after_table_container = opt.after_table_container,
      suggestion_container = opt.suggestion_container,
      table_interaction = opt.table_interaction,
      table, after_table, db = opt.db, suggestions,
      onsuggest = opt.onsuggest;

  view.initUI = function() {
    after_table_container.empty();
    table_container.empty();
    suggestion_container.empty();
    var fields = db.fields();
    table = db.plot('spreadsheet', table_container.attr('id'), fields, {interaction:table_interaction, header_vis:true})

    after_table = db.plot('spreadsheet', after_table_container.attr('id'), fields, {interaction:undefined})
    table.update();
    dw.view.preview(table, undefined, after_table, undefined)
  }

  view.update = function(wrangler_state) {
    suggestions = dw.view.suggestions(suggestion_container);
    suggestions.suggestions(wrangler_state.suggestions())
    suggestions.initUI();
    suggestions.update();

    var preview_suggestion = function() {
      var suggestion_index = wrangler_state.selected_suggestion_index(),
          suggestion = undefined;
      if (suggestion_index != undefined) {
        suggestion = wrangler_state.suggestions()[suggestion_index];
      }
      suggestions.highlight_suggestion(suggestion_index)
      dw.view.preview(table, suggestion, after_table, undefined)
      if (onsuggest) {
        onsuggest(suggestion);
      }
    }

    preview_suggestion();

    jQuery(document).unbind('keydown.wrangler_view');
    jQuery(document).bind('keydown.wrangler_view', function(event) {
      var type = event && event.srcElement && event.srcElement.type
    	if(type!='text'){
    	  switch(event.which){
          case 38:
            /*Up*/
      	    wrangler_state.decrement_selected_suggestion_index();
      	    preview_suggestion();
      	    event.preventDefault()
            break
          case 40:
      		  /*Down*/
      	    wrangler_state.increment_selected_suggestion_index();
      	    preview_suggestion();
            event.preventDefault()
            break
        }
      }
    })


  }

  return view;
};
dw.functor = function(v) {
  return (typeof v === "function" && !(v instanceof RegExp)) ? v : function() { return v; };
};


typeOf = function(value) {
    var s = typeof value;
    if (s === 'object') {
        if (value) {
            if (typeof value.length === 'number' &&
                    !(value.propertyIsEnumerable('length')) &&
                    typeof value.splice === 'function') {
                s = 'array';
            }
        } else {
            s = 'null';
        }
    }
    return s;
}

dw.ivar = function(obj, ivars){
	if(typeOf(ivars) != 'array') ivars = [ivars]
	ivars.forEach(function(ivar){
		var initial;
		if(typeOf(ivar) === 'object'){
			initial = ivar.initial;
			ivar = ivar.name;
		}
		var name = "_"+ivar;
		obj[name] = initial;
		obj[ivar] = function(v){
			if(arguments.length){
				obj[name] = v
				return obj;
			}
			return obj[name]
		}
	})
}

dw.ivara = function(obj, ivars){
	if(typeOf(ivars) != 'array') ivars = [ivars]
	ivars.forEach(function(ivar){
		var initial;
		if(typeOf(ivar) === 'object'){
			initial = ivar.initial;
			if(initial!=undefined && typeOf(initial)!='array') initial = [initial];
			ivar = ivar.name;
		}
		var name = "_"+ivar;
		obj[name] = initial;
		obj[ivar] = function(v){
			if(arguments.length){
				obj[name] = (typeOf(v) === 'array' ? v : [v])
				return obj;
			}
			return obj[name]
		}
	})
};

/**
 * @param {number} start
 * @param {number=} stop
 * @param {number=} step
 */
dw.range = function(start, stop, step) {
  if (arguments.length === 1) { stop = start; start = 0; }
  if (step == null) step = 1;
  if ((stop - start) / step == Infinity) throw new Error("infinite range");
  var range = [],
       i = -1,
       j;
  if (step < 0) while ((j = start + step * ++i) > stop) range.push(j);
  else while ((j = start + step * ++i) < stop) range.push(j);
  return range;
};

dw.display_name = function(name){
	if(name && name[0]==='_') return name.substr(1);
	return name
};

dw.JSON = {};


(function () {
    "use strict";

    function f(n) {

        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf()) ?
                this.getUTCFullYear()     + '-' +
                f(this.getUTCMonth() + 1) + '-' +
                f(this.getUTCDate())      + 'T' +
                f(this.getUTCHours())     + ':' +
                f(this.getUTCMinutes())   + ':' +
                f(this.getUTCSeconds())   + 'Z' : null;
        };

        String.prototype.toJSON      =
            Number.prototype.toJSON  =
            Boolean.prototype.toJSON = function (key) {
                return this.valueOf();
            };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {






        escapable.lastIndex = 0;
        return escapable.test(string) ? '"' + string.replace(escapable, function (a) {
            var c = meta[a];
            return typeof c === 'string' ? c :
                '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
        }) + '"' : '"' + string + '"';
    }


    function str(key, holder) {



        var i,
            k,
            v,
            length,
            mind = gap,
            partial,
            value = holder[key];



        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }




        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }



        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':



            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':





            return String(value);




        case 'object':




            if (!value) {
                return 'null';
            }



            gap += indent;
            partial = [];



            if (Object.prototype.toString.apply(value) === '[object Array]') {




                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }




                v = partial.length === 0 ? '[]' : gap ?
                    '[\n' + gap + partial.join(',\n' + gap) + '\n' + mind + ']' :
                    '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }



            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    k = rep[i];
                    if (typeof k === 'string') {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {



                for (k in value) {
                    if (Object.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }




            v = partial.length === 0 ? '{}' : gap ?
                '{\n' + gap + partial.join(',\n' + gap) + '\n' + mind + '}' :
                '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }



    if (typeof dw.JSON.stringify !== 'function') {
        dw.JSON.stringify = function (value, replacer, space) {







            var i;
            gap = '';
            indent = '';




            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }



            } else if (typeof space === 'string') {
                indent = space;
            }




            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                    typeof replacer.length !== 'number')) {
                throw new Error('dw.JSON.stringify');
            }




            return str('', {'': value});
        };
    }




    if (typeof dw.JSON.parse !== 'function') {
        dw.JSON.parse = function (text, reviver) {




            var j;

            function walk(holder, key) {




                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }






            text = String(text);
            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }














            if (/^[\],:{}\s]*$/
                    .test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
                        .replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']')
                        .replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {






                j = eval('(' + text + ')');




                return typeof reviver === 'function' ?
                    walk({'': j}, '') : j;
            }



            throw new SyntaxError('dw.JSON.parse');
        };
    }
}());
dw.regex = {};
dw.regex.match = function(value, params){

	if(!value) return ""

	var max_splits = params.max_splits;
	if(max_splits===undefined) max_splits = 1;

	var remainder_to_split = {start:0, end:value.length,value:value}
	var splits = []
	var numSplit = 0;
	var which = Number(params.which)
	if(isNaN(which)) which = 1

	while(max_splits <= 0 || numSplit < max_splits*which){
		var s = dw.regex.matchOnce(remainder_to_split.value, params)

		if(s.length > 1){

				remainder_to_split = s[2];
				splits.push(s[0])
				splits.push(s[1])
				occurrence = 0


		}
		else{
			break
		}
		numSplit++;
		if(numSplit > 1000){

			break;
		}
	}

	splits.push(remainder_to_split)




	var occurrence = 0;
	var newSplits = []
	var prefix = ''
	var i;
	for(i = 0; i < splits.length; ++i){
		if(i%2===1){
			occurrence++;
			if(occurrence===which){
				newSplits.push({value:prefix, start:0, end:prefix.length})
				newSplits.push({start:prefix.length, end:prefix.length+splits[i].value.length, value:splits[i].value})
				occurrence = 0;
				prefix = ''
				continue
			}
		}
		prefix += splits[i].value
	}
	newSplits.push({start:0, end:prefix.length, value:prefix})



	return newSplits;
}

dw.regex.matchOnce = function(value, params){

	var positions = params.positions;
	var splits = [];

	if(positions && positions.length){
		if(positions.length==2){
			if(value.length >= positions[1]){
				var split_start = positions[0]
				var split_end = positions[1]
				splits.push({start:0, end:split_start, value:value.substr(0, split_start)});
				splits.push({start:split_start, end:split_end, value:value.substr(split_start, split_end-split_start)})
				splits.push({start:split_end, end:value.length, value:value.substr(split_end)})

				return splits;
			}
			return [{start:0, end:value.length, value:value}]

		}
	}




	var before = params.before;
	var after = params.after;
	var on = params.on
	var ignore_between = params.ignore_between;


	var remainder = value;
	var remainder_offset = 0;
	var start_split_offset = 0;
	var add_to_remainder_offset = 0;


	while(remainder.length){

		var valid_split_region = remainder;
		var valid_split_region_offset = 0;


		start_split_offset = remainder_offset;


		if(ignore_between){

			var match = remainder.match(ignore_between);
			if(match){

				valid_split_region = valid_split_region.substr(0, match.index)
				remainder_offset += match.index+match[0].length;
				remainder = remainder.substr(match.index+match[0].length)

			}
			else{
				remainder = ''
			}

		}
		else{
			remainder = ''
		}

		if(after){
			var match = valid_split_region.match(after)
			if(match){
				valid_split_region_offset = match.index+match[0].length;
				valid_split_region = valid_split_region.substr(valid_split_region_offset)

			}
			else{
				continue;
			}
		}
		if(before){
			var match = valid_split_region.match(before)
			if(match){
				valid_split_region = valid_split_region.substr(0, match.index)
			}
			else{
				continue;
			}
		}


		var match = valid_split_region.match(on)
		if(match){

			var split_start = start_split_offset + valid_split_region_offset+match.index;
			var split_end = split_start + match[0].length;

			splits.push({start:0, end:split_start, value:value.substr(0, split_start)});
			splits.push({start:split_start, end:split_end, value:value.substr(split_start, split_end-split_start)})
			splits.push({start:split_end, end:value.length, value:value.substr(split_end)})
			return splits;

		}
		continue;

	}

	return [{start:0, end:value.length, value:value}]


};
/*New column positions*/
dw.INSERT_RIGHT = 'right';
dw.INSERT_END = 'end';

/*Result*/
dw.ROW = 'row';
dw.COLUMN = 'column';

dw.clause = {
	column: 'column',
	regex: 'regex',
	input: 'input',
	array: 'array',
	select: 'select'
};

dw.status = {
	active: 'active',
	inactive: 'inactive',
	deleted: 'deleted',
	invalid: 'invalid'
}

dw.transform = function(column){
	var t = {};

	t.is_transform = true;

	dw.ivara(t, {name:'column', initial:(column!=undefined)?column:[]})
	dw.ivar(t, [{name:'table', initial:0},{name:'status', initial:dw.status.active},{name:'drop', initial:false}])
	t.getTable = function(tables){
		return tables[t.table()]
	}


	t.show_details = false;

	t.active = function(){
		return t._status === dw.status.active;
	}

	t.inactive = function(){
		return t._status === dw.status.inactive;
	}

	t.deleted = function(){
		return t._status === dw.status.deleted;
	}

	t.invalid = function(){
		return t._status === dw.status.invalid;
	}

	t.toggle = function(){
		t.active() ? t.status(dw.status.inactive) : t.status(dw.status.active);
	}

	t.delete_transform = function(){
		t._status = dw.status.deleted;
	}

	t.errors = [];

	t.invalidate = function(errors){
		t._status = dw.status.invalid;
		t.errors = errors;
	}

	t.validate = function(){
		t._status = dw.status.active;
		t.errors = []
	}

	t.errorMessage = function(){
		return t.errors.join('\n')
	}

	t.columns = function(table){
		if(t._column && t._column.length)
			return t._column.map(function(c){
				return table[c];
			})
		return table.map(function(c){return c})

	}

	t.has_parameter = function(p){
		return t[p] != undefined;
	}

	t.well_defined = function(table){
		return true;
	}

	t.params = function(){
		return d3.keys(t).filter(function(k){return k[0]==='_'})
	}

	t.enums = function() {
		return [];
	}


	t.param_equals = function(l, r){

		if(l===undefined || r === undefined) return l === r;
		ktype = typeOf(l);
		switch(ktype){
			case 'function':
				return l.toString() === r.toString();
			case 'array':
				if(l.length!=r.length) return false;
				for(var i = 0; i < l.length; ++i){
					if(!t.param_equals(l[i], r[i])) return false;
				}
				return true;
			case 'object':
				if(l.equals) return l.equals(r);
				return l.toString() === r.toString();
			case 'number':
			case 'string':
			case 'boolean':
				return l === r;
			default:
				return l === r;
		}
	}

	t.similarity = function(other){
		var nameShift = (t.name!=other.name) ? -1 : 0;
		var tkeys = t.params(), okeys = other.params(), l, r, ktype, equalCount=0;
		for(var i = 0; i < tkeys.length; ++i){
			l = t[tkeys[i]], r = other[okeys[i]];
			if(t.param_equals(l, r)){
				equalCount++;
			}
		}
		return nameShift+(equalCount/tkeys.length);
	}

	t.equals = function(other){
		if(t.name!=other.name) return false;
		var tkeys = t.params(), okeys = other.params(), l, r, ktype;
		for(var i = 0; i < tkeys.length; ++i){
			l = t[tkeys[i]], r = other[okeys[i]];
			if(!t.param_equals(l, r)){
				return false;
			}
		}
		return true;
	}

	t.check_validity = function(tables){
		return t.valid_columns(tables)
	}

	t.valid_columns = function(tables){
		var table = t.getTable(tables);
		var columns = t.columns(table).filter(function(c){return c===undefined});
		if(columns.length){
			return {valid:false, errors : ['Invalid columns']}
		}
		return {valid:true}

	}

	t.clone_param = function(param){
			var ktype = typeOf(param);
			switch(ktype){
				case 'function':
					return param
				case 'array':
					return param.map(function(p){return t.clone_param(p)})
				case 'object':
					if(param.clone) return param.clone();
					return param;
				case 'number':
				case 'string':
				case 'boolean':
					return param;
				default:
					return param;
			}
	}


	t.default_transform = function(){
		return dw.transform.create(t.name)
	}

	t.clone = function(){
		var other = t.default_transform(),
				tkeys = t.params(), param;
		for(var i = 0; i < tkeys.length; ++i){
			param = t[tkeys[i]];
			other[tkeys[i]] = t.clone_param(param);
		}
		return other;
	}

	t.description_length = function(){
		return 0;
	}

	t.comment = function(){
		var clauses = t.description();

		return clauses.map(function(clause){
			if(typeOf(clause)==='string')
				return clause

			return clause.description();

		}).join(' ')


	}

	t.sample_apply = function(tables){
		return t.apply(tables, {max_rows:1000, warn:true})
	}


	var parse_javascript_parameter = function(x){
		if(x===true) return 'true'
		if(x===false) return 'false'
		if(x===undefined) return 'undefined'

		if(typeOf(x)==='object' ||typeOf(x)==='function'){
			if(x.is_transform){
				return x.as_javascript();
			}
			return dw.JSON.stringify(x.toString().replace(/^\/|\/$/g,''))
		}

		if(typeOf(x)==='array'){
			return '['+x.map(parse_javascript_parameter)+']'
		}
		return dw.JSON.stringify(x)
	}

	t.displayed_parameters = function () {
	  return dw.metadata.displayed_parameters(t);
	}

	t.constructor_parameters = function () {
	  return dw.metadata.constructor_parameters(t);
	}

	t.translate_wrapper = function(table_name, schema, table_query, toDelete) {
    return t.translate(schema, table_query || table_name, toDelete)
	}

	t.translate = function() {
    alert('Runtime exception: unimplemented method');
	}

	t.as_javascript = function() {
  	var constructor, params, seperator = '', format_whitespace = '',
  	    constructor_param = t.constructor_parameters()[0];
		if (constructor_param != undefined) {
      constructor_param = parse_javascript_parameter(t['_' + constructor_param]);
		} else {
		  constructor_param = ''
		}
		constructor = 'dw.' + t.name + '(' + constructor_param  + ')';
		params = t.displayed_parameters().map(function(p){
			return '.' + p.name + '(' + parse_javascript_parameter(t['_'+p.name]) + ')' + seperator
		}).join(format_whitespace)

		return constructor + params;

	};

	return t;
}

dw.transform.create = function(name){
	return dw[name]()
}

dw.transform.SPLIT = 'split';
dw.transform.EXTRACT = 'extract';
dw.transform.CUT = 'cut';
dw.transform.MERGE = 'merge';
dw.transform.FOLD = 'fold';
dw.transform.UNFOLD = 'unfold';
dw.transform.FILL = 'fill';
dw.transform.FILTER = 'filter';
dw.transform.DROP = 'drop';
dw.transform.ROW = 'row';
dw.transform.COPY = 'copy';
dw.transform.LOOKUP = 'lookup';
dw.transform.TRANSLATE = 'translate';
dw.transform.EDIT = 'edit';
dw.transform.SORT = 'sort';
dw.transform.TRANSPOSE = 'transpose';
dw.transform.STRING = 'string';
dw.transform.INT = 'int';
dw.transform.NUMBER = 'number';
dw.transform.DATE = 'date';
dw.transform.SET_TYPE = 'set_type';
dw.transform.SET_ROLE = 'set_role';
dw.transform.SET_NAME = 'set_name';
dw.transform.PROMOTE = 'promote';
dw.transform.WRAP = 'wrap';
dw.transform.MARKDOWN = 'markdown';


/** Metadata of transforms */

dw.transform.type = {
  'cut':1,
  'derive':1,
  'drop':1,
  'extract':1,
  'fill':1,
  'filter':1,
  'fold':1,
  'merge':1,
  'split':1
}

dw.transform.types = [];
for(var x in dw.transform.type) {
  dw.transform.types.push(x);
}dw.copy = function(column){
	var t = dw.map(column);

	t.well_defined = function(table){
		return t._column.length === 1;
	}

	t.transform = function(values){
		return values;
	}

	t.description = function(){
		return [
			'Copy',
			dw.column_clause(t, t._column, 'column')
		]
	}

	t.name = dw.transform.COPY;

	return t;
}
dw.drop = function(column){
	var t = dw.transform(column);
	t._drop = true;
	dw.ivar(t, [])
	t.description = function(){
		return [
			'Drop',
			dw.column_clause(t, t._column, 'column', {editor_class:'droppedColumn'})		]
	}
	t.apply = function(tables){
		var table = t.getTable(tables),
			  columns = t.columns(table);
		if(t._drop){
			columns.forEach(function(col){
				table.removeColumn(col.name());
			})
		}
		return {droppedCols:columns}
	}
	t.name = dw.transform.DROP;
	return t;
}
dw.map = function(column){
	var t = dw.transform(column);
	dw.ivar(t, [{name:'result', initial:dw.COLUMN},{name:'update', initial:false},{name:'insert_position', initial:dw.INSERT_RIGHT},{name:'row', initial:undefined}])


	t.apply = function(tables, options){

		if(t._result === dw.COLUMN) {
		  return t.apply_column_map(tables, options);
		} else {
		  return t.apply_row_map(tables, options);
		}

	}

	t.apply_row_map = function(tables, options) {
	  options = options || {};
		var table = t.getTable(tables),
			  columns = t.columns(table),
  			new_columns = [],
			  rows = table.rows(),
			  values, valueStats = [], transformedValues, transformStats,start_row = options.start_row || 0,
			  end_row = options.end_row || rows,
			  row = t._row.tester(tables), new_cols = [], dropped_cols = [];

    values = dv.array(columns.length);

    var repeated_col_indices = dw.range(table.length);
    if(t._drop) {
      repeated_col_indices = repeated_col_indices.filter(function(i) {
        return columns.indexOf(table[i]) === -1;
      })
    }
    repeated_cols = repeated_col_indices.map(function(index){
      var x = [];
      x.name = table[index].name;
      x.type = table[index].type;
      x.lut = table[index].lut;
      return x
    });

    var new_column = [], current_insert_row = 0;

		for(var i = start_row; i < end_row; ++i){
			if(!row || row.test(table, i)){
				for(var c = 0; c < columns.length; ++c){
					values[c] = columns[c].get_raw(i);
				}
				transformedValues = t.transform(values, table);
				for(var j = 0; j < transformedValues.length; ++j) {
				  new_column[current_insert_row] = transformedValues[j];
				  for(var k = 0; k < repeated_col_indices.length; ++k) {
				    repeated_cols[k][current_insert_row] = table[repeated_col_indices[k]][i];
				  }
				  current_insert_row++;
				}
			}
		}



  	var insertPreference = t.insert_position();
  	var insertPosition;
		switch(insertPreference) {
  		case dw.INSERT_RIGHT:
  			insertPosition = columns[columns.length-1].index;
  			break
  		case dw.INSERT_END:
  			insertPosition = table.length;
  			break
  	}


    var tl = table.length;
    for(c = 0; c < tl; ++c) {
      table.removeColumn(0);
    }



    for(c = 0; c < repeated_cols.length; ++c) {
      table.addColumn(repeated_cols[c].name, repeated_cols[c], repeated_cols[c].type, {encoded:true, lut:repeated_cols[c].lut});
    }


    table.addColumn(t.name, new_column, "nominal");

		return transformStats;
	}

	t.apply_column_map = function(tables, options) {
	  options = options || {};
		var table = t.getTable(tables),
			  columns = t.columns(table),
  			new_columns = [],
			  rows = table.rows(),
			  values, valueStats = [], transformedValues, transformStats,start_row = options.start_row || 0,
			  end_row = options.end_row || rows,
			  row = t._row && t._row.tester(tables),
			  new_cols = [], dropped_cols = [];

    values = dv.array(columns.length);

		for(var i = start_row; i < end_row; ++i){
			if(!row || row.test(table, i)){

				for(var c = 0; c < columns.length; ++c){
					values[c] = columns[c].get_raw(i);
				}
				transformedValues = t.transform(values, table);
        valueStats.push(transformedValues.stats);
				for(var j = 0; j < transformedValues.length; ++j) {
				  if(new_columns[j]===undefined) new_columns[j] = dv.array_with_init(rows, undefined);
				  new_columns[j][i] = transformedValues[j];
				}
			}
		}

  	var insertPreference = t.insert_position();
  	var insertPosition;
		switch(insertPreference) {
  		case dw.INSERT_RIGHT:
  			insertPosition = columns[columns.length-1].index;
  			break
  		case dw.INSERT_END:
  			insertPosition = table.length;
  			break
  	}

    for (c = 0; c < new_columns.length; ++c) {
      new_cols.push(table.addColumn(t.name, new_columns[c], "nominal", {index:insertPosition+c+1}));
    }


    if (t._drop) {
      for(c = 0; c < columns.length; ++c) {
        dropped_cols.push(columns[c])
        table.removeColumn(columns[c].index);
      }
    }

    return {newCols:new_cols, droppedCols:dropped_cols, valueStats:valueStats}
	}

	return t;
}
dw.merge = function(column){
	var t = dw.map(column);
	dw.ivar(t, [{name:'glue', initial:''}])

	t.transform = function(values){
		var	glue = t._glue,
		    v = values.filter(function(v){return v!=undefined}).join(glue)
		return [v];
	}


	t.description = function(){
		return [
			'Merge',
			dw.column_clause(t, t._column, 'column'),
			' with glue ',
			dw.input_clause(t, 'glue')
		]
	}

	t.well_defined = function(table){
		return t._column.length > 1;
	}

	t.name = dw.transform.MERGE;

	return t;
}
dw.textPattern = function(column){
	var t = dw.map(column);
	dw.ivar(t, [
		{name:'on', initial:undefined},{name:'before', initial:undefined},{name:'after', initial:undefined},{name:'ignore_between', initial:undefined}, {name:'quote_character', initial:undefined},
		{name:'which', initial:1},{name:'max', initial:1}
	])
	dw.ivara(t, [{name:'positions', initial:undefined}])


	t.well_defined = function(){
		return ((t._positions && !t._on && !t._before && !t._after) || (!t._positions && (t._on || t._before || t._after))) && !t._row;
	}

	t.description_length = function(){
		if(t._positions) return 0;
		var score = dw.regex.description_length(t._on)+ dw.regex.description_length(t._before) + dw.regex.description_length(t._after)



		return score;

	}


	t.check_validity = function(tables){
		var x = t.valid_columns(tables);
		if(x.valid) {

			if(t.well_defined()){
				return {valid:true}
			}
			else{
				return {valid:false, errors:['Must define split criteria']}
			}
		}
		else{
			return x;
		}
	}

	t.match_description = function(options){
		options = options || {}
		var description = [];

		if(t._positions){
			return [
				'between positions',
				dw.column_clause(t, t._positions, options)
			]
		}


		if(t._on && t._on.toString()!="/.*/"){

			description = description.concat(
				[
					'on',
					dw.regex_clause(t,'on', options)
				]

			)
		}
		if(t._before && !t._after){
			description = description.concat(
				[
					'before',
					dw.regex_clause(t, 'before', options)
				]
			)
		}
		if(t._after && !t._before){
			description = description.concat(
				[
					'after',
					dw.regex_clause(t, 'after', options)
				]
			)
		}
		if(t._after && t._before){
			description = description.concat(
				[
					'between',
					dw.regex_clause(t, 'after', options),
					'and',
					dw.regex_clause(t, 'before', options)
				]
			)
		}
		return description;
	}

	return t;
}
dw.extract = function(column){
	var t = dw.textPattern(column);
	t.transform = function(values){
		if(values[0]===undefined) return []
		if(t._positions && t._positions.length){
			var val = ""+values[0]
			var indices = t._positions;
			var startIndex = indices[0], endIndex = indices[1] || indices[0];
			var splitValues = [];
			if(endIndex <= val.length){
				splitValues.push(val.substring(startIndex, endIndex))
				splitValues.stats = [{splits:[{start:startIndex, end:endIndex}]}]
			}
			return splitValues;
		}
		else{
			var params = {which:t._which, max_extracts:t._max, before:t._before,after:t._after,on:t._on,ignore_between:t._ignore_between}
			var extracts = dw.regex.match(values[0], params);
			var extractValues = [];
			extractValues.stats = [];
			for(var i = 0; i < extracts.length; ++i){
				if(i%2==1){
					extractValues.push(extracts[i].value)
					extractValues.stats.push({splits:[{start:extracts[i].start, end:extracts[i].end}]})
				}
			}



			return extractValues;
		}
	}

	t.description = function(){

		var description = [
			'Extract from',
			dw.column_clause(t, t._column, 'column', {editor_class:'none'})
		]

		regex = t.match_description({editor_class:'extract'});

		description = description.concat(regex)


		return description;

	}

	t.name = dw.transform.EXTRACT;

	return t;
}
dw.cut = function(column){
	var t = dw.textPattern(column);
	t._drop = true;
	t.transform = function(values){
		if(values[0]===undefined) return []
		if(t._positions && t._positions.length){
			var val = ""+values[0]
			var indices = t._positions;
			var startIndex = indices[0], endIndex = indices[1] || indices[0];
			var splitValues = [];
			splitValues.push(val.substring(0,startIndex) + val.substring(endIndex))
			splitValues.stats = [{splits:[{start:startIndex, end:endIndex}]}]
			return splitValues;
		}
		else{
			var val;
			var z = [];
			for(var v = 0; v < values.length; ++v){
				val = values[v];
				var params = {which:t._which, max_splits:t._max, before:t._before,after:t._after,on:t._on,ignore_between:t._ignore_between}
				var cuts = dw.regex.match(val, params);
				var cutValues = [];
				cutValues.stats = [];
				for(var i = 0; i < cuts.length; ++i){
					if(i%2==0){
						cutValues.push(cuts[i].value)
					}
					else{
						cutValues.stats.push({splits:[{start:cuts[i].start, end:cuts[i].end}]})
					}
				}
				z.push(cutValues.join(''));
				if(!v) z.stats = cutValues.stats;
			}
			return z;
		}
	}
	t.description = function(){
		var cutStart = (t._column && t._column.length) ? 'Cut from' : 'Cut';
		var description = [
			cutStart,
			dw.column_clause(t, t._column, 'column')
		]
		regex = t.match_description();
		description = description.concat(regex)
		return description;
	}
	t.name = dw.transform.CUT;
	return t;
}
dw.unfold = function(column){
	var t = dw.transform(column);
	dw.ivar(t, [{name:'measure', initial:undefined}])
	t.description = function(){
		return [
			'Unfold',
			dw.column_clause(t, t._column, 'column', {editor_class:'unfold', single:true}),
			' on ',
			dw.column_clause(t, [t._measure], 'measure' ,{single:true})
		]
	}

	t.apply = function(tables, options){
		options = options || {};
		var table = t.getTable(tables),
			columns = t.columns(table),
			toHeaderNames = columns.map(function(c){return c.name()}),
			keyColumns = table.filter(function(c){return toHeaderNames.indexOf(c.name())===-1 && t._measure != c.name()}),
			rows = table.rows(), newIndex = 0,
			valueCol = table[t._measure],
			max_rows = options.max_rows || 1000,
			start_row = options.start_row || 0, end_row = options.end_row || rows;

		end_row = Math.min(rows, end_row);




		end_row = rows;

		var headerColumn = columns[0];

		var newColumnHeaders = [];
		headerColumn.forEach(function(e) {
			if (newColumnHeaders.indexOf(e) === -1) {
				newColumnHeaders.push(e);
			}
		});


		var new_table = [];
		keyColumns.forEach(function(e) {new_table.push([]);});

		newColumnHeaders.forEach(function(e, i) {
			var col = [];
			col.name = e;
			new_table.push(col);
		});

		var reduction = {};
		var reduction_index = 0;
		for (var r = start_row; r < end_row; r++) {
			var key = keyColumns.map(function(e){return e.get_raw(r);}).join('*');
			if (reduction[key]===undefined) {
				reduction[key] = reduction_index;

				for (var i = 0; i < keyColumns.length; i++) {
					var col = keyColumns[i];
					new_table[i][reduction_index] = col.get_raw(r);
				}
				reduction_index += 1;
			}

			index = reduction[key];
			header = headerColumn[r];
			measure = valueCol[r];

			new_table[keyColumns.length + newColumnHeaders.indexOf(header)][index] = measure;
		}

		var length = table.cols();
		for(var i = 0; i < length; ++i){
			table.removeColumn(0);
		}

		var name, valueCols = [];
		new_table.forEach(function(col, i) {
			if (i < keyColumns.length) {
				name = keyColumns[i].name();
			}
			else {
				name = col.name
			}
			table.addColumn(name, col, dv.type.nominal);

			if (i >= keyColumns.length) {
				valueCols.push(name);
			}
		});

		return { toKeyRows:[-1], toHeaderCols:columns, toValueCols:[valueCol], valueCols:valueCols.map(function(c){return table[c]}).filter(function(c){return c!=undefined})};
	}

	t.description_length = function(){
		if(t._measure==='State') return 1;
		return 0;
	}

	t.well_defined = function(table){
		if(t._column && t._column.length === 1 && t._measure && t._measure != t._column[0] && (!table || table.length >= 3)){

			var col = table[t._column[0]];
			return true;
		}

		return false;
	}

	t.check_validity = function(tables){
		var x = t.valid_columns(tables);
		if(x.valid) {
			var col = t.getTable(tables)[t._measure]
			if(col){
				return {valid:true}
			}
			else{
				return {valid:false, errors:['Invalid Measure']}
			}
		}
		else{
			return x;
		}
	}

	t.translate = function(schema, table_query, toDelete){
			var toHeaderNames = t.column(),
			keyColumns = schema.filter(function(c){return toHeaderNames.indexOf(c)===-1 && t._measure != c});

		var headerColumn = t.column()[0];
		var newColumnHeaders;

    if (!toDelete) {
      var columnHeaderQueries = "SELECT DISTINCT " + (headerColumn) + " FROM " + table_query + ";"
      return {query:columnHeaderQueries, schema:toDelete};
    }



    newColumnHeaders = toDelete;
    var groupByColumns = keyColumns.map(function(c){return c}).join(' ,');

    var query = "SELECT " + groupByColumns + ", " +
       newColumnHeaders.map(function(header){return "last_non_null(case when " + headerColumn + " = " + header + " then " + t._measure + " else NULL end) as \"" + header + '"' }).join(',')
       + " from " + table_query + " group by " + groupByColumns + ";"
    return {query:query, schema:groupByColumns};
	}
	t.name = dw.transform.UNFOLD;
	return t;
}

/*Fill Direction*/
dw.LEFT = 'left';
dw.UP = 'up';
dw.DOWN = 'down';
dw.RIGHT = 'right';
/*Fill Method*/
dw.COPY = 'copy';
dw.INTERPOLATE = 'interpolate';

dw.fill = function(column){
	var t = dw.transform(column);
	dw.ivar(t, [
		{name:'direction', initial:dw.DOWN},{name:'method', initial:dw.COPY},{name:'row', initial:undefined}
	])

	t.description_length = function(){
		if(t._row){
			return t._row.description_length();
		}
		return 0;
	}

	t.description = function(){
		return [
			'Fill',
			dw.column_clause(t, t._column, 'column', {all_columns:true}),
			dw.row_clause(t, t._row, 'row', {editor_class:'updatedColumn'}),
			'with',


			'values from',
			dw.select_clause(t, {select_options:{'right':'the left', 'left':'the right', 'up':'below', 'down':'above'}, param:'direction'})

		]
	}

	t.apply = function(tables, options){
		options = options || {};
		var table = t.getTable(tables),
			columns = t.columns(table),
			rows = table.rows(),
			row = (t._row || dw.row()).tester(tables),
			values, missing = dt.MISSING, error = dt.ERROR,
			start_row =  0,
			end_row =  rows,
			method = t._method,
			direction = t._direction;



		if(method === dw.COPY){
			var col, v, fillCode, rawValue;
			if(direction === dw.DOWN){
				for(var c = 0; c < columns.length; ++c){
					col = columns[c];
					fillCode = undefined;
					rawValue = undefined;
					for(var i = start_row; i < end_row; ++i){
						v = col[i];
						if (v === missing) {
							if (row.test(table, i)) {
								col.set_code_and_raw(i, fillCode, rawValue);
							}
						}
						else {
						  fillCode = v;
						  rawValue = col.get_raw(i);
					  }
					}
				}
			}
			else if(direction === dw.RIGHT){
				for(var i = start_row; i < end_row; ++i){
					if(row.test(table, i)){
						fillCode = undefined;
						rawValue = undefined;
						for(var c = 0; c < columns.length; ++c){
							col = columns[c];
							v = col[i];
							if(v === missing) col.set_code_and_raw(i, fillCode, rawValue);
							else {
							  fillCode = v;
							  rawValue = col.get_raw(i);
						  }
						}
					}
				}
			}
			else if(direction === dw.LEFT){
				for(var i = start_row; i < end_row; ++i){
					if(row.test(table, i)){
						fillValue = undefined;
						rawValue = undefined;
						for(var c = columns.length-1; c >= 0; --c){
							col = columns[c];
							v = col[i];
							if(v === missing) col.set_code_and_raw(i, fillCode, rawValue);
							else {
							  fillCode = v;
							  rawValue = col.get_raw(i);
						  }
						}
					}
				}
			}
			else if(direction === dw.UP){
				for(var c = 0; c < columns.length; ++c){
					col = columns[c]
					fillCode = undefined;
					rawValue = undefined;
					for(var i = end_row-1; i >= start_row; --i){
						v = col[i];
						if(v === missing){
							if(row.test(table, i)){
								col.set_code_and_raw(i, fillCode, rawValue);
							}
						}
						else {
						  fillCode = v;
						  rawValue = col.get_raw(i)
					  }
					}
				}
			}
		}

		return {updatedCols:columns}

	}


	t.horizontal = function(){
		return t._direction===dw.LEFT || t._direction===dw.RIGHT;
	}

	t.well_defined = function(table){




		var columns = t.columns(table);

		var horizontal = t.horizontal();


		if(t._row){
			if (t._row.formula() === 'empty()') return false;
		}


		if(t.horizontal()){
			if(columns.length === 1){
						return false;
			}
			var col, seenMissingAfterNonMissing=false, seenNonMissing=false;

			if(t._row===undefined){
				if(t._direction===dw.LEFT){
					for(var i = 0; i < columns.length;++i){
						col = columns[i];
						if(dw.summary(col)['missing'].length===0){
							if(seenNonMissing){
								seenMissingAfterNonMissing=true;
								break;
							}
						}
						else{
							seenNonMissing=true;
						}
					}
				}
				else if(t._direction===dw.RIGHT){
					for(var i = columns.length-1; i >=0 ;--i){
						col = columns[i];
						if(dw.summary(col)['missing'].length===0){
							if(seenNonMissing){
								seenMissingAfterNonMissing=true;
								break;
							}
						}
						else{
							seenNonMissing=true;
						}
					}

				}


				if(!seenMissingAfterNonMissing) return false;
			}





		}
		else{

			var missingCols = columns.filter(function(col){
				var missing = dw.summary(col)['missing'];
				return missing.length === 0;
			});
			if(missingCols.length)
				return false;
		}







		return true;
	}

	t.enums = function(table){
		return ['direction'];
	}

	t.name = dw.transform.FILL;
	return t;
}
dw.filter = function(row){
	var t = dw.transform();
	t._drop = true;

	row = dw.row(row);

	dw.ivar(t, [
		{name:'row', initial:row}
	]);

	t.description = function(){
		return [
			'Delete',
			dw.row_clause(t, t._row, 'row')
		]
	}

	t.description_length = function(){
		if(t._row)
			return t._row.description_length();

		return 0;
	}



	t.apply = function(tables, options){
		options = options || {};
		var table = t.getTable(tables),
			cols = table.cols(),
			rows = table.rows(),
			row = t._row.tester(tables),
			filteredTable = table.slice(0,0),
			effectedRows = [], drop = t._drop,
			start_row = options.start_row || 0,
			end_row = options.end_row || rows, luts = table.map(function(c){return c.lut}),
			filter;

		for(var r = start_row; r < end_row; ++r){
			filter = row.test(table, r);
			if (filter) {
				effectedRows.push(r)
			}
			if (!filter || !drop) {
				for (var c = 0; c < cols; ++c) {
					col = filteredTable[c];
					col.push(table[c].get_raw(r))
				}
			}
		}

		var l = table.cols();
		var names = table.map(function(c) {return c.name()});
		var types = table.map(function(c) {return c.type});
		for(var c = 0; c < l; ++c){
			table.removeColumn(0);
		}
		for(var c = 0; c < l; ++c){
			table.addColumn(names[c], filteredTable[c], types[c])
		}

		return {effectedRows:effectedRows}
	}

	t.valid_columns = function(tables){
		if(t._row)
			return t._row.valid_columns(tables);

		return {valid:true}
	}


	t.well_defined = function(){
		return t._row.valid_filter()
	}

	t.name = dw.transform.FILTER;
	return t;
}
dw.fold = function(column){
	var t = dw.transform(column);
	dw.ivara(t, {name:'keys', initial:[-1]})

	t.description = function(){
		return [
			'Fold',
			dw.column_clause(t, t._column, 'column'),
			' using ',
			dw.key_clause(t, t._keys.map(function(c){return c===-1?'header' : c }), 'keys', {editor_class:'fold', clean_val:function(x){return Number(x)}}),

			(t._keys.length===1? 'as a key' : ' as keys ')
		]
	}


	t.apply = function(tables, options){
		options = options || {};
		var table = t.getTable(tables),
			columns = t.columns(table),
			names = columns.map(function(c){return c.name}),
			rows = table.rows(),
			newIndex = 0,
			col,
			values,
			newCols,
			start_row = options.start_row || 0,
			end_row = options.end_row || rows;


		end_row = Math.min(end_row, rows)

		/*These are the keys to use for the fold...We use the header if the key = -1 otherwise we use the value in the cell*/
		var keys = columns.map(function(c){
			return t._keys.reduce(function(a, b){
				if(b===-1) a.push(dw.display_name(c.name()));
				else a.push(c[b])
				return a;
			}, [])
		})

		/*The new columns to put the keys in*/
		var keyCols = dv.range(keys[0].length).map(function(k){
			var x = [];
			x.name = 'fold';
			x.type = dv.type.nominal;
			return x;
		})

		var valueCol = []; valueCol.name = 'value'; valueCol.type = dv.type.nominal, newColumns = [];

		/*Copy the values from all other columns*/
		/*Also find where to insert to the new columns*/
		var updateCol;
		var foundLeft = false;
		var cols = table.filter(function(c){
			if(names.indexOf(c.name) === -1){
				return true;
			}
			else{
				if(!foundLeft) updateCol = c;
			}
			foundLeft = true;
			return false;
		}).map(function(c){
			var x = [];
			x.name = c.name;
			x.type = c.type;
			x.lut = c.lut;
			return x;
		})

		var v;

		for(var row = start_row; row < end_row; ++row){

			if(t._keys.indexOf(row)===-1){
				for(var k = 0; k < columns.length; ++k){
					for(var c = 0; c < cols.length; ++c){
						col = cols[c];
						col[newIndex] = table[col.name()][row];
					}
					for(var j = 0; j < keyCols.length; ++j){
						keyCols[j][newIndex] = keys[k][j]
					}
					valueCol[newIndex] = columns[k][row]
					++newIndex;
				}
			}
		}

		var updateIndex = updateCol ? updateCol.index : 0;

		while(table.cols()){
			table.removeColumn(0);
		}
		cols.forEach(function(c){
			table.addColumn(c.name(), c, c.type, {encoded:true, lut:c.lut})
		})

		keyCols.concat([valueCol]).forEach(function(c, i){
			newColumns.push(table.addColumn(c.name, c, c.type, {index:updateIndex+i, wranglerType:c.wrangler_type}));
		})

		return {keyCols:newColumns.slice(0, newColumns.length-1), valueCols:newColumns.slice(newColumns.length-1), toValueCols:columns, keyRows:t._keys}


	}

	t.well_defined = function(table){

		return true;
	}

	t.name = dw.transform.FOLD;
	return t;
}
dw.row = function(formula){

	var t = dw.transform();
	dw.ivar(t, [
		{name:'formula', initial:formula || ''}
	])

  t.valid_filter = function() {
    return t._formula && t._formula.length;
  }

	t.description_length = function(){
			return t._formula.length;

			if(t._conditions.length===0){
				return 0;
			}
			if(t._conditions.length === 1){
				switch(t._conditions[0].name){
					case dw.row.INDEX:
						return 1
					case dw.row.EMPTY:
						return 2;
					default:
						break
				}
			}
			return 3;
	}

	t.description = function(){

		return t._formula;
		if(t._conditions.length === 1){
			switch(t._conditions[0].name){
				case dw.row.INDEX:
				case dw.row.CYCLE:
				case dw.row.EMPTY:
					return t._conditions[0].description({simple:true})
				default:
					break
			}
		}

		return [
			' rows where ' + t._conditions.map(function(c){return c.description()}).join(' and ')
		]
	}

	t.valid_columns = function(tables){
		var conds = t._conditions, cond, v;
		for(var i = 0; i < conds.length; ++i){
			cond = conds[i];
			v = cond.valid_columns(tables)
			if(!v.valid){
				return v;
			}
		}
		return {valid:true}
	}

  t.tester = function(tables) {
    var formula = t._formula,
        expression, table, result, filter_predicate;

    if (formula && formula.length) {
      expression = dw.parser.parse(formula);
      table = t.getTable(tables);
	    result = expression.evaluate(table);
  		filter_predicate = function(table, row) {
  		  return result[row];
  		}
    } else {
      filter_predicate = function(table, row) {
  		  return true;
  		}
    }
		return {test:filter_predicate};
  }

	t.test = function(tables, row){
		var conds = t._conditions, cond;
		for(var i = 0; i < conds.length; ++i){
			cond = conds[i];
			if(!cond.test(tables, row)){
				return 0;
			}
		}
		return 1;
	}
	t.name = dw.transform.ROW;
	return t;
}

dw.row.fromFormula = function(formula){

	if(formula===''){
		return dw.row([])
	}

	var preds = formula.split(/ & /g)
	var index;
	preds = preds.map(function(pred){
		if(pred === 'row is empty'){
			return dw.empty();
		}
		if(index = pred.indexOf( 'index in (') != -1){

			var indices = pred.substring(index+9, pred.length-1);
			indices = indices.split(/,/g).map(function(i){return Number(i)-1});
			return dw.rowIndex(indices);
		}

		var match = pred.match(/\=|<\=|>\=|!=|is null|is not|matches role|matches type|like/)
		var op = match[0], index = match.index, cond, lhs = pred.substr(0, index).replace(/^ */, '').replace(/ *$/,''), rhs = pred.substr(index+op.length).replace(/^ * /,'').replace(/ *$/, '');




		switch(rhs){
			case 'a number':
				rhs = dw.number();
				break
			case 'a date':
				rhs = dw.date();
				break
			case 'a string':
				rhs = dw.string();
				break;
			case 'a integer':
				rhs = dw.integer();
				break;
			default:
				if(rhs[0]==="'") rhs = rhs.substring(1, rhs.length-1);
				else rhs = Number(rhs)
		}


		switch(op){
			case "=":
				cond = dw.eq(lhs, rhs, true);
				break;
			case "<":
				cond = dw.lt(lhs, rhs, true);
				break;
			case "<=":
				cond = dw.le(lhs, rhs, true);
				break;
			case ">":
				cond = dw.gt(lhs, rhs, true);
				break;
			case ">=":
				cond = dw.ge(lhs, rhs, true);
				break;
			case "!=":
				cond = dw.neq(lhs, rhs, true);
				break;
			case "is null":
				cond = dw.is_null(lhs);
				break;
			case "matches role":
				cond = dw.matches_role(lhs);
				break;
			case "is not":

				cond = dw.matches_type(lhs, rhs);
				break;
			case "matches type":

				cond = dw.matches_type(lhs);
				break;
			case "~":
				cond = dw.like(lhs, rhs, true);
				break;
			default:
				throw "Invalid row predicates"
		}
		return cond;
	})

	return dw.row(preds);
}

dw.row.INDEX = 'rowIndex'
dw.row.CYCLE = 'rowCycle'
dw.row.EMPTY = 'empty'
dw.row.IS_NULL = 'is_null'
dw.row.IS_VALID = 'is_valid'
dw.row.MATCHES_ROLE = 'is_role'
dw.row.MATCHES_TYPE = 'is_type'
dw.row.STARTS_WITH = 'starts_with'
dw.row.LIKE = 'like'
dw.row.EQUALS = 'eq'
dw.row.NOT_EQUALS = 'neq'
dw.row.CONTAINS = 'contains'
dw.rowIndex = function(indices){
	var t = dw.transform();
	dw.ivara(t, [
		{name:'indices', initial:indices || []}
	])
	t.test = function(table, row){

		return t._indices.indexOf(row) != -1
	}

  t.formula = function() {
    return indices.map(function(i) { return 'index() = ' + i}).join(' or ')
  }

	t.description = function(o){
		o = o || {}, indices = t._indices;

		var simple = o.simple || false;
		if(simple){

			return (indices.length === 1 ? (indices[0]===-1 ? '' : 'row ') : 'rows ') + indices.map(function(i){return i===-1?'header':(i+1)}).join(',')
		}
		else{



			return 'index in (' + indices.map(function(i){return i+1}).join(',') + ')'
		}
	}

	t.valid_columns = function(){
		return {valid:true};
	}

	t.name = dw.row.INDEX;

	return t;
}

dw.rowCycle = function(cycle, start, end){
	var t = dw.transform();

	dw.ivar(t, [
		{name:'cycle', initial:cycle != undefined ? cycle : 1},
		{name:'start', initial:start || 0},
		{name:'end', initial:end}
	])



	t.test = function(table, row){
		var e = t.end(), s = t.start();
		if((s === undefined || row >= s) && (e === undefined || row <= e))
		return (row-s) % t.cycle() === 0;
	}
	t.description = function(o){
		o = o || {}, indices = t._indices;

		var simple = o.simple || false;
		if(simple){

			var qualifier = '';

			if(t.start() && t.end()!=undefined){
				qualifier = ' between ' + (t.start()+1) + ',' + (t.end()+1);
			}
			else if(t.start()){
				qualifier = ' starting with ' + (t.start()+1);
			}
			else if(t.end()){
				qualifier = ' before ' + (t.end()+1);
			}


			return 	' every ' + t.cycle() + ' rows ' + qualifier
		}
		else{

			var qualifier = '';

			if(t.start() && t.end()!=undefined){
				qualifier = ' between ' + (t.start()+1) + ',' + (t.end()+1);
			}
			else if(t.start()){
				qualifier = ' after ' + (t.start()+1);
			}
			else if(t.end()){
				qualifier = ' before ' + (t.end()+1);
			}


			return 'every ' + t.cycle() + ' rows' + qualifier;
		}
	}

	t.valid_columns = function(){
		return {valid:true};
	}

	t.name = dw.row.CYCLE;

	return t;
}

dw.vcompare = function(lcol, value){
	var t = dw.transform();

	dw.ivar(t, [
		{name:'lcol', initial:lcol},{name:'value', initial:value}
	])


	t.test = function(table, row){
		return t.compare(table[t._lcol][row], value)
	}

	t.description = function(){
		return dw.display_name(t._lcol) + " " + t._op_str + " '"  + t._value + "'";
	}

	t.valid_columns = function(tables){
		if(tables[0][lcol])
			return {valid:true};
		return {valid:false, errors:['Invalid left hand side']}
	}

	return t;
}

dw.ccompare = function(lcol, rcol){
	var t = dw.transform();

	dw.ivar(t, [
		{name:'lcol', initial:lcol},{name:'rcol', initial:rcol}
	])


	t.test = function(table, row){
		return t.compare(table[lcol][row], table[rcol][row])
	}

	t.description = function(){
		return dw.display_name(t._lcol) + " " + t._op_str + " "  + t._rcol;
	}

	t.valid_columns = function(tables){
		if(tables[0][lcol] && tables[0][rcol])
			return {valid:true};
		return {valid:false, errors:['Invalid comparison']}
	}


	return t;
}

dw.compare = function(lcol, rcol, value){



	var t = value ? dw.vcompare(lcol, rcol) : dw.ccompare(lcol, rcol);
	t.default_transform = function(){
		return dw[t.name](lcol, rcol, value)
	}
	return t;
}

dw.eq = function(l, r, v){

	var t = dw.compare(l ,r, v);

	t._op_str = '='

	t.compare = function(a, b){
		return a === b;
	}

	t.name = dw.row.EQUALS;

	return t;
}

dw.neq = function(l, r, v){

	var t = dw.compare(l ,r, v);

	t._op_str = '!='

	t.compare = function(a, b){
		return a != b;
	}

	t.name = dw.row.NOT_EQUALS;

	return t;
}


dw.starts_with = function(l, r, v){
	var t = dw.compare(l ,r, v);

	t._op_str = 'starts with'

	t.compare = function(a, b){
		a = ""+a
		b = ""+b

		return a.indexOf(b)==0;
	}

			t.name = dw.row.STARTS_WITH;

	return t;
}

dw.like = function(l, r, v){
	var t = dw.compare(l ,r, true);
	t._op_str = '~'
	t.compare = function(a, b){
		a = ""+a
		b = ""+b
		return a.match(b)!=null;
	}

	t.name = dw.row.LIKE;

	return t;
}


dw.contains = function(l, r, v){
	var t = dw.compare(l ,r, v);

	t._op_str = 'contains'

	t.compare = function(a, b){
		a = ""+a
		b = ""+b

		return a.indexOf(b)!=-1;
	}

	t.name = dw.row.CONTAINS;

	return t;
}

dw.is_null = function(l, r, v){
	var t = dw.compare(l ,r, true);

	t._op_str = 'is null'

	t.compare = function(a, b){
		return dw.is_missing(a);
	}

	t.description = function(){

		return dw.display_name(t._lcol) + ' ' +  t._op_str;


	}
		t.name = dw.row.IS_NULL;
	return t;
}



dw.matches_role = function(lcol){
	var t = dw.transform();

	dw.ivar(t, [
		{name:'lcol', initial:lcol}
	])

	t.test = function(table, row){
		return (table[lcol].wrangler_role.parse(table[lcol][row])===undefined);
	}

	t.description = function(){
		return dw.display_name(t._lcol) + ' does not match role';
	}
	t.name = dw.row.MATCHES_ROLE;


	t.valid_columns = function(tables){
		if(tables[0][lcol])
			return {valid:true};
		return {valid:false, errors:['Invalid comparison']}
	}


	return t;
}

dw.matches_type = function(lcol, type){
	var t = dw.transform();
	dw.ivar(t, [
		{name:'lcol', initial:lcol},
		{name:'type', initial:type}
	])


	t.test = function(table, row){
		var wt = t._type || table[lcol].wrangler_type;
		return !wt || (wt.parse(table[t._lcol][row])===undefined);
	}

	t.description = function(){
		return dw.display_name(t._lcol) + ' is not a ' + type.name;
	}

	t.valid_columns = function(tables){
		if(tables[0][lcol])
			return {valid:true};
		return {valid:false, errors:['Invalid comparison']}
	}


		t.name = dw.row.MATCHES_TYPE;
	return t;
}




dw.is_missing = function(v){
	return v == undefined || (''+v).replace(/[ \t\n]/g, '').length === 0;
}

dw.empty = function(){
	var t = dw.transform();

	dw.ivar(t, [
		{name:'percent_valid', initial:0},
		{name:'num_valid', initial:0}
	])

  t.formula = function() {
    return "empty()"
  }

	t.test = function(table, row){
		var v;

		var total = table.cols();
		var num_missing = 0;
		var percent_valid = t.percent_valid();
		var num_valid = t.num_valid();

		for(var c = 0; c < total; ++c){
			v = (table[c][row])
			if (dw.is_missing(v)) num_missing++;

			if ((num_missing >= (total - num_valid)) ||
					(num_missing / total) >= ((100 - percent_valid) / 100)) {
				return 1;
			}
		}

		return 0;
	}

	t.description = function(o){
		o = o || {};
		var simple = o.simple || false;

		var percent_valid = t.percent_valid();
		var num_valid = t.num_valid();

		if(simple){
			if (percent_valid > 0) {
				return 'rows with <= ' + percent_valid + '% values'
			}
			else if (num_valid > 0) {
				return 'rows with <= ' + num_valid + ' values'
			}
			else {
				return 'empty rows'
			}
		}
		else{
			if (percent_valid > 0) {
				return ' row is (sort of) empty '
			}
			else if (num_valid > 0) {
				return ' row is (sort of) empty '
			}
			else {
				return ' row is empty '
			}
		}
	}
	t.valid_columns = function(tables){
			return {valid:true};
	}
	t.name = dw.row.EMPTY;
	return t;
}
dw.split = function(column){
	var t = dw.textPattern(column);

	t._drop = true;
	t.transform = function(values){
		if(t._positions && t._positions.length){
			if(values[0]===undefined) return []
			var val = ""+values[0]
			var indices = t._positions;
			var startIndex = indices[0], endIndex = indices[1] || indices[0];
			var splitValues = [];
			splitValues.push(val.substring(0, startIndex))
			splitValues.push(val.substring(endIndex))
			splitValues.stats = [{splits:[{start:startIndex, end:endIndex}]}]
			return splitValues;
		}
		else{
			var ignore_between, qc;
			if((qc = t._quote_character) != undefined){
				ignore_between = new RegExp(qc+'[^'+qc+']*'+qc);
			}
			var params = {which:t._which, max_splits:t._max, before:t._before,after:t._after,on:t._on,ignore_between:ignore_between || t._ignore_between}
			var splits = dw.regex.match(values[0], params);



			var splitValues = [];
			splitValues.stats = [];
			for(var i = 0; i < splits.length; ++i){
				if(i%2==0){
					splitValues.push(splits[i].value)
				}
				else{
					splitValues.stats.push({splits:[{start:splits[i].start, end:splits[i].end}]})
				}
			}


			return splitValues;
		}
	}

	t.description = function(table){

		var description = [
			'Split',
			dw.column_clause(t, t._column, 'column', {editor_class:'none'})
		]


		if(Number(t._max) === 0){

			description = description.concat(dw.select_clause(t, {select_options:{'0':'repeatedly','1':'once'},param:'max'}))
		}
		regex = t.match_description();


		description = description.concat(regex)

		if(t._result === dw.ROW){
			description = description.concat(' into ')
			description = description.concat(dw.select_clause(t, {select_options:{'row':'rows'}, param:'result'}))
		}



		return description;

	}



	t.name = dw.transform.SPLIT;

	return t;
}
dw.set_type = function(column, types){
	var t = dw.transform(column);
	dw.ivara(t, [{name:'types', initial:types || []}])

	t.description = function(){
		return [
		]
	}

	t.apply = function(tables){
		var table = t.getTable(tables),
			columns = t.columns(table);

		columns.forEach(function(col, i){
			col.wrangler_type = t._types[i]
		})

		return {}

	}

	t.name = dw.transform.SET_TYPE;

	return t;
}

dw.promote = function(column) {
  var t = dw.transform(column);
	t._drop = true;
	dw.ivar(t, [{name:'header_row', initial:0}])
	t.transform = function(values){

	}

	t.well_defined = function(){
		return t._header_row != undefined
	}

	t.description = function(){
	}

	t.apply = function(tables){
		var table = t.getTable(tables),
			columns = t.columns(table);
		if(t._header_row!=undefined){
			var row = table.row(t._header_row);
			table.forEach(function(c, i){
				var val = row[i];
				if(dw.is_missing(val)) val = 'undefined';
				c.name(val)


				if(t._drop){
					c.splice(t._header_row, 1)
				}
			})
			return {promoteRows:[-1, t._header_row]}
		}
		return {}
	}

	t.name = dw.transform.PROMOTE;

	return t;
};


dw.set_name = function(column, names){
	var t = dw.transform(column);
	t._drop = true;
	dw.ivara(t, [{name:'names', initial:names || []}])
	dw.ivar(t, [{name:'header_row', initial:undefined}])
	t.transform = function(values){

	}

	t.well_defined = function(){
		return t._names.length || t._header_row != undefined
	}

	t.description = function(){
		if(t._header_row!=undefined){
			row = t._header_row;

			if(typeOf(row)==='number') row = dw.row(dw.rowIndex([t._header_row]))
			return [
				'Promote row',
				dw.key_clause(t, [t._header_row], 'header_row'),
				' to header'
			];
		}
		else{
			return [
				'Set ',
				dw.column_clause(t,  t._column, 'column', {extra_text:""}),
				' name to ',
				dw.input_clause(t, 'names')
			];
		}
	}

	t.apply = function(tables){
		var table = t.getTable(tables),
			columns = t.columns(table);
		if(t._header_row!=undefined){
			var row = table.row(t._header_row);
			table.forEach(function(c, i){
				var val = row[i];
				if(dw.is_missing(val)) val = 'undefined';
				c.name(val)


				if(t._drop){
					c.splice(t._header_row, 1)
				}
			})
			return {promoteRows:[-1, t._header_row]}
		}
		else{
			columns.forEach(function(col, i){
				col.name(names[i])


			})
		}
		return {}
	}

	t.name = dw.transform.SET_NAME;

	return t;
};

dw.metadata = (function() {

  var metadata = {},
      transform_parameters, map_parameters, text_pattern_parameters, fold_parameters, unfold_parameters, merge_parameters, fill_parameters, row_parameter,
      always_show = ['column', 'on', 'measure'], never_show = ['table', 'status', 'insert_position', 'ignore_between'];

  row_parameter = {
    name: 'row',
    description: 'Specifies which rows the transform should operate on.  Defaults to all rows.  See documentation for how to create filters.',
    default_value: undefined,
    helper_message: 'See documentation for how to create filters.',
    type: 'row',
    possible_values: 'See documentation on filters.'
  }

  transform_parameters = [
    {
			name: 'column',
      description: 'The columns to transform.',
      default_value: [],
      helper_message: '',
      type: 'columns',
      possible_values: 'Column in the table.'
    },
    {
			name: 'drop',
      description: 'Whether or not to drop input columns from the table.',
      default_value: function(t) {return ['drop', 'split', 'promote', 'filter', 'cut'].indexOf(t.name) > -1},
      helper_message: '',
      type: 'boolean',
      possible_values: [true, false]
    },
    {
			name: 'table',
      description: 'The table to transform.',
      default_value: 0,
      helper_message: 'Which table to transform.  Should not need to use this currently.',
      type: 'integer',
      possible_values: 'Value between 0 and number of tables - 1'
    },
    {
			name: 'status',
      description: 'Whether transform is currently active',
      default_value: dw.status.active,
      helper_message: 'Used internally to activate/inactive transforms.',
      type: 'enumerable',
      possible_values: [dw.status.active, dw.status.inactive, dw.status.deleted, dw.status.invalid]
    }
  ];


  map_parameters = [
    {
			name: 'result',
      description: 'Whether generated values should appear in new columns or should generate new rows.',
      default_value: dw.COLUMN,
      helper_message: '',
      type: 'enumerable',
      possible_values: [dw.COLUMN, dw.ROW]
    },
    {
			name: 'insert_position',
      description: 'Start position of new columns within the table.',
      default_value: dw.INSERT_RIGHT,
      helper_message: 'Where to place new columns in the table.  This is used internally for now.',
      type: 'enumerable',
      possible_values: [dw.INSERT_RIGHT, dw.INSERT_END]
    },
    row_parameter
  ]

  filter_parameters = [
      row_parameter
  ]

  row_parameters = [
    {
  	 name: 'formula',
     description: 'The conditions to filter',
     default_value: '',
     helper_message: 'Type in a filter condition',
     type: 'filter_condition',
     possible_values: 'A valid filter'
    }
  ]

  promote_parameters = [
    {
 			name: 'header_row',
     description: 'The row to convert to a header.',
     default_value: 0,
     helper_message: 'The row to convert to a header',
     type: 'row_index',
     possible_values: 'Any row index'
    }
  ]

  text_pattern_parameters = [
    {
			name: 'on',
      description: 'A string or regular expression to match against.',
      default_value: undefined,
      helper_message: 'Which regular expression to use.',
      type: 'regex',
      possible_values: 'Any string or regular expression.'
    },
    {
			name: 'before',
      description: 'A string or regular expression to match against.',
      default_value: undefined,
      helper_message: 'Which regular expression to use.',
      type: 'regex',
      possible_values: 'Any string or regular expression.'
    },
    {
			name: 'after',
      description: 'A string or regular expression to match against.',
      default_value: undefined,
      helper_message: 'Which regular expression to use.',
      type: 'regex',
      possible_values: 'Any string or regular expression.'
    },
    {
			name: 'ignore_between',
      description: 'A string or regular expression used to ingore text.',
      default_value: undefined,
      helper_message: 'Which regular expression to use.',
      type: 'regex',
      possible_values: 'Any string or regular expression.'
    },
    {
			name: 'quote_character',
      description: 'A quote character.',
      default_value: undefined,
      helper_message: 'Used to ignore matches between occurrences of the character.',
      type: 'character',
      possible_values: 'Any character.'
    },
    {
			name: 'which',
      description: 'Which occurrence of the pattern to match against.',
      default_value: 1,
      helper_message: 'Used to select the nth occurrence of a pattern.',
      type: 'integer',
      possible_values: 'Any non-negative integer.'
    },
    {
			name: 'max',
      description: 'How many occurrences to match.',
      default_value: 1,
      helper_message: 'Use 0 to indicate as many times as possible.',
      type: 'integer',
      possible_values: 'Any non-negative integer.'
    },
    {
			name: 'positions',
      description: 'Index positions of text to match.',
      default_value: undefined,
      helper_message: 'Use to split text positionally',
      type: 'ints',
      possible_values: 'Any array of 2 non-negative integers.'
    }
  ]

  fill_parameters = [
    {
			name: 'direction',
      description: 'The direction of the fill.',
      default_value: dw.DOWN,
      helper_message: 'Use to indicate which direction to fill.',
      type: 'enumerable',
      possible_values: [dw.DOWN, dw.UP, dw.LEFT, dw.RIGHT]
    },
    row_parameter
  ]

  fold_parameters = [
    {
			name: 'keys',
      description: 'The direction of the fill.',
      default_value: [-1],
      helper_message: 'Use -1 to indicate header row',
      type: 'row_indices',
      possible_values: 'Array of ints >= -1'
    }
  ]

  unfold_parameters = [
    {
			name: 'measure',
      description: 'The attribute to unfold on.',
      default_value: undefined,
      helper_message: '',
      type: 'column',
      possible_values: 'A column name'
    }
  ]

  merge_parameters = [
    {
			name: 'glue',
      description: 'The text to use between cells.',
      default_value: '',
      helper_message: '',
      type: 'string',
      possible_values: 'Any string.'
    }
  ]

  var transforms = {
    'cut': {
      parameters: transform_parameters.concat(map_parameters).concat(text_pattern_parameters),
      constructor_parameters: ['column']
    },
    'copy': {
      parameters: transform_parameters.concat(map_parameters),
      constructor_parameters: ['column']
    },
    'drop':{
      parameters: transform_parameters,
      constructor_parameters: ['column']
    },
    'extract':{
      parameters: transform_parameters.concat(map_parameters).concat(text_pattern_parameters),
      constructor_parameters: ['column']
    },
    'fill':{
      parameters: transform_parameters.concat(fill_parameters),
      constructor_parameters: ['column']
    },
    'filter':{
      parameters: transform_parameters.concat(filter_parameters),
      constructor_parameters: [],
      ignored_parameters: ['column']
    },
    'fold':{
      parameters: transform_parameters.concat(fold_parameters),
      constructor_parameters: ['column']
    },
    'merge':{
      parameters: transform_parameters.concat(map_parameters).concat(merge_parameters),
      constructor_parameters: ['column']
    },
    'promote':{
      parameters: transform_parameters.concat(promote_parameters),
      constructor_parameters: ['column']
    },
    'row':{
      parameters: transform_parameters.concat(row_parameters),
      constructor_parameters: ['formula'],
      ignored_parameters: ['column']
    },
    'split':{
      parameters: transform_parameters.concat(map_parameters).concat(text_pattern_parameters),
      constructor_parameters: ['column']
    },
    'unfold':{
      parameters: transform_parameters.concat(unfold_parameters),
      constructor_parameters: ['column']
    }
  }


  for(var t in transforms) {
    transforms[t].parameters.forEach(function(p) {
      if(typeOf(p.default_value) != 'function') {
        p.default_value = dw.functor(p.default_value);
      }
    })
  }

  return {
    transforms: transforms,
    constructor_parameters: function(t) {
      return transforms[t.name].constructor_parameters;
    },
    displayed_parameters: function(t) {
      var transform = transforms[t.name];
      return transform.parameters.filter(function(p) {
        if (transform.constructor_parameters.indexOf(p.name) != -1 ) {
          return false;
        }
        if (transform.ignored_parameters && transform.ignored_parameters.indexOf(p.name) != -1) {
          return false;
        }
        return (always_show.indexOf(p.name) !== -1) || (never_show.indexOf(p.name) === -1 && t["_"+p.name] != p.default_value(t));
      })
    }

  };
})();

dw.derive = function(){
	var t = dw.transform();
	dw.ivar(t, [{name:'result', initial:dw.COLUMN},{name:'formula', initial:undefined},{name:'insert_position', initial:dw.INSERT_RIGHT},{name:'row', initial:undefined}])
	t.apply = function(tables, options){

    var table = t.getTable(tables),
        result = dw.parser.parse(t.formula()).evaluate(table);
        table.addColumn('derived', result, result.type, {encoded:result.lut != undefined, lut:result.lut});
	}
	return t;
}
dw.derive.derived_predicate = function(expression) {
  var pred = dw.transform();

  pred.apply = function(tables, options) {
    options = options || {};
		var table = pred.getTable(tables),
		result = expression.evaluate(table), filter_predicate;
		filter_predicate = function(table, row) {
		  return result[row];
		}
		dw.filter({test:filter_predicate}).apply(tables, options);
  }

  return pred;
};dw.derive.expression = function(children) {
	var exp = {},
		children = children || [];

	exp.children = function(x) {
		if(!arguments.length) return children;
		children = x;
		if(typeOf(children) !== 'array') {
      children = [children];
    }
		return exp;
	};

	exp.evaluate = function(table) {
		var values = children.map(function(c) {
      return c.evaluate(table);
    })





		return exp.transform(values, table);
	};

	exp.children(children);
	return exp;
};
dw.derive.constant = function(c, type) {
	var constant = dw.derive.expression();
	constant.transform = function(values, table) {
		var length = table.rows();
		    result = dv.array_with_init(length, c);
		result.type = type;
		return result;
	}
	return constant;

}
dw.derive.variable = function(x) {

	var variable = dw.derive.expression();
	variable.transform = function(values, table) {
		var result = table[x].copy();
		return result;
	}
	return variable;

}
dw.derive.add = function(children) {

	var add = dw.derive.expression(children);

	add.transform = function(values) {
		var x = values[0], y = values[1], length = x.length, i,
		    result = dv.array(length);
		for (i = 0; i < length; ++i) {
		  result[i] = x[i] + y[i];
		}

		if (x.type.name === y.type.name) {
		  result.type = x.type;
		} else {
		  result.type = dt.type.string();
		}
		return result;
	}

	return add;

};
dw.derive.multiply = function(children) {
	var add = dw.derive.expression(children);

	add.transform = function(values) {
		var x = values[0], y = values[1], length = x.length, i,
		    result = dv.array(length);
		for (i = 0; i < length; ++i) {
		  result[i] = x[i] * y[i];
		}
		result.type = dt.type.number();
		return result;
	}
	return add;

}
dw.derive.subtract = function(children) {

	var subtract = dw.derive.expression(children);

	subtract.transform = function(values) {
		var x = values[0], y = values[1], length = x.length, i,
		    result = dv.array(length);
		for (i = 0; i < length; ++i) {
		  result[i] = x[i] - y[i];
		}
	  result.type = dt.type.number();
		return result;
	}
	return subtract;

};
dw.derive.divide = function(children) {

	var divide = dw.derive.expression(children);

	divide.transform = function(values) {
		var x = values[0], y = values[1], length = x.length, i,
		    result = dv.array(length);
		for (i = 0; i < length; ++i) {
		  result[i] = x[i] / y[i];
		}
    result.type = dt.type.number();
		return result;
	}
	return divide;

};
dw.derive.log = function(children, base) {

	var derive = dw.derive.expression(children);

  derive.base = function (x) {
    if(!arguments.length) return base;
    base = x;
    return derive;
  }

	derive.transform = function(values, table) {
		var x = values[0], length = x.length, i,
		    result = dv.array(length), val, log_base = base && base.evaluate(table);
		for (i = 0; i < length; ++i) {
      if (x[i] === 0) result[i] = 0;
      else {
        val = Math.log(x[i])
  		  if(log_base) {
  		    val = val / Math.log(log_base[i]);
  		  }
  		  result[i] = val;
      }
		}
		result.type = dt.type.number();
		return result;
	}

  derive.name = 'log';

  derive.base(base);
	return derive;

}
dw.derive.pow = function(children, exp) {

	var derive = dw.derive.expression(children);

	derive.base = function (x) {
    if(!arguments.length) return exp;
    exp = x;
    return derive;
  }

	derive.transform = function(values, table) {
		var x = values[0], length = x.length, i,
		    result = dv.array(length), val, pow_exp = exp && exp.evaluate(table);
		for (i = 0; i < length; ++i) {
		  val = x[i];
		  if (pow_exp) {
		    val = Math.pow(val, pow_exp[i]);
		  }
		  result[i] = val;
		}
		result.type = dt.type.number();
		return result;
	}

  derive.name = 'pow';

	return derive;

}
dw.derive.negate = function(children) {

	var add = dw.derive.expression(children);

	add.transform = function(values) {
		var x = values[0], length = x.length, i,
		    result = dv.array(length);
		for (i = 0; i < length; ++i) {
		  result[i] = -x[i];
		}
    result.type = dt.type.number();
		return result;
	}
	return add;

}
dw.derive.parse = function(formula) {
	return new MathProcessor().parse(formula);
}




MathProcessor = function(){
    var o = this;
	if(true){
		o.o = {
	        "+": function(a, b){ return dw.derive.add().children([a, b]); },
			"-": function(a, b){ return dw.derive.subtract().children([a, b]); },
			"/": function(a, b){ return dw.derive.divide().children([a, b]); },
	        "*": function(a, b){ return dw.derive.multiply().children([a, b]); }
	    };

	}
	else {
		o.o = {
			        "+": function(a, b){ return +a + b; },
			        "-": function(a, b){ return a - b; },
			        "%": function(a, b){ return a % b; },
			        "/": function(a, b){ return a / b; },
			        "*": function(a, b){ return a * b; },
			        "^": function(a, b){ return Math.pow(a, b); },
			        "~": function(a, b){ return Math.sqrt(a, b); }
			    };

	}
    o.s = { "^": 3, "~": 3, "*": 2, "/": 2, "%": 1, "+": 0, "-": 0 };
    o.u = {"+": 1, "-": -1}, o.p = {"(": 1, ")": -1};
};

MathProcessor.prototype.parse = function(e){
    for(var n, x, o = [], s = [x = this.RPN(e.replace(/ /g, "").split(""))]; s.length;)
        for((n = s[s.length-1], --s.length); n[2]; o[o.length] = n, s[s.length] = n[3], n = n[2]);
    for(; (n = o.pop()) != undefined; n[0] = this.o[n[0]](n[2][0], n[3][0]));

    return x[0];
};

MathProcessor.prototype.methods = {
    "div": function(a, b){ return parseInt(a / b); },
    "frac": function(a){ return a - parseInt(a); },
    "sum": function(n1, n2, n3, n){ for(var r = 0, a, l = (a = arguments).length; l; r += a[--l]); return r; },
    "medium": function(a, b){ return (a + b) / 2; }
};

MathProcessor.prototype.error = function(s){
    throw new Error("MathProcessor: " + (s || "Erro na expressão"));
}

MathProcessor.prototype.RPN = function(e){
    var _, r, c = r = [, , , 0];
    if(e[0] in this.u || !e.unshift("+"))
        for(; e[1] in this.u; e[0] = this.u[e.shift()] * this.u[e[0]] + 1 ? "+" : "-");
    (c[3] = [this.u[e.shift()], c, , 0])[1][0] = "*", (r = [, , c, 0])[2][1] = r;
    (c[2] = this.v(e))[1] = c;
    (!e.length && (r = c)) || (e[0] in this.s && ((c = r)[0] = e.shift(), !e.length && this.error()));
     while(e.length){
        if(e[0] in this.u){
            for(; e[1] in this.u; e[0] = this.u[e.shift()] * this.u[e[0]] + 1 ? "+" : "-");
            (c = c[3] = ["*", c, , 0])[2] = [-1, c, , 0];
        }
        (c[3] = this.v(e))[1] = c;
        e[0] in this.s && (c = this.s[e[0]] > this.s[c[0]] ?
            ((c[3] = (_ = c[3], c[2]))[1][2] = [e.shift(), c, _, 0])[2][1] = c[2]
            : r == c ? (r = [e.shift(), , c, 0])[2][1] = r
            : ((r[2] = (_ = r[2], [e.shift(), r, ,0]))[2] = _)[1] = r[2]);
    }
    return r;
};

MathProcessor.prototype.v = function(e){
    if("0123456789.".indexOf(e[0]) + 1){
        for(var i = -1, l = e.length; ++i < l && "0123456789.".indexOf(e[i]) + 1;);
        return [+e.splice(0,i).join(""), , , 0];
    }
    else if(e[0] == "("){
        for(var i = 0, l = e.length, j = 1; ++i < l && (e[i] in this.p && (j += this.p[e[i]]), j););
        return this.RPN(l = e.splice(0,i), l.shift(), !j && e.shift());
    }
    else{
        var i = 0, c = e[0].toLowerCase();
        if((c >= "a" && c <= "z") || c == "_"){
			while((c = e[++i])&&((c.toLowerCase() >= "a" && c <= "z") || c == "_" || (c >= 0 && c <= 9)));
            if(c == "("){
                for(var l = e.length, j = 1; ++i < l && (e[i] in this.p && (j += this.p[e[i]]), j););
                return [e.splice(0,i+1).join(""), , , 0];
            }
        }
		return [e.splice(0,i).join(""), , , 0]
    }
    this.error();
}

MathProcessor.prototype.f = function(e){
    var i = 0, n;
    if(((e = e.split(""))[i] >= "a" && e[i] <= "z") || e[i] == "_"){
        while((e[++i] >= "a" && e[i] <= "z") || e[i] == "_" || (e[i] >= 0 && e[i] <= 9));
        if(e[i] == "("){
            !this.methods[n = e.splice(0, i).join("")] && this.error("Função \"" + n + "\" não encontrada"), e.shift();
            for(var a = [], i = -1, j = 1; e[++i] && (e[i] in this.p && (j += this.p[e[i]]), j);)
                j == 1 && e[i] == "," && (a.push(this.parse(e.splice(0, i).join(""))), e.shift(), i = -1);
            a.push(this.parse(e.splice(0,i).join(""))), !j && e.shift();
        }
        return this.methods[n].apply(this, a);
    }
};dw.parser = PEG.buildParser(' \
start \
  = additive \
 \
additive \
  = left:multiplicative [ ]*"+"[ ]* right:additive { return dw.derive.add([left, right]); } \
  / left:multiplicative [ ]*"-"[ ]* right:additive { return dw.derive.subtract([left, right]); } \
  / left:multiplicative [ ]*"or"[ ]* right:additive { return dw.derive.or([left, right]); } \
  / left:multiplicative [ ]*"||"[ ]* right:additive { return dw.derive.or([left, right]); } \
  / left:multiplicative [ ]*"and"[ ]* right:additive { return dw.derive.and([left, right]); } \
  / left:multiplicative [ ]*"&&"[ ]* right:additive { return dw.derive.and([left, right]); } \
  / multiplicative \
 \
multiplicative \
  = left:primary [ ]*"*"[ ]* right:multiplicative { return dw.derive.multiply([left, right]); } \
  / left:primary [ ]*"/"[ ]* right:multiplicative { return dw.derive.divide([left, right]); } \
  / left:primary [ ]*"<"[ ]* right:multiplicative { return dw.derive.lt([left, right]); } \
  / left:primary [ ]*"<="[ ]* right:multiplicative { return dw.derive.lte([left, right]); } \
  / left:primary [ ]*">"[ ]* right:multiplicative { return dw.derive.gt([left, right]); } \
  / left:primary [ ]*">="[ ]* right:multiplicative { return dw.derive.gte([left, right]); } \
  / left:primary [ ]*"is missing"[ ]* { return dw.derive.is([left], dt.MISSING); } \
  / left:primary [ ]*"is not missing"[ ]* { return dw.derive.is([left], dt.MISSING, false); } \
  / left:primary [ ]*"is error"[ ]* { return dw.derive.is([left], dt.ERROR); } \
  / left:primary [ ]*"is not error"[ ]* { return dw.derive.is([left], dt.ERROR, false); } \
  / left:primary [ ]*"is valid"[ ]* { return dw.derive.is([left], dt.VALID); } \
  / left:primary [ ]*"is not valid"[ ]* { return dw.derive.is([left], dt.VALID, false); } \
  / left:primary [ ]*"="[ ]* right:multiplicative { return dw.derive.eq([left, right]); } \
  / left:primary [ ]*"!="[ ]* right:multiplicative { return dw.derive.neq([left, right]); } \
  / "not " primary:primary {return dw.derive.not([primary])} \
  / "!" primary:primary {return dw.derive.not([primary])} \
  / "-" primary:primary {return dw.derive.negate([primary])} \
  / primary \
 \
primary \
  = float \
  / integer \
  / string \
  / function \
  / variable \
  / "(" additive:additive ")" { return additive; } \
 \
float "float" \
 = digits:[0-9]+ "." decimal:[0-9]+ { return dw.derive.constant(parseFloat(digits.join("")+"."+decimal.join("")), dt.type.number()); } \
\
integer "integer" \
  = digits:[0-9]+ { return dw.derive.constant(parseInt(digits.join(""), 10), dt.type.number()); } \
 \
string "string" \
 = quote:[\'\""] chars:[^\'^"]+ otherquote:[\'\""] { return dw.derive.constant(chars.join(""), dt.type.string()); } \
\
function "function" \
  = identifier:identifier "()" {return dw.derive[identifier].apply(null)} \
  / identifier:identifier "(" argumentList:argumentList ")"{ return dw.derive[identifier].apply(null, argumentList); } \
\
variable "variable" \
  = identifier:identifier { return dw.derive.variable(identifier); } \
 \
argumentList \
  =	firstArgument:additive arguments:( [ ]*","[ ]* additive )* { if(arguments) {arguments = arguments.map(function(arg) {return arg[3]}) }; arguments.unshift(firstArgument); return arguments;} \
identifier "identifier" \
  = firstChar:([a-zA-Z]) chars:([a-zA-Z0-9_\.]*) { return firstChar+chars.join(""); } \
');
dw.derive.univariate = function(formula, alias) {
	var fn = {},
		alias = alias || 'x';

	var expression = dw.derive.parse(formula);

	fn.alias = function(x) {
		if(!arguments.length) return alias;
		alias = x;
		return fn;
	}

	fn.expression = function(x) {
		if(!arguments.length) return expression;
		expression = x;
		return fn;
	}


	fn.evaluate = function(x){
		var vals = {};
		vals[alias] = x;
		return expression.evaluate(vals)
	}

	return fn;
};
dw.derive.bivariate = function(formula, xalias, yalias) {
	var fn = {},
		alias = xalias || 'x',
		alias = yalias || 'y';

	var expression = dw.derive.parse(formula);

	fn.xalias = function(x) {
		if(!arguments.length) return xalias;
		xalias = x;
		return fn;
	}

	fn.yalias = function(x) {
		if(!arguments.length) return yalias;
		yalias = x;
		return fn;
	}

	fn.expression = function(x) {
		if(!arguments.length) return expression;
		expression = x;
		return fn;
	}

	fn.evaluate = function(x, y){
		var vals = {};
		vals[xalias] = x;
		vals[yalias] = y;
		return expression.evaluate(vals);
	}

	return fn;
};
dw.derive.empty = function(children) {
	var row = dw.derive.expression([]);
	row.transform = function(values, table) {
		var result = dv.array(table.rows()), r, c, rows = result.length, cols = table.length,
		    num_missing, missing = dt.MISSING;
    for (r = 0; r < rows; ++r) {
      num_missing = 0;
		  for(c = 0; c < cols; ++c) {
			  v = table[c].get(r);
			  if (v === missing) {
			    num_missing++;
		    } else {
		      break
		    }
			}
			if (num_missing == cols) {
			  result[r] = 1;
			} else {
			  result[r] = 0;
			}
		}
		return result;
	}

	return row;
}
dw.derive.index = function(children) {
	var row = dw.derive.expression([]);
	row.transform = function(values, table) {
		var result = d3.range(table.rows());
		result.type = dt.type.integer();
		return result;
	}
	return row;

}
dw.derive.zscore = function(children) {

	var derive = dw.derive.expression(children);

	derive.transform = function(values, table) {
    var mean = dw.derive.avg([]).transform(values, table),
        stdev = dw.derive.stdev([]).transform(values, table), result;
    result = dw.derive.divide([]).transform([dw.derive.subtract([]).transform([values[0], mean]), stdev]);
    result.type = dt.type.number();
    return result;
	}

	return derive;

}
dw.derive.eq = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], y = values[1], length = x.length,
		    i, xval, yval,
		    result = dv.array(length);

		for (i = 0; i < length; ++i) {
		  xval = x.lut ? x.lut[x[i]] : x[i];
		  yval = y.lut ? y.lut[y[i]] : y[i];
		  result[i] = xval === yval;
		}
		return result;
	}
	return compare;
};dw.derive.missing = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], length = x.length,
		    i, xval, missing = dt.MISSING,
		    result = dv.array(length);
		for (i = 0; i < length; ++i) {
		  xval = x[i];
		  result[i] = (xval === missing);
		}
		return result;
	}
	return compare;
};dw.derive.neq = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], y = values[1], length = x.length,
		    i, xval, yval,
		    result = dv.array(length);

		for (i = 0; i < length; ++i) {
		  xval = x.lut ? x.lut[x[i]] : x[i];
		  yval = y.lut ? y.lut[y[i]] : y[i];
		  result[i] = xval != yval;
		}
		return result;
	}
	return compare;
};dw.derive.lt = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], y = values[1], length = x.length,
		    i, xval, yval,
		    result = dv.array(length);

		for (i = 0; i < length; ++i) {
		  xval = x.lut ? x.lut[x[i]] : x[i];
		  yval = y.lut ? y.lut[y[i]] : y[i];
		  result[i] = xval < yval;
		}
		return result;
	}
	return compare;
};dw.derive.lte = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], y = values[1], length = x.length,
		    i, xval, yval,
		    result = dv.array(length);

		for (i = 0; i < length; ++i) {
		  xval = x.lut ? x.lut[x[i]] : x[i];
		  yval = y.lut ? y.lut[y[i]] : y[i];
		  result[i] = xval <= yval;
		}
		return result;
	}
	return compare;
};dw.derive.gt = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], y = values[1], length = x.length,
		    i, xval, yval,
		    result = dv.array(length);

		for (i = 0; i < length; ++i) {
		  xval = x.lut ? x.lut[x[i]] : x[i];
		  yval = y.lut ? y.lut[y[i]] : y[i];
		  result[i] = xval > yval;
		}
		return result;
	}
	return compare;
};dw.derive.gte = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], y = values[1], length = x.length,
		    i, xval, yval,
		    result = dv.array(length);

		for (i = 0; i < length; ++i) {
		  xval = x.lut ? x.lut[x[i]] : x[i];
		  yval = y.lut ? y.lut[y[i]] : y[i];
		  result[i] = xval >= yval;
		}
		return result;
	}
	return compare;
};dw.derive.is = function (children, val, is) {
	var compare = dw.derive.expression(children);
	is = is || true;
	compare.transform = function(values) {
		var x = values[0], length = x.length,
		    i, xval,
		    result = dv.array(length),
		    missing = dt.MISSING, error = dt.ERROR, valid = dt.VALID;
    for (i = 0; i < length; ++i) {
      xval =x[i];
      if (val === valid) {
        result[i] = is ? (xval !== missing && xval !== error) : (xval === missing || xval === error);
      } else {
		    result[i] = is ? (xval === val) : (xval !== val);
      }
		}
		return result;
	}
	return compare;
};dw.derive.and = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], y = values[1], length = x.length,
		    i,
		    result = dv.array(length);

		for (i = 0; i < length; ++i) {
		  result[i] = x[i] && y[i];
		}
		return result;
	}
	return compare;
};dw.derive.or = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], y = values[1], length = x.length,
		    i,
		    result = dv.array(length);

		for (i = 0; i < length; ++i) {
      result[i] = x[i] || y[i];;
		}
		return result;
	}
	return compare;
};dw.derive.not = function (children) {
	var compare = dw.derive.expression(children);
	compare.transform = function(values) {
		var x = values[0], length = x.length,
		    i,
		    result = dv.array(length);

		for (i = 0; i < length; ++i) {
		  result[i] = !x[i];
		}
		return result;
	}
	return compare;
};dw.derive.aggregate = function(children, group) {

	var agg = dw.derive.expression(children);

  group = group || [];

  agg.group = function (x) {
    if(!arguments.length) return group;
    group = x;
    if (typeOf(group) !== 'array') {
      group = [group];
    }
    return agg;
  }

  agg.transform = function(values, table) {



  	var x = values[0], length = x.length, i,
  	    result = dv.array(length), query, query_result,
        table_wrapper = table.copy_shallow(), x_name = (x.name && x.name()) || 'x',
        x = table_wrapper.addColumn(x_name, x, dv.type.numeric), partition, partition_bins;

    query = agg.query([x.name()]);



    partition_bins = [];
    agg.group().map(function(g) {
      var temp_col = g.evaluate(table);
      temp_col = table_wrapper.addColumn('bin', temp_col, dv.type.nominal);
      partition_bins.push(temp_col.name());
    })
    partition = dv.partition(table_wrapper, partition_bins);
    query_result = partition.query(query);
    result = query_result[partition_bins.length];


    result.type = dt.type.number();
    return result;
  }

  agg.group(group)

	return agg;

};
dw.derive.sum = function(children, group) {

	var sum = dw.derive.aggregate(children, group);

	sum.query = function(vals) {
	  return {vals:[dv.sum(vals[0])], bins:[]}
	}

  sum.name = 'sum';

	return sum;

};

dw.derive.avg = function(children, group) {

	var avg = dw.derive.aggregate(children, group);

	avg.query = function(vals) {
	  return {vals:[dv.avg(vals[0])], bins:[]}
	}

	avg.name = 'avg';

	return avg;

};

dw.derive.min = function(children, group) {

	var min = dw.derive.aggregate(children, group);

	min.query = function(vals) {
	  return {vals:[dv.min(vals[0])], bins:[]}
	}

  min.name = 'min';

  return min;

};

dw.derive.max = function(children, group) {

	var max = dw.derive.aggregate(children, group);

	max.query = function(vals) {
	  return {vals:[dv.max(vals[0])], bins:[]}
	}

	max.name = 'max';

	return max;

};

dw.derive.count = function(children, group) {

	var count = dw.derive.aggregate(children, group);

	count.query = function(vals) {
	  return {vals:[dv.count(vals[0])], bins:[]}
	}

	count.name = 'count';

	return count;

};

dw.derive.stdev = function(children, group) {

	var stdev = dw.derive.aggregate(children, group);

	stdev.query = function(vals) {
	  return {vals:[dv.stdev(vals[0])], bins:[]}
	}

	stdev.name = 'stdev';

	return stdev;

};

dw.derive.variance = function(children, group) {

	var variance = dw.derive.aggregate(children, group);

	variance.query = function(vals) {
	  return {vals:[dv.variance(vals[0])], bins:[]}
	}

  variance.name = 'variance';

	return variance;

};

enable_proactive = false;
enable_hyperactive = false;

dw.engine = function(options){
	var engine = {}, options = options || {}, transform_set = options.transform_set || dw.engine.transform_set, corpus = options.corpus || dw.corpus(), workingTransform;

	dw.ivar(engine, [{name:'table', initial:undefined}]);
	dw.ivara(engine, [{name:'inputs', initial:[]}]);

	engine.run = function(k){
		var params = inferSelection().concat(inferRow()).concat(inferCol()).concat(inferEdit());

		var inferredTransforms = inferTransforms(params, k);
		var promotes = filterInputs([dw.engine.promote, dw.engine.param]);





		if (enable_proactive &&
				inferredTransforms.length==1 &&
				((promotes.length==0 && inferredTransforms[0]===undefined) ||
				 (promotes.length > 0))) {
			var nRows = engine._table.rows();
			var nCols = engine._table.cols();

			var stateScore = dw.calc_state_score(engine._table);
			var numUniques = dw.num_unique_elts(engine._table);
			var potentialSuggestions = [];









			var colsToDelSet = {};

			var emptyColNames = [];

			for (var c = 0; c < nCols; c++) {
				var col = engine._table[c];









				var onlyEmptyRowsMissing = true;

				var numMissing = 0;
				for (var r = 0; r < nRows; r++) {
					var elt = col[r];
					if (dw.is_missing(elt)) {
						numMissing++;

						if (onlyEmptyRowsMissing) {
							var rowContents = engine._table.row(r);
							var rowIsEmpty = (rowContents.filter(dw.is_missing).length == rowContents.length);
							if (!rowIsEmpty) {
								onlyEmptyRowsMissing = false;
							}
						}
					}
				}


				if (numMissing == nRows) {

					emptyColNames.push(col.name());



				}
				else {

					if (numMissing >= (nRows / 2)) {

					}

					var hasCommas = false;
					var hasColons = false;
					var hasPipes = false;
					var hasTabs = false;

					col.forEach(function(elt) {
						if (elt) {

							var commas = elt.match(/,/g);
							var colons = elt.match(/\:/g);
							var pipes = elt.match(/\|/g);
							var tabs = elt.match(/\t/g);






							if (commas) hasCommas = true;
							if (colons) hasColons = true;
							if (pipes) hasPipes = true;
							if (tabs) hasTabs = true;
						}
					});








					/* nix this suggestion for now since Jeff thinks it's too brittle
						 and might result in false positives like important rows hidden
						 'below the fold' being erroneously deleted


					if (numMissing > 0 && !onlyEmptyRowsMissing) {


						var nullEltsStr = col.map(dw.is_missing).join();
						if (colsToDelSet[nullEltsStr] === undefined) {
							potentialSuggestions.push(dw.filter().row(dw.row(dw.is_null(col.name))));

							colsToDelSet[nullEltsStr] = 1;
						}
					}
					*/
				}
			}















			for (var r = 0; r < nRows; r++) {
				var rowElts = engine._table.row(r);
				var numMissing = rowElts.filter(dw.is_missing).length;
				var pctMissing = numMissing / rowElts.length;


				if (pctMissing > 0.5 && pctMissing < 1) {





				}
			}





			var foldColNames = engine._table.slice_cols(1, engine._table.cols()).map(function(e) {return e.name()});





			var numFoldedColumns = foldColNames.length;




			if (nRows > 1 && numFoldedColumns > 1) {



				var allHeaderNamesMeaningful = true;

				for (var i = 1; i < nCols; i++) {
					if (!engine._table[i].nameIsMeaningful) {
						allHeaderNamesMeaningful = false;
						break;
					}
				}

				if (allHeaderNamesMeaningful && dw.is_slice_all_valid_and_unique(engine._table[0], 0)) {
					potentialSuggestions.push(dw.fold(foldColNames).keys([-1]));
				}

				if (dw.is_slice_all_valid_and_unique(engine._table[0], 1)) {
					potentialSuggestions.push(dw.fold(foldColNames).keys([0]));
				}
			}
			if (nRows > 2 && numFoldedColumns > 2 &&
					dw.is_slice_all_valid_and_unique(engine._table[0], 2)) {
				potentialSuggestions.push(dw.fold(foldColNames).keys([0, 1]));
			}
			if (nRows > 3 && numFoldedColumns > 3 &&
					dw.is_slice_all_valid_and_unique(engine._table[0], 3)) {
				potentialSuggestions.push(dw.fold(foldColNames).keys([0, 1, 2]));
			}



			if (nCols >= 3 && nCols <= 5) {


				for (var c1 = 0; c1 < nCols; c1++) {
					for (var c2 = 0; c2 < nCols; c2++) {

						if (c1 == c2) {
							continue;
						}

						otherColsIndices = [];
						for (var i = 0; i < nCols; i++) {
							otherColsIndices.push(i);
						}
						otherColsIndices.splice(otherColsIndices.indexOf(c1), 1);
						otherColsIndices.splice(otherColsIndices.indexOf(c2), 1);

						var c1Col = engine._table[c1];
						var c2Col = engine._table[c2];
						var otherCols = otherColsIndices.map(function(c) {return engine._table[c]});

						var c1Summary = dw.summary(c1Col);
						var c2Summary = dw.summary(c2Col);
						var otherColsSummaries = otherCols.map(dw.summary);



						if (c1Summary.missing.length > 0) {
							continue;
						}
						if (otherColsSummaries.filter(function(e) {return (e.missing.length > 0)}).length > 0) {
							continue;
						}



						if (c1Summary.bparse.length > 0) {
							continue;
						}
						if (otherColsSummaries.filter(function(e) {return (e.bparse.length > 0)}).length > 0) {
							continue;
						}

						potentialSuggestions.push(dw.unfold(c1Col.name()).measure(c2Col.name()));
					}
				}
			}



			var scoredCandidates = [];

			for (var i = 0; i < potentialSuggestions.length; i++) {
				var tableCopy = engine._table.slice();
				var curSuggestion = potentialSuggestions[i];
				curSuggestion.apply([tableCopy]);

				var transformType = curSuggestion.description()[0];




				if (transformType == "Unfold") {
					var measureCol = engine._table[curSuggestion._measure];






					var endIdx = tableCopy.cols();

					var flattenedSubmatrix = [];
					for (var c = nCols - 2; c < endIdx; c++) {
						var col = tableCopy[c];


						for (var r = 0; r < tableCopy.rows(); r++) {
							flattenedSubmatrix.push(col[r]);
						}
					}

					var measureColStats = dw.get_column_stats(measureCol, nRows);


					var flattenedSubmatrixStats = dw.get_column_stats(flattenedSubmatrix, flattenedSubmatrix.length);


					var measureColScore = (1 - measureColStats.colHomogeneity) +
																(measureColStats.numMissing / nRows);
					var flattenedSubmatrixScore = (1 - flattenedSubmatrixStats.colHomogeneity) +
																				(flattenedSubmatrixStats.numMissing / flattenedSubmatrix.length);

					/*
					console.log(curSuggestion.description().map(function(e) {
						if (e.description) {
							return e.description();
						}
						else {
							return e;
						}}).join(' '), measureColScore, flattenedSubmatrixScore, flattenedSubmatrixScore - measureColScore);
					*/


					if (flattenedSubmatrixScore <= measureColScore) {
						scoredCandidates.push([flattenedSubmatrixScore - measureColScore, curSuggestion]);
					}
				}
				else {
					var newScore = dw.calc_state_score(tableCopy);
					var newNumUniques = dw.num_unique_elts(tableCopy);

					/*
					console.log(curSuggestion.description().map(function(e) {
						if (e.description) {
							return e.description();
						}
						else {
							return e;
						}}).join(' '), newScore, stateScore - newScore, 'Data loss:', numUniques-newNumUniques);
					*/

					if (newScore < stateScore) {
						scoredCandidates.push([stateScore - newScore, curSuggestion]);
					}
				}
			}


			scoredCandidates.sort(function(a, b) {return b[0] - a[0];});

			params = scoredCandidates.map(function(e) {return e[1];});




			var promotes = filterInputs([dw.engine.promote, dw.engine.param]);
			var promote = promotes[promotes.length-1];
			var workingTransform = (promote && promote.transform);

			if (workingTransform) {

				params.unshift(workingTransform);



				params = params.filter(function(t, i){
					if(i===0 || t===undefined) return true;
					if(params[0] && t.equals(params[0])){
						return false;
					}
					return true;
				});
			}
			else {

				params.unshift(undefined);
			}

			return params;
		}


		return inferredTransforms.slice(0, k);
	}

	engine.input = function(input){
		engine._inputs.push(input)
		return engine;
	}

	engine.restart = function(){

	}

	engine.promoted_transform = function(){
		var promotes = filterInputs([dw.engine.promote, dw.engine.param, dw.engine.filter]), promote = promotes[promotes.length-1];
		return promote && promote.transform;
	}

	var inferTransforms = function(params, k){

		var promotes = filterInputs([dw.engine.promote, dw.engine.param]), promote = promotes[promotes.length-1], transforms = [], tset=transform_set.slice(0);

		workingTransform = (promote && promote.transform)

		if(workingTransform){
			tset = tset.filter(function(t){return t.name!=workingTransform.name})
			tset.unshift(workingTransform)
		}

		transforms = transforms.concat(tset.reduce(function(tforms, t){
			return tforms.concat(params.filter(function(p){return !p.is_transform}).reduce(function(acc, p){
					return acc.concat(inferTransformParameterSet(t, p));
			}, []))
		}, []))

		transforms = params.filter(function(p){return p.is_transform}).concat(transforms)
		transforms = transforms.concat(inferMissing()).concat(inferBadType()).concat(inferBadRole()).concat(inferValid())
		transforms = sortTransforms(transforms)

		/* Hack because working transform is just the first suggestion */
    if (workingTransform) {
      transforms.unshift(workingTransform)
    }

		transforms = varyTransforms(transforms)
		transforms = transforms.slice(0, k).filter(function(t, i){
			if(i===0 || t===undefined) return true;

			if(transforms[0] && t.equals(transforms[0])){
				return false;
			}

			return true;
		})



		if(transforms.length === 1 && transforms[0]===undefined){
			var type = getFilterType();
			if(type)
				transforms = [dw[type]()];
		}

		return transforms;


	}

	var varyTransforms = function(transforms){
		var counts = {}, all_counts = {}, remaining_counts = {}, current, currentCount, filterType = getFilterType(), variedTransforms = [],
			exemptName = filterType || (workingTransform && workingTransform.name), maxCount = Math.max(Math.ceil(Math.min(6, transforms.length)*.33), 6);



		var total_count = 0;

		for(var i = 0; i < transforms.length; ++i){
			current = transforms[i];
			if(current===undefined){

			}
			else{
				currentCount = all_counts[current.name] || 0;
				if(current.name === exemptName){
					total_count++;
				}
				else{
					all_counts[current.name] = ++currentCount;
					if(currentCount <= maxCount){
						total_count++;
					}
				}
			}
		}

		/* Change 6 to a variable to control number of suggestions...here 6 is max number of suggestions*/
		var remaining_count = 6 - total_count;


		for(var i = 0; i < transforms.length; ++i){
			current = transforms[i];
			if(current === undefined){
				variedTransforms.push(current)
			}
			else{
				currentCount = counts[current.name] || 0;
				if(current.name === exemptName){
					variedTransforms.push(current);
				}
				else{
					counts[current.name] = ++currentCount;
					if(currentCount <= maxCount){
						variedTransforms.push(current)
					}
					else{
						if(remaining_count > 0){
							remaining_count--;
							variedTransforms.push(current)
						}
					}
				}
			}
		}
		return variedTransforms;
	}

	var getFilterType = function(){
		var filters = filterLatestInputs(dw.engine.filter), filter = filters[filters.length-1], filterType = (filter ? filter.transform : undefined);
		return filterType;
	}

	var sortTransforms = function(transforms){
		var inputs = getSelectionRecords();
		transforms.forEach(function(t){
			t.weights = {};
			t.weights.tf = corpus.frequency(t, {inputs:inputs});
			t.weights.td = transformDifficulty(t)
			t.weights.tdl = transformDescriptionLength(t)
			if(workingTransform) t.weights.wts = workingTransform.similarity(t)
		})

		var aw, bw, filterType = getFilterType();


		transforms.sort(function(a, b){
			aw = a.weights; bw = b.weights;
			if(workingTransform){
				if(a.name === workingTransform.name && b.name != workingTransform.name) return -1;
				if(b.name === workingTransform.name && a.name != workingTransform.name) return 1;
				if(a.name === workingTransform.name && b.name === workingTransform.name){
					var as = aw.wts, bs = bw.wts;
					if(as > bs) return -1;
					if(bs > as) return 1;
				}

			}

			if(filterType){
				if(a.name === filterType && b.name != filterType) return -1;
				else if(b.name === filterType && a.name != filterType) return 1;
			}



			if(aw.td > bw.td) return -1; if(bw.td > aw.td) return 1;
			if(aw.tf > bw.tf) return -1; if(bw.tf > aw.tf) return 1;
			if(aw.tdl < bw.tdl) return -1; if(bw.tdl < aw.tdl) return 1;
			return 0;
		})

		return transforms

	}


	var transformDescriptionLength = function(t){
		return t.description_length();
	}

	var transformDifficulty = function(t){
		switch(t.name){
			case dw.transform.SPLIT:
			case dw.transform.CUT:
			case dw.transform.EXTRACT:
			case dw.transform.FILTER:
				return 1;
			default:
				return 0;
		}
	}




	var inferTransformParameterSet = function(transform, param){



		if(param.is_transform) return [param]

		var t = transform.clone();

		var keys = d3.keys(param), p, neededParams;




		for(var i = 0; i < keys.length; ++i){
			p = keys[i];

			if(!t.has_parameter(p)) return [];
			try{
				t[p](param[p]);
			}
			catch(e){
				console.error(e)
			}

		}






		neededParams = t.enums().filter(function(x){return keys.indexOf(x)===-1})
		var top = corpus.top_transforms({transform:t, given_params:keys, needed_params:neededParams, table:engine._table})

		var promoted = engine.promoted_transform();
		if(promoted && promoted === t.name){
			return top.slice(0, 30);
		}
		else{
			return top.slice(0, 30).filter(function(x){return x.well_defined(engine._table)})
		}



	}

	var inferMissing = function(){
		var inputs = filterLatestInputs(dw.engine.missing_bar), col, candidates = [];


		if(inputs.length){
			col = inputs[inputs.length-1].col;

			candidates.push(dw.fill(engine._table[col].name()))
			candidates.push(dw.fill(engine._table[col].name()).direction(dw.UP))
			candidates.push(dw.filter(dw.is_null(engine._table[col].name())))
		}

		return candidates;
	}

	var inferValid = function(){
		var inputs = filterLatestInputs(dw.engine.valid_bar), col, candidates = [];

		if(inputs.length){
			col = inputs[inputs.length-1].col;
			candidates.push(dw.filter(dw.is_valid(engine._table[col].name())))
		}

		return candidates;
	}

	var inferBadRole = function(){
		var inputs = filterLatestInputs(dw.engine.bad_role_bar), col, candidates = [];

		if(inputs.length){
			col = inputs[inputs.length-1].col;
			candidates.push(dw.filter(dw.matches_role(engine._table[col].name())))
		}

		return candidates;
	}

	var inferBadType = function(){
		var inputs = filterLatestInputs(dw.engine.bad_type_bar), col, candidates = [];

		if(inputs.length){
			col = inputs[inputs.length-1].col;
			candidates.push(dw.filter(dw.matches_type(engine._table[col].name(), engine._table[col].type)))
		}

		return candidates;
	}

	var inferRow = function(){
		var inputs = filterLatestInputs(dw.engine.row), parameters = [], rows, candidates;


		if(inputs.length){
			rows = inputs[inputs.length-1].rows
		 	candidates = dw.row_inference().candidates(engine.table(), inputs[inputs.length-1].rows);
			parameters = candidates;

		}

		return parameters;
	}

	var inferEdit = function(){
		var inputs = filterLatestInputs(dw.engine.edit), parameters = [], rows, candidates;


		if(inputs.length){
			candidates = dw.edit_inference().candidates(engine.table(), inputs);
			parameters = candidates;
		}



		return parameters;
	}

	var inferCol = function(){
		var inputs = filterLatestInputs(dw.engine.col), parameters = [], names;
		if(inputs.length){

			names = inputs[inputs.length-1].cols.map(function(c){
				return engine._table[c].name()
			});

			if(names.length	 > 0){
				parameters.push({column:names})
				if(names.length === 2){
					parameters.push({column:[names[0]], measure:names[1]})
					parameters.push({column:[names[1]], measure:names[0]})
				}
			}
		}

		return parameters;
	}

	var getSelectionRecords = function(inputs){
		inputs = inputs || filterLatestInputs(dw.engine.highlight);

		if(inputs && inputs.length){
			var selection, row, col, text, start, end, position, records, table = engine.table();
			return inputs.map(function(input, i){
				row = input.position.row, col = input.position.col, text = engine._table[col].get_raw(row), start = input.selection.startCursor, end = input.selection.endCursor;
				return {type:dw.engine.highlight, params:dw.regex.record(text, start, end, table[col].name(), row, table)};
			})
		}

		inputs =  filterLatestInputs(dw.engine.row);
		if(inputs && inputs.length){
			return inputs.map(function(i){
				return {type:dw.engine.row, params:{rows:i.rows, table: engine.table()}}
			})
		}

		inputs =  filterLatestInputs(dw.engine.col);
		if(inputs && inputs.length){
			return inputs.map(function(i){
				return {type:dw.engine.col, params:{cols:i.cols, table: engine.table()}}
			})
		}
	}



	var inferSelection = function(){

		var inputs = filterLatestInputs(dw.engine.highlight),
			selection, row, col, text, start, end, position, records, table = engine.table();

		if(!inputs.length) return []




		records = inputs.map(function(input, i){
			row = input.position.row, col = input.position.col, text = engine._table[col].get_raw(row), start = input.selection.startCursor, end = input.selection.endCursor;
			return dw.regex.record(text, start, end, table[col].name(), row, table);
		})



		var candidates = dw.regex().candidates(records);


		if(inputs.length === 1 || candidates.length < 2){
			candidates.unshift({positions:[inputs[inputs.length-1].selection.startCursor, inputs[inputs.length-1].selection.endCursor]})
		}

		var startRecord = records.length-1;

		while(candidates.length<3 && startRecord > 0){
			candidates = dw.regex().candidates(records.slice(records.length-startRecord))
			startRecord-=1;
		}




		var column = inputs[inputs.length-1].position.col
		column = engine._table[column].name();
		candidates.forEach(function(c){
			c.column = column
		})

		candidates = candidates.concat(dw.row_inference().candidates(engine.table(), records, {type:dw.engine.highlight}))



		return candidates;
	}

	var filterLatestInputs = function(type, o){
		var o = o || {}, inputs = engine._inputs, clear_index = inputs.length-1, clearTypes = o.clear_types || [type, dw.engine.filter, dw.engine.promote, dw.engine.param];
		while(clear_index >= 0){
			if(clearTypes.indexOf(inputs[clear_index].type)===-1){
				break;
			}
			clear_index--;
		}

		return engine._inputs.slice(clear_index+1).filter(function(i){
			return i.type === type;
		})
	}




	var filterInputs = function(type, o){

		var o = o || {}, inputs = engine._inputs, clear_index = inputs.length-1, clearTypes = o.clear_types || [dw.engine.execute, dw.engine.clear];

		if(typeOf(type)!='array') type = [type];

		while(clear_index >= 0){
			if(clearTypes.indexOf(inputs[clear_index].type)!=-1){
				break;
			}
			clear_index--;
		}

		return engine._inputs.slice(clear_index+1).filter(function(i){
			return type.indexOf(i.type)!=-1;
		})
	}


	return engine;
}

dw.engine.transform_set = [
	dw.split(),

	dw.extract(),
	dw.cut(),
	dw.fill(),
	dw.fold(),
	dw.merge(),
	dw.filter(),
	dw.drop(),
	dw.unfold(),
	dw.promote(),


	dw.copy()
]

dw.engine.highlight = 'text_select';
dw.engine.edit = 'text_edit';
dw.engine.row = 'row_select';
dw.engine.col = 'col_select';
dw.engine.filter = 'type_select';
dw.engine.transform = 'transform_select';
dw.engine.execute = 'execute_transform';
dw.engine.promote = 'promote_transform';
dw.engine.clear = 'clear_transform';
dw.engine.missing_bar = 'missing';
dw.engine.bad_type_bar = 'bparse';
dw.engine.bad_role_bar = 'brole';
dw.engine.valid_bar = 'bvalid';

dw.engine.param = 'param_edit';




dw.calc_state_score = function(table) {
	var sumHomo = 0;
	var totalDelims = 0;
	var totalMissing = 0;
	var totalElts = 0;
	var nCols = table.cols();

	for (var c = 0; c < nCols; c++) {
		var col = table[c];
		var colStats = dw.get_column_stats(col, table.rows());

		sumHomo += colStats.colHomogeneity;




		totalElts += table.rows();

		totalMissing += colStats.numMissing;
		totalDelims += colStats.numDelims;
	}



	var avgHomo = sumHomo / nCols;
	var pctMissing = totalMissing / totalElts;


	var avgDelims = 0;
	if (totalMissing < totalElts) {
		avgDelims = totalDelims / (totalElts - totalMissing);
	}





	var stateScore = (1-avgHomo) + pctMissing + avgDelims;



	return stateScore;
}





dw.get_column_stats = function(col, nRows) {
	var numMissing = 0;
	var numDates = 0;
	var numNumbers = 0;
	var numStrings = 0;

	var numCommas = 0;
	var numColons = 0;
	var numPipes = 0;
	var numTabs = 0;


	for (var r = 0; r < nRows; r++) {
		var elt = col[r];







		if (dw.is_missing(elt)) {
			numMissing++;
		}
		else if (dw.date_parse(elt)) {
			numDates++;
		}
		else if (!isNaN(Number(elt))) {
			numNumbers++;
		}










		if (elt) {
			var commas = elt.match(/,/g);
			var colons = elt.match(/\:/g);
			var pipes = elt.match(/\|/g);
			var tabs = elt.match(/\t/g);






			if (commas) numCommas += commas.length;
			if (colons) numColons += colons.length;
			if (pipes) numPipes += pipes.length;
			if (tabs) numTabs += tabs.length;
		}
	}
	numStrings = nRows - numMissing - numNumbers - numDates;

	var numRealElts = nRows - numMissing;


	var colHomogeneity = 0;


	var pctDates = numDates / nRows;
	var pctNumbers = numNumbers / nRows;
	var pctStrings = numStrings / nRows;


	/*
	if (numRealElts > 0) {
		var pctDates = numDates / numRealElts;
		var pctNumbers = numNumbers / numRealElts;
		var pctStrings = numStrings / numRealElts;
	}
	*/

	colHomogeneity = pctDates*pctDates + pctNumbers*pctNumbers + pctStrings*pctStrings;

	return {colHomogeneity: colHomogeneity,
					numMissing:     numMissing,
					numDelims:      numCommas+numColons+numPipes+numTabs};
}



dw.num_unique_elts = function(table) {
	var numUniques = 0;
	var uniques = {};
	for (var c = 0; c < table.cols(); c++) {
		var col = table[c];
		for (var r = 0; r < table.rows(); r++) {
			var elt = col[r];

			if (!dw.is_missing(elt) && uniques[elt] != 1) {
				numUniques++;
				uniques[elt] = 1;
			}
		}
	}

	return numUniques;
}



dw.is_slice_all_valid_and_unique = function(lst, i) {
	lst = lst.slice(i);
	var uniques = {};
	lst.forEach(function(e) {

		if (dw.is_missing(e)) {
			return false;
		}
		uniques[e] = 1;
	});
	var numUniques = 0;
	for (e in uniques) numUniques++;
	return (numUniques == lst.length);
}

dw.summary = function(col){
	var type = col.type || dt.type.string(), badParse = [], badRole = [], missing = [], valid = [], unique = {};

	for(var i = 0; i < col.length; ++i){
		var v = col.get(i);
		var vwrap = {index:i, value:v}
		if(dt.is_missing(v)){
			missing.push(i)
		}
		else if(type.parse(v)===undefined){
			badParse.push(i)
		}
		else{
			valid.push(i)
		}
		unique[v] = 1;
	}

	return {missing:missing, bparse:badParse, brole:badRole, valid:valid, unique:unique};
};
dw.row_inference = function(){
	var r = {};

	r.candidates = function(table, records, o){

		o = o || {}
		var type = o.type || dw.engine.row, candidates = [];

		if(records.length){
			switch(type){
				case dw.engine.row:

					var index = dw.row(dw.rowIndex(records).formula());
					candidates.push({row:index})
					candidates.push({keys:records})
					if(records.length===1){
						candidates.push({header_row:records[0]})
					}
          candidates = candidates.concat(enumerateEmpty(table, records))
          candidates = candidates.concat(enumerateRowEquals(table, records))


					return candidates;

				case dw.engine.highlight:
          return [];
					records = records.filter(function(r){return r.text.length > 0});

					candidates = candidates.concat(enumerateEquals(table, records))
					candidates = candidates.concat(enumerateStartsWith(table, records))
					candidates = candidates.concat(enumerateContains(table, records))

					return candidates;
			}
		}


		return []

	}


	var enumeratePromote = function(table, records, o){
		var candidates = [];
		if(records.length === 1){
			var r = records[0];
			if(r < 5){

			}
		}
		return candidates.map(function(c){return {row:c}});
	}


	var enumerateRowEquals = function(table, records, o){
		var candidates = [];
		if(records.length){
			table.forEach(function(col){
				var val = col.get_raw(records[records.length-1]);
				if(val)
          candidates = candidates.concat([dw.row(col.name() + " = '" + val + "'")])

				else{
          candidates = candidates.concat([dw.row(col.name() + " is missing ")])

				}
			})
		}

		candidates = candidates.filter(function(c){
			var tester = c.tester([table])
			for(var i = 0; i < records.length; ++i){
				if(tester.test(table, records[i])===0){
					return false;
				}
			}
			return true;
		})
		return candidates.map(function(c){return {row:c}});
	}

	var enumerateRowCycle = function(table, records, o){

		if(records.length >= 2){
			var sortedRecords = records.slice().sort(function(a,b){return a-b > 0});
			var difference = sortedRecords[1]-sortedRecords[0];

			if(difference===1) return [];

			for(var i = 1; i < sortedRecords.length - 1; ++i){
				if(sortedRecords[i+1]-sortedRecords[i]!=difference){
					return []
				}
			}

			var all = dw.row(dw.rowCycle(difference, sortedRecords[0]%difference))



			var t = [all].reverse()

			return t.map(function(x){return {row:x}})

		}

		return [];




	}


	var enumerateEquals = function(table, records, o){
		if(records.length > 0){
			var record = records[records.length-1];
			if(record.start === 0 && record.end === record.text.length){
				var t = dw.row(dw.eq(record.col, record.text.substring(record.start, record.end), true));
				return [{row:t}]

			}
		}
		return []
	}



	var enumerateStartsWith = function(table, records, o){

		if(records.length > 0){
			var record = records[records.length-1];

			if(record.start === 0){
				var t = dw.row(dw.starts_with(record.col, record.text.substring(record.start, record.end), true));
				return [{row:t}]
			}
		}
		return []

	}

	var enumerateContains = function(table, records, o){

		if(records.length > 0){
			var record = records[records.length-1];
			var t = dw.row(dw.contains(record.col, record.text.substring(record.start, record.end), true));
			return [{row:t}]

		}
		return []

	}


	var enumerateIsNull = function(table, records, o){

	}



	var enumerateEmpty = function(table, records, o){
		var t = dw.row(dw.empty().formula()).tester([table]);
		for(var i = 0; i < records.length; ++i){
			if(!t.test(table, records[i])){
				return []
			}
		}
		return [{row:dw.row(dw.empty().formula())}]
	}


	return r;
}
dw.regex = function(){
	var r = {};

	var numberRecord = function(m){


		/*TODO: Add regex such as #of digits or range of digits*/
		var r = [
			new RegExp(m),
			/\d+/
		];
		return r;
	}

	var stringRecord = function(m){


		/*TODO: Add conditional regex such as UPPERCASE, LOWERCASE, or paramterized by length of word*/
		var r = [
			new RegExp(m),
			/[a-zA-Z]+/
		];

		if(m.toLowerCase()===m){
			r.push(/[a-z]+/)
		}
		else if(m.toUpperCase()===m){
			r.push(/[A-Z]+/)
		}
		return r;

	}

	var symbolRecord = function(m){
		var regex

		if(['|'].indexOf(m)!=-1){
			m = '\\'+m
		}

		if (m == '.') {
			m = '\\.';
		}

		try{
			regex = new RegExp(m);
		}
		catch(e){
			regex = new RegExp('\\'+m);
		}

		var r = [
			regex
		];
		return r;
	}


	r.candidates = function(records, o){

		if(records.length){
			var enumerations = r.parse(records[0].text, records[0].start, records[0].end),
				tests = records.slice(0), on, between, match, candidates;




			on = (enumerations.on || []).map(function(c){
				return {on:c}
			});


			var before = enumerations.before, after = enumerations.after;



			if(before === undefined || before.length === 0){
				between = after.map(function(a){return {after:a, on:/.*/}});
			}
			else if(after === undefined || after.length === 0){
				between = before.map(function(a){return {before:a,on:/.*/}});
			}
			else{
				between = (before||[]).reduce(function(x, b){
					return x.concat((after||[]).map(function(a){
						return {before:b, after:a, on:/.*/}
					}))
				}, [])
			}





			candidates = on.concat(between);


			if(tests.length===0) return candidates;

			candidates = candidates.filter(function(candidate){
				return tests.filter(function(test){
					match = dw.regex.match(test.text, candidate);
					return(match.length < 2 || match[1].start!=test.start||match[1].end!=test.end)
				}).length===0
			})
			return candidates
		}

		return []

	}

	var collapse = function(regexArray){
		var joined = regexArray.map(function(r){
			return r.toString().replace(/^\/|\/$/g,'')
		}).join('')

		return new RegExp(joined)
	}


	r.parse = function(str, startCursor, endCursor, o){
		str = ''+str

		var token = /([a-zA-Z]+)|([0-9]+)|([^a-zA-Z0-9])/g;

		var match = (str.substring(0, startCursor).match(token) || [])
					.concat(str.substring(startCursor, endCursor).match(token) || [])
					.concat(str.substring(endCursor).match(token) || [])



		var	o = o || {}, code, records, startIndex, endIndex, index = 0,
			on, before, after,
			matchAfter = o.matchAfter||3, matchBefore=o.matchBefore||3; /*candidates*/



		match = match.filter(function(m){return m!=null})



		records = match.map(function(m, ind){
			code = m.charCodeAt(0);
			if(startCursor >= index && startCursor < index+m.length){
				startIndex = ind;
			}
			if(endCursor > index && endCursor <= index+m.length){
				endIndex = ind;
			}
			index+=m.length;

			if((code > 64 && code < 91) || (code > 96 && code < 123)){
				return stringRecord(m);
			}else if(code > 47 && code < 58){
				return numberRecord(m);
			}
			else{
				return symbolRecord(m);
			}
		})




		if(startIndex===undefined) startIndex = match.length-1;
		if(endIndex===undefined) endIndex = match.length-1


		on = records.slice(startIndex, endIndex+1).reduce(function(a, b){
			var cross = [];
			a.forEach(function(i){
				b.forEach(function(j){
					cross.push(i.concat(j))
				})
			})
			return cross;
		}, [[]])




		var enumerate = function(a, b){
			var cross = [];
			if(a.length){
				a.forEach(function(i){
					b.forEach(function(j){
						cross.push(i.concat(j))
					})
				})
				return a.concat(cross);
			}
			else{
				return b.map(function(j){
					return [j];
				})
			}
		}




			after = records.slice(Math.max(startIndex-matchAfter-1, 0), startIndex).reverse().reduce(enumerate, [])

			before = records.slice(endIndex+1, Math.min(endIndex+matchBefore+1, records.length)).reduce(enumerate, [])




		return {on:on.map(collapse), after:(after||[]).map(function(x){return collapse(x.reverse())}), before:(before||[]).map(function(x){return collapse(x)})}

	}

	return r;
}

dw.regex.record = function(text, start, end, col, row, table){
	return {text:text, start:start, end:end, col:col, row:row, table:table}
}

dw.regex.friendly_description = function(regex){

	var regex = regex.toString().replace(/^\/|\/$/g,'')
	regex = regex.replace(/\n/g, 'newline')
	regex = regex.replace(/ /g, ' ')
	regex = regex.replace(/\t/g, 'tab')
	regex = regex.replace(/\(?(\[0\-9\]|\\d)\+\)?/g, ' any number ')
	regex = regex.replace(/\(?(\[a\-z\A\-Z\]|\[A\-Z\a\-\z\])\+\)?/g, ' any word ')
	regex = regex.replace(/\(?(\[a\-z\])\+\)?/g, ' any lowercase word ')
	regex = regex.replace(/\(?(\[A\-Z\])\+\)?/g, ' any uppercase word ')
	regex = regex.replace(/\$$/, '{end}')
	regex = regex.replace(/^\^/, '{begin}')

	regex = regex.replace('\\','')


	if(regex === 'newline') return regex

	return "'"+regex+"'";
}

dw.regex.description_length = function(regex){
	if(!regex) return 0;

	regex = regex.toString().replace(/^\/|\/$/g,'');







	regex = regex.replace(/\\n/g, 'n')
	regex = regex.replace(/ /g, ' ')
	regex = regex.replace(/\t/g, 't')
	regex = regex.replace(/\(?(\[0\-9\]|\\d)\+\)?/g, 'n')
	regex = regex.replace(/\(?(\[A\-Z\])\+\)?/g, ' w')
	regex = regex.replace(/\(?(\[a\-z\])\+\)?/g, 'w')
	regex = regex.replace(/\(?(\[a\-z\A\-Z\]|\[A\-Z\a\-\z\])\+\)?/g, 'w')
	regex = regex.replace(/\$$/, 'e')
	regex = regex.replace(/^\^/, 'b')
	regex = regex.replace('\\','')

	var match = regex.match(/([a-zA-Z]+)|([0-9]+)|([^a-zA-Z0-9])/g)

	return match.length+1


	return regex.length;
}
dw.regex.match = function(value, params){

	if(!value) return ""

	var max_splits = params.max_splits;
	if(max_splits===undefined) max_splits = 1;

	var remainder_to_split = {start:0, end:value.length,value:value}
	var splits = []
	var numSplit = 0;
	var which = Number(params.which)
	if(isNaN(which)) which = 1

	while(max_splits <= 0 || numSplit < max_splits*which){
		var s = dw.regex.matchOnce(remainder_to_split.value, params)

		if(s.length > 1){

				remainder_to_split = s[2];
				splits.push(s[0])
				splits.push(s[1])
				occurrence = 0


		}
		else{
			break
		}
		numSplit++;
		if(numSplit > 1000){

			break;
		}
	}

	splits.push(remainder_to_split)




	var occurrence = 0;
	var newSplits = []
	var prefix = ''
	var i;
	for(i = 0; i < splits.length; ++i){
		if(i%2===1){
			occurrence++;
			if(occurrence===which){
				newSplits.push({value:prefix, start:0, end:prefix.length})
				newSplits.push({start:prefix.length, end:prefix.length+splits[i].value.length, value:splits[i].value})
				occurrence = 0;
				prefix = ''
				continue
			}
		}
		prefix += splits[i].value
	}
	newSplits.push({start:0, end:prefix.length, value:prefix})



	return newSplits;
}

dw.regex.matchOnce = function(value, params){

	var positions = params.positions;
	var splits = [];

	if(positions && positions.length){
		if(positions.length==2){
			if(value.length >= positions[1]){
				var split_start = positions[0]
				var split_end = positions[1]
				splits.push({start:0, end:split_start, value:value.substr(0, split_start)});
				splits.push({start:split_start, end:split_end, value:value.substr(split_start, split_end-split_start)})
				splits.push({start:split_end, end:value.length, value:value.substr(split_end)})

				return splits;
			}
			return [{start:0, end:value.length, value:value}]

		}
	}




	var before = params.before;
	var after = params.after;
	var on = params.on
	var ignore_between = params.ignore_between;


	var remainder = value;
	var remainder_offset = 0;
	var start_split_offset = 0;
	var add_to_remainder_offset = 0;


	while(remainder.length){

		var valid_split_region = remainder;
		var valid_split_region_offset = 0;


		start_split_offset = remainder_offset;


		if(ignore_between){

			var match = remainder.match(ignore_between);
			if(match){

				valid_split_region = valid_split_region.substr(0, match.index)
				remainder_offset += match.index+match[0].length;
				remainder = remainder.substr(match.index+match[0].length)

			}
			else{
				remainder = ''
			}

		}
		else{
			remainder = ''
		}

		if(after){
			var match = valid_split_region.match(after)
			if(match){
				valid_split_region_offset = match.index+match[0].length;
				valid_split_region = valid_split_region.substr(valid_split_region_offset)

			}
			else{
				continue;
			}
		}
		if(before){
			var match = valid_split_region.match(before)
			if(match){
				valid_split_region = valid_split_region.substr(0, match.index)
			}
			else{
				continue;
			}
		}


		var match = valid_split_region.match(on)
		if(match){

			var split_start = start_split_offset + valid_split_region_offset+match.index;
			var split_end = split_start + match[0].length;

			splits.push({start:0, end:split_start, value:value.substr(0, split_start)});
			splits.push({start:split_start, end:split_end, value:value.substr(split_start, split_end-split_start)})
			splits.push({start:split_end, end:value.length, value:value.substr(split_end)})
			return splits;

		}
		continue;

	}

	return [{start:0, end:value.length, value:value}]


}
dw.view.suggestions = function(container, opt) {
  opt = opt || {};
  var view = {}, vis,
      suggestions,
      suggestion_view = opt.type || dw.view.suggestion.text,
      selected_suggestion_index;

  view.initUI = function() {
    jQuery(container).empty();
    vis = d3.select(container[0])
            .append('div');
   };

  view.suggestions = function(x) {
    if (!arguments.length) return suggestions;
    suggestions = x;
    return view;
  }

  view.highlight_suggestion = function(x) {
    selected_suggestion_index = x;
    vis.selectAll('div.suggestion')
        .classed("selected_suggestion", function(d, i) {
            return i === selected_suggestion_index;
        })
  }

  view.update = function() {
    var idx, suggestion_containers;
    jQuery(vis[0]).empty();
    idx = d3.range(suggestions.length);

    function suggestion_clicked(d, i) {
      opt.onclick(i);
    }

    suggestion_containers = vis.selectAll('div.suggestion')
               .data(idx)
               .enter().append('div')
               .attr('class', 'suggestion')
               .classed("selected_suggestion", function(d, i) {
                 return i === selected_suggestion_index;
               })
               .on('click', suggestion_clicked)

    suggestion_containers.each(function(i) {
      var suggestion = suggestion_view(jQuery(this))
      suggestion.suggestion(suggestions[i])
      suggestion.initUI();
      suggestion.update();
    })
  }

  return view;
};

dw.view.related_view_type = undefined;
dw.view.grouped_suggestions = function(container, opt) {
  opt = opt || {};
  var view = {}, vis,
      suggestions,
      suggestion_view = opt.type || dw.view.suggestion.text,
      selected_suggestion_index;

  view.initUI = function() {

    vis = d3.select(container[0])
            .append('div');
   };

  view.suggestions = function(x) {
    if (!arguments.length) return suggestions;
    suggestions = x;
    return view;
  }

  view.highlight_suggestion = function(x) {
    selected_suggestion_index = x;
    vis.selectAll('div.suggestion')
        .classed("selected_suggestion", function(d, i) {
            return i === selected_suggestion_index;
        })
  }

  view.update = function() {
    var idx, suggestion_containers;
    jQuery(vis[0]).empty();

    function switch_related(d, i) {
      opt.onswitchtype(d);
    }


    function draw_related_options(related_container) {
      var related_type_select = dv.jq('select').attr('id', 'related_type_select');

      related_container.append(dv.jq('div').addClass('related_views_title')
         .text("Related Views:"))



      related_container.append(related_type_select);



      related_container.append(dv.jq('div').addClass('browser_title')
         .text("Anomaly Browser"))

      add_option = function(type, name) {
    		dv.add_select_option(related_type_select, name, type);
    	}

    	related_type_select.change(function() {
      dw.view.related_view_type = related_type_select.val().toLowerCase();
        opt.onswitchtype(related_type_select.val())
    	})
      var items = ['None', 'Anomalies', 'Data Values'];
      items.forEach(function(ex) {
        add_option(ex, ex);
      })
    }
    function draw_table_options(related_container) {
      var related_type_select = dv.jq('select').attr('id', 'table_type_select');
      related_container.append(related_type_select);

      add_option = function(type, name) {
    		dv.add_select_option(related_type_select, name, type);
    	}

    	related_type_select.change(function() {
      dw.view.related_view_type = related_type_select.val().toLowerCase();
        opt.onswitchtype(related_type_select.val())
    	})

      add_option(undefined, 'Hide Table');
      ['Show Table'].forEach(function(ex) {
        add_option(ex, ex);
      })
    }

















    function suggestion_clicked(d, i) {
      opt.onclick(i);
    }

    var grouped_suggestions = [];
    suggestions.map(function(s) {
      if (!grouped_suggestions[s.group]) {
        grouped_suggestions[s.group] = [];
      }
      grouped_suggestions[s.group].push(s);
    })

    d3.keys(grouped_suggestions).map(function(k) {
      grouped_suggestions.push(grouped_suggestions[k])
    })

    idx = d3.range(grouped_suggestions.length);

    suggestion_groups = vis.selectAll('div.suggestion_group')
               .data(idx)
               .enter().append('div')
               .attr('class', 'suggestion_group')
              .classed('selected_group', function(d) {return d === 0})


    function switch_group(d, i) {
      jQuery(d3.event.currentTarget).parent().toggleClass('selected_group')
    }

    suggestion_groups.append('div')
                  .attr('class', 'group_type')
                  .text(function(d) {return grouped_suggestions[d][0].group + " (" + grouped_suggestions[d].length + ")"})
                  .on('click', switch_group)



    suggestion_groups.selectAll('div.suggestion')
               .data(function(d) {return grouped_suggestions[d]})
               .enter().append('div')
               .attr('class', 'suggestion')

    suggestion_containers = vis.selectAll('div.suggestion')
               .classed("selected_suggestion", function(d, i) {
                 return i === selected_suggestion_index;
               })
               .on('click', suggestion_clicked)


    suggestion_containers.each(function(d, i) {
      var suggestion = suggestion_view(jQuery(this), {suggest:suggestion_clicked})
      suggestion.suggestion(d)
      suggestion.initUI();
      suggestion.update();
    })
  }

  return view;
};
dw.view.suggestion = function(container, opt) {
  var view = {}, vis,
      suggestion;

  view.initUI = function() {
    jQuery(container).empty();
    vis = d3.select(container[0])
            .append('div');
   };

  view.vis = function() {
    return vis;
  }

  view.suggestion = function(x) {
    if (!arguments.length) return suggestion;
    suggestion = x;
    return view;
  }

  view.update = function() {
      vis.append('div')
         .text('Suggestion!')
  }

  return view;
};
dw.view.suggestion.text = function(container, opt) {
  var view = dw.view.suggestion(container, opt)

  view.update = function() {
    var suggestion = view.suggestion(),
        vis = view.vis();

    if (!suggestion) {
      return;
    }

    dw.transform.description(vis.append('div'), suggestion, {}).update()

  }

  return view;
};
/*
* spreadsheet: the spreadsheet to draw the preview on
*
* transform: the transform to preview
* after_table_container: the container display an after table in
* table_selection: object that controls spreadsheets table selections
*/
/*
 *
 *
 */
dw.view.preview = function(spreadsheet, transform, after_spreadsheet, table_selection){
	var chart = spreadsheet.chart(),
	    data = chart.data(),
	    after_chart = after_spreadsheet.chart(),
	    visible_rows = chart.visible_rows(),
	    start_row = Math.max(0, visible_rows[0]), end_row = Math.max(0, visible_rows[1]),
	    sample = data.slice(),
	    wrangler = dw.wrangle(),
	    tableNames = data.schema(),
	    inputColumn,
	    original, updated, colIndex,
	    old_drop, spreadsheet_container = jQuery(chart.container()[0]),
	    after_spreadsheet_container = jQuery(after_chart.container()[0]);

  function cells(x) {

    var cell_chart = x.chart || chart;
    if ((x.rows && x.rows.length) || (x.cols && x.cols.length)) {
      if (x.rows && x.rows.indexOf(-1) > -1) x.header = true;
      return cell_chart.cells(x)
    }
    return d3.select();
  }

  reset_tables();


  function reset_tables() {
    jQuery("#playground_after_table_container").addClass('hidden')
    spreadsheet_container.removeClass('previewBeforeTable').removeClass('updatedTable')
  	after_spreadsheet_container.removeClass('previewAfterTable')
  }

	if(transform){
    old_drop = transform.drop();
		transform.drop(false);
		if(transform.name===dw.transform.CUT) transform.update(false)
		var tstats = transform.apply([sample], {max_rows:1000, start_row:start_row, end_row:end_row}),
			newCols = tstats.newCols || [],
			updatedCols = tstats.updatedCols || [],
			droppedCols = tstats.droppedCols || [],
			toValueCols = tstats.toValueCols || [],
			toHeaderCols = tstats.toHeaderCols || [],
			toKeyRows = tstats.toKeyRows || [],
			keyRows = tstats.keyRows || [],
			valueCols = tstats.valueCols || [],
			keyCols = tstats.keyCols || [],
			newTables = tstats.newTables || [],
			valueStats = tstats.valueStats || [],
			promoteRows = tstats.promoteRows || [],
			splits = valueStats.map(function(v){if(v) return v[0] && v[0].splits})
			filteredRows = tstats.effectedRows || [], columnTable = sample;

		if(transform.name===dw.transform.CUT) transform.update(true)
		switch(transform.name){
			case dw.transform.FOLD:
			case dw.transform.UNFOLD:
			case dw.transform.WRAP:
			case dw.transform.TRANSPOSE:
				spreadsheet_container.addClass('previewBeforeTable')
				spreadsheet.data(data).update_rollup().update();
				after_spreadsheet.data(sample).update_rollup().update();
        after_spreadsheet_container.addClass('previewAfterTable')
        jQuery("#playground_after_table_container").removeClass('hidden')
			break
			case dw.transform.FILTER:
				spreadsheet_container.addClass('updatedTable')
				spreadsheet.data(sample).update_rollup().update();
			break

			case dw.transform.SPLIT:
			case dw.transform.CUT:
			case dw.transform.EXTRACT:
				highlightClass = transform.name+'Highlight'
			default:
				spreadsheet_container.addClass('updatedTable')
				spreadsheet.data(sample).update_rollup().update()
		}


		var colIndex, original, updated, children, node, val, split, rows;


		if (splits && splits.length) {
		  transform.column().forEach(function(col){
  			original = columnTable[col];
  			var children = cells({cols:[original]})[0];
  			for(var index = 0; index < splits.length; ++index){
  				split = splits[index];
  				if (split) {
  					node = children[index];
  					if (node) {
  						node = node.firstChild
  					}
  					else {
  						break;
  					}
  					val = original.get_raw(index+start_row);
  					if(node && val != undefined && split[0] && val.length >= split[0].end) {
  						Highlight.highlight(node, split[0].start, split[0].end, {highlightClass:highlightClass})
  					}
  				}
  			}
  		})
		}


    cells({cols:newCols}).classed('previewNew', true).classed('unclickable', true)


    cells({cols:droppedCols}).classed("previewDeleted", true)


    cells({cols:toHeaderCols}).classed("previewSchema", true)


		cells({rows:filteredRows}).classed('previewDeleted', true)


		cells({rows:promoteRows}).classed('previewKey', true)


		updatedCols.forEach(function(col){
			original = data[col.name()];
			updated = sample[col.name()];
			colIndex = original.index;
			var updated_rows = dv.range(0, data.rows()).filter(function(r, i) {
			  return (updated[i] !== undefined && original[i] !== updated[i])
			})
			cells({cols:[col], rows:updated_rows}).classed('previewNew', true)
		})


    cells({cols:toValueCols}).classed('previewNew', true)


    cells({cols:toValueCols, rows:keyRows}).classed('previewKey', true)


    cells({cols:valueCols, chart:after_chart}).classed('previewNew', true)


    cells({cols:valueCols, chart:after_chart, rows:toKeyRows}).classed('previewKey', true)


    cells({cols:keyCols, chart:after_chart}).classed('previewKey', true)


		transform.drop(old_drop);
	}
	else{
		spreadsheet.update();
	}

	jQuery('.unclickable').unbind('mouseup').unbind('mousedown')
	spreadsheet.data(data).update_rollup()
}
jQuery.fn.highlight = function(start,end) {
 function innerHighlight(node, start, end) {
  var skip = 0;

  if (node.nodeType == 3) {
   if (start >= 0 && start < node.data.length && end >= 0 && end <= node.data.length) {
    var spannode = document.createElement('span');

	spannode.className = 'highlight';
    var middlebit = node.splitText(start);
    var endbit = middlebit.splitText(end-start)
    var middleclone = middlebit.cloneNode(true);
    spannode.appendChild(middleclone);
    middlebit.parentNode.replaceChild(spannode, middlebit);
    skip = 1;
   }
  }
  else if (node.nodeType == 1 && node.childNodes && !/(script|style)/i.test(node.tagName)) {
    innerHighlight(node.childNodes[0], start, end);
  }
  return skip;
 }
 return this.each(function() {
  innerHighlight(this, start, end);
 });
};

jQuery.fn.removeHighlight = function() {
	console.log('remove')
 return this.find("span.highlight").each(function() {
  this.parentNode.firstChild.nodeName;
  with (this.parentNode) {
   replaceChild(this.firstChild, this);
   normalize();
  }
 }).end();
};

Highlight = {}
Highlight.highlight = function(node, start, end, options){

	if (node.nodeType == 3) {


	   if (start >= 0 && start < node.data.length && end >= 0 && end <= node.data.length) {
	    var spannode = document.createElement('span');
	    spannode.className = options.highlightClass + ' highlight';
	    var middlebit = node.splitText(start);

		var endbit = middlebit.splitText(end-start)




		var middleclone = middlebit.cloneNode(true);








			spannode.appendChild(middleclone);

	    middlebit.parentNode.replaceChild(spannode, middlebit);
	   }
	 }


}

Highlight.removeHighlight = function(node) {

 jQuery(node).find("span.highlight").each(function() {

  this.parentNode.firstChild.nodeName;
  with (this.parentNode) {
   replaceChild(this.firstChild, this);
   normalize();
  }
 });
};
dw.transform.description = function(container, transform, opt) {
  opt = opt || {};
  var view = {},
      vis;

  vis = container.append('div')
      .attr('class', 'transform_description');

  view.vis = function() {
    return vis;
  }

  view.update = function() {
    var displayed_parameters,
        clauses, clause_type, name = transform.name;

    displayed_parameters = dw.metadata.displayed_parameters(transform);
    vis.append('div').text(name[0].toUpperCase()+name.slice(1, name.length)).attr('class', 'transform_clause')
    clauses = displayed_parameters.map(function(p, i) {
      clause_container = vis.append('div').attr('class', 'transform_clause')
      return dw.transform.description.clause[p.type](clause_container, transform, p.name, {}).update()
    })
  }

  return view;
};
dw.transform.description.clause = function(container, transform, parameter, opt) {
  var clause = {},
      vis;

  vis = container.append('div');

  clause.vis = function() {
    return vis;
  }

  clause.update = function() {
    vis.text(" " + clause.text() + " ");
  }

  return clause;
};
dw.transform.description.clause.columns = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  clause.text = function() {
    return transform[parameter]().join(', ').substr(0, 12)
  }

  return clause;
};
dw.transform.description.clause.row = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  clause.text = function() {
    return transform[parameter]().description();
  }

  return clause;
};
dw.transform.description.clause.enumerable = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  clause.text = function() {
    return transform[parameter]().substr(0, 12)
  }

  return clause;
};
dw.transform.description.clause.column = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  clause.text = function() {
    return transform[parameter]().substr(0, 12)
  }

  return clause;
};
dw.transform.description.clause.filter = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  clause.text = function() {
    var filter = transform[parameter]();
    return filter;
  }

  return clause;
};
dw.transform.description.clause.ints = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  clause.text = function() {
    return transform[parameter]().join(', ').substr(0, 12)
  }

  return clause;
};
dw.transform.description.clause.int = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  clause.text = function() {
    return transform[parameter]();
  }

  return clause;
};
dw.transform.description.clause.row_index = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  function suffix(d) {
    switch (d) {
      case 1:
        return 'st'
      case 2:
        return 'nd'
      case 3:
        return 'rd'
      default:
        return 'th'
    }
  }

  clause.text = function() {
    var row = transform[parameter](),
        prefix =  'row';

    return prefix + (row + 1);
  }

  return clause;
};
dw.transform.description.clause.row_indices = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  function int_suffix(d) {
    switch (d) {
      case 1:
        return 'st'
      case 2:
        return 'nd'
      case 3:
        return 'rd'
      default:
        return 'th'
    }
  }

  clause.text = function() {
    var rows = transform[parameter](),
        suffix;

    suffix = rows.length === 1 ? ' row' : ' rows';
    return rows.map(function(d) {
      return d === -1 ? 'header' : ((d+1) + int_suffix(d+1))
    }).join(', ') + suffix;
  }

  return clause;
};
dw.transform.description.clause.regex = function(container, transform, parameter, opt) {
  var clause = dw.transform.description.clause(container, transform, parameter, opt),
      vis;

  clause.vis = function() {
    return vis;
  }

  clause.text = function() {
    var regex = transform[parameter]();

    return regex ? regex.toString() : regex;
  }

  return clause;
};
dw.table_selection = function(){
	var ts = {}, rowSelection = dw.selection(), colSelection = dw.selection();

	ts.add = function(selection){
		var keytype;
		if(selection.shift){
			keytype = dw.selection.shift;
		}
		else if(selection.ctrl){
			keytype = dw.selection.ctrl;
		}

		switch(selection.type){
			case dw.engine.row:
				rowSelection.add({type:keytype, selection:selection.position.row})
				colSelection.clear()
				break
			case dw.engine.col:
				colSelection.add({type:keytype, selection:selection.table[selection.position.col].index})
				rowSelection.clear()
				break
			default:
		}
		return ts;
	}

	ts.clear = function(){
		rowSelection.clear();
		colSelection.clear();
	}

	ts.selection = function(){
		return {rows:rowSelection, cols:colSelection}
	}

	ts.rows = function(){
		return rowSelection.slice(0);
	}

	ts.cols = function(){
		return colSelection.slice(0);
	}



	return ts;
}

dw.table_selection.row = 'row';
dw.table_selection.col = 'col';
dw.selection = function(){
	var selection = []
	var history = [];
	selection.add = function(s){
		var e = s.selection, index, last, range;
		switch(s.type){
			case dw.selection.ctrl:
				index = selection.indexOf(e);
				if(index===-1){
					selection.push(e)
				}
				else{
					selection.splice(index, 1)
				}
				break
			case dw.selection.shift:
				if(selection.length){
					last = history[history.length-1];
					if(last.type!=dw.selection.clear){
						range = (last.selection < e) ? dv.range(last.selection, e+1) : dv.range(e, last.selection+1);
						range.forEach(function(r){
							if(selection.indexOf(r) === -1){
								selection.push(r)
							}
						})
					}
				}
				else{
					selection.push(e)
				}
				break;
			case dw.selection.clear:
				selection.length = 0;
				break;
			default:
				selection.length = 0;
				selection.push(e)
		}
		history.push(s)
		return selection;
	}

	selection.clear = function(){
		selection.add({type:dw.selection.clear})
	}

	return selection;
}

dw.selection.ctrl = 'ctrl'
dw.selection.shift = 'shift'
dw.selection.clear = 'clear'
dw.corpus = function(){
	var corpus = {};

	/*Todo: update this with live feed to corpus*/
	corpus.frequency = function(transform, o){
		o = o || {};
		var inputs = o.inputs || [], input = inputs[inputs.length-1];

		if(input){
			switch(input.type){
				case dw.engine.highlight:
					if(input && input.params.start!=undefined){
						if(input.params.end - input.params.start > 1){
							switch(transform.name){
								case dw.transform.SPLIT:

									return 9;

								case dw.transform.EXTRACT:

									return 24;

								case dw.transform.CUT:

									return 10;

								case dw.transform.FILTER:

										return 8;
							}
						}
					}
					break;
				case dw.engine.row:
					var t = dw.row(dw.empty().formula()).tester([input.params.table]);

					for(var i = 0; i < input.params.rows.length; ++i){
						if(t.test(input.params.table, input.params.rows[i])){
							if(transform.name===dw.transform.FILL){
								return 0;
							}
						}
					}


					if(transform.name===dw.transform.SET_NAME){
						var rows = input.params.rows;
						if(rows.length === 1 && rows[0] < 4){
							if(!dw.row(dw.empty().percent_valid(80)).test(input.params.table, rows[0])){
								return 40
							}
						}

					}

			}
		}





		switch(transform.name){
			case dw.transform.SPLIT:

				return 35;

			case dw.transform.EXTRACT:

				return 32;

			case dw.transform.CUT:

				return 28;

			case dw.transform.DROP:

				return 13;

			case dw.transform.FOLD:

				return 12;

			case dw.transform.UNFOLD:
				if(input && input.params.table.length > 3){
					return 0;
				}

				return 8;


				case dw.transform.SET_NAME:

					return 4;

						case dw.transform.SHIFT:

							return 5;

			case dw.transform.FILL:

				return 21;

			case dw.transform.MERGE:

				return 3;

				case dw.transform.COPY:

					return 6;



			case dw.transform.FILTER:

				return 25;
		}

	}

	corpus.top_transforms = function(o, k){
		o = o || {};
		var transform = o.transform, given_params = o.given_params, needed_params = o.needed_params, table = o.table;

		switch(transform.name){
			case dw.transform.FILL:
				if(given_params.indexOf('column')===-1&&needed_params.indexOf('direction')!=-1){
					var column = transform.column(), row = transform.row();
					if(column && column.length!=1 && row){
						return [transform.clone().direction(dw.RIGHT),/*transform.clone().direction(dw.LEFT),*/ transform.clone().direction(dw.DOWN), transform.clone().direction(dw.UP)]
					}
					else{
						return [transform.clone().direction(dw.DOWN),transform.clone().direction(dw.UP),/*transform.clone().direction(dw.LEFT),*/ transform.clone().direction(dw.RIGHT)]
					}
				}
				else{
					return [transform.clone().direction(dw.DOWN),transform.clone().direction(dw.UP),/*transform.clone().direction(dw.LEFT),*/ transform.clone().direction(dw.RIGHT)]
				}
				return [transform.clone()]
			case dw.transform.FOLD:
				if(given_params.indexOf('keys')===-1)
					return [transform.clone().keys([-1]),transform.clone().keys([0]),transform.clone().keys([0,1]),transform.clone().keys([0,1,2])]

				if(given_params.indexOf('column')===-1){
					return [transform.clone()].concat(get_columns(table, [dt.type.integer(), dt.type.string()]).map(function(c){return transform.clone().column(c)}))
				}

				return [transform.clone()]

			case dw.transform.UNFOLD:
				if(given_params.indexOf('measure')===-1){

					return get_columns(table, [dt.type.integer(), dt.type.number(), dt.type.string()]).map(function(c){return transform.clone().measure(c)})


				}
				return [transform.clone()]

			default:
				return [transform.clone()]
		}
	}

	get_columns = function(table, type_hierarchy, count){
		var cols = table.slice(0);
		cols.map(function(c){})
		cols.sort(function(a, b){
			var aindex = type_hierarchy.indexOf(a.type.name())
			var bindex = type_hierarchy.indexOf(b.type.name())

			if(aindex===-1) aindex = 1000000;
			if(bindex===-1) bindex = 1000000;

			if(aindex < bindex) return -1;
			if(bindex < aindex) return -1;

			return 0;
		})
		return cols.slice(0, count).map(function(c){return c.name()})
	}
	return corpus;
}
dw.io = {};
dw.io.delimited = function(opt) {
  opt = opt || {};
  var io = {},
      delimiter = opt.delimiter || /,/,
      row_delimiter = opt.row_delimiter || /\n/,
      quote_char = opt.quote_char || '"',
      header_row = opt.header_row || false;

  io.parse = function(text) {
    var wrangle = dw.wrangle(),
        split_rows, split_columns, cut_quotes, set_names,
        data_name = 'data',
        table = dv.table([{type:dv.type.nominal, name:data_name, values:[text]}]);

    split_rows = dw.split([data_name])
                   .on(row_delimiter)
                   .result(dw.ROW)
                   .max(0);

    split_columns = dw.split(["split"])
                      .on(delimiter)
                      .result(dw.COLUMN)
                      .max(0);

    wrangle.add(split_rows).add(split_columns);

    if(header_row) {
      set_names = dw.promote()
                    .header_row(0);

      wrangle.add(set_names);
    }


    wrangle.apply([table]);

    return table;

  }

  io.debug = function() {
    return JSON.stringify({delimiter:delimiter, row_delimiter:row_delimiter, quote_char:quote_char});
  }

  return io;
}


dw.io.inference = function(text, opt) {
  opt = opt || {};
  var char_sample = opt.char_sample || text.length, char_stats = dv.array(300),
      c, delimiters, quote_chars, delimiter, row_delimiter, quote_char;

  for(c = 0; c < char_sample; ++c) {
    char_stats[text.charCodeAt(c)]++;
  }

  delimiters = opt.delimiters || [',', '\t', '|', ':', ';'];
  row_delimiters = opt.row_delimiters || ['\n', '\r'];
  quote_chars = opt.quote_chars || ['"', "'"];

  delimiter = top_char(delimiters);
  row_delimiter = top_char(row_delimiters);
  quote_char = top_char(quote_chars);

  return dw.io.delimited({delimiter:delimiter, row_delimiter:row_delimiter, quote_char:quote_char});

  function top_char(chars, opt) {
    var top_chars = chars.map(function(d) {
      return d.charCodeAt(0);
    }).sort(function(a, b) {
      if(char_stats[a] < char_stats[b]) return 1;
      return -1;
    });
    return String.fromCharCode(top_chars[0]);
  }

}})();