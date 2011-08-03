-module(tenc_main).

%-export([
%	work/2
%]).

-compile(export_all).

work (Params, Arg) -> 
	io:format("here!"),
	show("Hello, world.").

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
