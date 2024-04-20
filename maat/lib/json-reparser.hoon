::  In Hoon JSON is represented as a `unit` and cells head-tagged with the
::  JSON type.
::
::  JSON must be processed twice:
::    1. First the JSON is parsed from text (`@t` `cord`) into a tagged cell
::       representation `+$json` using `++dejs:html`.
::    2. Then the parsed JSON is sent through a custom-built reparser to
::       retrieve particular values.
::
::  This file implements the second processing step: The reparser.
::
/-  *maat
|%
++  enjs
  |%
    ++  version
      |=  v=@t
      ^-  json
      [%s v]
    ++  ship
      |=  s=^ship
      ^-  json
      [%s (scot %p s)]
    ++  ships
      |=  s=(set ^ship)
      ^-  json
      [%a (turn ~(tap in s) ship:enjs)]
    ++  member
      |=  m=^member
      ^-  json
      [%s m]
    ++  members
      |=  m=(set ^member)
      ^-  json
      [%a (turn ~(tap in m) member:enjs)]
    ++  group
      |=  g=^group
      ^-  json
      %-  pairs:enjs:format
      :~
        :-  'gid'       [%s gid.g]
        :-  'title'     [%s title.g]
        :-  'host'      [%s (scot %p host.g)]
        :-  'public'    [%b public.g]
      ==
    ::  (lists as json array)
    ::
    ++  groups
      |=  g=^groups
      ^-  json
      [%a (turn ~(val by g) group:enjs)]
    ++  tag
      |=  t=@t
      ^-  json
      [%s t]
    ++  task
      |=  t=^task
      ^-  json
      %-  pairs:enjs:format
      :~
        :-  'gid'       [%s gid.t]
        :-  'tid'       [%s tid.t]
        :-  'title'     [%s title.t]
        :-  'desc'      [%s desc.t]
        :-  'date'      (sect:enjs:format date.t)
        :-  'done'      [%b done.t]
        :-  'tags'      [%a (turn ~(tap in tags.t) tag:enjs)]
      ==
    ++  led
      |=  vals=(list ^task)
      ^-  json
      [%a (turn vals task:enjs)]
  --
::
++  dejs
  |%
  ++  member
    ^-  $-(json member=^member)
    %-  ot:dejs:format
    :~
      :-  %member    so:dejs:format
    ==
  ++  ship
    ^-  $-(json ship=^ship)
    %-  ot:dejs:format
    :~
      :-  %ship      (se:dejs:format %p)
    ==
  ++  group
    ^-  $-(json [=gid =title =public])
    %-  ot:dejs:format
    :~
      :-  %gid       so:dejs:format
      :-  %title     so:dejs:format
      :-  %public    bo:dejs:format
    ==
  ++  task
    ^-  $-(json ^task)
    %-  ot:dejs:format
    :~
      :-  %gid       so:dejs:format
      :-  %tid       so:dejs:format
      :-  %title     so:dejs:format
      :-  %desc      so:dejs:format
      :-  %date      du:dejs:format
      :-  %done      bo:dejs:format
      :-  %tags      (as:dejs:format so:dejs:format):dejs:format
    ==
  --
--
