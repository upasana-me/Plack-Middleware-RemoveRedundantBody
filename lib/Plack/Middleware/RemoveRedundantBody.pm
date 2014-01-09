package Plack::Middleware::RemoveRedundantBody;
use strict;
use warnings;
use parent qw( Plack::Middleware );

use Plack::Util;
# ABSTRACT: Plack::Middleware which sets removes body for HTTP response if it's not required

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
__END__

=head1 NAME

Plack::Middleware::RemoveRedundantBody - removes body for HTTP response if it's not required

=head1 SYNOPSIS

   use strict;
   use warnings;

   use Plack::Builder;

   my $app = sub { ...  };

   builder {
       enable "RemoveRedundantBody";
       $app;
   };

=head1 DESCRIPTION

This module removes body in HTTP response, if it's not required.

=cut
