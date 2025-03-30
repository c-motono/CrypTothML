#!/usr/bin/perl
use strict;
use warnings;

# コマンドライン引数の処理
if (@ARGV < 2) {
     die "Usage: $0 [AllInfoFile] [PDB_ID]\n";
     }

#     # 引数の取得
     my $all_info_file = $ARGV[0];
     my $pdb_id = $ARGV[1];  # シェルスクリプトから渡される変数 (例: 2am9)

#     # ALLファイルを開く
     open(ALL, $all_info_file) || die "Cannot open $all_info_file.\n";

# 見出しを出力
print "Patch\tProbes\tProbeNumber\tgfe\tsize\tprotrusion\tconvexity\tcompactness\thydrophobicity\tcharge_density\tflexibility\tfpocket\tall_gfe\tall_size\tall_protrusion\tall_convexity\tall_compactness\tall_hydrophobicity\tall_charge_density\tall_flexibility\tall_fpocket\n";

my %probes;
my %all;
my %a00;

my $num_all = 0;
my $flag_all = 0;

# ALLファイルの読み込み
while (<ALL>) {
    if ($_ =~ /^Patch/) {
        chomp($_);
        my ($tag, $num) = split(/\s+/, $_);
        $num_all = $num;
        $flag_all = 1;
    } elsif ($_ =~ /^\s*$/) {
        $flag_all = 0;
    } elsif ($flag_all == 1) {
        chomp($_);
        $_ =~ s/^\s+//;
        my ($tag, $val) = split(/ \: /, $_, 2);
        $val =~ s/^\s+//;  # 数値の前の空白を削除
        my $patch = "Patch" . $num_all;
        my $info = $patch . ":" . $tag;
        $all{$info} = $val;
    }
}
close(ALL);

# 最大パッチ番号を使用してprobesハッシュを作成
for my $i (1 .. $num_all) {
    $probes{$i} = 'H2O' . "\t" . 1;
}

# 特徴データの取得
my $base_path = "/work/BINDS2022/motono/imsbio/cosmd20230725_water";
my $feature_file_h2o = "$base_path/${pdb_id}_water/0002_2025Jan/H2O/H2O_info.txt";
my $feature_file_a00 = "$base_path/${pdb_id}_water/0002_2025Jan/A00/A00_info.txt";
my $feature_file;

if (-e $feature_file_h2o) {
    $feature_file = $feature_file_h2o;
} elsif (-e $feature_file_a00) {
    $feature_file = $feature_file_a00;
} else {
    die "Error: Neither '$feature_file_h2o' nor '$feature_file_a00' exists for PDB ID '$pdb_id'.\n";
}

%a00 = get_features($feature_file);

my @fs = ("gfe", "size", "protrusion", "convexity", "compactness", "hydrophobicity", "charge_density", "flexibility", "fpocket");

# プローブデータの処理と出力
foreach (sort { $a <=> $b } keys %probes) {
    my $k = $_;
    my $id = "Patch" . $k;
    my $probe_set = $probes{$k};
    my ($probe_mem, $probe_num) = split(/\t/, $probe_set);
    print "$id\t$probe_mem\t$probe_num\t";
    for (@fs) {
        my $in_tag = $id . ":" . $_;
        my $val = $all{$in_tag};
        print "$val\t";
    }
    for (@fs) {
        my $in_tag2 = $id . ":" . $_;
        print "$all{$in_tag2}\t";
    }
    print "\n";
}

# 特徴データを取得するサブルーチン
sub get_features {
    my ($file_p) = @_;
    my $num = 0;
    my $flag = 0;
    my %features;

    open(AA, $file_p) || die "Cannot open $file_p.\n";
    while (<AA>) {
        if ($_ =~ /^Patch/ && $flag == 0) {
            chomp($_);
            my ($tag1, $num1) = split(/\s/, $_);
            $num = $num1;
            $flag = 1;
        } elsif ($_ =~ /^\n/ && $flag == 1) {
            $num = 0;
            $flag = 0;
        } elsif ($_ =~ /^\t/ && $flag == 1) {
            chomp($_);
            $_ =~ s/\t//g;
            my ($tag, $val) = split(/ \: /, $_);
            my $patch = "Patch" . $num;
            my $info = $patch . ":" . $tag;
            $features{$info} = $val;
        }
    }
    close(AA);

    return %features;
}

