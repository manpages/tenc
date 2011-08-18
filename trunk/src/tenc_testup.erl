-module(tenc_testup).

-compile(export_all).

-include_lib("tenc/include/tenc.hrl").
-include_lib("yaws/include/yaws_api.hrl").


work(_, _) -> 
	tenc_main:show(hehe:run("tenc/html/upload_test.hehe")).
