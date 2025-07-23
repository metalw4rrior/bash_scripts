#!/bin/bash
/usr/bin/php /var/www/glpi/bin/console glpi:plugin:activate gappessentials
/usr/bin/php /var/www/glpi/bin/console glpi:plugin:activate telegrambot
/usr/bin/php /var/www/glpi/bin/console glpi:plugin:activate glpiinventory

# paste this in crontab -- */5 * * * * /usr/local/bin/force_enable_plugins.sh >> /var/log/glpi_plugin_force.log 2>&1
