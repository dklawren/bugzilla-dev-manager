package BugzillaDevConfig;

use strict;
use base 'Exporter';

use File::Slurp;

our @EXPORT = qw(
    $HTDOCS_PATH
    $DATA_PATH
    $REPO_PATH
    $YUI2_PATH
    $YUI3_PATH

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

    @NEVER_DISABLE_BUGMAIL

    notify_mac
);

my  $ROOT_PATH                = '/home/bugzilla/devel';
our $HTDOCS_PATH              = "$ROOT_PATH/htdocs";
our $DATA_PATH                = "$ROOT_PATH/bugzilla-dev-manager/data";
our $REPO_PATH                = "$ROOT_PATH/repos/bzr";
our $YUI2_PATH                = "$ROOT_PATH/yui2";
our $YUI3_PATH                = "$ROOT_PATH/yui3";

our $DEFAULT_BZR_HOST         = 'https://bzr.mozilla.org';
our $DEFAULT_BMO_REPO         = 'bmo/4.2';
our $DEFAULT_BMO_DB           = 'bugs_bmo';
our $BUGZILLA_TRUNK_MILESTONE = '5.0';

our $URL_BASE                 = 'http://bzweb/';
our $ATTACH_BASE              = 'http://bzweb/';
our $MODPERL_BASE             = 'http://bzweb/mod_perl/';
our $MODPERL_ATTACH_BASE      = 'http://bzweb/mod_perl/';

our $MAIL_FROM                = 'admin@mozilla.com';
our $MAINTAINER               = 'admin@mozilla.com';

our %LOCALCONFIG = (
    'cvsbin'         => '/usr/bin/cvs',
    'db_host'        => 'localhost',
    'db_pass'        => 'bugs',
    'db_port'        => '3306',
    'db_user'        => 'bugs',
    'diffpath'       => '/usr/bin',
    'interdiffbin'   => '/usr/bin/interdiff',
    'webservergroup' => 'bugzilla',
);

our %PARAMS = (
    allow_attachment_display          => 1,
    attachment_base                   => $ATTACH_BASE . '%s/',
    defaultpriority                   => '--',
    defaultseverity                   => 'normal',
    insidergroup                      => 'admin',
    mail_delivery_method              => 'Test',
    mailfrom                          => $MAIL_FROM,
    maintainer                        => $MAINTAINER,
    strict_isolation                  => 0,
    smtpserver                        => '',
    specific_search_allow_empty_words => 0,
    timetrackinggroup                 => '',
    upgrade_notification              => 'disabled',
    urlbase                           => $URL_BASE . '%s/',
    usebugaliases                     => 1,
    useclassification                 => 1,
    useqacontact                      => 1,
    user_info_class                   => 'CGI',
    usestatuswhiteboard               => 1,
    usetargetmilestone                => 1,
    webdotbase                        => '/usr/bin/dot',
);

our %TEST_PARAMS = (
    browser                           => '*firefox /usr/lib64/firefox/firefox',
    browser_url                       => 'http://centos',
    admin_user_login                  => 'admin@mozilla.com',
    admin_user_passwd                 => 'password',
    admin_user_username               => 'admin',
    permanent_user                    => 'permanent_user@mozilla.com',
    permanent_user_login              => 'permanent_user@mozilla.com',
    permanent_user_passwd             => 'password',
    unprivileged_user_login           => 'no-privs@mozilla.com',
    unprivileged_user_passwd          => 'password',
    unprivileged_user_username        => 'no-privs',
    unprivileged_user_login_truncated => 'no-privs@my',
    QA_Selenium_TEST_user_login       => 'QA-Selenium-TEST@mozilla.com',
    QA_Selenium_TEST_user_passwd      => 'password',
    editbugs_user_login               => 'editbugs@mozilla.com',
    editbugs_user_passwd              => 'password',
    canconfirm_user_login             => 'canconfirm@mozilla.com',
    canconfirm_user_passwd            => 'password',
    tweakparams_user_login            => 'tweakparams@mozilla.com',
    tweakparams_user_login_truncated  => 'tweakparams@my',
    tweakparams_user_passwd           => 'password',
    disabled_user_login               => 'disabled@mozilla.com',
    disabled_user_passwd              => 'password',
    common_email                      => '@mozilla.com',
    test_extensions                   => 1,
);

our %PARAMS_BMO = (
    password_complexity => 'letters_numbers',
    user_info_class     => 'Persona,CGI',
);

our @NEVER_DISABLE_BUGMAIL = qw(
    dkl@mozilla.com
    dklawren@hotmail.com
);

sub notify_mac {
    my $message = shift;
=cut
    my @title = split /\000/, read_file('/proc/self/cmdline');
    shift @title;     # perl
    $title[0] = 'bz'; # script
    my $title = join(' ', @title);

    # growl
    system(
        'ssh',
        'byron@mac',
        join(
            ' ',
            (
                'echo',
                sprintf('"(%s) %s"', $title, $message),
                '|',
                '/usr/local/bin/growlnotify',
            )
        )
    );

    # terminal-notifier
    system(
        'ssh',
        'byron@mac',
        join(
            ' ',
            (
                '/usr/local/bin/terminal-notifier',
                '-sound Pop',
                '-activate com.googlecode.iterm2',
                '-title "' . $title . '"',
                '-message "' . $message . '"',
            )
        )
    );
=cut
}

1;
