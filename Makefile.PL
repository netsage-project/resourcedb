use strict;
use warnings;

use ExtUtils::MakeMaker;


sub MY::postamble { << 'END'; }
TEST_VERBOSE=1

rpm: dist
	rpmbuild -ta resourcedb-$(VERSION).tar.gz --define="_buildno 1"

test: pure_all
	$(FULLPERL) t/TEST $(TEST_VERBOSE)
END


sub MY::test { << 'END'; }
TEST_VERBOSE=1

rpm_jenkins: dist
	rpmbuild -ta resourcedb-$(VERSION).tar.gz --define="_buildno ${BUILD_NUMBER}"

test_jenkins: pure_all
	$(FULLPERL) t/TEST $(TEST_VERBOSE) --formatter=TAP::Formatter::Console
END


WriteMakefile(
    NAME         => 'resourcedb',
    AUTHOR       => 'GRNOC Systems Engineering <syseng@grnoc.iu.edu>',
    VERSION_FROM => 'lib/GRNOC/NetSage/ResourceDB.pm',
    PL_FILES     => {},
    PREREQ_PM    => {
    },
    dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean        => { FILES => 'resourcedb-*' },
);
