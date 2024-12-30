#!usr/local/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval);

my $start_time = [gettimeofday];

my $elapsed = tv_interval($start_time);

my $s = 4.5;
my $m = 13;

my $p_a_e = $s * $m;

my ($years, $type, $cash, $negotiate, $no_kasko ) = @ARGV;

if ( !defined $years || !defined $type ) {

	print "Please provide YEARS exploitation and TYPE of car\n";
	return 0;
}

my $annum_costs = {
	old => {
		grazhdanska 	=> 360,
		change_tyres	=> 220,  
		road_tax	=> 100,
		car_tax		=> 100, 
		oil_change	=> 350, 
		washing		=> 100, 
		kasko		=> 1,
	},
	new => {
		grazhdanska 	=> 360,
		change_tyres	=> 220,  
		road_tax	=> 100,
		car_tax		=> 100, 
		oil_change	=> 350, 
		washing		=> 100, 
		kasko		=> 1,
	},
};
$annum_costs = $annum_costs->{$type};

my $km_a 	= 20000;
my $fuel_price 	= 2.6;
my $consumption = 5.5;

my $fuel_a = ($km_a/100) * $consumption * $fuel_price;

$annum_costs->{fuel} = $fuel_a;

my $initial_costs = {
	new => {
		tyres 		=> 600,
		register 	=> 300,
		product_tax 	=> 125,
		leasing 	=> 533,
		initial		=> $negotiate ? 39000 : 40000,
		notary		=> 600,
	},
	old => {
		tyres 		=> 600,
		register 	=> 300,
		product_tax 	=> 125,
		leasing 	=> 0,
		initial		=> 27000,
	},
};
$initial_costs = $initial_costs->{$type};

my $selling_price = {
	new => {
		5 	=> 27000,
		10 	=> 17000,
		15 	=> 10000,
	},
	old => {
		5 	=> 17000,
		10 	=> 10000,
		15 	=> 6000,
	},
};
$selling_price = $selling_price->{$type};

my $monthly = 0;
my $total = 0;

if ( $cash) {

	$initial_costs->{leasing} = 0;
	$initial_costs->{notary} = 0;
}

foreach ( keys %$annum_costs ) {

	if ( $_ ne 'kasko' ) {
		$total += $annum_costs->{$_} * $years; 
	} else {
		next if $no_kasko;
		my $sum = 0;
		my $depr_price = $initial_costs->{initial};
		my $coeff_tbl = {
			1 => 0.2,
			2 => 0.15,
			3 => 0.15,
		};
		my $mod = $type eq 'old' ? 5 : $cash ? 2 : 0;

		foreach my $i (1..$years) {

			$depr_price -= $i == 1 ? 0 : $depr_price * ($coeff_tbl->{$i - 1 + $mod} || 0.1);
			my $kasko = $depr_price * ( $cash ? 0.04 : 0.05 );
			print $kasko, " for year $i\n";
			$sum += $kasko;
		}
		print "Kasko cost = $sum\n";
		$total += $sum;
	}
}

foreach ( keys %$initial_costs ) {
	$total += $initial_costs->{$_};
}

$total -= $selling_price->{$years};

print "Result for [ $type ] car driven and sold after [ $years ]\n";
print "Total = $total\n";
print "Monthly = ", $total/($years*12), "\n";
