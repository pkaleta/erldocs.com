-module(erldocs).

-export([build_docs/1, build_docs/0 ]).

-define(OTP_SRC, "/home/dale/otp_src_R13B01").
-define(ROOT, "/home/dale/lib/erldocs.com").

build_docs() ->
    build_docs(?OTP_SRC).
    
build_docs(OtpSrc) ->
    [ build_app_docs(OtpSrc, Src)
      || Src <- filelib:wildcard(OtpSrc++"/lib/*/"), filelib:is_dir(Src) ],

    file:set_cwd(?ROOT),
    ok.

build_app_docs(OtpSrc, Src) ->
    [ App | _Rest] = lists:reverse(string:tokens(Src, "/")),
    AppDocRoot = OtpSrc++"/lib/"++App++"/doc/src/",

    ok = filelib:ensure_dir(?ROOT++"/www/"++App++"/"),
    file:set_cwd(AppDocRoot),
    
    [ build_app_docs(OtpSrc, App, Xml)
      || Xml <- filelib:wildcard(AppDocRoot++"*.xml") ],
    
    file:set_cwd(?ROOT),
    ok.


build_app_docs(OtpSrc, App, Src) ->

    Dest = ?ROOT++"/www/"++App++"/",

    Opts = [ {space, normalize}, {encoding, "latin1"},
             {fetch_path, [OtpSrc++"/lib/docbuilder/dtd/"]}],
    {Type, _Attr, _Rest2} = simplexml_read_file(Src, Opts),

    case lists:member(Type, buildable()) of
        false -> ok;
        true  -> docb_transform:file(Src, [{outdir, Dest}])
    end.

buildable() ->
    [ erlref ].

% Src and Dest should both be directories
%% copy_dir(Src, Dest) ->

%%     case filelib:is_dir(Dest) of
%%         true  -> throw({error, destination_exists});
%%         false -> ok = filelib:ensure_dir(Dest++"/")
%%     end,
    
%%     {ok, Files} = file:list_dir(Src),
   
%%     [ do_copy_dir(filename:join(Src, File),
%%                   filename:join(Dest, File))
%%       || File <- Files ],
    
%%     ok.
   
%% do_copy_dir(Src, Dest) ->
%%     case filelib:is_dir(Src) of
%%         true  -> ok           = copy_dir(Src, Dest);
%%         false -> {ok, _Bytes} = file:copy(Src, Dest)
%%     end.
                        
simplexml_read_string(Str, Opts) ->
    {XML,_Rest} = xmerl_scan:string(Str, Opts),
    xmerl_lib:simplify_element(XML).

simplexml_read_file(File, Opts) ->
    {ok, Bin} = file:read_file(File),
    simplexml_read_string(binary_to_list(Bin), Opts).
