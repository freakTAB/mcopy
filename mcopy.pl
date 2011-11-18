use warnings;
use strict;

use File::stat;

sub basename {
    my $fname = shift;
    $fname =~ /^(.*)\/(.*)$/;
    return $2;
}

sub mcopy {
    my $from = shift;
    my $to = shift;

    open(FROM, "< $from") or die "can't open $from: $!";
    binmode(FROM);

    open(OUT,"> $to") or die "can't open $from: $!";
    binmode(OUT);

    my $st = stat $from;
    my $blksize = $st->blksize || 16384;

    print  "from    : $from\n";
    print  "to      : $to\n";
    printf "size    : %s\n",$st->size;
    printf "blksize : %s\n",$blksize;

    while (my $len = sysread(FROM, my $buf, $blksize)) {
	if (!defined $len) {
	    next if $! =~ /^Interrupted/;
	    die "System read error: $!\n";
	}
	my $offset = 0;
	while ($len) {
	    defined(my $written = syswrite(OUT, $buf, $len, $offset))
		or die "System write error: $!\n";
	    $len -= $written;
	    $offset += $written;
	};
	print "."
    }

    print "\n";
    close(FROM);
    close(OUT);
}

my $gl = shift;
my $dest = shift;

while(glob($gl)) {
    my $dest_fname = $dest . basename($_);
    mcopy($_,$dest_fname);
}
