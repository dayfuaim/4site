#!/usr/bin/perl

package modules::Validate;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw( $err_msg
				is_long is_number is_number_float is_number_sp
				is_text_rus is_text_rus_wide is_word_rus is_text_lat
				page_exists adjust_page_url is_url_valid
				validate_menu
				is_date_valid is_datetime_valid
				rebuild_pages rebuild_pages_templ);
our $VERSION=1.9;
use strict;
use vars qw($err_msg $result_msg $error $warning);
use modules::Debug;

################ �������� ������ (�� �������������� ����)#######################

sub is_long {
	my ($field, $fldname, $min_length, $max_length) = @_;
	my $err = 0;
	if ($field !~ /^[\d\D]{$min_length,$max_length}$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� ������������� ��������� ����� (�� $min_length �� $max_length ��������)<br/>};
		$err = 1;
		}
	return $err;
	} # is_long

sub is_number {
	my ($field, $fldname, $min_length, $max_length) = @_;
	my $err = 0;
	if ($field !~ /[\d]+/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� �������� ������<br/>};
		$err = 1;
		}
	elsif ($field !~ /^[\d]{$min_length,$max_length}$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� ������������� ��������� ����� (�� $min_length �� $max_length ����)<br/>};
		$err = 1;
		}
	return $err;
	} # is_number

sub is_number_float {
	my ($field, $fldname, $min_length, $max_length) = @_;
	my $err = 0;
	if ($field !~ /[.\d]+/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� �������� ������ � ��������� �������<br/>};
		$err = 1;
		}
	elsif ($field !~ /^[.\d]{$min_length,$max_length}$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� ������������� ��������� ����� (�� $min_length �� $max_length ����)<br/>};
		$err = 1;
		}
	return $err;
	} # is_number_float

sub is_number_sp {
	my ($field, $fldname, $min_length, $max_length) = @_;
	my $err = 0;
	if ($field !~ /[\d ]+/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� �������� ������ � ���������<br/>};
		$err = 1;
		}
	elsif ($field !~ /^[\d ]{$min_length,$max_length}$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� ������������� ��������� ����� (�� $min_length �� $max_length ����)<br/>};
		$err = 1;
		}
	return $err;
	} # is_number_sp

sub is_text_rus {
	my ($field, $fldname, $min_length, $max_length) = @_;
	my $err = 0;
	if ($field !~ /^[�����������娸����������������������������������������������� \-]+$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� �������� ������� �� ������� ����<br/>};
		$err = 1;
		}
	elsif ($field !~ /^[�����������娸����������������������������������������������� \-]{$min_length,$max_length}$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� ������������� ��������� ����� (�� $min_length �� $max_length ����)<br/>};
		$err = 1;
		}
	return $err;
	} # is_text_rus

sub is_text_rus_wide {
	my ($field, $fldname, $min_length, $max_length) = @_;
	my $err = 0;
	if ($field !~ /^[�����������娸����������������������������������������������� \-]+$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� �������� ������� �� ������� ����<br/>};
		$err = 1;
		}
	elsif ($field !~ /^[�����������娸����������������������������������������������� \-]{$min_length,$max_length}$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� ������������� ��������� ����� (�� $min_length �� $max_length ����)<br/>};
		$err = 1;
		}
	return $err;
	} # is_text_rus

sub is_word_rus {
	my ($field, $fldname, $min_length, $max_length) = @_;
	my $err = 0;
	if ($field !~ /^[�����������娸�����������������������������������������������\-]+$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� �������� ������ �� ������� ����<br/>};
		$err = 1;
		}
	elsif ($field !~ /^[�����������娸�����������������������������������������������\-]{$min_length,$max_length}$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� ������������� ��������� ����� (�� $min_length �� $max_length ����)<br/>};
		$err = 1;
		}
	return $err;
	} # is_word_rus

sub is_text_lat {
	my ($field, $fldname, $min_length, $max_length) = @_;
	my $err = 0;
	if ($field !~ /^[A-Za-z \-]+$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� �������� ��������� (��������� �����) (�� $min_length �� $max_length ����)<br/>};
		$err = 1;
		}
	elsif ($field !~ /^[A-Za-z \-]{$min_length,$max_length}$/)
		{
		$err_msg .= qq{��������� �������� "$field" � ���� "$fldname" �� ������������� ��������� ����� (�� $min_length �� $max_length ����)<br/>};
		$err = 1;
		}
	return $err;
	} # is_text_lat

