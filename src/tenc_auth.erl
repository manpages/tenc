-module(tenc_auth).

%IMPORTANT! Assumes that passwords are already encrypted

-export([
	login_by_id/2,
	login/2,
	register/2,
	cookie/1
]).

-include_lib("tenc/include/tenc.hrl").

-include_lib("yaws/include/yaws.hrl").
-include_lib("yaws/include/yaws_api.hrl").

login(Nick, Password) ->
	UIDVal = fission_syn:get({user, Nick, id}),
	case (UIDVal) of
		{value, UID} -> login_by_id(UID, Password);
		false -> false
	end
.
	
login_by_id(UID, Password) -> 
	case (fission_syn:get_v({user, UID, password}) == Password) of
		true ->	set(UID, Password);
		false -> false
	end
.

register(Nick, Password) ->
	ExistingID = fission_syn:get({user, Nick, id}),
	%io:format("~p~n~p~n~p~n",[ExistingID, UserData, Password]),
	case ExistingID of
		false ->
			UID = fission_syn:inc_v({user, nextid}),
			fission_list:push(users, UID),
			fission_syn:set({user, UID, lastseen}, 0),
			fission_syn:set({user, UID, profile}, #profile{
				lastname = "",
				firstname = "",
				nick = Nick,
				avatar = ""
			}),
			fission_syn:set({user, UID, password}, Password),
			fission_syn:set({user, Nick, id}, UID),
			% TODO: set cookies
			login(Nick, Password);
		_ -> false
	end
.

set(UID, Password) ->
	random:seed(erlang:now()),
	Salt = integer_to_list(random:uniform(1000000)),
	Hash = tenc_util:md5(integer_to_list(UID) ++ "-w880i-" ++ Salt ++ "-" ++ Password),
	integer_to_list(UID) ++ ":" ++ Salt ++ ":" ++ Hash
.

cookie(Cookie) ->
	catch case string:tokens(Cookie, ":") of
		[SUID, Salt, Hash] ->
			UID = list_to_integer(SUID),
			Password = fission_syn:get_v({user, UID, password}),
			%io:format("~n~p~n~p~n~p~n~p~n~n", [SUID, Salt, Hash, tenc_util:md5(integer_to_list(UID) ++ "-w880i-" ++ Salt ++ "-" ++ Password)]),
			case tenc_util:md5(integer_to_list(UID) ++ "-w880i-" ++ Salt ++ "-" ++ Password) of
				Hash ->
					UID;
				_ ->
					false
			end;
		_ ->
			false
	end.
