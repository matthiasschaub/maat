/-  *maat
/+  dbug
/+  verb
/+  default-agent
/+  server                    :: HTTP request processing
/+  schooner                  :: HTTP response handling
::
/*  html-index                %html   /app/ui/html/index/html
/*  html-tasks                %html   /app/ui/html/tasks/html
/*  html-tasks-public         %html   /app/ui/html/tasks-public/html
/*  html-create               %html   /app/ui/html/create/html
/*  html-invites              %html   /app/ui/html/invites/html
/*  html-invite               %html   /app/ui/html/invite/html
/*  html-settings             %html   /app/ui/html/settings/html
/*  html-about                %html   /app/ui/html/about/html
/*  html-edit-list            %html   /app/ui/html/edit-list/html
/*  html-edit-task            %html   /app/ui/html/edit-task/html
/*  html-show-task            %html   /app/ui/html/show-task/html
/*  css-udjat                 %css    /app/ui/css/udjat/css
/*  css-style                 %css    /app/ui/css/style/css
/*  svg-circles               %svg    /app/ui/svg/circles/svg
/*  svg-circle                %svg    /app/ui/svg/circle/svg
/*  svg-circle-checked        %svg    /app/ui/svg/circle-checked/svg
/*  svg-circle-plus           %svg    /app/ui/svg/circle-plus/svg
/*  svg-circle-question       %svg    /app/ui/svg/circle-question/svg
/*  svg-icon                  %svg    /app/ui/svg/icon/svg
/*  png-icon-16               %png    /app/ui/png/16/png
/*  png-icon-180              %png    /app/ui/png/180/png
/*  ttf-soria                 %ttf    /app/ui/ttf/soria/ttf
/*  js-index                  %js     /app/ui/js/index/js
/*  js-helper                 %js     /app/ui/js/helper/js
/*  js-edit-task              %js     /app/ui/js/edit-task/js
/*  js-htmx                   %js     /app/ui/js/htmx/js
/*  js-json-enc               %js     /app/ui/js/json-enc/js
/*  js-path-deps              %js     /app/ui/js/path-deps/js
/*  js-client-side-templates  %js     /app/ui/js/client-side-templates/js
/*  json-manifest             %json   /app/ui/json/manifest/json
::
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  state-0
  ==
+$  state-0  [%0 page=@t]
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
      :*  %pass  /bind  %arvo  %e
          %connect  `/apps/maat  %maat-ui
      ==
    ==
  %=  this
    page  'Hello World'
  ==
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
    =/  hx-req=?
      ?~  (get-header:http 'hx-request' header-list.request.inbound-request)
        %.n
      %.y
    =/  request-line
      (parse-request-line:server url.request.inbound-request)
    =+  site=site.request-line
    =+  ext=ext.request-line
    =+  send=(cury response:schooner eyre-id)
    =+  auth=authenticated.inbound-request
    =/  group=(unit group)
      ?.  (gte (lent site) 4)
        ~
      =/  gid   (snag 3 site)
      =/  path  /(scot %p our.bowl)/maat/(scot %da now.bowl)/[gid]/noun
      =,  .^([=group =acl =reg =led] %gx path)
      (some group)
    =/  public=?
      ?^  group
        public:(need group)
      ?~  ext
        %.n
      ?+  +.ext  %.n
        %css    %.y
        %js     %.y
        %ttf    %.y
        %woff2  %.y
        %png    %.y
        %svg    %.y
        %json   %.y
      ==
    ?.  ?|(auth public)
      ?.  hx-req
        [(send [302 ~ [%login-redirect './apps/maat']]) state]
      [(send [200 ~ [%hx-login-redirect './apps/maat']]) state]
    ?.  =(method.request.inbound-request %'GET')
      [(send [405 ~ [%plain "405 - Method Not Allowed"]]) state]
    ?+  site  [(send [404 ~ [%plain "404 - Not Found"]]) state]
      ::
      [%apps %maat ~]
        [(send [200 ~ [%html html-index]]) state]
      [%apps %maat %invites ~]
        [(send [200 ~ [%html html-invites]]) state]
      ::  css
      ::
      [%apps %maat %udjat ~]
        [(send [200 ~ [%css css-udjat]]) state]
      [%apps %maat %style ~]
        [(send [200 ~ [%css css-style]]) state]
      ::  svg
      ::
      [%apps %maat %circles ~]
        [(send [200 ~ [%svg svg-circles]]) state]
      [%apps %maat %circle ~]
        [(send [200 ~ [%svg svg-circle]]) state]
      [%apps %maat %circle-checked ~]
        [(send [200 ~ [%svg svg-circle-checked]]) state]
      [%apps %maat %circle-plus ~]
        [(send [200 ~ [%svg svg-circle-plus]]) state]
      [%apps %maat %circle-question ~]
        [(send [200 ~ [%svg svg-circle-question]]) state]
      [%apps %maat %icon ~]
        [(send [200 ~ [%svg svg-icon]]) state]
      ::  png
      ::
      [%apps %maat %icon180 ~]
        [(send [200 ~ [%png png-icon-180]]) state]
      [%apps %maat %icon16 ~]
        [(send [200 ~ [%png png-icon-16]]) state]
      ::  woff2
      ::
      [%apps %maat %soria ~]
        :: [(send [200 ~ [%font-ttf q.dat.ttf-soria]]) state]
        [(send [200 ~ [%font-ttf q.ttf-soria]]) state]
      ::  js
      ::
      [%apps %maat %index ~]
        [(send [200 ~ [%js js-index]]) state]
      [%apps %maat %create ~]
        [(send [200 ~ [%html html-create]]) state]
      [%apps %maat %helper ~]
        [(send [200 ~ [%js js-helper]]) state]
      [%apps %maat %edit-task ~]
        [(send [200 ~ [%js js-edit-task]]) state]
      [%apps %maat %htmx ~]
        [(send [200 ~ [%js js-htmx]]) state]
      [%apps %maat %json-enc ~]
        [(send [200 ~ [%js js-json-enc]]) state]
      [%apps %maat %path-deps ~]
        [(send [200 ~ [%js js-path-deps]]) state]
      [%apps %maat %client-side-templates ~]
        [(send [200 ~ [%js js-client-side-templates]]) state]
      ::  json
      ::
      [%apps %maat %manifest ~]
        [(send [200 ~ [%json json-manifest]]) state]
      ::  html
      ::
      [%apps %maat %lists @t %tasks @t %edit ~]
        ?:  auth
          [(send [200 ~ [%html html-edit-task]]) state]
        ?.  hx-req
          [(send [302 ~ [%login-redirect './apps/maat']]) state]
        [(send [200 ~ [%hx-login-redirect './apps/maat']]) state]
      [%apps %maat %lists @t %tasks @t %show ~]
        [(send [200 ~ [%html html-show-task]]) state]
      [%apps %maat %lists @t @t ~]
        =/  endpoint  (snag 4 `(list @t)`site)
        ?+  endpoint  [(send [404 ~ [%plain "404 - Not Found"]]) state]
          %tasks
            ?:  auth
              [(send [200 ~ [%html html-tasks]]) state]
            [(send [200 ~ [%html html-tasks-public]]) state]
          %settings
            ?:  auth
              [(send [200 ~ [%html html-settings]]) state]
            ?.  hx-req
              [(send [302 ~ [%login-redirect './apps/maat']]) state]
            [(send [200 ~ [%hx-login-redirect './apps/maat']]) state]
          %about
            [(send [200 ~ [%html html-about]]) state]
          %edit
            ?:  auth
              [(send [200 ~ [%html html-edit-list]]) state]
            ?.  hx-req
              [(send [302 ~ [%login-redirect './apps/maat']]) state]
            [(send [200 ~ [%hx-login-redirect './apps/maat']]) state]
          %invite
            ?:  auth
              [(send [200 ~ [%html html-invite]]) state]
            ?.  hx-req
              [(send [302 ~ [%login-redirect './apps/maat']]) state]
            [(send [200 ~ [%hx-login-redirect './apps/maat']]) state]
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
    %eyre-rejected-maat-ui-bind
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