sub adjust_page_url {
	my $url = shift;
	$url =~ s!\&\#(\d+);!!gex;	# Every hex-like char
	$url =~ s![\300-\377]!!gex;	# Every high-byte (i.e. Cyrillic) char
	$url =~ s!%([A-Fa-f0-9]{2})! pack("C",hex($1)) !gex;	# Every URL-encoded char
	$url =~ s!\\!/!g;	   # Windows-style backslashes
	$url =~ s!\.\./!!g;	 # `cd ..` slashes
	$url =~ s!\./!!g;	   # `cd .` slashes
	$url =~ s!/+!/!g;	   # repeating slashes
	$url ='/'.$url unless $url =~ m!^/!;
	return $url
}

sub is_url_valid {
	my $url = shift;
	my $err = 0;
	if ($url =~ m![\300-\377]!) {
		$err=1;
		$err_msg .= qq{��������� � ���� URL �������� �������� ������������ �������<br/>}
	}
	return $err
}

sub is_datetime_valid {
	my $date = shift;
	my $err = 0;
	if ($date !~ m![0-9.: ]!) {
		$err++;
		$err_msg .= qq{��������� � ���� ����-������� �������� �������� ������������ �������<br/>}
	}
	if ($date !~ m/^(0?\d|[12]\d|30|31)\.(0?\d|1[0-2])\.(19|20)\d\d\s(0?\d|1\d|2[0-3]):([0-5]\d)(:([0-5]\d))?/) {
		$err++;
		$err_msg .= qq{��������� � ���� ����-������� �������� �� �������� ����� � ���������� ������� "<b>[d]d.[m]m.yyyy HH:MM:SS</b>"<br/>}
	}
	return $err
}

sub is_date_valid {
	my $date = shift;
	my $err = 0;
	if ($date !~ m![0-9.:]!) {
		$err++;
		$err_msg .= qq{��������� � ���� ���� �������� �������� ������������ �������<br/>}
	}
	if ($date !~ m/^(0?\d|[12]\d|30|31)\.(0?\d|1[0-2])\.(19|20)\d\d/) {
		$err++;
		$err_msg .= qq{��������� � ���� ���� �������� �� �������� ����� � ���������� ������� "<b>[d]d-[m]m-yyyy</b>"<br/>}
	}
	return $err
}

sub page_exists {
	my $fname = shift;
	my $err = 0;
	my $p = $modules::Core::soap->fileExists([$fname])->result;
	if ((split /\|/,$p)[-1]) {
		$err_msg .= qq{<b>������ ��� �������� �����</b>: ���� �� �������� ������ ��� ����������! ������� ������������ ����.<br/>};
		$err++
	}
	return $err
} # page_exists

sub validate_menu {
	my @pages;
	my %err;
	my @r = $modules::Core::soap->getQuery("SELECT url_fld, enabled_fld FROM page_tbl ORDER BY url_fld")->paramsout;
	# Got @pages
	foreach (@r) { push @pages, join "|"=>@$_ }
# 	modules::Debug::dump(\@pages);
	@r = $modules::Core::soap->fileExists(\@pages)->paramsout;
	foreach my $p (@r) {
		my ($url,$enabled,$exists) = split /\|/,$p;
		unless ($exists) {
			$modules::Core::soap->doQuery("UPDATE page_tbl SET enabled_fld='0' WHERE url_fld='$url'");
			$err{$url} = "<i style='color:Red'>��� �����</i>";
		} else {
			$err{$url} = "<b style='color:#006600'>OK</b>";
			$err{$url} .= " <span style='color:Grey'>(���������)</span>" unless $enabled;
		}
	}
	return \%err;
} # check_menu

