use strict;
#use warnings;
use 5.010;
use warnings;
use IPC::Open2;
my $debug = 0; # toggle to 1 to enable debug
my $passedCases = 0;
my $passedCase = 0;
my $outputFile = "autograder_moment_processor.txt"; # file where the output will be printed
# Handle ctrl+C

sub clearFiles {

    say "Interrupting Run & removing files...\n";
    system("");
    system("rm $outputFile");
    exit 1;
}
system("clear");

my $testerFile = $ARGV[0];  # file with the test cases

print "===========Moment Preventer===========\n";
if (-e $testerFile) {
  print "found tester file: $testerFile\n";
} else{
 print "ERROR: tester file not found: $testerFile\n";
 print "======================================\n";
 exit 1;
}
system("rm $outputFile");
system("touch $outputFile");
my $loopCount = $ARGV[1]; # number of times run program
open(my $LOG, '>>', $outputFile);
select $LOG;

for (my $i = 0; $i <= $loopCount; $i += 1) {  

	$SIG{INT} = \&clearFiles;
    select STDOUT;
    print "testing ... $i/$loopCount\r";
    if ($i == $loopCount){
        print "testing ... $i/$loopCount\n";
    }

	if ($i%100==0){
    select STDOUT;
		print "reseting make files...\r";
		select $LOG;
		system("make clean");
		system("make");
		system("clear");
	}
    
    select $LOG;

    system("./$testerFile >> $outputFile 2>&1");
    #system("./$testerFile 1> $outputFile");
    #system("cat $outputFile");
    my $full_score = 0;
    my $score = "100/100";
    open(my $fh, '<:encoding(UTF-8)', $outputFile)
        or die "Could not open file '$outputFile' $!";
    while ( my $line = <$fh> ) {
    if (index($line, "Final") != -1) {
        if (index($line, $score) != -1){
            $full_score = 1;
        }else{
            $full_score = -1;
        }
    } 
    
    }
    
    if ( $full_score == -1 ){
        select STDOUT;
        print "\n===========Moment Found===========\n";
        print "======================================\n";
        system("cat $outputFile");
        system("rm $outputFile");
        exit 1;
    }
    if ($i%50==0){
      select STDOUT;
      print "printing example output...\r";
		  system("cat $outputFile");
      sleep(1);
      system("clear");
      select $LOG;
    }
    
    system("cat /dev/null > $outputFile");
    
    #exit 1;
}
select STDOUT;
print "No moments detected!\n";
print "======================================\n";
