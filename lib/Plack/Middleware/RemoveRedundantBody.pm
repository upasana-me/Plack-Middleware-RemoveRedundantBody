package Plack::Middleware::RemoveRedundantBody;
use strict;
use warnings;
use parent qw( Plack::Middleware );

use Plack::Util;

sub call {
    my ($self, $env) = @_;

    my $res = $self->app->($env);

    return $self->response_cb($res, sub {
        my $response = shift;
        my $status = $response->[0];
        my $headers = Plack::Util::headers($response->[1]); # first index contains HTTP header
        if( $status =~ /^(1\d\d|[23]04)$/ ) {
            $response->[2] = [];
            $headers->remove("Content-Length");
            return $response;
	}
    });
}

1;
