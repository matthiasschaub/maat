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
+$  id       @tas
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
+$  desc     @t
+$  date     @da
+$  done     ?
+$  task
  $:
    =id
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
    =id
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
+$  led      (map id task)
::
::   maps
::
+$  groups   (map id group)
+$  acls     (map id acl)
+$  regs     (map id reg)
+$  leds     (map id led)
+$  invs     (map id group)
::
::    input requests/actions
::
+$  action
  $%  ::
      :: group actions
      ::
      [%add-group =group]
      [%del-group =id]
  ==
::
::    output events/updater
::
::  these are all the possible events that can be sent to subscribers.
::
+$  update
  $%  [%group =id =group =acl =reg =led]
      [%acl =id =acl]
      [%reg =id =reg]
      [%led =id =led]
    ==
--
