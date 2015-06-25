package Bz::Bugzilla;
use Bz;
use Moo;

use Bz::Bugzilla;
use REST::Client;
use JSON::XS qw(decode_json);

use constant BUG_FIELDS => qw(
    id
    product
    version
    target_milestone
    summary
    status
    resolution
    assigned_to
);

has _proxy          => ( is => 'lazy' );
has _bug_cache      => ( is => 'rw', default => sub { {} } );

sub _build__proxy {
    my ($self) = @_;
    return REST::Client->new(
        host => "https://bugzilla.mozilla.org"
    );
}

sub bug {
    my ($self, $bug_id) = @_;
    die "missing id" unless $bug_id;

    if (!exists $self->_bug_cache->{$bug_id}) {
        my $uri = URI->new();
        $uri->query_form({
            include_fields => join(',', BUG_FIELDS),
        });
        my $response = $self->_call(
            'GET',
            "/rest/bug/$bug_id" . $uri->as_string
        );
        $self->_bug_cache->{$bug_id} = $response->{bugs}->[0];
    }
    return $self->_bug_cache->{$bug_id};
}

sub bugs {
    my ($self, $bug_ids) = @_;
    die "missing ids" unless $bug_ids && @$bug_ids;

    my @fetch_ids;
    foreach my $bug_id (@$bug_ids) {
        push @fetch_ids, $bug_id unless exists $self->_bug_cache->{$bug_id};
    }

    if (@fetch_ids) {
        my $uri = URI->new();
        $uri->query_form({
            bug_id         => join(',', @fetch_ids),
            include_fields => join(',', BUG_FIELDS),
        });
        my $response = $self->_call(
            'GET',
            '/rest/bug' . $uri->as_string
        );
        foreach my $bug (@{ $response->{bugs} }) {
            $self->_bug_cache->{$bug->{id}} = $bug;
        }
    }

    my @response;
    foreach my $bug_id (@$bug_ids) {
        push @response, $self->_bug_cache->{$bug_id};
    }
    return \@response;
}

sub user {
    my ($self, $login) = @_;
    die "missing login" unless $login;

    my $uri = URI->new();
    $uri->query_form({
        include_fields => [ 'name', 'real_name' ],
    });
    my $response = $self->_call(
        'GET',
        "/rest/user/$login" . $uri->as_string
    );
    return unless ref $response;
    return {
        login   => $response->{users}->[0]->{name},
        name    => $response->{users}->[0]->{real_name},
    };
}

sub attachments {
    my ($self, $bug_id) = @_;
    die "missing bug_id" unless $bug_id;
    my $uri = URI->new();
    $uri->query_form({
        exclude_fields => [ 'data' ],
    });
    return $self->_call(
        'GET',
        "/rest/bug/$bug_id/attachment" . $uri->as_string
    )->{bugs}->{$bug_id} // [];
}

sub attachment {
    my ($self, $attach_id) = @_;
    die "missing attach_id" unless $attach_id;
    my $attachments = $self->_call(
        'GET',
        "/rest/bug/attachment/$attach_id"
    );
    return $attachments->{attachments}->{$attach_id}
        || die "failed to get attachment $attach_id information\n"
}

sub _call {
    my ($self, $method, $url, $content) = @_;
    die "Bugzilla API key not found\n"
        unless Bz->config->bugzilla_api_key;
    $self->_proxy->request($method, $url, $content, {
        'Accept'             => 'application/json',
        'Content-Type'       => 'application/json',
        'X-Bugzilla-API-Key' => Bz->config->bugzilla_api_key
    });
    my $json;
    eval {
        $json = decode_json($self->_proxy->responseContent);
    };
    $@ && die "Invalid JSON content $@: " . $self->_proxy->responseContent; 
    return $json;
}

1;
