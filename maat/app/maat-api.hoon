/-  *maat
/+  dbug
/+  verb
/+  default-agent
/+  server         :: HTTP request processing
/+  schooner       :: HTTP response handling
/+  *json-reparser
::  types
::
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 ~]
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
|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %.n) bowl)
::
++  on-init
  ^-  [(list card) $_(this)]
  :-  ^-  (list card)
    :~
      :*  %pass  /eyre/connect  %arvo  %e
          %connect  `/apps/maat/api  %maat-api
      ==
    ==
  this
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old=vase
  ^-  [(list card) $_(this)]
  :-  ^-  (list card)
      ~
  %=  this
    state  !<(state-0 old)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  [(list card) $_(this)]
  |^
  ?+  mark  (on-poke:default mark vase)
    ::
      %handle-http-request
    =^  cards  state
      (handle-http !<([@ta =inbound-request:eyre] vase))
    [cards this]
  ==
  ++  handle-http
    |=  [eyre-id=@ta =inbound-request:eyre]
    ^-  [(list card) $_(state)]
    =/  request-line
      (parse-request-line:server url.request.inbound-request)
    =+  site=site.request-line
    =+  args=args.request-line
    =+  send=(cury response:schooner eyre-id)
    =+  auth=authenticated.inbound-request
    =/  public=?
        ?:  (gte (lent site) 5)
          =/  gid   (snag 4 site)
          =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[gid]/noun
          =,  .^([=group =acl =reg =led] %gx path)
          public.group
        %.n
    ?.  ?|(auth public)
      [(send [401 ~ [%plain "401 - Unauthorized"]]) state]
    ?+  method.request.inbound-request
      [(send [405 ~ [%plain "405 - Method Not Allowed"]]) state]
        ::
      ::
        %'GET'
      ~&  >  '%maat-api: GET'
      ?.  auth
        [(send [401 ~ [%plain "401 - Unauthorized"]]) state]
      ?+  site  [(send [404 ~ [%plain "404 - Not Found"]]) state]
        ::
          [%apps %maat %api @t ~]
        =/  endpoint  (snag 3 `(list @t)`site)
        ?+  endpoint  [(send [404 ~ [%plain "404 - Not Found"]]) state]

            %invites
          =/  path      /(scot %p our.bowl)/maat/(scot %da now.bowl)/invs/noun
          =/  invs   .^(invs %gx path)
          [(send [200 ~ [%json (groups:enjs invs)]]) state]

            %lists
          =/  path      /(scot %p our.bowl)/maat/(scot %da now.bowl)/groups/noun
          =/  groups    .^(groups %gx path)
          [(send [200 ~ [%json (groups:enjs groups)]]) state]
        ==
        ::
          [%apps %maat %api %lists @t ~]
        =/  gid       (snag 4 `(list @t)`site)
        =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[gid]/noun
        =,  .^([=group =acl =reg =led] %gx path)
        [(send [200 ~ [%json (group:enjs group)]]) state]
        ::
          [%apps %maat %api %lists @t @t ~]
        ::  get state of a group
        =/  gid    (snag 4 `(list @t)`site)
        =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[gid]/noun
        =/  endpoint  (snag 5 `(list @t)`site)
        =,  .^([=group =acl =reg =led] %gx path)
        ?+  endpoint
          [(send [404 ~ [%plain "404 - Not Found"]]) state]
          ::
             %version
           [(send [200 ~ [%json (version:enjs '2024-06-08.2')]]) state]
          ::
            %members
          [(send [200 ~ [%json (ships:enjs reg)]]) state]
          ::::
            ::%castoffs
          ::=/  regmod    `(set @tas)`(silt (skim ~(tap in reg) |=(m=member ?~(`(unit @p)`(slaw %p `@t`m) %.n %.y))))
          ::=/  aclmod    `(set @tas)`(~(run in acl) |=(=@p `@tas`(scot %p `@t`p)))
          ::=/  castoffs   (~(dif in regmod) aclmod)
          ::[(send [200 ~ [%json (members:enjs castoffs)]]) state]
            ::::
          ::   %invitees
          :: =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/invs/noun
          :: =,  .^(=invs %gx path)
          :: [(send [200 ~ [%json (ships:enjs (val by invs))]]) state]
          ::::
            %tasks
          =/  filter-by-done
            ?~  (find [[key='done' value='true'] ~] args)
              |=(=task .=(done.task %.n))
            ?~  (find [[key='done' value='false'] ~] args)
              |=(=task .=(done.task %.y))
            |=(=task %.y)
          =/  filter-by-tags
            ::  args contain tags?'
            ::
            ?:  ?!  (~(has in (silt (turn args |=(a=[k=@t v=@t] k.a)))) 'tags')
              |=(=task %.y)
            ::  matching tags?
            ::
            =/  =tags  (silt (turn args |=(a=[k=@t v=@t] ?:(.=(k.a 'tags') v.a ''))))
            |=(=task (~(any in tags) |=(=tag (~(has in tags.task) tag))))
          =/  tasks   ~(val by led)
          =.  tasks   (skim tasks filter-by-done)
          =.  tasks   (skim tasks filter-by-tags)
          =/  sorted  (sort tasks |=([a=task b=task] (gth date.a date.b)))
          [(send [200 ~ [%json (led:enjs sorted)]]) state]
          ::::
          ::  %balances
          ::=/  path  /(scot %p our.bowl)/tahuti/(scot %da now.bowl)/[gid]/net/noun
          ::=/  net   .^(net %gx path)
          ::[(send [200 ~ [%json (net:enjs [net currency.group])]]) state]
          ::  %reimbursements
          ::=/  path  /(scot %p our.bowl)/tahuti/(scot %da now.bowl)/[gid]/rei/noun
          ::=/  rei   .^(rei %gx path)
          ::[(send [200 ~ [%json (rei:enjs [rei currency.group])]]) state]
        ==
          [%apps %maat %api %lists @t %tasks @t ~]
        =/  gid       (snag 4 `(list @t)`site)
        =/  tid       (snag 6 `(list @t)`site)
        =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[gid]/noun
        =,  .^([=group =acl =reg =led] %gx path)
        =/  task      (~(got by led) tid)
        [(send [200 ~ [%json (task:enjs task)]]) state]
      ==
        ::
      ::
        %'PUT'
      ~&  >  '%maat-api: PUT'
      ?.  auth
        [(send [401 ~ [%plain "401 - Unauthorized"]]) state]
      ?~  body.request.inbound-request
        [(send [422 ~ [%plain "422 - Unprocessable Entity"]]) state]
      ?~  (de:json:html q.u.body.request.inbound-request)
        [(send [422 ~ [%plain "422 - Unprocessable Entity"]]) state]
      =/  content  (need (de:json:html q.u.body.request.inbound-request))
      ?+  site  [(send [404 ~ [%plain "404 - Not Found"]]) state]
        ::
          [%apps %maat %api %lists ~]
        =,  (group:dejs content)
        ?:  ?|
              .=(title '')
              .=(title ' ')
            ==
          [(send [422 ~ [%plain "422 - Unprocessable Entity"]]) state]
        =/  path      /(scot %p our.bowl)/maat/(scot %da now.bowl)/groups/noun
        =/  groups    .^(groups %gx path)
        =/  action
          ?~  (~(get by groups) gid)
            [%add-group [gid title host=our.bowl public]]
          [%upt-group [gid title host=our.bowl public]]
        :-  ^-  (list card)
          %+  snoc
            (send [200 ~ [%plain "ok"]])
          [%pass ~ %agent [our.bowl %maat] %poke %maat-action !>(action)]
        state
        ::
          [%apps %maat %api %lists @t %tasks ~]
        =/  gid       (snag 4 `(list @t)`site)
        =/  task      (task:dejs content)
        ?:  ?|(=(title.task '') =(title.task ' '))
          [(send [422 ~ [%plain "422 - Unprocessable Entity"]]) state]
        =/  action    [%add-task gid task]
        :-  ^-  (list card)
          %+  snoc
            (send [200 ~ [%plain "ok"]])
          [%pass ~ %agent [our.bowl %maat] %poke %maat-action !>(action)]
        state
        ::
          [%apps %maat %api %lists @t %invitees ~]
        ~&  >  '%maat-api: PUT /invitees'
        =/  gid      (snag 4 `(list @t)`site)
        ?.  (head (mule |.((invitee:dejs content))))
          [(send [422 ~ [%plain "422 - Unprocessable Entity"]]) state]
        =/  action  [%allow gid (invitee:dejs content)]
        :-  ^-  (list card)
          %+  snoc
            (send [200 ~ [%plain "ok"]])
          [%pass ~ %agent [our.bowl %maat] %poke %maat-action !>(action)]
        state
      ==
        ::
      ::
        %'DELETE'
      ~&  >  '%maat-api: DELETE'
      ?+  site  [(send [404 ~ [%plain "404 - Not Found"]]) state]
        ::
          [%apps %maat %api %lists @t ~]
        ?.  auth
          [(send [401 ~ [%plain "401 - Unauthorized"]]) state]
        =/  gid        (snag 4 `(list @t)`site)
        =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[gid]/noun
        =,  .^([=group =acl =reg =led] %gx path)
        ?.  .=(our.bowl host.group)
          [(send [403 ~ [%plain "Forbidden"]]) state]
        =/  action    [%del-group gid]
        :-  ^-  (list card)
          %+  snoc
            (send [200 ~ [%plain "ok"]])
          [%pass ~ %agent [our.bowl %maat] %poke %maat-action !>(action)]
        state
      ::
          [%apps %maat %api %lists @t %tasks @t ~]
        ?.  auth
          [(send [401 ~ [%plain "401 - Unauthorized"]]) state]
        ~&  >  '%tahuti-api: DELETE /tasks/{tid}'
        =/  gid       (snag 4 `(list @t)`site)
        =/  tid       (snag 6 `(list @t)`site)
        =/  action    [%del-task gid tid]
        :-  ^-  (list card)
          %+  snoc
            (send [200 ~ [%plain "ok"]])
          [%pass ~ %agent [our.bowl %maat] %poke %maat-action !>(action)]
        state
      ==
      ::
        %'POST'
      ~&  >  '%maat-api: POST'
      ?.  auth
        [(send [401 ~ [%plain "401 - Unauthorized"]]) state]
      ?~  body.request.inbound-request
        [(send [422 ~ [%plain "422 - Unprocessable Entity"]]) state]
      ?~  (de:json:html q.u.body.request.inbound-request)
        [(send [422 ~ [%plain "422 - Unprocessable Entity"]]) state]
      =/  content  (need (de:json:html q.u.body.request.inbound-request))
      ?+  site  [(send [404 ~ [%plain "404 - Not Found"]]) state]
        ::
          [%apps %maat %api %join ~]
        ~&  >  '%maat-api: POST /join'
        ?.  (head (mule |.((join:dejs content))))
          [(send [422 ~ [%plain "422 - Unprocessable Entity"]]) state]
        =/  action  [%join (join:dejs content)]
        :-  ^-  (list card)
          %+  snoc
            (send [200 ~ [%plain "ok"]])
          [%pass ~ %agent [our.bowl %maat] %poke %maat-action !>(action)]
        state
        ::
      ==
        ::
      ::
      ::   %'PATCH'
      :: ~&  >  '%maat-api: PATCH'
      :: ?+  site  [(send [404 ~ [%plain "404 - Not Found"]]) state]
      ::   ::
      ::     [%apps %maat %api %lists @t %tasks @t ~]
      ::   ?.  auth
      ::     [(send [401 ~ [%plain "401 - Unauthorized"]]) state]
      ::   ~&  >  '%tahuti-api: PATCH /tasks/{tid}'
      ::   =/  gid       (snag 4 `(list @t)`site)
      ::   =/  tid       (snag 6 `(list @t)`site)
      ::   =/  action    [%upt-task gid tid]
      ::   :-  ^-  (list card)
      ::     %+  snoc
      ::       (send [200 ~ [%plain "ok"]])
      ::     [%pass ~ %agent [our.bowl %maat] %poke %maat-action !>(action)]
      ::   state
      :: ==
    ==
  --
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  [(list card) $_(this)]
  ?.  ?=([%bind ~] wire)
    (on-arvo:default [wire sign-arvo])
  ?.  ?=([%eyre %bound *] sign-arvo)
    (on-arvo:default [wire sign-arvo])
  :: error if not accepted
  ::
  ~?  !accepted.sign-arvo
    %eyre-rejected-maat-api-binding
  :-  ^-  (list card)
      ~
  this
++  on-watch
  |=  =path
  ^-  [(list card) $_(this)]
  ?+    path  (on-watch:default path)
      [%http-response *]
    [~ this]
  ==
::
++  on-leave  on-leave:default
++  on-peek  on-peek:default
++  on-agent  on-agent:default
++  on-fail  on-fail:default
--
