#!/usr/bin/perl
use strict;
use warnings;

my @files = @ARGV;

for my $file ( @files )
{
    my $fakecfile = $file;
    $fakecfile =~ s/\.qc$/\.mqc/;
    
    open(QCFILE,"<$file") or die;
    open(FAKECFILE,">$fakecfile") or die;
    
    while(<QCFILE>)
    {
        if( /(void|float)\s*(\(.*?\))\s*(\w+?)\s*(=|;)/ )
        {
            if( $4 eq '=' )
            {
                # Function definition
                print FAKECFILE "$1 $3$2\n";
            }
            else
            {
                # Function prototype
                print FAKECFILE "$1 $3$2;\n";
            }
        }
        else
        {
            print FAKECFILE;
        }
    }
    
    close FAKECFILE;
    close QCFILE;
}
