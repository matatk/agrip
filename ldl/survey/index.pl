#!/usr/bin/perl -T
use strict;
use warnings;
use constant AWF_VERSION => '0.5';
use constant AWF_FROM => 'awf@obelisk.agrip.org.uk';
use constant STR_OPTIONAL => 'This question requires an answer.';
use Config::Tiny;
use CGI::Apache qw(:standard);
use HTML::Tidy;
use MIME::Lite;
use Text::CSV;


##############################
# Configuration
##############################

my $config = Config::Tiny->new();
$config = Config::Tiny->read('awf.ini');
my $query = new CGI;


##############################
# Subroutines
##############################

sub mainloop($);                # Displays the form
sub validationloop();           # Validates the form
sub header($);                  # HTML and errors header info
sub footer($);                  # DWISOTT
sub genList($);                 # Creates HTML for a selection list
sub genText($);                 #                    text box
sub genInfo($);                 #                    paragraph
sub genHead($);                 #                    heading
sub genTick($$);                #                    tick/radio set
sub genTickLoop($$);            # Used internally by genTick()
sub genCtrlLabel($);            # Creates HTML for control labels
sub genCtrlEnd();               # Closes DIVs for controls
sub addBug($$);                 # Reports bugs in the INI file
sub validateMarkInvalid($$);    # Flags a query param as invalid
sub validateList($);            # Checks listbox controls
sub validateTick($);            # Checks tickbox controls/sets
sub validateRadio($);           # Checks radio sets
sub validateText($);            # DWISOTT
sub updateNum($);               # Updates qnum if needed

# Silly functions...
sub qnum();
sub num_get($);
sub num_set($$);
sub num_exec_numbering($);
sub num_show_hide($$);

sub resreploop();


##############################
# Order of Execution
##############################

my $id = 1_000;
my %badfields;  # hashes of ( number, msg ) members
my $out;
my @bugs;
my %backrefs;

print $query->header();
if( !$ENV{'REQUEST_METHOD'} or $ENV{'REQUEST_METHOD'} ne 'POST' )
{
    # Form should be presented for initial data entry...
    mainloop(0);
}
else
{
    # Form has been posted; validate and return duff fields...
    validationloop();
}


##############################
# Main program
##############################

sub mainloop($)
{
    my $f_badfieldsonly = shift;
    my $qtype;

	if ( not $config->{'form'}->{'scripturl'} )
	{
		addBug('No script URL specified in [form] section.', 1);
	}

    num_set(0, 'qnum');
    
    $out .= "<h" . $config->{'form'}->{'level'} . ">" . $config->{'form'}->{'stitle'} . "</h" . $config->{'form'}->{'level'} . ">" unless $f_badfieldsonly;
    
    foreach my $question ( sort keys %{$config} )
    {
        # Get type of question...
        if( $config->{$question}->{'type'} )
        {
            $qtype = $config->{$question}->{'type'};
        }
        else
        {
            next; # the [form] section has no ``type'' key.
        }

        # Don't re-output this field if it was filled in correctly before...
        if( $f_badfieldsonly )
        {
            # We are only displaying bad fields...
            if( !$badfields{$question} )
            {
                # This field isn't a bad one so we need to store its value...
                #my $qpval = $query->param($question);
                
                # Try to find out if the field had an alternative name
                # this is necessary due to tickboxen...
                foreach my $f ( $query->param )
                {
                    if( $f =~ /$question/ )
                    {
                        $out .= "<input type='hidden' name='" . $question . "' value='" . $query->param($f) . "'/>";
                    }
                }
                next;
            }
            # We're still in the loop, so this must be a bad field.
            # Take it's number from the hash...
            $out .= "<div class='question'><div class='qnum'>";
            $out .= $badfields{$question}{'number'} if !$config->{$question}->{'hidenum'} or $config->{$question}->{'hidenum'} ne 'yes';
            $out .= "</div><div class='qcontent'><p class='error'>$badfields{$question}{'v_msg'}</p>";
        }
        else
        {
            # Normal full form display...
            if( $qtype ne 'head' and $qtype ne 'info' and $qtype ne 'numbering' )
            {
                $out .= "<div class='question'><div class='qnum'>";
                $out .= qnum() if updateNum($question);
                $out .= "</div><div class='qcontent'>";
            }
            # else it is a head/info and we don't need to do anything.
        }

        # Generate Form Element based on type...
        $id++;
        if( $qtype eq 'list' )
        {
            genList($question);
        }
        elsif( $qtype eq 'text' )
        {
            genText($question);
        }
        elsif( $qtype eq 'info' )
        {
            genInfo($question);
            next; # don't need to complete the span; not started.
        }
        elsif( $qtype eq 'head' )
        {
            genHead($question);
            next; # don't need to complete the span; not started.
        }
        elsif( $qtype eq 'numbering' )
        {
            num_exec_numbering($question);
            next; # don't need to complete the span; not started.
        }
        elsif( $qtype eq 'tick' )
        {
            genTick($question, 0);
        }
        elsif( $qtype eq 'radio' )
        {
            genTick($question, 1);
        }
        else
        {
            addBug("Unknown question type for $question.", 1);
        }
        $out .= "</div></div>"; # one for the qcontent inside the question
    }

    $out = header(1) . $out . footer(1);
    @bugs = ( );
 
    my $tidy = HTML::Tidy->new( {config_file => 'awf.tidy.conf'} );
    $tidy->ignore( type => TIDY_WARNING );
    $out = $tidy->clean( $out );
    print $out;
}


