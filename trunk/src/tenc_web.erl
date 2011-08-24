-module(tenc_web).

-export([
	out/1
]).

-include_lib("yaws/include/yaws.hrl").
-include_lib("yaws/include/yaws_api.hrl").

out(Arg) ->
	case prepare(Arg) of
		ok ->
			process(Arg);
		Error ->
			{html, Error}
	end.
	
prepare(_Arg) ->
	case {ok, true} of % dirty dirty
		{ok, true} ->
			case make:all([load]) of
				up_to_date ->
					ok;
				error ->
					"Recompile error."
			end;
		_ ->
			ok
	end.

process(Arg) ->
	% Eat em cookies

	Cookies = Arg#arg.headers#headers.cookie,
	
	% Prepare user data
	
	UID = case yaws_api:find_cookie_val("tenc_sweater_auth", Cookies) of
		[] -> 0;
		AC ->
			case tenc_auth:cookie(AC) of
				PUID when is_integer(PUID) ->
					tenc_user:prepare_data(PUID),
					PUID;
				_ -> 0
			end
	end,
	put(uid, UID),
	put(admin, lists:any(fun(X) -> X == UID end, fission_syn:get_def(admins, []))),
	%io:format("WEB>>UID>>~p~n", [get(uid)]),
	
	% What now?

	Tok = string:tokens(string:strip(Arg#arg.appmoddata, both, $/), "/"),
	
	case Tok of

		["!", Modname, Function |_] ->
			Module = list_to_existing_atom("tenc_" ++ Modname),
			{ok, {struct, Params}} = json:decode_string(binary_to_list(Arg#arg.clidata)),
			Res = try
				Module:rpc(Function, Params, Arg)
			catch
				exit:{return, Ret} ->
					Ret;
				ET:EV ->
					io:format("~p ~p ~p ~p", [{Module, Function, Params}, ET, EV, erlang:get_stacktrace()]),
					{error, tenc_lang:t("System error")}
			end,
			case Res of
				{_, _} ->
					{html, json:encode({struct, [Res]})};
				_ ->
					{html, json:encode({struct, Res})}
			end;
			
		_ ->
			case Tok of
				[Modname | Params] ->
					ok;
				[] ->
					{Modname, Params} = {"main", []}
			end,
			Module = list_to_existing_atom("tenc_" ++ Modname),
			
			% We'll probably show the main page, right?
			%tenc_main:prepare(),

			try
				Module:work(Params, Arg)
			catch
				exit:{return, Ret} ->
					Ret;
				ET:EV ->
					io:format("~p ~p ~p ~p", [{Module, work, Params}, ET, EV, erlang:get_stacktrace()]),
					tenc_lang:t("System error") % TODO nice errorpage?
			end
			
	end.
