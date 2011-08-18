-module(tenc_main).

%-export([
%	work/2
%]).

-compile(export_all).

work (Params, Arg) -> 
	io:format("here!"),
	show("<div class=\"notes\"><div class=\"note\"><div class=\"info\"><p class=\"topic\">CSS Test</p><span class=\"ids\"><span class=\"id\"><a href=\"#\">0</a></span></span></div><div class=\"text\"><p>Hello, World</p></div><div class=\"footer\"><span class=\"file\">file_link</span></div></div></div>").

show(Content) ->
	[   
		{header, {content_type, "text/html; charset=utf-8"}},
		{html, hehe:run("tenc/html/outer.hehe", [
			{content, Content}
		])} 
		%{html, Content}
	].  

show(Content, 'empty') ->
	[   
		{header, {content_type, "text/html; charset=utf-8"}},
		{html, hehe:run("tenc/html/outer_empty.hehe", [
			{content, Content}
		])} 
		%{html, Content}
	]. 