sub rebuild_pages {
	my @err;
	my %templ;
	my @r = $modules::Core::soap->getQuery("SELECT * FROM template_tbl")->paramsout;
	foreach (@r) {
		push @{$templ{$_->[0]}}, @{$_}[2,3]
	}
	#modules::Debug::dump(\%templ);
	@r = $modules::Core::soap->getQueryHash("SELECT url_fld,template_id,lm_fld FROM page_tbl")->paramsout;
	foreach (@r) {
		my %p = %$_;
		my $content = modules::Comfunctions::extract_content($p{url_fld});
		unless (length($content)>0) {
			push @err,$p{url_fld};
			next;
		}
		print " ";
 		my ($templ_top,$templ_bottom) = @{$templ{$p{template_id}}}; # �������� ���� � ��� �������
		grep { s/\r?\n/\n/g; s/&amp;/&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; } ($templ_top,$templ_bottom,$content);
	#	$templ_top	=~ s/\r?\n/\n/g;
	#	$templ_bottom =~ s/\r?\n/\n/g;
	#	$templ_top	=~ s/&lt;/</g;
	#	$templ_bottom =~ s/&lt;/</g;
	#$content =~ s/&lt;/</g;
	#$content =~ s/&gt;/>/g;
	#$content =~ s/&amp;/&/g;
	#$content =~ s/&quot;/"/g;
		$modules::Core::soap->putXMLFile([$p{url_fld},"$templ_top\n<!--\\\\START\\\\-->\n$content\n<!--\\\\END\\\\-->\n$templ_bottom",$p{lm_fld}]);
		print " "
	}
	@r = $modules::Core::soap->getQueryHash("SELECT url_fld,template_id FROM servpage_tbl")->paramsout;
	foreach (@r) {
		my %p = %$_;
		my $content = modules::Comfunctions::extract_content($p{url_fld});
		unless (length($content)>0) {
			push @err,$p{url_fld};
			next;
		}
		print " ";
		my ($templ_top,$templ_bottom) = @{$templ{$p{template_id}}}; # �������� ���� � ��� �������
		grep { s/\r?\n/\n/g; s/&amp;/&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; } ($templ_top,$templ_bottom,$content);
		$modules::Core::soap->putXMLFile([$p{url_fld},"$templ_top\n<!--\\\\START\\\\-->\n$content\n<!--\\\\END\\\\-->\n$templ_bottom",1]);
		print " "
	}
	return @err;
} # rebuild_pages

sub rebuild_pages_templ {
	my $template_id = shift;
	$result_msg = "";
	my @err;
	my @r = $modules::Core::soap->getQuery("SELECT top_fld,bottom_fld FROM template_tbl WHERE template_id=$template_id")->paramsout;
	my ($templ_top,$templ_bottom) = @{$r[0]}; # �������� ���� � ��� �������
	$templ_top	=~ s/\r\n/\n/g;
	chomp($templ_top);
	$templ_bottom =~ s/\r\n/\n/g;
	chomp($templ_bottom);
	@r = $modules::Core::soap->getQueryHash("SELECT page_id,label_fld,url_fld FROM page_tbl WHERE template_id=$template_id")->paramsout;
	if (scalar @r) {
		$result_msg .= "</p><p>�������� �� ������ �������:<blockquote>";
		foreach (@r) {
			my %p = %$_;
			my $content = modules::Comfunctions::extract_content($p{url_fld});
			$content =~ s/\r\n/\n/g;
			$content =~ s/[\r\n]+$//;
			unless (length($content)>0) {
				push @err,$p{url_fld};
				next;
			}
			$result_msg .= qq{�������� '<b>$p{label_fld}</b> ($p{url_fld})'... };
			$modules::Core::soap->putXMLFile([$p{url_fld},"$templ_top\n<!--\\\\START\\\\-->\n$content\n<!--\\\\END\\\\-->\n$templ_bottom",0]);
			$result_msg .= qq{�����������.<br/>}
		}
		$result_msg .= "</blockquote>"
	}
	unless ($result_msg) {
		$result_msg .= "</p><p>�� �� ������ ������� �� �������� �� ����� ��������."
	}
	return @err
} # rebuild_pages_templ

1;
__END__

=head1 NAME

B<Validate.pm> � ������ �������� �������� ������ �� ������� ������������
����������� ���� ������ � ������������ �����������.

=head1 SYNOPSIS

������ �������� �������� ������ �� ������� ������������
����������� ���� ������ � ������������ �����������.

=head1 DESCRIPTION

������ �������� �������� ������ �� ������� ������������
����������� ���� ������ � ������������ �����������.

=head2 is_long

������������ ������ �������� �����.

=over 4

=item �����:

C<&is_long("������","��������","min_�����_����","max_�����_����");>

=item ������ ������:

 &is_long("$FORM{label_fld}","���������","1","255");

=item ����������:

���.

=item �����������:

���.

=back

=head2 is_number

������������ ������ ����� �������� �����.

=over 4

=item �����:

C<&is_number("������","��������","min_�����_����","max_�����_����");>

=item ������ ������:

 &is_number("$FORM{tally_fld}","�����","1","8");

=item ����������:

���.

=item �����������:

���.

