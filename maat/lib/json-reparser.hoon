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
        :-  'id'        [%s id.g]
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
    ^-  $-(json [=id =title =public])
    %-  ot:dejs:format
    :~
      :-  %id        so:dejs:format
      :-  %title     so:dejs:format
      :-  %public    bo:dejs:format
    ==
  --
--