##############################
# Header Subroutine
##############################

sub header($)
{
    my $f_formheader = shift;
    my $header;

    # NB: The header is constructed after most processing, so that it can
    #     include error messages generated by the processing.
    #     For this reason, it is generated in a slightly different way
    #     than other output.
    
    $header .= "<html><head><title>" . $config->{'form'}->{'title'}  . "</title><style>\@import 'awf.css';</style></head><body>";

    foreach my $error ( @bugs )
    {
        $header .= '<p class=\'bug\'>ERROR: ' . $error . '</p>';
    }

    $header .= "<form action='" . $config->{'form'}->{'scripturl'} . "' method='post' enctype='multipart/form-data'>" if $f_formheader;

    return $header;
}


##############################
# Footer Subroutine
##############################

sub footer($)
{
    my $f_formfooter = shift;
    my $footer;

    $footer .= "<input type='submit' value='Send'/>&nbsp;&nbsp;<input type='reset'/></form>" if $f_formfooter;
    $footer .= "<hr/><p>" . $config->{'form'}->{'footer'} . "</p>" if $config->{'form'}->{'footer'};

    #resreploop();
    return $footer;
}


##############################
# genList Subroutine
##############################

sub genList($)
{
    my $q = shift;
    genCtrlLabel($q);
    
    $out .= "<select id='" . $id .  "' name='" . $q . "'>";
    # Nothing in by default...
    $out .= '<option>Please choose an option...</option>';
    foreach my $opt ( sort keys %{$config->{$q}} )
    {
        if( $opt =~ /value/ )
        {
            $out .= "<option>" . $config->{$q}->{$opt} . "</option>";
        }
    }
    $out .= "</select>";
    
    genCtrlEnd();
}


##############################
# genText Subroutine
##############################

sub genText($)
{
    my $q = shift;
    genCtrlLabel($q);
    
    $out .= "<input id='" . $id . "' type='text' name='" . $q . "'/>";
    
    genCtrlEnd();
}

##############################
# genInfo Subroutine
##############################

sub genInfo($)
{
    my $q = shift;
    foreach my $key ( sort keys %{$config->{$q}} )
    {
        if( $key =~ /value/ )
        {
            $out .= '<p>' . $config->{$q}->{$key} . "</p>";
        }
    }
}


##############################
# genHead Subroutine
##############################

sub genHead($)
{
    my $q = shift;
    my $level = 1;
    
    if( $config->{$q}->{'level'} )
    {
        $level = $config->{$q}->{'level'};
    }

    $out .= "<h" . $level . ">" . $config->{$q}->{'value'} . "</h" . $level . ">";
}


