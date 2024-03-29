-module(tenc_util).
-export([
	md5/1,

	to_int/1,
	to_list/1,
	to_binary/1,

	apply/2,

	unixtime/0,
	unixtime_float/0,
	msec/0,
	date_format/1,

	keyfind/2,
	keyfind/3,
	json_find/2,
	json_find/3,

	log/1,

	bbcode_to_html/1,
	get_page_from_params/1,
	links_for_pages/2,
	html_pid/0
]).

md5(Value) ->
	<<X:128/big-unsigned-integer>> = .erlang:md5(to_binary(Value)),
	.lists:flatten(.io_lib:format("~32.16.0b", [X])).

to_int(Value) when is_integer(Value) ->
	Value;
to_int(Value) when is_list(Value) ->
	list_to_integer(Value);
to_int(Value) when is_binary(Value) ->
	list_to_integer(binary_to_list(Value)).

to_list(Value) when is_list(Value) ->
	Value;
to_list(Value) when is_integer(Value) ->
	integer_to_list(Value);
to_list(Value) when is_binary(Value) ->
	binary_to_list(Value);
to_list(Value) ->
	io_lib:format("~p", [Value]).

to_binary(Value) when is_binary(Value) ->
	Value;
to_binary(Value) when is_list(Value) ->
	list_to_binary(Value);
to_binary(Value) when is_integer(Value) ->
	list_to_binary(integer_to_list(Value));
to_binary(Value) ->
	list_to_binary(.io_lib:format("~p", [Value])).

apply({Module, Function}, Args) ->
	erlang:apply(Module, Function, Args);
apply({Module, Function, Args2}, Args) ->
	erlang:apply(Module, Function, Args ++ Args2);
apply(Fun, Args) ->
	erlang:apply(Fun, Args).

unixtime() ->
	{Mega, Secs, _} = erlang:now(),
	Mega * 1000000 + Secs.

unixtime_float() ->
	{Mega, Secs, MSec} = erlang:now(),
	Mega * 1000000 + Secs + MSec / 1000000.

msec() ->
	{Mega, Secs, MSec} = erlang:now(),
	Mega * 1000000000 + Secs * 1000 + MSec div 1000.

date_format(Time) ->
	{{Year,Month,Day}, {Hour,Minutes,Seconds}} = calendar:now_to_universal_time({Time div 1000000000, Time rem 1000000000 div 1000, Time rem 1000}),
	lists:concat([Day, " ", tenc_lang:t({month, to, Month}), " ", Hour, ":", Minutes]).

keyfind(Key, List) ->
	{Key, Value} = .lists:keyfind(Key, 1, List),
	Value.

keyfind(Key, List, Default) ->
	case lists:keyfind(Key, 1, List) of
		{Key, Value} ->
			Value;
		_ ->
			Default
	end.

json_find(Key, {struct, List}) ->
	keyfind(Key, List).

json_find(Key, {struct, List}, Default) ->
	keyfind(Key, List, Default).

log(Stuff) ->
	Out = [msec()|Stuff],
	F = string:copies("~p ", length(Out)) ++ "~n",
	io:format(F, Out).

bbcode_replacements() ->
	[
		{"\\<", "\\&lt;"},%
		{"\\>", "\\&gt;"},%those guys are to be the first two
		{"\n", "<br />"},
		{"\\[b\\]", "<strong>"},
		{"\\[/b\\]", "</strong>"},
		{"\\[u\\]", "<u>"},
		{"\\[/u\\]", "</u>"},
		{"\\[i\\]", "<em>"},
		{"\\[/i\\]", "</em>"}
	]
	.
bbcode_to_html(UnsafeBbcode) -> 
	bbcode_to_html(bbcode_replacements(), UnsafeBbcode).
bbcode_to_html([], SafeBbcode) -> SafeBbcode;
bbcode_to_html([{Old, New}|Rest], UnsafeBbcode) ->
	bbcode_to_html(Rest, erlang:element(2, regexp:gsub(UnsafeBbcode, Old, New) )).

links_for_pages(Prefix, 0) ->
	"";
links_for_pages(Prefix, PageCount) ->
	links_for_pages(Prefix, PageCount, 1).
links_for_pages(Prefix, 1, CurrentPage) ->
	"<a href=\"" ++ Prefix ++ "/page/" ++ integer_to_list(CurrentPage) ++ "\">" ++ integer_to_list(CurrentPage) ++ "</a>"
	;	
links_for_pages(Prefix, PageCount, CurrentPage) ->
	lists:append(
		"<a href=\"" ++ Prefix ++ "/page/" ++ integer_to_list(CurrentPage) ++ "\">" ++ integer_to_list(CurrentPage) ++ "</a> ",
		links_for_pages(Prefix, PageCount - 1, CurrentPage + 1)
	).

get_page_from_params(Rest) ->
	case (Rest) of
		["page" | [Page_param|_Rest]] ->
			{PageNo,_} = string:to_integer(Page_param),
			case is_integer(PageNo) of
				true  -> PageNo;
				false -> 1
			end;
		_ -> 1
	end.

html_pid() -> string:sub_string(pid_to_list(self()), 2, string:len(pid_to_list(self())) - 1).
%might be a faster solution than the one implemented in regexp lib
%but i'm not sure, that's why i use library functions.

%sub(Str,Old,New) ->
%	Lstr = len(Str),
%	Lold = len(Old),
%	Pos  = str(Str,Old),
%	if 
%		Pos =:= 0 -> 
%			Str;
%	true      ->
%		LeftPart = left(Str,Pos-1),
%		RitePart = right(Str,Lstr-Lold-Pos+1),
%		concat(concat(LeftPart,New),RitePart)
%	end.
%
%gsub(Str,Old,New) ->
%	Acc = sub(Str,Old,New),
%	subst(Acc,Old,New,Str).
%
%subst(Str,_Old,_New, Str) -> Str;
%subst(Acc, Old, New,_Str) ->
%	Acc1 = sub(Acc,Old,New),
%	subst(Acc1,Old,New,Acc).
