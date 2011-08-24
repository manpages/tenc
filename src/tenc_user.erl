-module(tenc_user).

-compile(export_all).

-include_lib("tenc/include/tenc.hrl").
-include_lib("yaws/include/yaws_api.hrl").


work(["signup"], Arg) -> 
	HttpMethod = erlang:element(2, Arg#arg.req),

	case(HttpMethod) of
		
		'GET'  -> tenc_main:show(
			hehe:run("tenc/html/signup.hehe")
		);

		'POST' -> 
			UserData = yaws_api:parse_post(Arg),
			Nick = erlang:element(2, lists:keyfind("nick", 1, UserData)),
			Password = tenc_util:md5( erlang:element(2, lists:keyfind("password", 1, UserData) )),
			Confirm = tenc_util:md5( erlang:element(2, lists:keyfind("confirm", 1, UserData) )),
			case (Password == Confirm andalso tenc_auth:register(Nick, Password)) of
				false -> tenc_main:show(
					"<span class=\"error\">" ++ tenc_lang:t("Password mismatch") ++ "</span>" ++
					hehe:run("tenc/html/signup.hehe")
				);
				Cookie -> 
					[
						{redirect, "/"}, 
						yaws_api:setcookie("tenc_sweater_auth", Cookie, "/")
					]
			end;
		_ -> tenc_main:show("http method isn't supported")
	end;
work(["signin"], Arg) -> 
	HttpMethod = erlang:element(2, Arg#arg.req),

	case(HttpMethod) of
		
		'GET'  -> tenc_main:show(
			hehe:run("tenc/html/signin.hehe")
		);

		'POST' -> 
			UserData = yaws_api:parse_post(Arg),
			Nick = erlang:element(2, lists:keyfind("nick", 1, UserData)),
			Password = tenc_util:md5( erlang:element(2, lists:keyfind("password", 1, UserData) )),
			case (tenc_auth:login(Nick, Password)) of
				false -> tenc_main:show(
					"wrong password" ++
					hehe:run("tenc/html/signin.hehe")
				);
				Cookie -> [ {redirect, "/"}, yaws_api:setcookie("tenc_sweater_auth", Cookie, "/") ]
			end;

		_ -> tenc_main:show("http method isn't supported")

	end;
work(["me"], Arg) ->
	case UID = get(uid) of
		0 -> {redirect_local, "/user/signin"};
		_ -> user_editor(UID, Arg)
	end;
work(["logout"], _Arg) ->
	[
		{redirect, "/"}, 
		yaws_api:setcookie("tenc_sweater_auth", "loggedOut", "/")
	];
work(_, _) -> ok.


%DATA
default_data() ->
	[profile].

prepare_data(UID) ->
	prepare_data(UID, default_data()).

prepare_data(UID, Keys) ->
	lists:foreach(fun (Key) -> tenc_user:get_r(UID, Key) end, Keys).


send_data(UID, PID) ->
	send_data(UID, default_data(), PID).

send_data(UID, Keys, PID) ->
	lists:foreach(fun (Key) -> tenc_user:send_to(UID, Key, PID) end, Keys).


get_r(UID, Key) ->
	once_cmd(UID, Key, request).
get(UID, Key) ->
	once_cmd(UID, Key, wait).
get_v(UID, Key) ->
	once_cmd(UID, Key, wait_v).
get_e(UID, Key) ->
	once_cmd(UID, Key, expect).
get_ev(UID, Key) ->
	once_cmd(UID, Key, expect_v).

get_c(UID, Key) ->
	{FKey, FCmd} = get_cmd(UID, Key),
	fission_syn:cmd(FKey, FCmd).
get_cv(UID, Key) ->
	{FKey, FCmd} = get_cmd(UID, Key),
	fission_syn:cmd_v(FKey, FCmd).
get_ca(UID, Key) ->
	{FKey, FCmd} = get_cmd(UID, Key),
	fission_asyn:cmd(FKey, FCmd).

send_to(UID, Key, PID) ->
	once_cmd(UID, Key, request_to, [PID]).

once_cmd(UID, Key, Cmd) ->
	once_cmd(UID, Key, Cmd, []).

once_cmd(UID, Key, Cmd, Args) ->
	{FKey, FCmd} = get_cmd(UID, Key),
	apply(fission_once, Cmd, [FKey, FCmd] ++ Args).

get_cmd(UID, Key) ->
	{{user, UID, Key}, get}.


%LOGIC TODO: put all signup/signin logic here in form of functions
user_editor(UID, Arg) ->
	HttpMethod = erlang:element(2, Arg#arg.req),

	case(HttpMethod) of
		
		'GET'  -> tenc_main:show(
			hehe:run("tenc/html/me.hehe")
		);

		'POST' -> 
			case (update_user_data(UID, Arg)) of
				false -> 
					{redirect_local, "/user/me"};
				Cookie -> [
					{redirect_local, "/user/me"},
					yaws_api:setcookie("tenc_sweater_auth", Cookie, "/")
				]
			end
	end.

update_user_data(UID, Arg) ->
	Password = get_cv(UID, password),
	UserData = yaws_api:parse_post(Arg),
	FirstName  = erlang:element(2, lists:keyfind("firstname", 1, UserData)),
	LastName  = erlang:element(2, lists:keyfind("lastname", 1, UserData)),
	OldPassword = tenc_util:md5( erlang:element(2, lists:keyfind("old_password", 1, UserData) )),
	NewPassword = tenc_util:md5( erlang:element(2, lists:keyfind("password", 1, UserData) )),
	Confirm = tenc_util:md5( erlang:element(2, lists:keyfind("confirm", 1, UserData) )),
	Cookie = case (OldPassword == Password andalso NewPassword == Confirm andalso NewPassword /= tenc_util:md5("")) of
		true -> 
			fission_syn:set({user, UID, password}, NewPassword),
			tenc_auth:login_by_id(UID, NewPassword);
		false -> false
	end,
	%fission_syn:set({user, UID, profile}, #profile {
	%	lastname = LastName,
	%	firstname = FirstName
	%})
	fission_tuple:set({user, UID, profile}, #profile.lastname, LastName),
	fission_tuple:set({user, UID, profile}, #profile.firstname, FirstName),
	Cookie.