##############################
# genTick Subroutine
##############################

sub genTick($$)
{
    my $q = shift;
    my $radio = shift;
   
    if( keys %{$config->{$q}} > 2 )
    {
        $out .= "<fieldset><legend>" . $config->{$q}->{'blurb'}  . "</legend>";
        genTickLoop($q, $radio);
        $out .= "</fieldset>";
    }
    else
    {
        genTickLoop($q, $radio);
    }
}


##############################
# genTickLoop Subroutine
##############################

sub genTickLoop($$)
{
    my $q = shift;
    my $radio = shift;
    my $ctrl_type = 'checkbox';
    my $ctrl_name = $q;
    
    $ctrl_type = 'radio' if( $radio );
    
    foreach my $ctrl ( sort keys %{$config->{$q}} )
    {
        if( $ctrl =~ /label/ )
        {
            $ctrl_name .= '_' . $id if !$radio;
            $out .= "<input id='" . $id . "' type='" . $ctrl_type . "' name='" . $ctrl_name . "' value='" . $config->{$q}->{$ctrl} . "'/>";
            genCtrlLabelL($config->{$q}->{$ctrl});
            genCtrlEnd();
            $id++;
        }
    }
}


##############################
# genCtrlLabel Subroutine
# FIXME shouldn't need to put space char in!
##############################

sub genCtrlLabel($)
{
    my $q = shift;
    $out .= "<label for='" . $id  . "'>" . $config->{$q}->{'blurb'} . "</label> ";
}

sub genCtrlLabelL($)
{
    my $l = shift;
    $out .= "<label for='" . $id  . "'>" . $l . "</label> ";
}


##############################
# genCtrlEnd Subroutine
##############################

sub genCtrlEnd()
{
    $out .= "<br/>";
}


##############################
# Main validation program
##############################

sub validationloop()
{
    my $qtype;
    
    num_set(0, 'qnum');
    foreach my $question ( sort keys %{$config} )
    {
        # Generate question number...
        $qtype = $config->{$question}->{'type'};

        if( $qtype )
        {
            if( $qtype ne 'head' and $qtype ne 'info' and $qtype ne 'numbering' )
            {
                updateNum($question);
            }
           
            if( $qtype eq 'text' )
            {
                validateText($question);
            }
            elsif( $qtype eq 'list' )
            {
                validateList($question);
            }
            elsif( $qtype eq 'tick' )
            {
                validateTick($question);
            }
            elsif( $qtype eq 'radio' )
            {
                validateRadio($question);
            }
            elsif( $qtype eq 'numbering' )
            {
                num_exec_numbering($question);
            }
            # else < a type we don't validate >
            # FIXME validate lists
        }
        # else < is [form] >
    }

    if( keys %badfields > 0 )
    {
        $out .= "<h" . $config->{'form'}->{'level'} . ">" . $config->{'form'}->{'vtitle'} . "</h" . $config->{'form'}->{'level'} . ">";
        foreach my $vfmsgline ( sort keys %{$config->{'form'}} )
        {
            $out .= '<p>' . $config->{'form'}->{$vfmsgline} . '</p>' if $vfmsgline =~ /v_fmsg/;
        }
        # FIXME warn of submitted Qs
        mainloop(1);
    }
    else
    {
        $out .= "<h" . $config->{'form'}->{'level'} . ">" . $config->{'form'}->{'vtitle'} . "</h" . $config->{'form'}->{'level'} . ">";
        if( resreploop() )
        {
            # YES!!!
            foreach my $vsmsgline ( sort keys %{$config->{'form'}} )
            {
                $out .= '<p>' . $config->{'form'}->{$vsmsgline} . '</p>' if $vsmsgline =~ /v_smsg/;
            }
        }
        else
        {
            # ERROR!!!
            $out .= "<p>There was an error when attempting to record your answers!  Please go back and resubmit your answers.</p><p>Apologies for any inconvenience caused.  If the problem persists, please <a href='mailto:" . $config->{'form'}->{'mailto'}  . "'>contact the author</a></p>";
        }
        $out = header(0) . $out . footer(0);
        my $tidy = HTML::Tidy->new( {config_file => 'awf.tidy.conf'} );
        $tidy->ignore( type => TIDY_WARNING );
        $out = $tidy->clean( $out );
        print $out;
    }
}


