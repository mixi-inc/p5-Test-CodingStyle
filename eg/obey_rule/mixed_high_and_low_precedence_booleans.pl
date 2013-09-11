return +{
    title       => 'mixed_high_and_low_precedence_booleans',
    description => q/
        Checking for existing Operators which have different precedence.

        For example, These will work unexpected
            (not 1 || 1) work as (not (1 || 1))  -> FALSE.
            (not 1 or 1) work as ((not 1) or 1)  -> TRUE.
        
        To prevent these situation,
        It is better to use only ( and, or, not ) OR only ( &&, ||, ! ).
    /,
    point       => 1,
    target_dir  => [qw( lib/MixedPrecedence )],
    blacklist   => [qw( lib/MixedPrecedence/Black.pm)],
    except_list => [qw( lib/MixedPrecedence/Permit.pm)],
    coderef     => sub{
        my $text = shift;

        use PPI::Document;
        use List::MoreUtils;

        # target operator
        my %low_boolean    = map {$_ => 1} qw/not or and/;
        my %high_boolean   = map {$_ => 1} qw/! || &&/;
        my %check_operator = (%low_boolean, %high_boolean);

        my $doc = PPI::Document->new(\$text);
        return 1 if not $doc;
        my $operators = $doc->find(sub{
            $_[1]->isa('PPI::Token::Operator')
        });
        my %uniq_parent_element;
        for my $operator (@$operators) {
            # ignore not target operator
            next if not $check_operator{$operator->content};
            # ignore parent element which has already been checked
            my $parent_element = $operator->parent;
            if ($parent_element) {
                next if $uniq_parent_element{$parent_element->content};
                $uniq_parent_element{$parent_element->content} = 1;
            }
            # get target operator
            my @elements = grep {
                $_->isa('PPI::Token::Operator')
            } (
                $parent_element
                    ? $parent_element->children
                    : ($operator)
            );
            # check operators
            if (
                (List::MoreUtils::any {$low_boolean{$_} } @elements) and
                (List::MoreUtils::any {$high_boolean{$_}} @elements)
            ) {
                my $target_line = $parent_element ? $parent_element : '(UNKNOWN)';
                return (0, sprintf('Mixed high and low-precedence booleans in "%s".', $target_line));
            }
        }
        return 1;
    },
};
