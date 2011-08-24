-module (tenc_helloworld).

-compile(export_all).

-include_lib("tenc/include/tenc.hrl").

work(Params, _Arg) ->
	tenc_main:show(
		hehe:run ("tenc/html/txt")
	).