##############################
# validateText Subroutine
##############################

sub validateText($)
{
    my $q = shift;
    my $f_invalid = 0;
    my $vtype = $config->{$q}->{'v_type'};

    if( $vtype )
    {
        # REGEX VALIDATION...
        if( $vtype eq 'regex' )
        {
            if( $config->{$q}->{'v_regex'} )
            {
                if( $query->param($q) )
                {
                    # Data present; check regex...
                    $f_invalid = 1 unless $query->param($q) =~ /$config->{$q}->{'v_regex'}/;
                }
                else
                {
                    # Data not present; check if it was optional...
                    if( !$config->{$q}->{'optional'} )
                    {
                        $f_invalid = 1;
                    }
                    else
                    {
                        $f_invalid = 1 unless $config->{$q}->{'optional'} eq 'yes';
                    }
                }
            }
            else
            {
                addBug("Regex validation specified for $q, but no regex given!", 0);
            }
        }
        # SAME-AS VALIDATION...
        elsif( $vtype eq 'same-as' )
        {
            my $target = $config->{$q}->{'v_same-as'};
            if( $target eq $q )
            {
                addBug("Sameas validation specified for $q, but target set to $q!", 0);
            }
            elsif( $target ne '' )
            {
                # The field tagged ``sameas'' must come before the filed it points to.
                # The field it points to is where the validation check can be found.
                # Details of this field are stored in %backrefs so that they can be
                # referred to later.
                $backrefs{$target}{'name'} = $q;
                $backrefs{$target}{'num'} = qnum();
            }
            else
            {
                addBug("Sameas validation specified for $q, but no link to another (existant) question given!", 0);
            }
        }
        # UNKNOWN VALIDATION TYPE...
        else
        {
            addBug("Unkown v_type for $q.", 0);
        }
    }
    else
    {
        # No validation required, but the data may still be non-optional...
        if( !$query->param($q) )
        {
            # Data not present; check if it was optional...
            if( !$config->{$q}->{'optional'} )
            {
                $f_invalid = 1;
            }
            else
            {
                $f_invalid = 1 unless $config->{$q}->{'optional'} eq 'yes';
            }
        }
    }
    
    # Check if this question is the target of a ``sameas'' validation for a
    # previous field...
    if( $backrefs{$q} )
    {
        # This question's answer should be the same as the answer to
        # $backrefs{$q}.
        #   If this question's answer is invalid, so is the other one.
        #   If this question's answer is != the others; both are invalid.
       
        # Compare the two answers...
        my $ans_other = $query->param($backrefs{$q}{'name'});
        my $ans_this = $query->param($q);
        $ans_other = '' if !$ans_other; # avoids empty string warnings
        $ans_this = '' if !$ans_this;   # in logfiles :-)
        if( $ans_other ne $ans_this )
        {
            $f_invalid = 1;
        }
       
        # Test for validity of both fields...
        if( $f_invalid )
        {
            validateMarkInvalid($backrefs{$q}{'name'}, $backrefs{$q}{'num'});
        }
        else
        {
            delete $backrefs{$q};
        }
    }
    
    validateMarkInvalid($q, qnum()) if $f_invalid;
}


##############################
# validateList Subroutine
##############################

sub validateList($)
{
    my $q = shift;
    my $f_invalid = 0;

    my $f_optional = 1;
    $f_optional = 0 if( !$config->{$q}->{'optional'} or $config->{$q}->{'optional'} eq 'no' );

    if( !$f_optional )
    {
        # The field is not optional
        $f_invalid = 1 if $query->param($q) eq 'Please choose an option...';
    }

    validateMarkInvalid($q, qnum()) if $f_invalid;
}


