package BugzillaDevConfig;

use strict;
use base 'Exporter';

our @EXPORT = qw(
    $HTDOCS_PATH
    $DATA_PATH
    $REPO_PATH
    $YUI_PATH

    $DEFAULT_BZR_HOST
    $DEFAULT_BMO_REPO
    $DEFAULT_BMO_DB
    $BUGZILLA_TRUNK_MILESTONE

    $URL_BASE
    $ATTACH_BASE
    $MODPERL_BASE
    $MODPERL_ATTACH_BASE

    $MAIL_FROM
    $MAINTAINER

    %LOCALCONFIG
    %PARAMS
    %TEST_PARAMS
    %PARAMS_BMO

    GROWL
);

our $HTDOCS_PATH              = '/home/dkl/devel/htdocs';
our $DATA_PATH                = '/home/dkl/devel/repos/git/bugzilla-dev-manager/data';
our $REPO_PATH                = '/home/dkl/devel/repos/bzr';
our $YUI_PATH                 = '/home/dkl/devel/yui';

our $DEFAULT_BZR_HOST         = 'https://bzr.mozilla.org';
our $DEFAULT_BMO_REPO         = 'bmo/4.0';
our $DEFAULT_BMO_DB           = 'bugs_bmo';
our $BUGZILLA_TRUNK_MILESTONE = '4.4';

our $URL_BASE                 = 'http://centos/';
our $ATTACH_BASE              = 'http://centos/';
our $MODPERL_BASE             = 'http://centos/mod_perl/';
our $MODPERL_ATTACH_BASE      = 'http://centos/mod_perl/';

our $MAIL_FROM                = 'admin@mozilla.com';
our $MAINTAINER               = 'admin@mozilla.com';

our %LOCALCONFIG = (
    'db_host' => 'centosdb',
    'db_port' => '3306',
    'db_user' => 'bugs',
    'db_pass' => 'bugs',
    'cvsbin' => '/usr/bin/cvs',
    'interdiffbin' => '/usr/bin/interdiff',
    'diffpath' => '/usr/bin',
    'webservergroup' => 'dkl',
);

our %PARAMS = (
    allow_attachment_display => 1,
    attachment_base => $ATTACH_BASE . '%s/',
    defaultpriority => '--',
    defaultseverity => 'normal',
    insidergroup => 'admin',
    mail_delivery_method => 'Test',
    mailfrom => $MAIL_FROM,
    maintainer => $MAINTAINER,
    strict_isolation => 0, 
    smtpserver => '',
    specific_search_allow_empty_words => 0,
    timetrackinggroup => '',
    upgrade_notification => 'disabled',
    urlbase => $URL_BASE . '%s/',
    usebugaliases => 1,
    useclassification => 1,
    useqacontact => 1,
    user_info_class => 'CGI',
    usestatuswhiteboard => 1,
    usetargetmilestone => 1,
);

our %TEST_PARAMS = (
    'browser'                           => '*firefox /usr/lib64/firefox/firefox',
    'browser_url'                       => 'http://centos',
    'admin_user_login'                  => 'admin@mozilla.com',
    'admin_user_passwd'                 => 'password',
    'admin_user_username'               => 'admin',
    'permanent_user'                    => 'permanent_user@mozilla.com',
    'permanent_user_login'              => 'permanent_user@mozilla.com', 
    'permanent_user_passwd'             => 'password', 
    'unprivileged_user_login'           => 'no-privs@mozilla.com',
    'unprivileged_user_passwd'          => 'password',
    'unprivileged_user_username'        => 'no-privs',
    'unprivileged_user_login_truncated' => 'no-privs@my',
    'QA_Selenium_TEST_user_login'       => 'QA-Selenium-TEST@mozilla.com',
    'QA_Selenium_TEST_user_passwd'      => 'password',
    'editbugs_user_login'               => 'editbugs@mozilla.com',
    'editbugs_user_passwd'              => 'password',
    'canconfirm_user_login'             => 'canconfirm@mozilla.com',
    'canconfirm_user_passwd'            => 'password',
    'tweakparams_user_login'            => 'tweakparams@mozilla.com',
    'tweakparams_user_login_truncated'  => 'tweakparams@my',
    'tweakparams_user_passwd'           => 'password',
    'disabled_user_login'               => 'disabled@mozilla.com',
    'disabled_user_passwd'              => 'password',
    'common_email'                      => '@mozilla.com',
    'test_extensions'                   => 1, 
);

our %PARAMS_BMO = (
    user_info_class => 'Persona,CGI',
);

sub GROWL {
    my $message = shift;
    #system "ssh byron\@mac 'echo \"$message\"|/usr/local/bin/growlnotify'";
    #system "/usr/bin/notify-send $message";
}

1;
