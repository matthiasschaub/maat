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
=|  state-1
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
    ^-  state-1
    |-
    |^  ?-  -.old
          %1  old
          %0  $(old (state-0-to-1 old))
        ==
    ++  state-0-to-1
      |=  =state-0
      ^-  state-1
      |^  :*
            %1
            groups.state-0
            acls.state-0
            (~(run by regs.state-0) reg-0-to-1)
            leds.state-0
            invs.state-0
          ==
      ++  reg-0-to-1
        |=  =reg-0
        ^-  reg
        (~(run in reg-0) member-0-to-ship)
      ++  member-0-to-ship
        |=  =@t
        `@p`(slav %p t)
      --
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
    ::
      %upt-group
    ~&  >  '%maat (on-poke): update group'
    =/  group  (~(got by groups) gid.group.action)
    ?>  ?&
          .=(our.bowl src.bowl)
          .=(our.bowl host.group)
        ==
    ?>  ?&
          .=(gid.group gid.group.action)
          .=(host.group host.group.action)
        ==
    :-  ^-  (list card)
      ~
      ::  TODO:
      :: :~  (do-update [%group gid.group group.action])
      :: ==
    %=  this
      groups   (~(put by groups) gid.group group.action)
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
          (~(has in reg) src.bowl)
          .=(src.bowl host.group)
        ==
    ?>  ?|
          (~(has in acl) src.bowl)
          .=(src.bowl host.group)
        ==
    =/  led  (~(got by leds) gid.action)
    =.  led  (~(put by led) tid.task.action task.action)
    :-  ^-  (list card)
      :~
        :: if, ship is not host
        ::
        ?.  =(our.bowl host.group)
          :: then, send data to host
          ::
          (do-action [host.group action])
        :: else, send data to subscribers
        ::
        (do-update [%led gid.action led])
      ==
    %=  this
      leds  (~(put by leds) gid.action led)
    ==
    ::
      %upt-task
    ~&  >  '%maat (on-poke): update task'
    =/  group  (~(got by groups) gid.action)
    =/  acl    (~(got by acls) gid.action)
    =/  reg    (~(got by regs) gid.action)
    ?>  ?|
          (~(has in reg) src.bowl)
          .=(src.bowl host.group)
        ==
    ?>  ?|
          (~(has in acl) src.bowl)
          .=(src.bowl host.group)
        ==
    =/  led   (~(got by leds) gid.action)
    =/  task  (~(got by led) tid.task.action)
    ?>  ?&
          .=(gid.task gid.task.action)
          .=(tid.task tid.task.action)
          .=(date.task date.task.action)
        ==
    =.  led  (~(put by led) tid.task.action task.action)
    :-  ^-  (list card)
      :~
        :: if, ship is not host
        ::
        ?.  =(our.bowl host.group)
          :: then, send data to host
          ::
          (do-action [host.group action])
        :: else, send data to subscribers
        ::
        (do-update [%led gid.action led])
      ==
    %=  this
      leds  (~(put by leds) gid.action led)
    ==
    ::
      %del-task
    ~&  >  '%maat (on-poke): delete task'
    =/  group  (~(got by groups) gid.action)
    =/  acl    (~(got by acls) gid.action)
    =/  reg    (~(got by regs) gid.action)
    ?>  ?|
          (~(has in reg) src.bowl)
          .=(src.bowl host.group)
        ==
    ?>  ?|
          (~(has in acl) src.bowl)
          .=(src.bowl host.group)
        ==
    =/  led  (~(got by leds) gid.action)
    =.  led  (~(del by led) tid.action)
    :-  ^-  (list card)
      :~
        :: if, ship is not host
        ::
        ?.  =(our.bowl host.group)
          :: then, send data to host
          ::
          (do-action [host.group action])
        :: else, send data to subscribers
        ::
        (do-update [%led gid.action led])
      ==
    %=  this
      leds  (~(put by leds) gid.action led)
    ==
    ::
      %allow
    ~&  >  '%maat (on-poke): allow'
    =/  group  (~(got by groups) gid.action)
    ?>  ?&
          .=(our.bowl src.bowl)
          .=(our.bowl host.group)
          !=(our.bowl p.action)
        ==
    =/  acl  (~(got by acls) gid.action)
    =.  acl  (~(put in acl) p.action)
    :-  ^-  (list card)
      :~
        (do-update [%acl gid.action acl])
        (do-action [p.action [%add-invite group]])
      ==
    %=  this
      acls  (~(put by acls) gid.action acl)
    ==
    ::  (receive invitation to join a group)
      ::
      %add-invite
    ~&  >  '%maat (on-poke): receive invite'
    ?>  ?|
          .=(our.bowl src.bowl)
          .=(src.bowl host.group.action)
        ==
    :-  ^-  (list card)
      :~
        :*  %pass
          /notify
          %agent
          [our.bowl %hark]
          %poke
          %hark-action
          !>  :*  %add-yarn
                %.y
                %.y
                `@uvH`eny.bowl
                [~ ~ %maat /apps/maat/invites]
                now.bowl
                :*  'You are invited to join '
                  [%emph title.group.action]
                  ' by '
                  [%ship host.group.action]
                  ~
                ==
                /[gid.group.action]
                ~
              ==
        ==
      ==
    %=  this
      invs  (~(put by invs) gid.group.action group.action)
    ==
    ::  (subscribe to a group and remove invite)
      ::
      %join
    ~&  >  '%maat (on-poke): join'
    ?>  .=(our.bowl src.bowl)
    =/  path  /[gid.action]
    :-  ^-  (list card)
      :~  [%pass path [%agent [host.action %maat] [%watch path]]]
      ==
    %=  this
      invs  (~(del by invs) gid.action)
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
    =.  reg    (~(put in reg) src.bowl)
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
      [%x %invs ~]
    ~&  >  '%maat (on-peek): send group data'
    [~ ~ [%noun !>(invs)]]
    ::
      [%x =gid ~]
    ~&  >  '%maat (on-peek): send group data'
    =/  group  (~(got by groups) gid.path)
    =/  acl    (~(got by acls) gid.path)
    =/  reg    (~(got by regs) gid.path)
    =/  led    (~(got by leds) gid.path)
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
