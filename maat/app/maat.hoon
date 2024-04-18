/-  *maat
/+  default-agent  :: agent arm defaults
/+  agentio        :: agent input/output helper
/+  dbug
/+  verb
::  types
::
|%
+$  card  card:agent:gall
--
=|  state-0
=*  state  -
::  debug wrap
::
%+  verb   %.n
%-  agent:dbug
::  agent core
::
^-  agent:gall
=<
|_  =bowl:gall
::  aliases
::
+*  this  .
    default  ~(. (default-agent this %.n) bowl)
::
++  on-init
  ^-  [(list card) $_(this)]
  :-  ^-  (list card)
      ~
  this
::
::  envases, produces current state
::
++  on-save
  ^-  vase
  !>(state)
::
::  unwraps old vase, make state changes
::
++  on-load
  |=  =vase
  ^-  [(list card) $_(this)]
  |^  =+  !<(old=versioned-state vase)
      :-  ^-  (list card)
          ~
      %=  this
        state  (build-state old)
      ==
  ++  build-state
    |=  old=versioned-state
    ^-  state-0
    |-
    |^  ?-  -.old
          %0  old
        ==
    --
  --
::
::  another agents sends a message, react
::
++  on-poke
  |=  [=mark =vase]
  ^-  [(list card) $_(this)]
  ?>  ?=(%tahuti-action mark)
  =/  action  !<(action vase)
  ?-  -.action
    ::
      %add-group
    ~&  >  '%maat (on-poke): add group'
    ?>  ?&
          .=(our.bowl src.bowl)
          .=(our.bowl host.group.action)
        ==
    ?<  (~(has by groups) id.group.action)
    :-  ^-  (list card)
        ~
    %=  this
      groups  (~(put by groups) id.group.action group.action)
      acls    (~(put by acls) id.group.action ~)
      regs    (~(put by regs) id.group.action ~)
      leds    (~(put by leds) id.group.action ~)
    ==
    ::  (delete group and kick all subscribers)
      ::
      %del-group
    ~&  >  '%maat (on-poke): delete group'
    =/  group  (~(got by groups) id.action)
    ?>  ?&
          .=(our.bowl src.bowl)
          .=(our.bowl host.group)
        ==
    :-  ^-  (list card)
        :~  [%give %kick [/[id.action] ~] ~]
        ==
    %=  this
      groups   (~(del by groups) id.action)
      acls     (~(del by acls) id.action)
      regs     (~(del by regs) id.action)
      leds     (~(del by leds) id.action)
      invs     (~(del by invs) id.action)
    ==
  ==
++  on-arvo  on-arvo:default
::
::  another agent subscribes, handle subscription
::
++  on-watch
  |=  path=(pole knot)
  ^-  [(list card) $_(this)]
  ?+  path  ~|('%maat (on-watch)' (on-watch:default path))
    ::  (send group data only to the new subscriber)
      ::
      [=id ~]
    ~&  >  '%maat (on-watch)'
    =/  group  (~(got by groups) id.path)
    =/  acl    (~(got by acls) id.path)
    =/  reg    (~(got by regs) id.path)
    =/  led    (~(got by leds) id.path)
    ?>  (~(has in acl) src.bowl)
    =/  reg    (~(got by regs) id.path)
    =.  reg  (~(put in reg) `@tas`(scot %p src.bowl))
    :-  ^-  (list card)
        :~  (do-update [%group id.path group acl reg led])
        ==
    %=  this
      regs  (~(put by regs) id.path reg)
    ==
  ==
::
::  another agent unsubscribes, quit subscription
::
++  on-leave
  |=  path=(pole knot)
  ^-  [(list card) $_(this)]
  ?+  path  ~|('%maat (on-leave)' (on-leave:default path))
    ::  (remove from access-control list)
      ::
      [=id ~]
    ~&  >  '%maat (on-leave)'
    =/  acl  (~(got by acls) id.path)
    =.  acl  (~(del in acl) src.bowl)
    :-  ^-  (list card)
      :~  (do-update [%acl id.path acl])
      ==
    %=  this
      acls  (~(put by acls) id.path acl)
    ==
  ==
::
::  another agent requests data, send data
::
++  on-peek
  |=  path=(pole knot)
  ^-  (unit (unit [mark vase]))
  ?+  path  ~|('%maat (on-peek)' (on-peek:default path))
    ::
      [%x %groups ~]
    ~&  >  '%maat (on-peek): send list of groups'
    [~ ~ [%noun !>(groups.this)]]
    ::
      [%x =id ~]
    ~&  >  '%maat (on-peek): send group data'
    =/  group  (~(got by groups) id.path)
    =/  acl    (~(got by acls) id.path)
    =/  reg    (~(got by regs) id.path)
    =/  led    (~(got by leds) id.path)
    =.  reg    (~(put in reg) `@tas`(scot %p host.group))
    =/  reg    (~(got by regs) id.path)
    [~ ~ [%noun !>([group acl reg led])]]
  ==
::
::  another agent sends data, receive data
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  [(list card) $_(this)]
  ?+  -.sign  (on-agent:default wire sign)
    ::
      %watch-ack
    ?~  p.sign
      ~&  >  '%tahuti (on-agent): subscription successful'
      [~ this]
    ~&  >>>  '%tahuti (on-agent): subscription failed'
    [~ this]
    ::
      %fact
    ?>  ?=(%maat-update p.cage.sign)
    =/  =update  !<(update q.cage.sign)
    =/  =id  `@tas`(head wire)
    ?>  =(id id.update)
    :: ?>  =(our.bowl host.group.update)
    ?-  -.update
      ::
        %group
      ~&  >  '%maat (on-agent): update group'
      :-  ^-  (list card)
          :~  (fact:agentio cage.sign [/[id] ~])
          ==
      %=  this
        groups   (~(put by groups) id group.update)
        regs     (~(put by regs) id reg.update)
        acls     (~(put by acls) id acl.update)
        leds     (~(put by leds) id led.update)
      ==
      ::
        %acl
      ~&  >  '%maat (on-agent): update access-control list'
      :-  ^-  (list card)
          :~  (fact:agentio cage.sign [/[id] ~])
          ==
      %=  this
        acls     (~(put by acls) id acl.update)
      ==
      ::
        %reg
      ~&  >  '%maat (on-agent): update register'
      :-  ^-  (list card)
          :~  (fact:agentio cage.sign [/[id] ~])
          ==
      %=  this
        regs  (~(put by regs) id reg.update)
      ==
        %led
      ~&  >  '%maat (on-agent): update ledger'
      :-  ^-  (list card)
          :~  (fact:agentio cage.sign [/[id] ~])
          ==
      %=  this
        leds     (~(put by leds) id led.update)
      ==
    ==
  ==
++  on-fail   on-fail:default
--
::
::  Helper Core
::
|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %|) bowl)
::  (give fact as gift - or update subscribers)
::
++  do-update
  |=  data=update
  ^-  card
  =/  path  /[id.data]
  =/  vase  !>  ^-  update  data
  [%give [%fact [path ~] [%maat-update vase]]]
::  (pass poke as task - or request action on agent)
::
++  do-action
  |=  [=ship data=action]
  ^-  card
  =/  vase  !>  ^-  action  data
  [%pass ~ [%agent [ship %maat] [%poke [%maat-action vase]]]]
--
