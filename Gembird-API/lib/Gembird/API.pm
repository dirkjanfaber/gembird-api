package Gembird::API;
use Dancer ':syntax';
use JSON;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

set serializer => 'JSON';

get '/switch/:switch' => sub {
  
  return { 'message' => 'hello world' };
};

get '/state/:switch?' => sub {
  # Get state of one or all switches
  my $state;
  map {
    chomp;
    if ( $_ =~ m/\[dev: (\d+)\]\[outlet: (\d+)\] is (on|off)/ ) {
      if ( params->{'switch'} ) {
        params->{'switch'} == $2  && push @{$state->{$1}}, { $2 => $3 };
      } else {
        push @{$state->{'devices'}->{$1}}, {
          'outlet' => $2
        , 'state' => $3 };
      }
    }
  } `/usr/local/bin/sispwctrl -s`;

  defined $state->{'devices'}->{'1'} || return { error => 'No gembird device found' };

  return $state;
};

true;
