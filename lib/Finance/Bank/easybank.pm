# $Id: easybank.pm,v 1.3 2003/01/28 10:03:11 florian Exp $

package Finance::Bank::easybank;

require 5.005_62;
use strict;
use warnings;

use WWW::Mechanize;
use HTML::TokeParser;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [ qw/ user pass / ],
  boolean       => 'return_floats',
  list          => 'accounts';

our $VERSION = '0.01';


sub check_balance {
	my $self  = shift;
	my $agent = WWW::Mechanize->new;
	my @accounts;

	die "Need user to connect.\n" unless $self->user;
	die "Need password to connect.\n" unless $self->pass;

	$agent->get('https://ebanking.easybank.at/InternetBanking/EASYBANK_webbank_de.html');
	$agent->follow(2);
	$agent->form(1);
	$agent->field('tn', $self->user);
	$agent->field('pin', $self->pass);
	$agent->click('Bsenden1');

	push @accounts, $self->_parse_summary($agent->{content});

	foreach my $account ($self->accounts) {
		$agent->form(1);
		$agent->field('selected-account', $account);
		$agent->click;

		push @accounts, $self->_parse_summary($agent->{content});
	}

	\@accounts;
}


sub _parse_summary {
	my ($self, $content) = @_;
	my $stream           = HTML::TokeParser->new(\$content);
	my %data;

	$stream->get_tag('table') for 1 .. 2;
	$stream->get_tag('td') for 1 .. 2;
	for(qw/bc account currency name date/) {
		$data{$_} = $stream->get_trimmed_text('/td');
		$stream->get_tag('td');
	}

	# only jump one table down, because of the last jump to td
	# in the last loop.
	$stream->get_tag('table');
	$stream->get_tag('b');
	$data{balance} = $stream->get_trimmed_text('/b');
	$stream->get_tag('b') for 1 .. 2;
	$data{final} = $stream->get_trimmed_text('/b');

	if($self->return_floats) {
		$data{$_} = $self->_scalar2float($data{$_}) for qw/balance final/;
	}

	\%data;
}


sub _scalar2float {
	my($self, $scalar) = @_;

	$scalar =~ s/\.//g;
	$scalar =~ s/,/\./g;

	return $scalar;
}


1;
__END__

=head1 NAME

Finance::Bank::easybank - check your easybank accounts from Perl

=head1 SYNOPSIS

  # look for this script in the examples directory of the
  # tar ball.
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

=head1 DESCRIPTION

This module provides a basic interface to the online banking system of
the easybank at C<http://www.easybank.at>.

Please note, that you will need either C<Crypt::SSLeay> or C<IO::Socket::SSL>
installed for working HTTPS support of LWP.

=head1 METHODS

=over

=item check_balance

Queries the via user and pass defined account - and all other defined
accounts - and returns a reference to a list of hashes containing all
fetched information:

 $VAR = [
          {
            'bc'        => bank code
            'account'   => account number
            'name'      => name of the account
            'date'      => date shown on the summary page
	                   (format: DD.MM.YYYY/hh:mm)
            'currency'  => currency
            'balance'   => account balance
            'final'     => final account balance
          }
	];

=back

=head1 ATTRIBUTES

All attributes are implemented by C<Class::MethodMaker>, so please take a
look at its man page for further information about the created accessor
methods.

=over

=item user

User to connect with (Verfuegernummer).

=item pass

Password to connect with (Pin).

=item accounts

Optional list of additional accounts to query. This list should contain
only account numbers formated in exactly the same way as they are listed
in the online banking system.

=item return_floats

Boolean value defining wether the module returns the balance as signed
float or just as it gets it from the online banking system (default:
false).

=back

=head2 WARNING

This is code for B<online banking>, and that means B<your money>, and that
means B<BE CAREFUL>. You are encouraged, nay, expected, to audit the source 
of this module yourself to reassure yourself that I am not doing anything 
untoward with your banking data. This software is useful to me, but is 
provided under B<NO GUARANTEE>, explicit or implied.

=head1 CAVEATS

I did'nt had the change of testing this module against an account mapped
to only one bank account.

It woule be very nice if someone with only one bank account could test
this module and drop me note about the results.

Also take note that this module can break easily if easybank changes the
layout of the online banking system.

=head1 THANKS

Simon Cozens <simon@cpan.org> for Finance::Bank::LloydsTSB from which I've
borrowed the warning message.

Chris Ball <chris@cpan.org> for his article about screen-scraping with
C<WWW::Mechanize> at C<http://www.perl.com/pub/a/2003/01/22/mechanize.html>.

=head1 AUTHOR

Florian Helmberger <fh@laudatio.com>

=head1 VERSION

$Id: easybank.pm,v 1.3 2003/01/28 10:03:11 florian Exp $

=head1 COPYRIGHT AND LICENCE

You may distribute under the terms of either the GNU General Public
License or the Artistic License, as specified in the Perl README file.

Copyright (C) 2003 Florian Helmberger

=head1 SEE ALSO

L<WWW::Mechanize>, L<HTML::TokeParse>, L<Class::MethodMaker>.

=cut
