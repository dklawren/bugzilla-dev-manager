package Bz::LocalPatches;
use Bz;

use File::Slurp;

use constant PATCHES => (
    {
        desc    => '__DIE__ handler',
        file    => 'Bugzilla.pm',
        apply   => {
            match   => sub { /^# ?\$::SIG{__DIE__} = i_am_cgi/ },
            action  => sub { s/^#\s*// },
        },
        revert  => {
            match   => sub { /^\$::SIG{__DIE__} = i_am_cgi/ },
            action  => sub { s/^/#/ },
        },
    },
    {
        desc    => 't/012 warnings to errors',
        file    => 't/012throwables.t',
        apply   => {
            match   => sub { /^\s+ok\(1, "--WARNING \$file has " \. scalar\(\@errors\)/ },
            action  => sub { s/ok\(1,/ok\(0,/ },
        },
        revert  => {
            match   => sub { /^\s+ok\(0, "--WARNING \$file has " \. scalar\(\@errors\)/ },
            action  => sub { s/ok\(0,/ok\(1,/ },
        },
    },
    {
        desc    => 'mod_perl sizelimit',
        file    => 'mod_perl.pl',
        apply   => {
            match   => sub { /^\s+Apache2::SizeLimit->set_max_unshared_size\(250_000\)/ },
            action  => sub { s/\(250_000\)/(1_000_000)/ },
        },
        revert  => {
            match   => sub { /^\s+Apache2::SizeLimit->set_max_unshared_size\(1_000_000\)/ },
            action  => sub { s/\(1_000_000\)/(250_000)/ },
        },
    },
    {
        desc    => '.htaccess',
        file    => '.htaccess',
        whole   => 1,
        apply   => {
            match   => sub { /\n\s*RewriteEngine On\n(?!\s*RewriteBase)/ },
            action  => sub { my $dir = $_[0]->dir; s/(\n(\s*)RewriteEngine On\n)/$1$2RewriteBase \/$dir\/\n/ },
        },
        revert   => { 
            match   => sub { /\n\s*RewriteEngine On\n\s*RewriteBase/ },
            action  => sub { s/(\n\s*RewriteEngine On)\n\s*RewriteBase [^\n]+/$1/ },
        },
    },
    {
        desc    => 'BugzillaTitle',
        file    => 'extensions/BMO/template/en/default/hook/global/variables-end.none.tmpl',
        apply   => {
            match   => sub { /Bugzilla\@Mozilla/ },
            action  => sub { s/Bugzilla\@Mozilla/Bugzilla\@Development/ },
        },
        revert  => {
            match   => sub { /Bugzilla\@Development/ },
            action  => sub { s/Bugzilla\@Development/Bugzilla\@Mozilla/ },
        },
    },
    {
        desc    => 'TimeDate version',
        file    => 'Bugzilla/Install/Requirements.pm',
        whole   => 1,
        apply   => {
            match  => sub { /\n\s*module\s*=>\s*\'Date::Format\',\n\s*version\s*=>\s*\'2\.23\'/  },
            action => sub { s/(\n\s*module\s*=>\s*\'Date::Format\',\n\s*version\s*=>\s*)\'2\.23\'/$1\'2\.22\'/ },
        },
        revert  => {
            match  => sub { /\n\s*module\s*=>\s*\'Date::Format\',\n\s*version\s*=>\s*\'2\.22\'/  },
            action => sub { s/(\n\s*module\s*=>\s*\'Date::Format\',\n\s*version\s*=>\s*)\'2\.22\'/$1\'2\.23\'/ },
        },
    },
    {
        desc    => 'DateTime version',
        file    => 'Bugzilla/Install/Requirements.pm',
        whole   => 1,
        apply   => {
            match  => sub { /\n\s*module\s*=>\s*\'DateTime\',\n\s*version\s*=>\s*\'0\.75\'/  },
            action => sub { s/(\n\s*module\s*=>\s*\'DateTime\',\n\s*version\s*=>\s*)\'0\.75\'/$1\'0\.28\'/ },
        },
        revert  => {
            match  => sub { /\n\s*module\s*=>\s*\'DateTime\',\n\s*version\s*=>\s*\'0\.28\'/  },
            action => sub { s/(\n\s*module\s*=>\s*\'DateTime\',\n\s*version\s*=>\s*)\'0\.28\'/$1\'0\.75\'/ },
        },
    },
    {
        desc    => 'DateTime-TimeZone version',
        file    => 'Bugzilla/Install/Requirements.pm',
        whole   => 1,
        apply   => {
            match  => sub { /\n\s*module\s*=>\s*\'DateTime::TimeZone\',\n\s*version\s*=>\s*\'1\.64\'/  },
            action => sub { s/(\n\s*module\s*=>\s*\'DateTime::TimeZone\',\n\s*version\s*=>\s*)\'1\.64\'/$1\'0\.71\'/ },
        },
        revert  => {
            match  => sub { /\n\s*module\s*=>\s*\'DateTime::TimeZone\',\n\s*version\s*=>\s*\'0\.71\'/  },
            action => sub { s/(\n\s*module\s*=>\s*\'DateTime::TimeZone\',\n\s*version\s*=>\s*)\'0\.71\'/$1\'1\.64\'/ },
        },
    },
);

sub apply {
    my ($class, $workdir) = @_;
    $class->_patch($workdir, 'apply');
}

sub revert {
    my ($class, $workdir) = @_;
    $class->_patch($workdir, 'revert');
}

sub _patch {
    my ($class, $workdir, $mode) = @_;

    chdir($workdir->path);
    foreach my $patch (PATCHES) {
        next unless-e $patch->{file};
        my $match  = $patch->{$mode}->{match};
        my $action = $patch->{$mode}->{action};

        if ($patch->{whole}) {
            $_ = read_file($patch->{file});
            next unless $match->($workdir);
            message(($mode eq 'revert' ? 'reverting' : 'applying') . " patch " . $patch->{desc});
            $action->($workdir);
            write_file($patch->{file}, $_);
        } else {
            my @file = read_file($patch->{file});
            foreach (@file) {
                next unless $match->($workdir);
                message(($mode eq 'revert' ? 'reverting' : 'applying') . " patch " . $patch->{desc});
                $action->($workdir);
            }
            write_file($patch->{file}, @file);
        }
    }
}

1;
