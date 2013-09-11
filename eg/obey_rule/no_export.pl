return +{
    title       => 'no_export',
    description => q/
        It is better to use @EXPORT_OK instead of @EXPORT.
        Because we often confuse [Where did this function come from?]

        Of course, Common library's function which is exported is useful.
        But we should not export all of function.(Particular our minor function)
    /,
    point       => 1,
    target_dir  => [qw( lib/Export )],
    blacklist   => [qw( lib/Export/Black.pm)],
    except_list => [qw( lib/Export/Permit.pm)],
    coderef     => sub{
        my $text = shift;

        if( $text =~ m/\@EXPORT\W/xms ){
            return (0, "'\@EXPORT' expression is not recommended.");
        }
        else{
            return 1;
        }
    },
};
