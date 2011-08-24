-module(tenc_longpoll).

-include_lib("tenc/include/tenc.hrl").
-include_lib("yaws/include/yaws_api.hrl").

-compile(export_all).

work ([PollID], _) ->
	case (get(uid)) of 
		0 -> false;
		UID -> 
			Descriptor = {poll, PollID, user, UID},
			fission_syn:del(Descriptor),
			PID = spawn(?MODULE, loop, [self(), Descriptor]),
			fission_syn:set(Descriptor, PID),
			io:format ("LONG_POLL: poll_id and forked PID: ~p ~p~n", [PollID, PID]),
			{streamcontent, "text/html", "[ "}
	end
.

loop (WorkPID, Descriptor) ->
	receive
	stop ->
		fission_syn:del(Descriptor),
		io:format ("LONG_POLL: sigkill recvd~n"),
		yaws_api:stream_chunk_deliver(WorkPID, "true, true ]"),
		yaws_api:stream_chunk_end(WorkPID);
	{data, Data} ->
		fission_syn:del(Descriptor),
		io:format ("LONG_POLL: data recvd~n"),
		yaws_api:stream_chunk_deliver(WorkPID, "false, " ++ Data ++ " ]"),
		yaws_api:stream_chunk_end(WorkPID);
	X -> %debug only
		io:format ("LONG_POLL (debug only): something received ~p~n", [X]),
		loop(WorkPID, Descriptor)
	after 10000 ->
		io:format ("LONG_POLL~p: testing connection~n", [self()]),
		case yaws_api:stream_chunk_deliver_blocking(WorkPID, "\n") of
			ok -> 
				loop (WorkPID, Descriptor);
			{error, _} -> 
				fission_syn:del(Descriptor),
				io:format("LONG_POLL: aptaujas ~p nave~n", [Descriptor])
		end
	end
.
