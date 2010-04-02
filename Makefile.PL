use inc::Module::Install;
name 'Sledge-Config-Extended';
all_from 'lib/Sledge/Config/Extended.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