##############################
# validateTick Subroutine
##############################

sub validateTick($)
{
    my $q = shift;
    my $f_invalid = 0;
    my $f_found = 0;

    my $f_optional = 1;
    $f_optional = 0 if( !$config->{$q}->{'optional'} or $config->{$q}->{'optional'} eq 'no' );

    if( !$f_optional )
    {
        # The field is not optional
        foreach my $f ( $query->param )
        {
            if( $f =~ /$q/ )
            {
                $f_found = 1;
            }
        }
        $f_invalid = 1 if !$f_found;
    }

    validateMarkInvalid($q, qnum()) if $f_invalid;
}


##############################
# validateRadio Subroutine
##############################

sub validateRadio($)
{
    my $q = shift;
    my $f_invalid = 0;

    my $f_optional = 1;
    $f_optional = 0 if( !$config->{$q}->{'optional'} or $config->{$q}->{'optional'} eq 'no' );

    if( !$f_optional )
    {
        # The field is not optional
        if( !$query->param($q) )
        {
            # not filled in -- invalid...
            $f_invalid = 1;
        }
    }

    validateMarkInvalid($q, qnum()) if $f_invalid;
}


##############################
# validateMarkInvalid Subroutine
##############################

sub validateMarkInvalid($$)
{
    my $q = shift;
    my $n = shift;

    my $f_optional = 1;
    $f_optional = 0 if( !$config->{$q}->{'optional'} or $config->{$q}->{'optional'} eq 'no' );

    $badfields{$q}{'number'} = $n;
    # Fill in validation message from INI file.
    # If none is present, and field was compulsory, put a default one in...
    if( !$config->{$q}->{'v_msg'} )
    {
        # No user-supplied validation error message...
        if( !$f_optional )
        {
            $badfields{$q}{'v_msg'} = STR_OPTIONAL;
        }
        else
        {
            addBug("No validation message supplied for $q.", 0);
        }
    }
    else
    {
        my $v_msg;

        # Using user-supplied validation error message...
        $v_msg = $config->{$q}->{'v_msg'};

        # Add on what the user entered, if they entered something...
        # Don't do this if it's a ``sameas'' question as the output could
        # confuse the user.
        $v_msg .= " (You entered \"" . $query->param($q) . "\" here last time.)" if $query->param($q);
        
        $badfields{$q}{'v_msg'} = $v_msg;
    }
}


##############################
# addBug Subroutine
##############################

sub addBug($$)
{
    my $bug = shift;
    my $f_printhere = shift;

    push @bugs, $bug;
    $out .= '<p class=\'bug\'>' . $bug . '</p>' if $f_printhere;
}


##############################
# updateNum Subroutine
##############################

sub updateNum($)
{
    my $q = shift;
    my $shownum = 1;
    
    $shownum = 0 if $config->{$q}->{'hidenum'} and $config->{$q}->{'hidenum'} eq 'yes';
    num_set(num_get('qnum') + 1, 'qnum') if $shownum;
    
    return $shownum;
}


##############################
# Number-related Subroutines
##############################

my $qnum;   # question number
my $f_show_qnum = 1;
my $snum;   # section number
my $f_show_snum = 1;
my $ssnum;  # subsection number
my $f_show_ssnum = 1;

sub num_exec_numbering($)
{
    my $q = shift;
    
    foreach my $key ( sort keys %{$config->{$q}} )
    {
        if( $key ne 'type' )
        {
            if( $config->{$q}->{$key} eq 'inc' )
            {
                num_set(num_get($key) + 1, $key);
                # If a section number was inc'd, inc the other two.
                # If a ssection number ws inc'd, inc qnum only.
                num_set(0, 'qnum') if $key eq 'snum' or $key eq 'ssnum';
                num_set(1, 'ssnum') if $key eq 'snum';
            }
            elsif( $config->{$q}->{$key} eq 'show' )
            {
                num_show_hide($key, 1);
            }
            elsif( $config->{$q}->{$key} eq 'hide' )
            {
                num_show_hide($key, 0);
            }
            else
            {
                num_set($config->{$q}->{$key}, $key);
            }
        }
        # else < type key >
    }
}

