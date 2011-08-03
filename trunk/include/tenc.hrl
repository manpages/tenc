%% fisbb.hrl

-record(forum, {
	id,

	name, 
	parent, 
	moderators,
	deleted,
	access, 
	flags

}).

-record(topic, {
	id,

	name,
	parent,
	author,
	messages,
	access,
	deleted,
	flags
}).

-record(message, {
	id,

	name, 
	parent, 
	author,
	time,
	text, 
	bbcode,
	deleted,
	flags

}).

-record(profile, {
	firstname,
	lastname,
	nick,

	avatar,
	kicked,
	blocked,
	admin
}).
