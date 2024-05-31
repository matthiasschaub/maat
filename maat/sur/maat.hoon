::    structure file (type definitions)
::
|%
::
::  state
::
+$  versioned-state
  $%  state-0
      state-1
  ==
+$  state-1         :: latest state
  $:  %1
    =groups
    =acls
    =regs
    =leds
    =invs
  ==
::
::    general
::
+$  title    @t
+$  ship     @p
::
::    tag
::
+$  tag      @tas
+$  tags     (set tag)
::
::    task
::
+$  gid      @tas
+$  tid      @tas
+$  desc     @t
+$  date     @da
+$  done     ?
+$  task
  $:
    =gid
    =tid
    =title
    =desc
    =date
    =done
    =tags
  ==
::
::    group of tasks
::
+$  host     @p
+$  public   ?
+$  group
  $:
    =gid
    =title
    =host
    =public
  ==
::
::    register of members (reg)
::    access-control list (acl)
::    ledger of tasks     (led)
::
+$  acl      (set ship)
+$  reg      (set ship)
+$  led      (map tid task)
::
::   maps
::
+$  groups   (map gid group)
+$  invs     (map gid group)
+$  acls     (map gid acl)
+$  regs     (map gid reg)
+$  leds     (map gid led)
::
::    input requests/actions
::
+$  action
  $%  ::
      :: group actions
      ::
      [%add-group =group]
      [%upt-group =group]
      [%del-group =gid]
      ::
      :: task action
      ::
      [%add-task =gid =task]
      [%upt-task =gid =task]
      [%del-task =gid =tid]
      ::
      :: member actions
      ::
      [%add-invite =group]
      :: [%del-invite =group]
      ::
      [%allow =gid =@p]     :: allow to subscribe
      [%join =gid =host]    :: subscribe
  ==
::
::    output events/updater
::
::  these are all the possible events that can be sent to subscribers.
::
+$  update
  $%  [%group =gid =group =acl =reg =led]
      [%acl =gid =acl]
      [%reg =gid =reg]
      [%led =gid =led]
    ==
::
::    old / legacy
::
+$  state-0
  $:  %0
      =groups
      =acls
      regs=regs-0
      =leds
      =invs
  ==
+$  regs-0     (map gid reg-0)
+$  reg-0      (set member-0)
+$  member-0   @tas
--
