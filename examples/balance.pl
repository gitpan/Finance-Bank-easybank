#!/usr/bin/perl

# $Id: balance.pl,v 1.1 2003/01/28 08:53:32 florian Exp $

use Finance::Bank::easybank;

use strict;
use warnings;

my $agent = Finance::Bank::easybank->new(
	user          => 'xxx',
	pass          => 'xxx',
	return_floats => 1,

	accounts      => [ qw/
		200XXXXXXXX
		/ ],
);

my $accounts = $agent->check_balance;

foreach my $account (@{$accounts}) {
        printf("%11s: %25s\n", $_->[0], $account->{$_->[1]})
                for(( [ qw/ Kontonummer account / ],
                      [ qw/ BLZ bc / ],
                      [ qw/ Bezeichnung name / ],
                      [ qw/ Datum date / ],
                      [ qw/ Waehrung currency / ]
                ));
        printf("%11s: %25.2f\n", $_->[0], $account->{$_->[1]})
		for(( [ qw/ Saldo balance / ],
                      [ qw/ Dispo final / ]
                ));
        print "\n";
}