sub qnum()
{
    my $retval;

    $retval = $snum . '.' if $f_show_snum;
    $retval .= $ssnum . '.' if $f_show_ssnum;
    $retval .= $qnum if $f_show_qnum;
    
    return $retval;
}

sub num_get($)
{
    my $type = shift;

    if( $type eq 'qnum' )
    {
        return $qnum;
    }
    elsif( $type eq 'snum' )
    {
        return $snum;
    }
    elsif( $type eq 'ssnum' )
    {
        return $ssnum;
    }
    else
    {
        addBug("Type $type given for getting number not recognised.", 0);
    }
}

sub num_set($$)
{
    my $num = shift;
    my $type = shift;

    if( $type eq 'qnum' )
    {
        $qnum = $num;
    }
    elsif( $type eq 'snum' )
    {
        $snum = $num;
    }
    elsif( $type eq 'ssnum' )
    {
        $ssnum = $num;
    }
    else
    {
        addBug("Type $type given for setting number (to $num) not recognised.", 0);
    }
}

sub num_show_hide($$)
{
    my $type = shift;
    my $val = shift;

    if( $val != 0 and $val != 1 )
    {
        addBug("Attempt to set $type to $val (should be 0 or 1 only).", 0);
        return;
    }

    if( $type eq 'qnum' )
    {
        $f_show_qnum = $val;
    }
    elsif( $type eq 'snum' )
    {
        $f_show_snum = $val;
    }
    elsif( $type eq 'ssnum' )
    {
        $f_show_ssnum = $val;
    }
    else
    {
        addBug("Type $type given for showing/hiding number not recognised (value passed in: $val).", 0);
    }
}


##############################
# Results reporting
##############################

sub resreploop()
{
    my $qtype;
    my $msg;
    my @field_values;
    my @field_headers;
    my $csv = Text::CSV->new;
    my $csvfile;
    my $shownum;

    num_set(0, 'qnum');
    
    foreach my $question ( sort keys %{$config} )
    {
        my $qpval = $query->param($question);
        $qpval = '' unless $qpval;

        # Get type of question...
        if( $config->{$question}->{'type'} )
        {
            $qtype = $config->{$question}->{'type'};
        }
        else
        {
            next; # the [form] section has no ``type'' key.
        }

        if( $qtype ne 'head' and $qtype ne 'info' and $qtype ne 'numbering' )
        {
            # This field isn't a bad one so we need to store its value...
            $shownum = updateNum($question);
            push @field_headers, qnum(); #if $shownum;
        }

        #$mailstr .= $config->{$question}->{'blurb'} . "\n" if $config->{$question}->{'blurb'};

        if( $qtype eq 'list' or $qtype eq 'text' or $qtype eq 'radio' )
        {
            push @field_values, $qpval;
        }
        elsif( $qtype eq 'tick' )
        {
            my @tickvals;
            foreach my $f ( $query->param )
            {
                if( $f =~ /$question/ )
                {
                    push @tickvals, $query->param($f);
                }
            }
            push @field_values, "@tickvals";
        }
        elsif( $qtype eq 'numbering' )
        {
            num_exec_numbering($question);
        }
    }

    $msg = MIME::Lite->new(
        From    => AWF_FROM,
        To      => $config->{'form'}->{'mailto'},
        Subject => 'Accessible WebForm Submission',
        Type    => 'multipart/mixed'
    );
   
    $csv->combine(@field_headers);
    $csvfile = $csv->string;
    $csv = Text::CSV->new;
    $csv->combine(@field_values);
    $csvfile .= "\r\n" . $csv->string;

    $msg->attach(Type => 'text/x-comma-separated-values',
                 Data => $csvfile,
                 Filename => 'submission.csv',
                 Disposition => 'attachment'
    );
                 
    $msg->send('smtp', 'localhost');
    return 1;
    return $msg->last_send_successful();
}

# END
