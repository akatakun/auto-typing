#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Win32::GuiTest qw( :ALL );
use Image::Match;

sub main {
  if ( my ( $id ) = FindWindowLike( undef, 'Chrome' ) ) {
    SetForegroundWindow( $id );
    my ( $x, $y, $w, $h ) = GetWindowRect( $id );
    my $screenshot;
    my $words = &load_words;

    SendKeys( '{SPACE}' ); # Game Start!!

    while ( 1 ) {
      $screenshot = Image::Match->screenshot( $x, $y, $w, $h );
      my $match_words = &match_words( $screenshot, $words );
      for my $x ( sort { $a <=> $b } keys %$match_words ) {
        SendKeys( $match_words->{ $x } );
      }
    }
  }
  return;
}

sub load_words {
  my %words;
  for ( 0 .. 9, 'a' .. 'z', '-', ',' ) {
    my $word = Prima::Image->load( "images/$_.png" );
    $words{ $_ } = $word if defined $word;
  }
  return \%words;
}

sub match_words {
  my ( $screenshot, $words ) = @_;

  my %match_words;
  for my $word ( keys %$words ) {
    my @coords = $screenshot->match( $words->{ $word }, multiple => 1 );
    my @xs = @coords[ grep { $_ % 2 == 0 } 0 .. $#coords ];
    $match_words{$_} = $word for @xs;
  }
  return \%match_words;
}

main;
