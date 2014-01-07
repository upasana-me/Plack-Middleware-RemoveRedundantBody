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
            if( _is_body_set( $response ) ) {
                # $c->log->debug('Removing body for informational or no content http responses');
                $response->[2] = [];
                $headers->remove("Content-Length");
            }
	}
    });
}

sub _is_body_set {
    my $response_ref = shift;
    my @response = @$response_ref;
    if( scalar( @response ) == 3 ) {
        my $body_ref = $response[2];
        my $body_ref_type = ref( $body_ref );
        if( $body_ref_type eq "ARRAY" ) {
            my @body = @$body_ref;
            if( scalar( @body ) == 0 ) {
                # if size of the body array is 0, then it's not set, so return false
                return 0;
            } else {
                foreach my $element ( @body ) {
                    if( $element ) {
                        # if even a single $element is set, then body is set, so return true
                        return 1;
                    }
                }
                # flow will reach this statement only after traversing
                # the whole body array in above foreach loop, which means that
                # no element is set in the body array, so return false
                return 0;
            }
        } elsif( $body_ref_type eq "GLOB" ) {
            if( -z $body_ref ) {
                return 0;
            } else {
                return 1;
            }
        }
    }
}

1;
