# $Id: Makefile.PL,v 1.1 2003/01/28 08:53:30 florian Exp $

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Finance::Bank::easybank',
    'VERSION_FROM'	=> 'lib/Finance/Bank/easybank.pm',
    'PREREQ_PM'		=> {
    	'WWW::Mechanize'      => 0.35,
	'HTML::TokeParser'    => 2.24,
	'Class::MethodMaker'  => 1.06,
    	},
    'dist'              => {
    	'COMPRESS'            => 'gzip --force --best'
        },
);
