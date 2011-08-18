-module(tenc_longpoll).

-include_lib("tenc/include/tenc.hrl").
-include_lib("yaws/include/yaws_api.hrl").

-compile(export_all).

work ([PollID], _) ->
	case (get(uid)) of 
		0 -> false;
		UID -> 
			Descriptor = {poll, PollID, user, UID},
			io:format ("~nLONG_POLL: poll_id `~p`~n", [PollID]),
			PID = spawn(?MODULE, loop, [self(), Descriptor]),
			fission_syn:set(Descriptor, PID),
			{streamcontent, "text/html", "[ "}
	end
.

loop (WorkPID, Descriptor) ->
	receive
	stop ->
		io:format ("LONG_POLL: sigkill recvd~n"),
		yaws_api:stream_chunk_deliver(WorkPID, "true, true ]"),
		yaws_api:stream_chunk_end(WorkPID),
		fission_asyn:del_n(Descriptor);
	{data, Data} ->
		io:format ("LONG_POLL: data recvd~n"),
		yaws_api:stream_chunk_deliver(WorkPID, "false, " ++ Data ++ " ]"),
		yaws_api:stream_chunk_end(WorkPID),
		fission_asyn:del_n(Descriptor)
	after 45000 ->
		io:format("LONG_POLL: testing connection~n"),
		case yaws_api:stream_chunk_deliver_blocking(WorkPID, "\n") of
			ok -> loop (WorkPID, Descriptor);
			{error, _} -> io:format("Aptaujas ~p nave~n", [Descriptor]), fission_asyn:del_n(Descriptor)
		end
	end
.
