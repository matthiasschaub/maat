::    structure file (type definitions)
::
|%
::
::  state
::
+$  versioned-state
  $%  state-0
  ==
+$  state-0         :: latest state
  $:  %0
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
+$  member   @tas
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
+$  reg      (set member)
+$  led      (map tid task)
::
::   maps
::
+$  groups   (map gid group)
+$  acls     (map gid acl)
+$  regs     (map gid reg)
+$  leds     (map gid led)
+$  invs     (map gid group)
::
::    input requests/actions
::
+$  action
  $%  ::
      :: group actions
      ::
      [%add-group =group]
      [%del-group =gid]
      ::
      :: task action
      ::
      [%add-task =gid =task]
      [%del-task =gid =tid]
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
--
