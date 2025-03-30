#!/usr/bin/perl
use strict;
use warnings;
# msmdの結果と、水mdの結果から必要な列を抽出して、特徴量のファイル生成。複数のタンパク質に対応

# 引数の確認。引数は複数のタンパク質のディレクトリ名が可能
if (@ARGV < 1) {
    die "Usage: $0 <directory_name> [directory_name ...]\n";
    }
     
# 各ディレクトリ名（タンパク質名）を順次処理
foreach my $dir_name (@ARGV) {

# 入力ファイル1とファイル2のパスを生成
my $file1 = "./$dir_name/output_${dir_name}_v3_2.txt";
my $file2 = "../cosmd20230725_water/${dir_name}_water/0002_2025Jan/output_${dir_name}_water_2.txt";

# 出力ファイルのパスを生成
my $output = "./feature_${dir_name}_v3_2_water.csv";

# 必要な列を指定
my @file2_columns = qw(size protrusion convexity compactness hydrophobicity charge_density flexibility);

# ファイルのデータを格納するハッシュ
my %file1_data;
my %file2_data;

# ファイル1を読み込み
open my $fh1, '<', $file1 or die "エラー: ファイル1 '$file1' が見つかりません。\n";
my $header1 = <$fh1>;
chomp $header1;
my @file1_columns = split /\t/, $header1;

# 'Probes'、'flexibility'、'fpocket'列を除外した列リストを作成
my @filtered_file1_columns = grep { $_ ne 'Probes' && $_ ne 'flexibility' && $_ ne 'fpocket' } @file1_columns;

# ファイル1の行順を保持する配列
my @file1_order;

while (<$fh1>) {
    chomp;
    my @fields = split /\t/, $_, scalar @file1_columns;  # 行データを正しい列数で分割
    my %record;
    @record{@file1_columns} = @fields;  # 元の列名でデータをマッピング

    # 'Probes'と'fpocket'列を除外
    my %filtered_record = map { $_ => $record{$_} } @filtered_file1_columns;

    # データを格納
    $file1_data{$record{'Patch'}} = \%filtered_record;

    # 行順を記録
    push @file1_order, $record{'Patch'};
}
close $fh1;

# ファイル2を読み込み
open my $fh2, '<', $file2 or die "エラー: ファイル2 '$file2' が見つかりません。\n";
my $header2 = <$fh2>;
chomp $header2;
my @file2_columns_all = split /\t/, $header2;

while (<$fh2>) {
    chomp;
    my @fields = split /\t/;
    my %record;
    @record{@file2_columns_all} = @fields;

    # 必要な列だけを格納
    my %selected_record = map { $_ => $record{$_} } ('Patch', @file2_columns);
    $file2_data{$record{'Patch'}} = \%selected_record;
}
close $fh2;
# '_water' を付加した新しいタイトルを作成
my @file2_columns_with_suffix = map { $_ . '_water' } @file2_columns;
# 結果を結合
open my $fh_out, '>', $output or die "エラー: 出力ファイル '$output' を作成できません。\n";
print $fh_out join(',', @filtered_file1_columns, @file2_columns_with_suffix) . "\n";

for my $patch (@file1_order) {
    if (exists $file1_data{$patch} && exists $file2_data{$patch}) {
        my @file1_values = map { $file1_data{$patch}{$_} // '' } @filtered_file1_columns;
        my @file2_values = map { $file2_data{$patch}{$_} // '' } @file2_columns;

        print $fh_out join(',', @file1_values, @file2_values) . "\n";
    }
}
close $fh_out;

print "データが結合され、'$output' に保存されました。\n";
}
