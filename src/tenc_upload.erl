-module(tenc_upload).

-include_lib("tenc/include/tenc.hrl").
-include_lib("yaws/include/yaws_api.hrl").
-include_lib("tenc/include/file.hrl").

-compile(export_all).

-record(upload, {
  fd,
  filename,
  last}).

-define(DIR, "/tmp/YawsTestUploads/").


work(_, A) when erlang:element(2, A#arg.req) == 'GET' ->
ok;
work(_, A) when A#arg.state == undefined ->
	case (get(uid)) of 
		0 -> 
			{html, "File transfer failed: user must be logged in"};
		_ ->
			State = #upload{},
			multipart(A, State)
	end;
work(_, A) ->
	case (get(uid)) of 
		0 -> 
			{html, "File transfer failed: user must be logged in"};
		_ ->
			multipart(A, A#arg.state)
	end.


err() ->
	{ehtml,
	 {p, [], "error"}}.

multipart(A, State) ->
	Parse = yaws_api:parse_multipart_post(A),
	case Parse of
		[] -> ok;
		{cont, Cont, Res} ->
			case addFileChunk(A, Res, State) of
				{done, Result} ->
					Result;
				{cont, NewState} ->
					{get_more, Cont, NewState}
			end;
		{result, Res} ->
			case addFileChunk(A, Res, State#upload{last=true}) of
				{done, Result} ->
					Result;
				{cont, _} ->
					err()
			end
	end.



addFileChunk(A, [{part_body, Data}|Res], State) ->
	addFileChunk(A, [{body, Data}|Res], State);

addFileChunk(A, [], State) when State#upload.last==true,
								 State#upload.filename /= undefined,
								 State#upload.fd /= undefined ->

	file:close(State#upload.fd),
	%%file:delete([?DIR,State#upload.filename]),
	Res = {ehtml,
			{p,[], "File upload done"}},
	last_chunk(),
	{done, Res};

addFileChunk(_A, [], State) when State#upload.last==true ->
	{done, err()};

addFileChunk(_A, [], State) ->
	{cont, State};

addFileChunk(A, [{head, {Name, Opts}}|Res], State ) ->
	put(poll_id, Name),
	case lists:keysearch(filename, 1, Opts) of
		{value, {_, Fname0}} ->
			Fname = yaws_api:sanitize_file_name(basename(Fname0)),

		file:make_dir(?DIR),
		case file:open([?DIR, Fname] ,[write]) of
		{ok, Fd} ->
			S2 = State#upload{filename = Fname,
					  fd = Fd},
			addFileChunk(A, Res, S2);
		_Err ->
			{done, err()}
		end;
	false ->
			addFileChunk(A,Res,State)
	end;

addFileChunk(A, [{body, Data}|Res], State)
  when State#upload.filename /= undefined ->
	case file:write(State#upload.fd, Data) of
		ok ->
			{ok, Size} = file:read_file_info(?DIR ++ "/" ++ State#upload.filename),
			new_chunk(Size#file_info.size*100/list_to_integer(A#arg.headers#headers.content_length)),
			addFileChunk(A, Res, State);
		_Err ->
			{done, err()}
	end.


basename(FilePath) ->
	case string:rchr(FilePath, $\\) of
		0 ->
			%% probably not a DOS name
			filename:basename(FilePath);
		N ->
			%% probably a DOS name, remove everything after last \
			basename(string:substr(FilePath, N+1))
	end.

new_chunk(X) -> 
	%io:format ("UPLOADER: new_chunk ~p|~p~n", [{length, X}, {descr, {poll, get(poll_id), user, get(uid)}}]),
	case fission_syn:get({poll, get(poll_id), user, get(uid)}) of
		{value, PID} -> PID ! {data, float_to_list(X)};
		_ -> false
	end
.

last_chunk() -> 
	%io:format ("UPLOADER: last_chunk ~p~n", [{descr, {poll, get(poll_id), user, get(uid)}}]),
	case fission_syn:get({poll, get(poll_id), user, get(uid)}) of
		{value, PID} -> 
			PID ! stop;
		_ -> false
	end
.
