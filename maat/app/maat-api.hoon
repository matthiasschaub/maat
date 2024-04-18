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
    =+  send=(cury response:schooner eyre-id)
    =+  auth=authenticated.inbound-request
    =/  public=?
        ?:  (gte (lent site) 5)
          =/  id   (snag 4 site)
          =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[id]/noun
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
      ?+  site  [(send [404 ~ [%plain "404 - Not Found"]]) state]
        ::
          [%apps %maat %api @t ~]
        =/  endpoint  (snag 3 `(list @t)`site)
        ?+  endpoint  [(send [404 ~ [%plain "404 - Not Found"]]) state]
          ::
            :: %invites
          :: =/  path      /(scot %p our.bowl)/maat/(scot %da now.bowl)/invites/noun
          :: =/  invites   .^(invites %gx path)
          :: [(send [200 ~ [%json (invites:enjs invites)]]) state]
          ::
            %lists
          ?.  auth
            [(send [401 ~ [%plain "401 - Unauthorized"]]) state]
          =/  path      /(scot %p our.bowl)/maat/(scot %da now.bowl)/groups/noun
          =/  groups    .^(groups %gx path)
          [(send [200 ~ [%json (groups:enjs groups)]]) state]
        ==
        ::
          [%apps %maat %api %lists @t ~]
        =/  id       (snag 4 `(list @t)`site)
        =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[id]/noun
        =,  .^([=group =acl =reg =led] %gx path)
        [(send [200 ~ [%json (group:enjs group)]]) state]
        ::
          [%apps %maat %api %lists @t @t ~]
        ::  get state of a group
        =/  id    (snag 4 `(list @t)`site)
        =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[id]/noun
        =/  endpoint  (snag 5 `(list @t)`site)
        =,  .^([=group =acl =reg =led] %gx path)
        ?+  endpoint
          [(send [404 ~ [%plain "404 - Not Found"]]) state]
          ::
            :: %version
          :: [(send [200 ~ [%json (version:enjs '2024-04-09.1')]]) state]
          ::
            ::%members
          ::::  FIX: does not work due to reg containing non Urbit-ID
          ::::    members which get filtered out when comparing against
          ::::    acl
          ::::
          ::=/  regmod    `(set @tas)`(silt (skim ~(tap in reg) |=(m=member ?~(`(unit @p)`(slaw %p `@t`m) %.n %.y))))
          ::=/  aclmod    `(set @tas)`(~(run in acl) |=(=@p `@tas`(scot %p p)))
          ::=/  castoffs  (~(dif in regmod) aclmod)
          ::=/  members   (~(dif in reg) castoffs)
          ::=.  members   (~(put in members) `@tas`(scot %p host.group))
          ::[(send [200 ~ [%json (members:enjs members)]]) state]
          ::::
            ::%castoffs
          ::=/  regmod    `(set @tas)`(silt (skim ~(tap in reg) |=(m=member ?~(`(unit @p)`(slaw %p `@t`m) %.n %.y))))
          ::=/  aclmod    `(set @tas)`(~(run in acl) |=(=@p `@tas`(scot %p `@t`p)))
          ::=/  castoffs   (~(dif in regmod) aclmod)
          ::[(send [200 ~ [%json (members:enjs castoffs)]]) state]
            ::::
            ::%invitees
          ::=/  aclmod    `(set @tas)`(~(run in acl) |=(=@p `@tas`(scot %p p)))
          ::=/  invitees  (~(dif in aclmod) reg)
          ::[(send [200 ~ [%json (members:enjs invitees)]]) state]
          ::::
            %tasks
          =/  val       ~(val by led)
          [(send [200 ~ [%json ~]]) state]
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
      ==
        ::
      ::
        %'PUT'
      ~&  >  '%maat-api: PUT'
      ?~  body.request.inbound-request
        [(send [418 ~ [%plain "418 - I'm a teapot"]]) state]
      ?+  site  [(send [404 ~ [%plain "404 - Not Found"]]) state]
        ::
          [%apps %maat %api %lists ~]
        ?.  auth
          [(send [401 ~ [%plain "401 - Unauthorized"]]) state]
        =/  content   (need (de:json:html q.u.body.request.inbound-request))
        =,  (group:dejs content)
        ?:  ?|
              .=(title '')
              .=(title ' ')
            ==
          [(send [422 ~ [%plain "422 - Unprocessable Entity"]]) state]
        =/  action    [%add-group [id title host=our.bowl public]]
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
        =/  id        (snag 4 `(list @t)`site)
        =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[id]/noun
        =,  .^([=group =acl =reg =led] %gx path)
        ?.  .=(our.bowl host.group)
          [(send [403 ~ [%plain "Forbidden"]]) state]
        =/  action    [%del-group id]
        :-  ^-  (list card)
          %+  snoc
            (send [200 ~ [%plain "ok"]])
          [%pass ~ %agent [our.bowl %maat] %poke %maat-action !>(action)]
        state
      ==
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
