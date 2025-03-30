#! /usr/bin/perl
#perl calc_feature_v2.pl spot_probe.toml all_info.txt > output.txt
use strict;
use warnings;

if (@ARGV>0) {
	open(IN,"$ARGV[0]")||die "Cannot open $ARGV[0].\n";
}else {
	die "Usage:./[This Script] [DataFile]\n";
}

print "Patch\tProbes\tProbeNumber\tA00\tA01\tA20\tA37\tB71\tE20\tgfe\tsize\tprotrusion\tconvexity\tcompactness\thydrophobicity\tcharge_density\tflexibility\tfpocket\tflexibility_A00\tflexibility_A01\tflexibility_A20\tflexibility_A37\tflexibility_B71\tflexibility_E20\n";
#print "Patch\tProbes\tProbeNumber\tA00\tA01\tA20\tA37\tB71\tE20\tgfe\tsize\tprotrusion\tconvexity\tcompactness\thydrophobicity\tcharge_density\tflexibility\tfpocket\tflexibility_A00\tflexibility_A01\tflexibility_A20\tflexibility_A37\tflexibility_B71\tflexibility_E20\tall_gfe\tall_size\tall_protrusion\tall_convexity\tall_compactness\tall_hydrophobicity\tall_charge_density\tall_flexibility\tall_fpocket\n";

my %probes;
my %all;
my %a01;
my %a20;
my %e20;
my %a00;
my %b71;
my %a37;

my $probe_num = 0;
my $patch_num = 0;

my @fs = ("gfe","size","protrusion","convexity","compactness","hydrophobicity","charge_density","flexibility","fpocket");

while(<IN>){
	chomp($_);
	my ($id,$p_cluster) = split(/ \= /,$_);
	my @probe_c = split(/, /,$p_cluster);
	my $A00 = 0;
	my $A01 = 0;
	my $A20 = 0;
	my $A37 = 0;
	my $B71 = 0;
	my $E20 = 0;
	my $probe_profile = "";
	
	for(@probe_c){
		if($_ eq "A00"){
			$A00 = 1;
		}elsif($_ eq "A01"){
			$A01 = 1;
		}elsif($_ eq "A20"){
			$A20 = 1;
		}elsif($_ eq "A37"){
			$A37 = 1;
		}elsif($_ eq "B71"){
			$B71 = 1;
		}elsif($_ eq "E20"){
			$E20 = 1;
		}
	}
	
	$probe_profile = "$A00\t$A01\t$A20\t$A37\t$B71\t$E20";
	#print "debug\t$probe_profile\n";
	
	$probe_num++;
	my $probe_mem = $#probe_c+1;
	my $patch = "Patch".$probe_num;
#	print "debug\t$patch\n";
	$probes{$probe_num} = $p_cluster."\t".$probe_mem."\t".$probe_profile;
#	print "debug\t$_\n";
}
open(ALL,"$ARGV[1]");
my $num_all = 0;
my $flag_all = 0;
while(<ALL>){
	if($_ =~ /^Patch/ && $flag_all == 0){
		chomp($_);
		my ($tag,$num) = split(/\s/,$_);
		$num_all = $num;
		$flag_all = 1;
	}elsif($_ =~ /^\n/ && $flag_all == 1){
		$num_all = 0;
		$flag_all = 0; 
	}elsif($_ =~ /^\t/ && $flag_all == 1){
		chomp($_);
		$_ =~ s/\t//g;
		my ($tag,$val) = split(/ \: /,$_);
		my $patch = "Patch".$num_all;
		my $info = $patch.":".$tag;
		$all{$info} = $val;
	}
}
close(ALL);

%a01 = get_features("./A01/A01_info.txt");
%a20 = get_features("./A20/A20_info.txt");
%e20 = get_features("./E20/E20_info.txt");
%a00 = get_features("./A00/A00_info.txt");
%b71 = get_features("./B71/B71_info.txt");
%a37 = get_features("./A37/A37_info.txt");
#%a01 = get_features("./A01/A01_info.txt");
#%a20 = get_features("./A20/A20_info.txt");
#%e20 = get_features("./E20/E20_info.txt");
#%a00 = get_features("./A00/A00_info.txt");
#%b71 = get_features("./B71/B71_info.txt");
#%a37 = get_features("./A37/A37_info.txt");

foreach (sort {$a <=> $b} keys %probes) {
    my $k = $_;
    my $id = "Patch" . $k;
    my $probe_set = $probes{$k};

    my ($probe_mem, $probe_num, $A00, $A01, $A20, $A37, $B71, $E20) = split(/\t/, $probe_set);
    print "$id\t$probe_mem\t$probe_num\t$A00\t$A01\t$A20\t$A37\t$B71\t$E20\t";
#  共通の処理として @data 配列を設定
    my @p_mem = split(/, /, $probe_mem);
    my @data;
    for (0 .. $#p_mem) {
        if ($p_mem[$_] eq "A00") {
            $data[$_] = \%a00;
        } elsif ($p_mem[$_] eq "A01") {
            $data[$_] = \%a01;
        } elsif ($p_mem[$_] eq "A20") {
            $data[$_] = \%a20;
        } elsif ($p_mem[$_] eq "A37") {
            $data[$_] = \%a37;
        } elsif ($p_mem[$_] eq "B71") {
            $data[$_] = \%b71;
        } elsif ($p_mem[$_] eq "E20") {
            $data[$_] = \%e20;
        }
    }

    # 各タグに対してスコアの合計と平均を計算し出力
    for (@fs) {
        my $in_tag = $id . ":" . $_;
        my $total = 0;
        my $c = 0;
        
        for (0 .. $#data) {
            my %score = %{$data[$_]};
            $total += $score{$in_tag};
            $c++;
        }
        
        my $ave = $total / $c;
        print "$ave\t";
    }

   #各プローブのflexibilityデータを出力
        my $in_tag3 = $id . ":" . "flexibility";
        print "$a00{$in_tag3}\t$a01{$in_tag3}\t$a20{$in_tag3}\t$a37{$in_tag3}\t$b71{$in_tag3}\t$e20{$in_tag3}\t";

#   # 各タグに対応する全体データを出力
#    for (@fs) {
#        my $in_tag2 = $id . ":" . $_;
#        print "$all{$in_tag2}\t";
#    }
    print "\n";
}


sub get_features{
	my ($file_p) = @_;
	my $num = 0;
	my $flag = 0;
	my %features;
	open(AA,$file_p);
	while(<AA>){
		if($_ =~ /^Patch/ && $flag == 0){
			chomp($_);
			my ($tag1,$num1) = split(/\s/,$_);
			$num = $num1;
			$flag = 1;
#			print "debug\t$_\n";
		}elsif($_ =~ /^\n/ && $flag == 1){
			$num = 0;
			$flag = 0; 
		}elsif($_ =~ /^\t/ && $flag == 1){
			chomp($_);
			$_ =~ s/\t//g;
			my ($tag,$val) = split(/ \: /,$_);
			my $patch = "Patch".$num;
			my $info = $patch.":".$tag;
#			print "debug1\t$_\t$num\n";
			$features{$info} = $val;
		}
	}
	return %features;
}

