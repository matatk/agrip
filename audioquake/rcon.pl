#!/usr/bin/perl
# AGRIP AudioQuake rconsole
# Copyright 2005 Matthew Tylee Atkinson
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
use strict;
use warnings;
use IO::Socket;

sub main();
main();


##############################
# Main Program
##############################

sub main()
{
    my( $addr, $ip, $port );
    my( $result, $recvd, $buffer );
    my( $pwd, $cmd, $cmd_part );
    my $timeout = 5;
    my $exitflag = 0;

    # Get user info...
    print "AudioQuake Server Remote Admin Console\n";
    print "Server address (port optional): ";
    $addr = <STDIN>;
    chomp $addr;
    print "Password: ";
    $pwd = <STDIN>;
    chomp $pwd;

    # Work out where we're connecting and connect...
    $ip = $port = $addr;
    if( $addr =~ /:/ )
    {
        $ip =~ s/:.+//;
        $port =~ s/.+://;
    }
    else
    {
        $port = 27500;
    }

    # Open socket...
    my $sock = IO::Socket::INET->new(
            Proto => "udp", 
            PeerAddr => $ip,
            PeerPort => $port );

    # Got a connection?
    if( ! $sock )
    {
        print "Connection error ($!)!\n";
    }
    else
    {
        print "Connected.  Type 'exit' to close ('quit' restarts the server).\n";
        print "You can also send the 'log' (non-rcon) command.\n";
        # Main Loop...
        while( ! $exitflag )
        {
            # Get user info...
            print "] ";
            $cmd_part = <STDIN>;
            chomp $cmd_part;

            if( $cmd_part ne 'exit' ) # quit command used in-game!
            {
                if( $cmd_part eq 'log' )
                {
                    $cmd = "\xFF\xFF\xFF\xFFlog\n";
                }
                else
                {
                    $cmd = "\xFF\xFF\xFF\xFFrcon " . $pwd . " " . $cmd_part . "\x00";
                }
        
                # Execute remote command...
                $result = $sock->syswrite($cmd, length($cmd));
                
                # Magic timeout catcher...
                eval
                {
                    local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
                    alarm $timeout;
                    $recvd = $sock->sysread($buffer, 9000);
                    alarm 0;
                };
                if ($@)
                {
                    die unless $@ eq "alarm\n";   # propagate unexpected errors
                    print "Server $addr timed out ($timeout seconds)!\n";
                    $exitflag = 1;
                }
                else
                {
                    # We got an answer within the timeout period...
                    $buffer =~ s/(\xFF)+n//g;
                    print $buffer;
                }
            }
            else
            {
                $exitflag = 1;
            }
        }
    }

    print "Press ENTER to exit.";
    <STDIN>;
}

