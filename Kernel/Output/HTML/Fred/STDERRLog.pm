# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Fred::STDERRLog;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::Output::HTML::FredSTDERRLog - layout backend module

=head1 SYNOPSIS

All layout functions of STDERR log objects

=over 4

=cut

=item new()

create an object

    $BackendObject = Kernel::Output::HTML::FredSTDERRLog->new(
        %Param,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item CreateFredOutput()

create the output of the STDERR log

    $LayoutObject->CreateFredOutput(
        ModulesRef => $ModulesRef,
    );

=cut

sub CreateFredOutput {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ModuleRef} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ModuleRef!',
        );
        return;
    }

    return if !$Param{ModuleRef}->{Data};
    return if ref $Param{ModuleRef}->{Data} ne 'ARRAY';

    # create html string
    my $HTMLLines;
    my $HTMLLinesFilter = $Kernel::OM->Get('Kernel::Config')->Get('Fred::STDERRLogFilter');

    LINE:
    for my $Line ( reverse @{ $Param{ModuleRef}->{Data} } ) {

        # filter content if needed
        if ($HTMLLinesFilter) {
            next LINE if $Line =~ /$HTMLLinesFilter/smx;
        }

        $HTMLLines .= $Line;
    }

    return if !$HTMLLines;

    # output the html
    $Param{ModuleRef}->{Output} = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
        TemplateFile => 'DevelFredSTDERRLog',
        Data         => {
            HTMLLines => $HTMLLines,
        },
    );

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
