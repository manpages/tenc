-module(tenc_lang).

-export([
	t/1
]).

% Month
t({month, X, 1}) -> "Jan";
t({month, X, 2}) -> "Feb";
t({month, X, 3}) -> "Mar";
t({month, X, 4}) -> "Apr";
t({month, X, 5}) -> "May";
t({month, X, 6}) -> "Jun";
t({month, X, 7}) -> "Jul";
t({month, X, 8}) -> "Aug";
t({month, X, 9}) -> "Sep";
t({month, X, 10}) -> "Oct";
t({month, X, 11}) -> "Nov";
t({month, X, 12}) -> "Dec";
%t({month, from, 1}) -> "janvāra";
%t({month, from, 2}) -> "februāra";
%t({month, from, 3}) -> "marta";
%t({month, from, 4}) -> "aprīļa";
%t({month, from, 5}) -> "maija";
%t({month, from, 6}) -> "jūnija";
%t({month, from, 7}) -> "jūlija";
%t({month, from, 8}) -> "augusta";
%t({month, from, 9}) -> "septembra";
%t({month, from, 10}) -> "oktobra";
%t({month, from, 11}) -> "novembra";
%t({month, from, 12}) -> "decembra";
%t({month, on, 1}) -> "janvārī";
%t({month, on, 2}) -> "februārī";
%t({month, on, 3}) -> "martā";
%t({month, on, 4}) -> "aprīlī";
%t({month, on, 5}) -> "maijā";
%t({month, on, 6}) -> "jūnijā";
%t({month, on, 7}) -> "jūlijā";
%t({month, on, 8}) -> "augustā";
%t({month, on, 9}) -> "septembrī";
%t({month, on, 10}) -> "oktobrī";
%t({month, on, 11}) -> "novembrī";
%t({month, on, 12}) -> "decembrī";
%t({month, to, 1}) -> "janvārim";
%t({month, to, 2}) -> "februārim";
%t({month, to, 3}) -> "martam";
%t({month, to, 4}) -> "aprīlim";
%t({month, to, 5}) -> "maijam";
%t({month, to, 6}) -> "jūnijam";
%t({month, to, 7}) -> "jūlijam";
%t({month, to, 8}) -> "augustam";
%t({month, to, 9}) -> "septembrim";
%t({month, to, 10}) -> "oktobrim";
%t({month, to, 11}) -> "novembrim";
%t({month, to, 12}) -> "decembrim";

t(X) -> X.