=back

=head2 is_number_float

������������ ������ ����� � ��������� ������� �������� �����.

=over 4

=item �����:

C<&is_number_float("������","��������","min_�����_����","max_�����_����");>

=item ������ ������:

 &is_number_float("$FORM{tally_fld}","�����","1","15");

=item ����������:

���.

=item �����������:

���.

=back

=head2 is_number_sp

������������ ������ ����� � ��������� �������� �����.

=over 4

=item �����:

C<&is_number_sp("������","��������","min_�����_����","max_�����_����");>

=item ������ ������:

 &is_number_sp("$FORM{tally_fld}","�����","1","15");

=item ����������:

���.

=item �����������:

���.

=back

=head2 is_text_rus

������������ ������ ������ �� ������� ���� �������� �����.

=over 4

=item �����:

C<&is_text_rus("������","��������","min_�����_����","max_�����_����");>

=item ������ ������:

 &is_text_rus("$FORM{body_fld}","���������","1","64");

=item ����������:

���.

=item �����������:

���.

=back

=head2 is_text_rus_wide

������������ ������ ������ �� ������� ���� �������� �����.
����������� ������� ������ ����������, C</>, C<\>, C<%>, C<�>, C<#>, C<-> (�����, ����, �����), �����.

=over 4

=item �����:

C<&is_text_rus_wide("������","��������","min_�����_����","max_�����_����");>

=item ������ ������:

 &is_text_rus_wide("$FORM{body_fld}","�����","1","64");

=item ����������:

���.

=item �����������:

���.

=back

=head2 is_word_rus

������������ ������ ����� (������������������ ������� ����) �������� �����.

=over 4

=item �����:

C<&is_word_rus("������","��������","min_�����_����","max_�����_����");>

=item ������ ������:

 &is_word_rus("$FORM{body_fld}","�����","1","64");

=item ����������:

���.

=item �����������:

���.

=back

=head2 is_text_lat

������������ ������ ������ �������� ����� (��������� �����).

=over 4

=item �����:

C<&is_text_lat("������","��������","min_�����_����","max_�����_����");>

=item ������ ������:

 &is_text_lat("$FORM{body_fld}","�����","1","64");

=item ����������:

���.

=item �����������:

���.

=back

=head2 adjust_page_url

�������� �� URL ���� ������������ ��������.

=over 4

=item �����:

C<&adjust_page_url("������");>

=item ������ ������:

 &adjust_page_url($FORM{url_fld});

=item ����������:

���.

=item �����������:

���.

=back

=head2 is_url_valid

�������� ���������� URL (���������� ������� ��������).

=over 4

=item �����:

C<&is_url_valid("URL");>

=item ������ ������:

 &is_url_valid($FORM{url_fld});

=item ����������:

���.

=item �����������:

���.

=back

=head2 is_date[time]_valid

�������� ���������� ���� (�������) (���������� �������� ����� ����).

=over 4

=item �����:

C<&is_date_valid("date");>

=item ������ ������:

 &is_date_valid($FORM{date_fld});

=item ����������:

���.

=item �����������:

���.

=back

=head2 page_exists

��� �������� �������� �� ������� ���������, ���������� �� ��� ��� ��������.

=over 4

=item �����:

C<&page_exists("file_name");>

=item ������ ������:

 &page_exists("$modules::Settings::c{dir}{htdocs}$FORM{url_fld}");

=item ����������:

���.

=item �����������:

���.

=back

=head2 validate_menu

�������� ����������� ������������� ������ �������, ��������� � ����, � ��������� �������������� ���������
�������� 'disabled' (�� ���������� � ����).

=over 4

=item �����:

C<&validate_menu;>

=item ������ ������:

 &validate_menu;

=item ����������:

���������� ��� ��� ������ ������� � �������� � ������������� ����.

=item �����������:

���.

=back

=head2 rebuild_pages

����������� ������� � ��������, ��� ������� ������.

=over 4

=item �����:

C<&rebuild_pages;>

=item ������ ������:

 &rebuild_pages;

=item ����������:

���������� ������ ��� ������ ��������������� �������.

=item �����������:

���.

=back

=head2 rebuild_pages_templ

����������� ������� � ��������, ��� ������� ������.

=over 4

=item �����:

C<&rebuild_pages_templ;>

=item ������ ������:

 &rebuild_pages_templ;

=item ����������:

���������� ������ ��� ������ ��������������� �������.

=item �����������:

���.

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
