# These are checks that can be run by the nagios server.
class nova::api::nagios_checks {
  nagios::command {
    'check_ec2_ssl':
      check_command =>
        '/usr/lib/nagios/plugins/check_http --ssl -u /services/Cloud/ -p \'$ARG1$\' -e 400 -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
    'check_ec2':
      check_command =>
        '/usr/lib/nagios/plugins/check_http -u /services/Cloud/ -p \'$ARG1$\' -e 400 -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
    'check_novnc':
      check_command =>
        '/usr/lib/nagios/plugins/check_http -p \'$ARG1$\' -e 200,404 -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
  }
}
