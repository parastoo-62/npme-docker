#!/bin/bash

# whenever we boot a new copy of the docker image, we remove the
# base copy of npm-explicit-installs and replace it with a copy
# that is linked on the host machine. This allows permanent edits
# to be made to the package listing page.
if [ ! -d "/etc/npme/data/npm-explicit-installs" ]; then
  mv /etc/npme/node_modules/npm-explicit-installs /etc/npme/data/npm-explicit-installs
fi
rm -rf /etc/npme/node_modules/@npm/website/node_modules/npm-explicit-installs
ln -f -s /etc/npme/data/npm-explicit-installs /etc/npme/node_modules/@npm/website/node_modules

{ cd /etc/npme/node_modules/@npm/npmo-web-proxy; node ./bin/npmo-web-proxy.js start --auth-host=$AUTH_HOST; } &
{ cd /etc/npme/node_modules/@npm/website; node server.js; } &
{ cd /etc/npme/node_modules/oauth2-server-pg; npm run migrate -- up; node bin/oauth2-server-pg.js start --private-routes; } &
{ cd /etc/npme/node_modules/@npm/npmo-auth-callbacks; node bin/npmo-auth-callbacks.js start --certificate=$CERTIFICATE --redis=$REDIS_URL --entity-id=$ENTITY_ID --assert-endpoint=$ASSERT_ENDPOINT --logout-endpoint=$LOGOUT_ENDPOINT --nameid-format=$NAMEID_FORMAT --sso-login-url=$SSO_LOGIN_URL --sso-logout-url=$SSO_LOGOUT_URL; } &
{ cd /etc/npme/node_modules/@npm/annotation-api; node bin/annotation-api.js start --redis-url=$REDIS_URL; } &
wait -n
kill 0
exit 1
