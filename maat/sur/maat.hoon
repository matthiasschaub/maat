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
    =invites
    =lists
    =regs
    =acls
  ==
::
::    tag
::
+$  tag       @tas
+$  tags      (list tags)
::
::    task
::
+$  tid       @tas
+$  title     @t
+$  desc      @tas
+$  date      @da
+$  done      ?
+$  task
  $:
    =tid
    =title
    =desc
    =date
    =done
    =tags
  ==
+$  tasks     (map tid task)
::
::    list
::
+$  lid       @tas
+$  host      @p
+$  public    ?
+$  list
  $:
    =lid
    =title
    =host
    =public
    =tasks
  ==
+$  lists     (map lid list)
::
::    register of members (reg)
::    access-control list (acl)
::
+$  member    @tas
+$  reg       (set member)
+$  acl       (set @p)
+$  regs      (map lid reg)
+$  acls      (map lid acl)
::
::    invites
::
+$  invites   (map lid host)
--
