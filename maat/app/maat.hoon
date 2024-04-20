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
  ~&  >  '%maat (on-poke)'
  |=  [=mark =vase]
  ^-  [(list card) $_(this)]
  ?>  ?=(%maat-action mark)
  =/  action  !<(action vase)
  ?-  -.action
    ::
      %add-group
    ~&  >  '%maat (on-poke): add group'
    ?>  ?&
          .=(our.bowl src.bowl)
          .=(our.bowl host.group.action)
        ==
    ?<  (~(has by groups) gid.group.action)
    :-  ^-  (list card)
        ~
    %=  this
      groups  (~(put by groups) gid.group.action group.action)
      acls    (~(put by acls) gid.group.action ~)
      regs    (~(put by regs) gid.group.action ~)
      leds    (~(put by leds) gid.group.action ~)
    ==
    ::  (delete group and kick all subscribers)
      ::
      %del-group
    ~&  >  '%maat (on-poke): delete group'
    =/  group  (~(got by groups) gid.action)
    ?>  ?&
          .=(our.bowl src.bowl)
          .=(our.bowl host.group)
        ==
    :-  ^-  (list card)
        :~  [%give %kick [/[gid.action] ~] ~]
        ==
    %=  this
      groups   (~(del by groups) gid.action)
      acls     (~(del by acls) gid.action)
      regs     (~(del by regs) gid.action)
      leds     (~(del by leds) gid.action)
      invs     (~(del by invs) gid.action)
    ==
    ::
      %add-task
    ~&  >  '%maat (on-poke): add task'
    =/  group  (~(got by groups) gid.action)
    =/  acl    (~(got by acls) gid.action)
    =/  reg    (~(got by regs) gid.action)
    ?>  ?|
          (~(has in reg) `@tas`(scot %p src.bowl))
          .=(src.bowl host.group)
        ==
    ?>  ?|
          (~(has in acl) src.bowl)
          .=(src.bowl host.group)
        ==
    ?.  =(our.bowl host.group)
      :-  ^-  (list card)
        :~  [%pass ~ %agent [host.group %maat] %poke %maat-action !>(action)]
        ==
      this
    =/  led  (~(got by leds) gid.action)
    =.  led  (~(put by led) tid.task.action task.action)
    :-  ^-  (list card)
      :~
        :*  %give  %fact  [/[gid.action] ~]  %maat-update
            !>  ^-  update  [%led gid.action led]
        ==
      ==
    %=  this
      leds  (~(put by leds) gid.action led)
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
      [=gid ~]
    ~&  >  '%maat (on-watch)'
    =/  group  (~(got by groups) gid.path)
    =/  acl    (~(got by acls) gid.path)
    =/  reg    (~(got by regs) gid.path)
    =/  led    (~(got by leds) gid.path)
    ?>  (~(has in acl) src.bowl)
    =/  reg    (~(got by regs) gid.path)
    =.  reg  (~(put in reg) `@tas`(scot %p src.bowl))
    :-  ^-  (list card)
        :~  (do-update [%group gid.path group acl reg led])
        ==
    %=  this
      regs  (~(put by regs) gid.path reg)
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
      [=gid ~]
    ~&  >  '%maat (on-leave)'
    =/  acl  (~(got by acls) gid.path)
    =.  acl  (~(del in acl) src.bowl)
    :-  ^-  (list card)
      :~  (do-update [%acl gid.path acl])
      ==
    %=  this
      acls  (~(put by acls) gid.path acl)
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
      [%x =gid ~]
    ~&  >  '%maat (on-peek): send group data'
    =/  group  (~(got by groups) gid.path)
    =/  acl    (~(got by acls) gid.path)
    =/  reg    (~(got by regs) gid.path)
    =/  led    (~(got by leds) gid.path)
    =.  reg    (~(put in reg) `@tas`(scot %p host.group))
    =/  reg    (~(got by regs) gid.path)
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
      ~&  >  '%maat (on-agent): subscription successful'
      [~ this]
    ~&  >>>  '%maat (on-agent): subscription failed'
    [~ this]
    ::
      %fact
    ?>  ?=(%maat-update p.cage.sign)
    =/  =update  !<(update q.cage.sign)
    =/  =gid  `@tas`(head wire)
    ?>  =(gid gid.update)
    :: ?>  =(our.bowl host.group.update)
    ?-  -.update
      ::
        %group
      ~&  >  '%maat (on-agent): update group'
      :-  ^-  (list card)
          :~  (fact:agentio cage.sign [/[gid] ~])
          ==
      %=  this
        groups   (~(put by groups) gid group.update)
        regs     (~(put by regs) gid reg.update)
        acls     (~(put by acls) gid acl.update)
        leds     (~(put by leds) gid led.update)
      ==
      ::
        %acl
      ~&  >  '%maat (on-agent): update access-control list'
      :-  ^-  (list card)
          :~  (fact:agentio cage.sign [/[gid] ~])
          ==
      %=  this
        acls     (~(put by acls) gid acl.update)
      ==
      ::
        %reg
      ~&  >  '%maat (on-agent): update register'
      :-  ^-  (list card)
          :~  (fact:agentio cage.sign [/[gid] ~])
          ==
      %=  this
        regs  (~(put by regs) gid reg.update)
      ==
        %led
      ~&  >  '%maat (on-agent): update ledger'
      :-  ^-  (list card)
          :~  (fact:agentio cage.sign [/[gid] ~])
          ==
      %=  this
        leds     (~(put by leds) gid led.update)
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
  =/  path  /[gid.data]
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
