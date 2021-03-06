use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

subtest 'pass within routes' => sub {
    {

        package App;
        use Dancer2;

        get '/' => sub { 'hello' };
        get '/**' => sub {
            response_header 'X-Pass' => 'pass';
            pass;
            redirect '/'; # won't get executed as pass returns immediately.
        };
        get '/pass' => sub {
            return "the baton";
        };
    }

    my $app = App->to_app;
    ok( is_coderef($app), 'Got app' );

    test_psgi $app, sub {
        my $cb = shift;

        {
            my $res = $cb->( GET '/pass' );
            is( $res->code, 200, '[/pass] Correct status' );
            is( $res->content, 'the baton', '[/pass] Correct content' );
            is(
                $res->headers->header('X-Pass'),
                'pass',
                '[/pass] Correct X-Pass header',
            );
        }
    };

};

done_testing;
