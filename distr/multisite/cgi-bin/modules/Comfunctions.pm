#!/usr/bin/perl

package modules::Comfunctions;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw( @exsts
				feature_down_sep feature_edit
				del_rel idfield
				date_to_rus timestamp_to_rus logpass logpass_gc logpass_func logpass_user
				limit_rows limit_rows_set rows_count_set array2in
				menu_all menu_exp
				get_master_pages
				create_tmptbl
				level
				ex_down ex_down_exp
				print_p
				refers_ary
				extract_content
				print_template
				edit_keywords
				get_id_by_URL get_result_message
				returnact act
				get_array
				getWarning info_msg alert_msg error_return count_downlist
				draw_table start_table end_table head_table
				bug_report _inst);
our @EXPORT_OK = qw(downlist SOAPdownlist downlist_sel SOAPdownlist_sel page_sections_downlist_sel downlist_desc downlist2 downlist_def downlist2_sel SOAPdownlist2_sel downlist_autosel
					add_record edit_record del_record Madd_record Medit_record Mdel_record
					file_upload module_settings_list get_array getWarning info_msg alert_msg error_return
					count_downlist draw_table start_table end_table head_table _inst);
our %EXPORT_TAGS = (
					downlist => [qw{downlist downlist_sel page_sections_downlist_sel downlist_desc downlist2 downlist_def downlist2_sel SOAPdownlist SOAPdownlist_sel SOAPdownlist2_sel downlist_autosel count_downlist}],
					records => [qw{add_record edit_record del_record Madd_record Medit_record Mdel_record}],
					elements => [qw{module_settings_list get_array getWarning
								 bug_report start_table end_table head_table
								 _inst}],
					file => [qw{file_upload}],
					);
our $VERSION=1.9;
use CGI;
use strict;

sub getWarning {
	return undef unless (my $w = shift);
	return qq{<table border="0" cellpadding="0" cellspacing="0" class="warning" id="warning" style="position: absolute; z-index: 1000; display: ;">
	<tr><td class="tl-big"><img src="/img/warning.gif" width="32" height="27" border="0" align="absmiddle" hspace="5"></td>
	<td class="tl-big">$w</td>
	<td align="right" valign="top" width="25"><a href="#" onclick="layerClose('warning'); return false"><img src="/img/error-close.gif" width="13" height="13" border="0"></td></tr>
	</table>
	<script type="text/javascript">
	var rr = layer('warning');
	rr.setTop(87)
	var pw = getDocumentWidth()-150;
	rr.setLeft(150+(pw-rr.getWidth())/2)
	</script>
	};
}

sub downlist {
	my ($table, $field) = @_;
	my $table_id = "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $sql = "SELECT $table_id, $field FROM $table_tbl";
	$sql .= " ORDER BY $field ASC";
	my $sth = $modules::DBfunctions::dbh->prepare($sql);
	$sth->execute();
	my $out;
	while (my @row = $sth->fetchrow_array) {
		$out .= qq{<option value="$row[0]">$row[1]</option>}
	}
	return $out
} # downlist

sub SOAPdownlist {
	my ($table, $field) = @_;
	my $table_id = "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $sql = "SELECT $table_id, $field FROM $table_tbl";
	$sql .= " ORDER BY $field ASC";
	#modules::Debug::notice($sql);
	my $out;
	my @r;
	if (exists $modules::Security::FORM{'s:'.$table_id.$field}) {
		@r = @{$modules::Security::FORM{'s:'.$table_id.$field}};
	} else {
		@r = $modules::Core::soap->getQuery($sql)->paramsout;
		$modules::Security::FORM{'s:'.$table_id.$field} = \@r;
	}
	foreach (@r) {
		$out .= qq{<option value="$_->[0]">$_->[1]</option>};
	}
	return $out;
} # SOAPdownlist

sub downlist_sel {
	my ($table, $field, $def) = @_;
	my $table_id = "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $sql = "SELECT $table_id, $field FROM $table_tbl ORDER BY $field ASC";
	my $sth = $modules::DBfunctions::dbh->prepare($sql);
	$sth->execute();
	my $out;
	while (my @row = $sth->fetchrow_array) {
		if ( $row[0] == $def ) {
			$out .= qq{<option value="$row[0]" selected>$row[1]</option>};
		} else {
			$out .= qq{<option value="$row[0]">$row[1]</option>};
		}
	}
	return $out;
	} # downlist_sel

sub SOAPdownlist_sel {
	my ($table, $field, $def, $not_same_fld) = @_;
#	modules::Debug::dump(\@_);
	my $table_id = $not_same_fld;
	$table_id ||= "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $sql = "SELECT $table_id, $field FROM $table_tbl ORDER BY $field ASC";
 	#modules::Debug::dump($sql);
	my $out;
	my @r;
	if (exists $modules::Security::FORM{'s:'.$table_id.$field}) {
		@r = @{$modules::Security::FORM{'s:'.$table_id.$field}};
	} else {
		@r = $modules::Core::soap->getQuery($sql)->paramsout;
		$modules::Security::FORM{'s:'.$table_id.$field} = \@r;
	}
	my $i = 1;
	foreach (@r) {
		next unless $_->[0];
		$out .= qq{<option value="$_->[0]"}.(($_->[0]==$def)?" selected":"").qq{>$_->[1]</option>};
	}
	return $out;
} # downlist

sub page_sections_downlist_sel {
	my $def = shift;
	my @r = $modules::Core::soap->getQuery("SELECT page_id, label_fld FROM page_tbl WHERE master_page_id=0 ORDER BY order_fld")->paramsout;
	my $out;
	foreach (@r) {
		if ( $_->[0] == $def ) {
			$out .= qq{<option value="$_->[0]" selected>$_->[1]</option>};
		} else {
			$out .= qq{<option value="$_->[0]">$_->[1]</option>};
		}
	}
	return $out;
} # downlist_sel

sub downlist2 {
	my ($table, $field1, $field2) = @_;
	my $table_id = "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $sql = "SELECT $table_id, $field1, $field2 FROM $table_tbl";
	$sql .= " ORDER BY $field1, $field2 ASC";
	my $sth = $modules::DBfunctions::dbh->prepare($sql);
	$sth->execute();
	my $out;
	while (my @row = $sth->fetchrow_array)
		{
		$out .= qq{<option value="$row[0]">$row[1] ($row[2])</option>
		};
		}
	return $out;
	} # downlist2

sub SOAPdownlist2 {
	my ($table, $field1, $field2) = @_;
	my $table_id = "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $sql = "SELECT $table_id, $field1, $field2 FROM $table_tbl";
	$sql .= " ORDER BY $field1, $field2 ASC";
	my $out;
	my @r;
	if (exists $modules::Security::FORM{'s:'.$table_id.$field1.$field2}) {
		@r = @{$modules::Security::FORM{'s:'.$table_id.$field1.$field2}};
	} else {
		@r = $modules::Core::soap->getQuery($sql)->paramsout;
		$modules::Security::FORM{'s:'.$table_id.$field1.$field2} = \@r;
	}
	foreach (@r) {
		$out .= qq{<option value="$_->[0]">$_->[1] ($_->[2])</option>};
	}
	return $out;
	} # downlist


sub downlist2_sel {
	my ($table, $field1, $field2, $def) = @_;
	my $table_id = "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $sql = "SELECT $table_id, $field1,
			   $field2
			   FROM $table_tbl
			   ORDER BY $field1, $field2 ASC";
	my $sth = $modules::DBfunctions::dbh->prepare($sql);
	$sth->execute();
	my $out;
	while (my @row = $sth->fetchrow_array)
		{
		if ( $row[0] == $def ) { $out .= qq{<option value="$row[0]" selected>$row[1] ($row[2])</option>
								}; }
		else { $out .= qq{<option value="$row[0]">$row[1] ($row[2])</option>
			  }; }
		}
	return $out;
	} # downlist2_sel

sub SOAPdownlist2_sel {
	my ($table, $field1, $field2, $def) = @_;
	my $table_id = "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $sql = "SELECT $table_id, $field1,
			   $field2
			   FROM $table_tbl
			   ORDER BY $field1, $field2 ASC";
	my $nh = qq{downl_}.Digest::MD5::md5_hex($sql);
	my $out;
	my @r;
	if (exists $modules::Security::FORM{'s:'.$table_id.$field1.$field2}) {
		@r = @{$modules::Security::FORM{'s:'.$table_id.$field1.$field2}};
	} else {
		@r = $modules::Core::soap->getQuery($sql)->paramsout;
		$modules::Security::FORM{'s:'.$table_id.$field1.$field2} = \@r;
	}
	foreach (@r) {
		$out .= qq{<option value="$_->[0]"}.(($_->[0]==$def)?" selected":"").qq{>$_->[1] ($_->[2])</option>};
	}
	return $out;
} # downlist


sub add_record {
	my $table = $_[0];
	my $sql = "INSERT INTO $table SET ";
	my $fieldset;
	my $id_name;
	my @r = $modules::Core::soap->getQuery("SHOW COLUMNS FROM $table")->paramsout;
	foreach (@r) {
		if ($_->[5] ne "auto_increment") {
			if ($modules::Security::FORM{$_->[0]} ne "") {
				$modules::Security::FORM{$_->[0]} =~ s/'/\\'/g;
				$fieldset .= "$_->[0]='$modules::Security::FORM{$_->[0]}', "
		   	}
		} elsif ($_->[5] eq "auto_increment") {
			$id_name = "$_->[0]"
		}
	}
	substr($fieldset,-2) = "";
	$sql = "$sql"."$fieldset";
  	#print qq{<b>add_record</b>: $sql <br/>}; return;
	return $modules::Core::soap->doQuery($sql)->result;
} # add_record

sub Madd_record {
	my $table = $_[0];
	my $sql = "INSERT INTO $table SET ";
	my $fieldset;
	my $id_name;
	my $sth = $modules::DBfunctions::dbh->prepare("SHOW COLUMNS FROM $table");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		if ($row[5] ne "auto_increment") {
			if ($modules::Security::FORM{$row[0]} ne "") {
				$modules::Security::FORM{$row[0]} =~ s/'/\\'/g;
				$fieldset .= "$row[0]='$modules::Security::FORM{$row[0]}', "
		   	}
		} elsif ($row[5] eq "auto_increment") {
			$id_name = "$row[0]"
		}
	}
	substr($fieldset,-2) = "";
	$sql = "$sql"."$fieldset";
	#print qq{$sql<br/>}; #return;
	$modules::DBfunctions::dbh->do($sql);
	$modules::Security::FORM{$id_name} = $modules::DBfunctions::dbh->selectrow_array("SELECT LAST_INSERT_ID()");
} # add_record

sub edit_record {
	my $table = $_[0];
	my $fieldset;
	my $sql = "UPDATE $table SET ";
	my $where_st = "WHERE ";
	my @r = $modules::Core::soap->getQuery("SHOW COLUMNS FROM $table")->paramsout;
	foreach (@r) {
		if ($_->[5] eq "auto_increment") {
			$where_st .= "$_->[0]='$modules::Security::FORM{$_->[0]}'"
	   	}
		if ($_->[1] !~ /timestamp/) {
			if (defined($modules::Security::FORM{$_->[0]})) {
				if ($modules::Security::FORM{$_->[0]} eq 'NULL') {
					$fieldset .= "$_->[0]=NULL, "
				} else {
					$modules::Security::FORM{$_->[0]} =~ s/'/\\'/g;
					$fieldset .= "$_->[0]='$modules::Security::FORM{$_->[0]}', "
				}
		   	} elsif ($modules::Security::FORM{$_->[0]} eq "" and $_->[1] =~ /enum/) {
					$fieldset .= "$_->[0]='$_->[4]', "
			}
		} elsif ( ($_->[1] =~ /timestamp/) and defined($modules::Security::FORM{$_->[0]}) ) {
				$fieldset .= "$_->[0]='$modules::Security::FORM{$_->[0]}', "
		}
	}
	chop $fieldset;
	chop $fieldset;
	$sql = "$sql"."$fieldset"." "."$where_st";
 	#modules::Debug::dump($sql,"edit_record"); return;
	my $r = $modules::Core::soap->doQuery($sql);
	#unless ($r->result) {
	#	modules::Debug::dump($r->faultstring,'ERROR (edit_record)')
	#}

} # edit_record

sub Medit_record {
	my $table = $_[0];
	my $fieldset;
	my $sql = "UPDATE $table SET ";
	my $where_st = "WHERE ";
	my $sth = $modules::DBfunctions::dbh->prepare("SHOW COLUMNS FROM $table");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		if ($row[5] eq "auto_increment") {
			$where_st .= "$row[0]='$modules::Security::FORM{$row[0]}'"
	   	}
		if ($row[1] !~ /timestamp/) {
			if (defined($modules::Security::FORM{$row[0]})) {
				$modules::Security::FORM{$row[0]} =~ s/'/\\'/g;
				$fieldset .= "$row[0]='$modules::Security::FORM{$row[0]}', "
		   	} elsif ($modules::Security::FORM{$row[0]} eq "" and $row[1] =~ /enum/) {
				$fieldset .= "$row[0]='$row[4]', "
			}
		} elsif ( ($row[1] =~ /timestamp/) and defined($modules::Security::FORM{$row[0]}) ) {
			$fieldset .= "$row[0]='$modules::Security::FORM{$row[0]}', "
		}
	}
	chop $fieldset;
	chop $fieldset;
	$sql = "$sql"."$fieldset"." "."$where_st";
 	# print "<b>edit_record</b>: $sql<br/>"; # return;
	$modules::DBfunctions::dbh->do($sql);
} # edit_record

sub del_record {
	my ($table,@fld) = @_;
	my $sql = "DELETE FROM $table WHERE ";
	my $fieldset;
	my @r = $modules::Core::soap->getQuery("SHOW COLUMNS FROM $table")->paramsout;
	foreach (@r) {
		if ($_->[5] eq "auto_increment") {
			$fieldset = "$_->[0]='$modules::Security::FORM{$_->[0]}'";
			last
		}
	}
	my $fld_add = join ' AND '=>map { exists $modules::Security::FORM{$_} && qq{$_='$modules::Security::FORM{$_}'}} @fld;
	$fieldset .= ($fieldset and $fld_add)?qq{ AND $fld_add}:$fld_add;
	$sql = "$sql"."$fieldset";
 	#print "$sql<br/>"; return;
	$modules::Core::soap->doQuery($sql);
} # del_record

sub Mdel_record {
	my ($table,@fld) = @_;
	my $sql = "DELETE FROM $table WHERE ";
	my $fieldset;
	my $sth = $modules::DBfunctions::dbh->prepare("SHOW COLUMNS FROM $table");
	$sth->execute();
	while (my @row = $sth->fetchrow_array) {
		if ($row[5] eq "auto_increment") {
			$fieldset = "$row[0]='$modules::Security::FORM{$row[0]}'";
			last
		}
	}
	my $fld_add = join ' AND '=>map { exists $modules::Security::FORM{$_} && qq{$_='$modules::Security::FORM{$_}'}} @fld;
	$fieldset .= ($fieldset and $fld_add)?qq{ AND $fld_add}:$fld_add;
	$sql = "$sql"."$fieldset";
	$modules::DBfunctions::dbh->do($sql);
} # Mdel_record

sub feature_down_sep {
	my ($table, $proper, $relation, $sep_tab, $sep_field, @fields) = @_;
	my $table_id = "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $proper_id = "$proper"."_id";
	my $proper_tbl = "$proper"."_tbl";
	my $sep_tab_id = "$sep_tab"."_id";
	my $sep_tab_tbl = "$sep_tab"."_tbl";
	my $sql = "SELECT $sep_tab_id, $sep_field FROM $sep_tab_tbl ORDER BY $sep_field ASC";
	my $sth = $modules::DBfunctions::dbh->prepare($sql);
	$sth->execute();
	my $out;
	my $j = 0;
		$out .= qq{
		<script>
		var gr = new Array();
		var groups = new Array();

		function onoff(oid) {
			var forms = document.getElementById('f'+oid);
			var img = document.getElementById('i'+oid);
			if (forms.style.display=="") {
				forms.style.display="none"
				img.src="/img/4site/menu/close.gif"
			} else {
				forms.style.display=""
				img.src="/img/4site/menu/open.gif"
			}
		}
		</script>
		<table class="tab">};
	while (my @separ = $sth->fetchrow_array) {
		my $num_col = $#fields + 2;
		my $sql_p = "SELECT $proper_id ";
		foreach (@fields) { $sql_p .= ", $_ " }
		$sql_p .= "FROM $proper_tbl WHERE $sep_tab_id=$separ[0]";
		my $sth_p = $modules::DBfunctions::dbh->prepare($sql_p);
		$sth_p->execute();
		if ($sth_p->rows) {
			$out .= qq{
			<tr><td colspan="2" align="left" valign="top"><a href="#" onclick="javascript:onoff('$separ[0]');return false"><img src="/img/4site/menu/close.gif" border="0" align="absmiddle" id="i$separ[0]"></a><input type="checkbox" id="cc$separ[0]" onclick="gr_onoff($j)"><label for="cc$separ[0]">$separ[1]</label></td></tr>
			<tr style="display: none" id="f$separ[0]"><td width="21">&nbsp;</td><td align="left">
				<table class="tab">};
			my $i = 1;
			my @g;
			my @uniq;
			my @curr;
			my %match;
			while (my ($prop_id, @prop) = $sth_p->fetchrow_array) {
				push @curr, ($prop_id, @prop);
				my $sth_c = $modules::DBfunctions::dbh->prepare("SELECT * FROM $relation WHERE $table_id=$modules::Security::FORM{$table_id} AND $proper_id=$prop_id");
				$sth_c->execute();
				my $ch = $sth_c->fetchrow_array;
				$out .= qq{<tr class="}.(($i++ % 2)?"tr_col1":"tr_col2").qq{"><td class="ta"><input type="checkbox" name="$prop_id" id="y$separ[0].$prop_id" value="on"}.(($ch)?" checked":"").qq{></td>};
				push @curr, ($prop_id, $ch, @prop);
				push @g, $prop_id;
				foreach (@prop) { $out .= qq{<td class="tl"><label for="y$separ[0].$prop_id">$_</label></td>} }
				$out .= qq{</tr>};
				$curr[3] =~ /^([^0-9]+)\d*/;
				$match{$1}++;
			}
			$out .= qq{</table></td></tr>};
			#foreach (@uniq) { /^([^0-9]+)\d*/ && $match{$1}++ }
			@uniq = grep { $match{$_}==2 } keys %match;
			$out .= qq{
			<script>
			gr[$j] = $separ[0];
			groups[$j] = new Array(}.(join ','=>@g).qq{,0);
			</script>
			};
			$j++;
		}
		#$out .= qq{<tr><td colspan="}.($num_col+1).qq{">&nbsp;</td></tr>} if ($sth_p->rows);
	}
	$out .= qq{</table><input type="hidden" name="$table_id" value="$modules::Security::FORM{$table_id}">
	<script>
	function gr_onoff(grid) {
		var g = gr[grid];
		var gg = groups[grid];
		var ch = document.getElementById('cc'+g);
		for (i=0;i<gg.length-1;i++) {
			var o = document.getElementById('y'+g+'.'+gg[i]);
			o.checked = ch.checked
		}
	}
	</script>
	};
	return $out;
	} # feature_down_sep

sub feature_edit {
	my ($table, $proper, $relation) = @_;
	my $table_id = "$table"."_id";
	my $table_tbl = "$table"."_tbl";
	my $proper_id = "$proper"."_id";
	my $proper_tbl = "$proper"."_tbl";
	my @r = $modules::Core::soap->doQuery("DELETE FROM $relation WHERE $table_id=$modules::Security::FORM{$table_id}")->paramsout;
	foreach my $name (keys %modules::Security::FORM) {
		if ($name =~ /^[\d]+$/) {
			$modules::Core::soap->doQuery("INSERT INTO $relation
							   SET $proper_id=$name, $table_id=$modules::Security::FORM{$table_id}")
		}
	}
	#my $name_log = "xlog_"."$relation";
	#$sth = $modules::Core::soap->getQuery("SHOW TABLES LIKE '$name_log'");
	#$sth->execute();
	#my $log_en = $sth->fetchrow_array;
	#if ($log_en) # �������� ������ � ���
	#	{
	#	my ($login, $pass) = modules::Security::decrypt($modules::Security::FORM{login}, $modules::Security::FORM{password});
	#	$sth = $modules::Core::soap->getQuery("SELECT user_id FROM user_tbl
	#						  WHERE (login_fld LIKE '$login') AND (pass_fld LIKE '$pass')");
	#	$sth->execute();
	#	my $user_id = $sth->fetchrow_array;
	#	foreach my $name (keys %FORM)
	#		{
	#		if ($name =~ /^[\d]+$/)
	#			{ $sth = $modules::Core::soap->doQuery("INSERT INTO $name_log SET loguser_id=$user_id, logoperation_id=1, remoteip_fld='$ENV{REMOTE_ADDR}', $proper_id=$name, $table_id=$modules::Security::FORM{$table_id}") }
	#		}
	#	}
	} # feature_edit

sub del_rel {
	my $table = $_[0];
	my $sql = "DELETE FROM $table WHERE ";
	my $fieldset;
	my @r = $modules::Core::soap->getQuery("SHOW COLUMNS FROM $table")->paramsout;
	foreach (@r) {
		$fieldset .= (defined($modules::Security::FORM{$_->[0]}))?"$_->[0]='$modules::Security::FORM{$_->[0]}' AND ":"";
		#push @log_f, "$_->[0]='$modules::Security::FORM{$_->[0]}'" if (defined($modules::Security::FORM{$_->[0]}));
	}
	substr($fieldset, -5) = "";
	$sql = "$sql"."$fieldset";
	$modules::Core::soap->doQuery($sql);
	#my $name_log = "xlog_"."$table";
	#$sth = $modules::Core::soap->getQuery("SHOW TABLES LIKE '$name_log'");
	#$sth->execute();
	#my $log_en = $sth->fetchrow_array;
	#if ($log_en) # �������� ������ � ���
	#	{
	#	my ($login, $pass) = modules::Security::decrypt($modules::Security::FORM{login},$modules::Security::FORM{password});
	#	$sth = $modules::Core::soap->getQuery("SELECT user_id FROM user_tbl
	#						  WHERE (login_fld LIKE '$login') AND (pass_fld LIKE '$pass')");
	#	$sth->execute();
	#	my $user_id = $sth->fetchrow_array;
	#	$sth = $modules::Core::soap->doQuery("INSERT INTO $name_log SET loguser_id=$user_id, logoperation_id=3, remoteip_fld='$ENV{REMOTE_ADDR}', $log_f[0], $log_f[1]");
	#	}
	} # del_rel

############# ������ � ����� ������ (�������������� �������) ###################

sub date_to_rus {
	my $date = "$_[0]";
	$date =~ m/^(\d{4})-(\d\d)-(\d\d)$/ ;
	$date = qq{$3.$2.$1 �.};
	return $date
	} # date_to_rus

sub timestamp_to_rus {
	my $date = "$_[0]";
	$date =~ m/^(\d{4})(\d\d)(\d\d)/ ;
	$date = qq{$3.$2.$1 �.};
	return $date
	} # timestamp_to_rus

############################ ������ � �������� #################################

sub logpass {
	use Digest::MD5 qw(md5_hex);
	my $mod = $modules::Security::session->param('module');
	my $act = $modules::Security::FORM{'returnact'};
	my $pa = $modules::Security::session->param('prev_act');
	my $same_site = $modules::Security::session->param('site') eq $modules::Security::session->param('prev_site');
	my $same_mod = $mod eq $modules::Security::session->param('prev_mod');
	unless ($mod and $modules::DBfunctions::dbh->selectrow_array("SELECT ".lc($mod)."_forms_id FROM ".lc($mod)."_forms_tbl WHERE ".lc($mod)."_forms_fld='$pa'")) {
		$pa = $act
	}
	my $logpass = qq{<input type="hidden" name="_4SITESID" value="}.($modules::Security::session->id).qq{">
	<input type="hidden" name="site" value="}.($_[0]||$modules::Security::session->param('site')).qq{">
	<input type="hidden" name="user" value="}.$modules::Security::session->param('user').qq{">
	<input type="hidden" name="prev_site" value="}.(($same_site)?$modules::Security::session->param('prev_site'):$modules::Security::session->param('site')).qq{">
	<input type="hidden" name="prev_mod" value="}.(($same_mod)?$modules::Security::session->param('prev_mod'):$mod).qq{">
	<input type="hidden" name="prev_act" value="}.(($same_site)?(($same_mod)?($modules::Security::session->param('enabled')?$act:$pa||$act):$act):$act).qq{">};
	return $logpass
	} # logpass

sub logpass_user {
	use Digest::MD5 qw(md5_hex);
	my $logpass = qq{<input type="hidden" name="_4SITESID" value="}.($modules::Security::session->id).qq{">
	<input type="hidden" name="user" value="}.$modules::Security::session->param('user').qq{">};
	return $logpass
}

sub returnact {
	qq{<input type="hidden" name="returnact" value="}.($modules::Security::FORM{returnact}||shift).qq{">}
}

sub act {
	qq{<input type="hidden" name="act" value="}.(shift).qq{">}
}

sub logpass_gc {
	use Digest::MD5 qw(md5_hex);
	my $logpass = qq{<input type="hidden" name="_4SITESID" value="}.($modules::Security::session->id).qq{">};
	return $logpass
	} # logpass

sub logpass_func {
	use Digest::MD5 qw(md5_hex);
	my $logpass = qq{<input type="hidden" name="_4SITESID" value="}.($modules::Security::session->id).qq{">
	<input type="hidden" name="fform" value="}.$_[1].qq{">
	<input type="hidden" name="prev_act" value="}.$_[2].qq{">
	<input type="hidden" name="prev_returnact" value="}.$modules::Security::session->param('prev_act').qq{">};
	return $logpass
	} # logpass

sub limit_rows_set {
	my ($sql, $quantity, $params) = @_;
	my $is_end=0;
	my $prev_row;
	my $logpass = logpass();
	my $num_of_rows = rows_count_set("$sql");
	if ($modules::Security::FORM{min} > $quantity) {$prev_row = $modules::Security::FORM{min} - $quantity;}
	else {$prev_row = 0;}
	if (!$modules::Security::FORM{min}) {$modules::Security::FORM{min} = 0;}
	my $last_row = $modules::Security::FORM{min} + $quantity - 1;
	my $last = int($num_of_rows / $quantity)*$quantity;
	if ($last_row >= ($num_of_rows - 1)) {$is_end=1; $last_row = $num_of_rows - 1}
	my $last_tx = $last_row + 1;
	my $fir_tx = $modules::Security::FORM{min} + 1;
	my $out = qq{<table class="tab2" cellpadding="0" cellspacing="0" border="1" width="100%">
	<tr class="tr_col3">
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
		<input type="hidden" name="min" value="0">
		<td class="tal" width="20"><input type="Image" src="/img/arrow_up1.gif" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" title="� �������" class="but"}.($fir_tx==1?' disabled':'').qq{></td>
		$params $logpass}.returnact().qq{
		</form>
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
		<td class="tal" width="20">
	}.returnact();
	$last_row += 1;
	if ($is_end) { $last_row = $modules::Security::FORM{min} }
	$out .= qq{<input type="hidden" name="min" value="$prev_row">
	<input type="Image" src="/img/arrow_left1.gif" title="�����" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"}.($fir_tx==1?' disabled':'').qq{>
	$params $logpass
	<td class="tl">�������� ������ � $fir_tx �� $last_tx �� <b>$num_of_rows</b></td>
	<td class="tar" valign="top"><span class="tr">����� ��</span><select name="_count" onchange="this.form.limit.value=this.value;this.form.submit()">}.count_downlist($quantity).qq{</select></td></form>
	<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl"><td class="tar" width="20">
	}.returnact().qq{
	<input type="hidden" name="min" value="$last_row">
	<input type="Image" src="/img/arrow_right1.gif" title="�����" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"}.($last_tx==$num_of_rows?' disabled':'').qq{>$params $logpass
	</td></form>
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
		<input type="hidden" name="min" value="$last">
		<td class="tal" width="20"><input type="Image" src="/img/arrow_down1.gif" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" title="� ����������" class="but"}.($last_tx==$num_of_rows?' disabled':'').qq{></td>
		$params $logpass}.returnact().qq{
		</form>
	</tr></table>};
	return $out
	} # limit_rows_set

sub rows_count_set {
	my $sql = $_[0];
	#$sql =~ s/^.+FROM/FROM/s;
	$sql =~ s/\sLIMIT.+$//s;
	my @rr = $modules::Core::soap->getQuery("$sql")->paramsout;
	my $total_rows = scalar @rr;
	return $total_rows
	} # rows_count_set

sub array2in { join(", ",@_) }

sub _inst {
	return unless scalar @_;
	my %m;
	foreach (@::INSTALLED,@_) { $m{$_}++ }
	return (scalar(grep { $m{$_}==2 } keys %m)==scalar(@_))?1:0
}

#################################### ���� ######################################

sub get_master_pages {
	my @out;
	my $page_id = shift;
	my $master = $modules::Core::soap->getQuery("SELECT master_page_id FROM page_tbl WHERE page_id=$page_id AND master_page_id>0")->result;
	if ($master) {
		push @out, $master;
		push @out, &get_master_pages($master);
	}
	return @out
} # get_master_pages

sub level { # ����������� ������ ��������
	my $page_id = $_[0];
	my $level = 1;
	my $mas = 1;
	until ($mas == 0) {
		$mas = ($page_id)?$modules::Core::soap->getQuery("SELECT master_page_id
									  FROM page_tbl
									  WHERE page_id=$page_id")->result:0;
		$page_id = $mas;
		$mas && $level++
	}
	return $level
} # level

sub refers_ary {
	my $id = shift;
	my $master = $modules::Core::soap->getQuery("SELECT master_page_id
										FROM page_tbl
										WHERE page_id=$id")->result;
	push (my @refers, $master);
	while ($master != 0) {
		$master = $modules::Core::soap->getQuery("SELECT master_page_id
										 FROM page_tbl
										 WHERE page_id=$master")->result;
		push (@refers, $master)
	}
	return @refers;
} # refers_ary

sub extract_content {
	my $fname = shift;
	my ($str,$flg) = ("",0);
	my @file = $modules::Core::soap->getFile($fname)->paramsout;
	#modules::Debug::dump(\@file,qq{[extract_content] $fname});
	foreach (@file) {
		s/&lt;/</g;
		s/&#xd;//g;
		if (m/^\<\!--\\\\START\\\\--\>/) {
			$flg=1;
			next;
		}
		if (m/^\<\!--\\\\END\\\\--\>/) {
			last if $flg;
		}
		$str .= $_ if $flg;
	}
	return $str;
}

sub print_template {
	my $out;
	my $page_id = shift;
	my $pt_id = $modules::Core::soap->getQuery("SELECT print_template_id FROM page_tbl WHERE page_id=$page_id")->result; # �������� ����� �����_�������.
	if ($pt_id) {
		# ���� ��-���� ���� �����_������...
		my @r = $modules::Core::soap->getQuery("SELECT top_fld,bottom_fld FROM print_template_tbl WHERE template_id=$pt_id")->paramsout;
		my ($templ_top,$templ_bottom) = @{$r[0]}; # �������� ���� � ��� �������
		my $fname = $modules::Core::soap->getQuery("SELECT url_fld FROM page_tbl WHERE page_id=$page_id")->result; # �������� ����� ��������
		$out .= $templ_top;
		$out .= extract_content($fname);
		$out .= $templ_bottom;
	}
	return $out;
} # print_template

sub edit_keywords {
	my $out;
	my @master = get_master_pages($modules::Security::FORM{page_id}); # ������� ������ �� ���������
# 	modules::Debug::dump(\@master);
	my $i = 1;
	if (scalar @master) {
		foreach my $id (@master) {
			my @data = $modules::Core::soap->getQuery("SELECT fulllabel_fld,descr_fld FROM page_tbl WHERE page_id=$id")->paramsout;
			my $inherit = $modules::Core::soap->getQuery("SELECT keywords_id
													FROM keywords_tbl
													WHERE add_page_id=$id AND page_id=$modules::Security::FORM{page_id}")->result;
			my $check = ($inherit)?" checked":"";
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tb"><input type="checkbox" name="kwd_id" value="$id"$check></td>
					   <td class="tl">$data[0]->[0]</td>
					   <td class="tl">$data[0]->[1]</td></tr>}
	   	}
	}
	use modules::ModSet;
	my $ch = $modules::Core::soap->getQuery("SELECT keywords_id
													FROM keywords_tbl
													WHERE add_page_id=0 AND page_id=$modules::Security::FORM{page_id}")->result;
	my $common = modules::ModSet::get_setting("menu","common_description");
	$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tb"><input type="checkbox" name="kwd_id" value="65535" }.($ch?"checked":"").qq{></td>
				   <td class="tl">���� ����</td>
				   <td class="tl">$common</td></tr>};
	return $out;
} # edit_keywords

sub module_settings_list {
	my $out;
	my $langinst = _inst('Language');
	if ($langinst) {
		$langinst = 0 unless $modules::Core::soap->getQuery("SELECT COUNT(language_id) FROM language_tbl")->result
	}
	my $def;
	my $logpass = logpass();
	if ($langinst) {
		$modules::Security::FORM{lang_id} ||= $modules::Core::soap->getQuery("SELECT language_id FROM language_tbl WHERE default_fld='1'")->result;
		$def = ($modules::Security::FORM{lang_id}==$modules::Core::soap->getQuery("SELECT language_id FROM language_tbl WHERE default_fld='1'")->result);
		#use modules::Language qw(:elements);
		$out .= qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl"><table class="nobord"><tr><td class="tr">�����:</td><td class="tal"><select name="lang_id" onchange="this.form.submit()">}.modules::Language::language_downlist($modules::Security::FORM{lang_id}||$modules::Core::soap->getQuery("SELECT language_id FROM language_tbl WHERE default_fld='1'")->result).qq{</select></td></tr></table>}.returnact().qq{$logpass</form>}
	}
	#modules::Debug::dump(\%modules::Security::FORM);
	my $module = shift;
	my $tbl = shift;
	$tbl ||= $module."_settings_tbl";
	my ($t) = $tbl =~ /^(\w+?)_settings_/;
	my $fld = $t."_settings_fld";
	my $id = $t."_settings_id";
	my $extperm = $modules::DBfunctions::dbh->selectrow_array("SELECT extperm_fld FROM user_tbl WHERE user_id=$modules::Security::FORM{user}");
	my $sql = "SELECT $id, $fld,
							 value_fld, description_fld, type_fld".($langinst?", language_id":'')."
							 FROM $tbl
							 ".($langinst?"WHERE language_id IN (0,$modules::Security::FORM{lang_id})
							 ":'')."ORDER BY $fld ASC".($langinst?", language_id DESC":'');
	#modules::Debug::notice($sql);
	my @r = $modules::Core::soap->getQuery($sql)->paramsout;
	my @param;
	push @param=>qq{Use Default} if $langinst;
	push @param=>('<img src="/img/del.gif" hspace="4"/>') if $extperm;
	push @param=>($extperm?'��������/���':'��������');
	push @param=>('��������','��������');
	$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="set" id="set">};
	$out .= start_table().head_table(@param);
	my $i = 1;
	my %f;
	foreach (@r) {
		next if $f{$_->[1]}++;
		#$_->[2] =~ s/</&lt;/g;
		#$_->[2] =~ s/>/&gt;/g;
		$_->[2] =~ s/&lt;/</g;
		my $field;
		if ($_->[4] eq 'TEXT') {
			my @str = split(/\r?\n/=>$_->[2]);
			if (length $_->[2]<=32 and scalar @str<2) {
				$field = qq{<input type="text"  name="value$_->[0]" size="40" value="}.CGI::escapeHTML($_->[2]).qq{"/><input type="hidden" name="type" value="$_->[4]"/><input type="hidden" name="name" value="$_->[1]"/><input type="hidden" name="dlang" value="" />}
			} elsif (scalar @str>2) {
				$field = qq{<textarea name="value$_->[0]" cols="42" rows="7">}.CGI::escapeHTML($_->[2]).qq{</textarea><input type="hidden" name="type" value="$_->[4]"><input type="hidden" name="name" value="$_->[1]"/><input type="hidden" name="dlang" value="" />}
			} else {
				$field = qq{<textarea name="value$_->[0]" cols="42" rows="}.(length $_->[2]>80?7:3).qq{">}.CGI::escapeHTML($_->[2]).qq{</textarea><input type="hidden" name="type" value="$_->[4]"><input type="hidden" name="name" value="$_->[1]"/><input type="hidden" name="dlang" value="" />}
			}
		} elsif ($_->[4] eq 'NUMBER') {
			$field = qq{<input type="text"  name="value$_->[0]" size="6" value="$_->[2]"/><input type="hidden" name="type" value="$_->[4]"/><input type="hidden" name="name" value="$_->[1]"/><input type="hidden" name="dlang" value="" />};
		} elsif ($_->[4] =~ m!^ON/OFF\[([^\]]+)\]!) {
			$field = qq{<label for="ch$_->[0]1" class="tl"}.($_->[2]==$1?' style="font-weight:bold"':'').qq{>ON ($1)</label>&nbsp;<input type="radio" name="value$_->[0]" size="10" value="$1" id="ch$_->[0]1"}.($_->[2]==$1?' checked':'').qq{>  <label for="ch$_->[0]0" class="tl"}.($_->[2]!=$1?' style="font-weight:bold"':'').qq{>OFF</label> <input type="radio" name="value$_->[0]" size="10" value="0" id="ch$_->[0]0"}.($_->[2]!=$1?' checked':'').qq{/><input type="hidden" name="type" value="$_->[4]"/><input type="hidden" name="name" value="$_->[1]"/><input type="hidden" name="dlang" value="" />};
		} elsif ($_->[4] =~ m!^LIST\[([^\]]+)\]!) {
			my @list = split ','=>$1;
			$field = qq{<select name="value_fld"><option value=""></option>};
			foreach my $p (@list) {
				$field .= qq{<option value="$p"}.(($p eq $_->[2])?' selected':'').qq{>$p</option>}
			}
			$field .= qq{</select><input type="hidden" name="type" value="$_->[4]"><input type="hidden" name="name" value="$_->[1]"><input type="hidden" name="dlang" />}
		}
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{" id="tr$_->[0]">}
		.($langinst?qq{<td class="ta"><input type="hidden" name="language_id" value="$_->[-1]" /><input type="checkbox" class="usedef" id="usedef$_->[0]" name="usedef$_->[0]" value="" title="Use default language"}.($_->[-1]==0&&!$def?' checked':$def?' disabled':'').qq{ onchange="togLang('$_->[0]',$modules::Security::FORM{lang_id},$_->[0])" /><input type="hidden" name="chlang$_->[0]" id="chlang$_->[0]" value="" /></td>}:'')
		.($extperm?qq{<td class="del-red"><input type="checkbox" name="del" value="$_->[0]" title="������� ���������" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>}:'')
		.qq{<td class="tal"><span class="tl"><b>$_->[1]</b></span>}.($extperm?qq{<br/><input type="text" name="type_fld"  value="$_->[4]" title="$_->[4]" style="color: #999"/>}:qq{<input type="hidden" name="type_fld" value="$_->[4]"/>}).qq{</td>}
		.qq{<td class="tal nbr">$field</td>}
		.qq{<td class="tl">$_->[3]</td>}
		.qq{<input type="hidden" name="$id" value="$_->[0]">}
		#.($langinst?qq{<input type="hidden" name="language_id" value="$_->[-1]" />}:'')
		.qq{</tr>}
	}
	$out .= qq{<tr class="tr_col3"><td colspan="}.($extperm?($langinst?5:4):3).qq{" class="tr"><input type="Image" src="/img/but/change1.gif" title="��������" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"/></td></tr>}
		.qq{<input type="hidden" name="act" value="edit_setting">}
		.qq{<input type="hidden" name="module" value="$module">
		<input type="hidden" name="tbl" value="$tbl">
		<input type="hidden" name="lang_id" value="$modules::Security::FORM{lang_id}">}
		.returnact().qq{$logpass};
	$out .= end_table().qq{</form>};
	$out .= <<EOHT;
<script type="text/javascript">
function formReady() {
	Ext.Element.select("#set input.usedef").each(function(el,thisel,index) {
		var eel = el.dom
		if (eel.checked) {
			var p = el.findParentNode('tr', 2, true);
			var pr = p.query('input[type="text"]');
			_dsbl(pr)
			pr = p.query('input[type="radio"]')
			_dsbl(pr)
			pr = p.query('textarea')
			_dsbl(pr)
		}
		//el.dom.disabled = true
	}, true)
}

function _dsbl(list) {
	if (list.length) {
		var ll = list.length
		for (var i=0; i<ll; i++) {
			if (list[i]!='') {
				list[i].disabled = true;
			}
		}
	}
}

function togLang(trid,lang,sid) {
	var chk = Ext.get('usedef'+trid).dom.checked
	Ext.Element.select('#tr'+trid+' td input').each(function(el,thisel,index) {
		var eel = el.dom
		if (eel.type!='checkbox') {
			eel.disabled = chk
		}
		if (eel.name=='language_id') {
			eel.value = (chk?0:lang)
		}
		if (eel.name=='dlang') {
			eel.disabled = false
			eel.value = (chk?sid:'')
		}
	}, true)
	Ext.Element.select('#tr'+trid+' td textarea').each(function(el,thisel,index) {
		var eel = el.dom
		eel.disabled = chk
	}, true)
	Ext.get('chlang'+trid).dom.value = (chk?0:lang)
}

</script>
EOHT
	return $out
} # module_settings_list

sub get_id_by_URL {
	#
	# ������� �������� ���� "� ���"
	#
	# ...� ��������� "�� �����". :)
	my $q = shift;
	my ($current,$query) = split /\?/,$q;
	# Parameters from URL
	my @param = get_URL_param($q);
	my %match;
	my %urls;
	my $sth = $modules::Core::soap->getQuery("SELECT page_id,url_fld FROM page_tbl ORDER BY url_fld");
	$sth->execute();
	# �������� ������ ���������� ���� �������
	while (my @row = $sth->fetchrow_array()) {
		my ($id,$url) = @row;
		# Parameters form DB
		my @p = get_URL_param($url);
		if ($#p <= $#param) {
			my %m;
			foreach (@p,@param) { $m{$_}++ }
			my $matches = grep { $_ == 2 } values %m;
			$match{$id} = $matches;
		}
	}

#	@match = grep { $param =~ /^$_/ } sort { $a cmp $b } @match;
	# ����� ������ �������� �� ����, ��������� ��� ����� ����������
	my $best = (sort { $b <=> $a } values %match)[0];
	# ����� ����� ������ �� ���������� ������
	my $key = (sort { $b <=> $a } grep { $match{$_} == $best } keys %match)[0];
#	my $id = $match[ (sort { $b <=> $a } @match)[0] ]; # �, �������, �������� $id ������ �����������!..
#	return $id;
}

sub get_URL_param {
	return sort { $a cmp $b } split /&/,(split /\?/,shift)[1];
}

sub get_result_message {
	my $act = $modules::Security::FORM{'act'};
	my ($msg_id,$text)  = $modules::DBfunctions::dbh->selectrow_array("SELECT actionmsg_id, message_fld FROM actionmsg_tbl WHERE action_fld='$act'");
	$text ||= $modules::Validate::result_msg;
	return " " unless $text;
	while ($text =~ /\{([^}]+)\}/) {
		my $fld = extract_fld($1);
		$text =~ s/\{[^}]+\}/$fld/;
	}
	return $text;
}

sub extract_fld {
	my ($id,$fld) = split /\|/,shift;
	$id =~ m/^(.+?)_id$/;
	my @t = split "_",$1;
	my $tbl = $t[0];
	$tbl = $1 if scalar @t == 2;
	my $data = $modules::DBfunctions::dbh->selectrow_array("SELECT $fld FROM ${tbl}_tbl WHERE $id=$modules::Security::FORM{$id}");
	return $data;
}

sub get_array {
	my $ref = shift;
	return () unless $ref;
	my $clean = shift;
	my @array = (ref $ref eq 'ARRAY')?@{$ref}:($ref);
	@array = grep { $_ } @array if $clean;
	return @array
}

sub info_msg {
	my $msg = shift;
	return qq{<table border="0" cellpadding="0" cellspacing="0" class="inform" height="32" align="center">
<tr><td class="tl-big"><img src="/img/info.gif" width="32" height="32" border="0" align="absmiddle" hspace="5"></td>
<td class="tl-big">$msg</td>
<td align="right" valign="top" width="25"><img src="/img/1pix.gif" width="13" height="13" border="0"></td>
</tr>
</table>
}
}

sub alert_msg {
	my $msg = shift;
	push @{$modules::Security::ERROR{act}}=>$msg;
	return qq{<table border="0" cellpadding="0" cellspacing="0" class="warning" height="32">
<tr><td class="tl-big" rowspan="2" valign="top"><img src="/img/warning.gif" width="32" height="27" border="0" align="absmiddle" hspace="5"></td>
<td class="tl-big" valign="top"><span class="alert">��������!</span></td></tr><tr><td class="tl-big" valign="top">$msg</td></tr></table>};
}

sub error_return {
	my $msg = shift;
	$msg ||= qq{������!};
	push @{$modules::Security::ERROR{act}}=>$msg;
	return 'err'
}

sub count_downlist {
	my $sel = shift|| $modules::Security::FORM{_count};
	my $out = join ''=>map { qq{<option value="$_"}.($_==$sel?' selected':'').qq{>$_</option>} } (4,8,12,16,20);
	$out .= qq{<option value="10000000"}.($sel==10000000?' selected':'').qq{>���</option>}
}

sub start_table {
	my @p = @_;
	my $id = shift;
	my $w = shift;
	return qq{<table class="tab" cellspacing="0" cellpadding="0" border="0"}.($id?qq{ id="$id"}:'').qq{><tr><td><table class="tab2" cellspacing="0" cellpadding="0" border="0"}.($id?qq{ id="${id}_chld"}:'').($w?qq{ width="$w"}:'').qq{>}
}

sub end_table() { return qq{</table></td></tr></table>} }

sub head_table {
	my $out;
	return undef unless (my @h = @_);
	$out .= qq{<tr>};
	foreach my $th (@h) {
		$out .= qq{<th};
		my $title = $th;
		if (ref $th eq 'ARRAY') {
			$title = $th->[0];
			$out .= qq{ colspan="$th->[1]"}
		}
		$out .= qq{>$title</th>}
	}
	$out .= qq{</tr>};
	return $out
}

sub draw_table {
	my $out;
	my $r = shift;
	my $head = shift;
	my $fld = shift;
	#modules::Debug::dump($r);
	#modules::Debug::dump($head);
	#modules::Debug::dump($fld);
	my $count = scalar @$head;
	$out .= qq{<table class="tab" cellspacing="0" cellpadding="0" border="0"><tr><td><table class="tab2" cellspacing="0" cellpadding="0" border="0">};
	$out .= qq{<tr>}.(join ''=>map { qq{<th>$_</th>} } @$head).qq{</tr>};
	for my $i (0..scalar @$r -1) {
		$out .= qq{<tr class="tr_col}.($i % 2 +1).qq{">};
		for my $j (0..scalar @$fld -1) {
			$out .= qq{<td };
			if (ref $fld->[$j] eq 'ARRAY') {
				$out .= qq{class="tal"><input type="text" name="}.$fld->[$j]->[0].qq{" value="}.$r->[$i]->[$fld->[$j]->[1]].qq{" size="}.$fld->[$j]->[2].qq{">}
			} else {
				$out .= qq{class="tal"><input type="Image" src="/img/but/}.$fld->[$j].qq{.gif" title="" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)">}
			}
			$out .= qq{</td>}
		}
		$out .= qq{</tr>}
	}
	$out .= qq{</table></td></tr></table>};
	return $out
}

sub bug_report {
	my $out;
	$out .= qq{<table class="tab" cellspacing="0" cellpadding="0" border="0"><tr><td><table class="tab2" cellspacing="0" cellpadding="0" border="0">};
	$out .= qq{<tr class="tr_col3"><td colspan="2" class="tl"><b>���������</b></td></tr><tr><th>����������</th><th>��������</th></tr>};
	%modules::Security::FORM = (%modules::Security::FORM,%modules::Security::ERROR);
	$modules::Security::FORM{password} = '*' x 16;
	$modules::Security::FORM{site_name} = $modules::DBfunctions::dbh->selectrow_array("SELECT site_fld
															FROM site_tbl
															WHERE site_id=$modules::Security::FORM{site_id}");
	delete $modules::Security::FORM{site_id};
	my $i = 1;
	foreach (sort { $a cmp $b } keys %modules::Security::FORM) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl" valign="top"><b>$_</b></td>};
		if ($_ eq 'ERROR_act') {
			$modules::Security::FORM{$_} =~ s/\\"/"/g;
		}
		unless (ref $modules::Security::FORM{$_}) {
			$out .= qq{<td class="tl">}.$modules::Security::FORM{$_}
		} else {
			$out .= qq{<td class="tal">}.modules::Debug::dump($modules::Security::FORM{$_})
		}
		$out .= qq{</td></tr>}
	}
	$out .= qq{</table></td></tr></table>};
	return $out
}

1;
__END__

=head1 NAME

B<Comfunctions.pl> � ������ ����� ������� (������ � ��, ��������, ������� ��� � �.�.)

=head1 SYNOPSIS

������ ����� ������� (������ � ��, ��������, ������� ��� � �.�.)

=head1 DESCRIPTION

������ ����� ������� (������ � ��, ��������, ������� ��� � �.�.). ������������ �������, ������ ���� ��������� �������.

=head2 [SOAP]downlist

���������� ��������������� ������ ������� ��������� �� �������. ���� ����� B<�����������_�������>, �� �� �� ���������.

=over 4

=item �����:

C<&downlist("���_������� ��� _tbl","���_����������_����"[,"�����������_�������_(id)"]);>

=item ������� ������:

 &downlist("interface","interface_fld");

 &downlist("interface","interface_fld","43");

=item ����������:

���.

=item �����������:

���.

=back

=head2 [SOAP]downlist_sel

���������� ��������������� ������ ������� ��������� �� ������� � ������� �������� �� ���������.

=over 4

=item �����:

C<&downlist_sel("���_������� ��� _tbl","���_����������_����","����������_�������_(id)");>

=item ������ ������:

 &downlist_sel("template","template_fld",$th{'template_id'});

=item ����������:

���.

=item �����������:

���.

=back

=head2 [SOAP]downlist_sel

���������� ��������������� ������ ������� ��������� �� ������� � ������� �������� �� ���������.

=over 4

=item �����:

C<&downlist_sel("���_������� ��� _tbl","���_����������_����","����������_�������_(id)");>

=item ������ ������:

 &downlist_sel("template","template_fld",$th{'template_id'});

=item ����������:

���.

=item �����������:

���.

=back

=head2 [SOAP]downlist2

���������� ��������������� ������ ������� ��������� �� ������� (��� ��������� ����).

=over 4

=item �����:

C<&downlist2("���_������� ��� _tbl","���_����������_����1","���_����������_����2","�����������_�������_(id)");>

=item ������ ������:

 &downlist2("template","template_id","template_fld","43");

=item ����������:

���.

=item �����������:

���.

=back

=head2 [SOAP]downlist2_sel

���������� ��������������� ������ ������� ��������� �� ������� (��� ��������� ����) � ������� �������� �� ���������.

=over 4

=item �����:

C<&downlist2_sel("���_������� ��� _tbl","���_����������_����1","���_����������_����2","����������_�������_(id)");>

=item ������ ������:

 &downlist2_sel("template","template_id","template_fld","43");

=item ����������:

���.

=item �����������:

���.

=back

=head2 [M]add_record

���������� ������ � ������� (SOAP). M-������ ������ �� ��, �� � ��������� ��.

=over 4

=item �����:

C<&add_record("���_�������");>

=item ������ ������:

 &add_record("page_tbl");

=item ����������:

������ ����� ������ �������� B<%FORM>.

=item �����������:

L<decrypt|::Security/"decrypt">.

=back

=head2 [M]edit_record

��������� ������ � ������� (SOAP). M-������ ������ �� ��, �� � ��������� ��.

=over 4

=item �����:

C<&edit_record("��� �������");>

=item ������ ������:

 &edit_record("page_tbl");

=item ����������:

������ ����� ������ �������� B<%FORM>.

=item �����������:

L<decrypt|::Security/"decrypt">.

=back

=head2 [M]del_record

�������� ������ �� ������� (SOAP). M-������ ������ �� ��, �� � ��������� ��.

=over 4

=item �����:

C<&del_record("��� �������");>

=item ������ ������:

 &del_record("page_tbl");

=item ����������:

������ ����� ������ �������� B<%FORM>.

=item �����������:

L<decrypt|::Security/"decrypt">.

=back

=head2 feature_down_sep

����� ������� ��� ���������� ������ ������������� ���� "����/���" � ����������� �� ������.

=over 4

=item �����:

C<&feature_down_sep("���_���_������� ��� _tbl","���_���_������� ��� _tbl","���_���_������������","���_���_����������� ��� _tbl","���_���� �����������","�����_���������_�����");>

=item ������ ������:

 &feature_down_sep("user","function","userfunction_tbl","funcgroup","funcgroup_fld","menuname_fld","function_fld");

������ ������ �������� �����.

=item ����������:

������ ����� ������ �������� B<%FORM>.

=item �����������:

���.

=back

=head2 feature_edit

���������� ������ ������������� ���� "����/���".

=over 4

=item �����:

C<&feature_edit("���_���_������� ��� _tbl","���_���_������� ��� _tbl","���_���_������������");>

=item ������ ������:

 &feature_edit("user","function","userfunction_tbl");

=item ����������:

���.

=item �����������:

L<decrypt|::Security/"decrypt">.

=back

=head2 del_rel

�������� ������� �� ������� � ������������ � ���������� �����������.

=over 4

=item �����:

C<&del_rel("���_�������");>

=item ������ ������:

 &del_rel("page_tbl");

=item ����������:

��������� ���������� ����� B<%FORM>.

=item �����������:

L<decrypt|::Security/"decrypt">.

=back

=head2 date_to_rus

���������� ����, ����������������� � ���������� ��������� (22.06.2000 �.).

=over 4

=item �����:

C<&date_to_rus("���� � ������� MySQL (yyyy-mm-dd)");>

=item ������ ������:

 &date_to_rus("2003-08-05");

=item ����������:

���� ���.

=item �����������:

���.

=back

=head2 timestamp_to_rus

���������� ����, ����������������� � ���������� ��������� (22.06.2000 �.).

=over 4

=item �����:

C<&timestamp_to_rus("���� � ������� MySQL timestamp (yyyymmddHHMMSS)");>

=item ������ ������:

 &timestamp_to_rus("20030805132000");

=item ����������:

���� ���.

=item �����������:

���.

=back

=head2 logpass

���������� � ����� ���� B<ID ������>, B<���� �������>, B<�������>, B<����������� ��������> � B<����� ����������� ��������>.

=over 4

=item �����:

C<&logpass();>

=item ������ ������:

 <input type="hidden" name="_4SITESID" value="ed5499aa992f4f1eff09e8c0b445b005">
 <input type="hidden" name="gc" value="7">
 <input type="hidden" name="fform" value="11">
 <input type="hidden" name="prev_act" value="edit_rel1">
 <input type="hidden" name="prev_returnact" value="edit_page">

=item ����������:

���� ���.

=item �����������:

���.

=back

=head2 logpass_gc

���������� � ����� ���� B<ID ������>.

=over 4

=item �����:

C<&logpass_gc();>

=item ������ ������:

 <input type="hidden" name="_4SITESID" value="ed5499aa992f4f1eff09e8c0b445b005">

=item ����������:

���� ���.

=item �����������:

���.

=back

=head2 logpass_func

���������� � ����� ���� B<ID ������>.

=over 4

=item �����:

C<&logpass_gc();>

=item ������ ������:

 <input type="hidden" name="_4SITESID" value="ed5499aa992f4f1eff09e8c0b445b005">

=item ����������:

���� ���.

=item �����������:

���.

=back

=head2 limit_rows_set

���������� ����� ��� ��������� �� ��������������� ������ ��������.

=over 4

=item �����:

C<&limit_rows_set("����� ������� SELECT","����������_�������_�_������", "�������������� ��������� ��� ������ �����");>

=item ������ ������:

 &limit_rows_set("SELECT page_id from page_fld",10,'<input type="hidden" name="act" value="add_record">');

=item ����������:

��� �������������� �������� ����� ����������, ��������, HTML-��� ����� (��� � �������). �� ������� �� ������� ����������. :)

=item �����������:

L<logpass|"logpass">, L<rows_count_set|"rows_count_set">.

=back

=head2 rows_count_set

������� ���������� ����� � �������������� ������.

=over 4

=item �����:

C<&rows_count_set("�����_�������");>

=item ������ ������:

 &rows_count_set("SELECT page_id from page_fld");

=item ����������:

������� ��������� ��� ����������� �������, �.�. ��������� ������� ������.

=item �����������:

���.

=back

=head2 array2in

�������������� �������� ������� � ������, ����������� ��������,
������������ ��� ����������� ��������� SQL-������� IN.

=over 4

=item �����:

C<&array2in("������");>

=item ������ ������:

 &array2in(@$refers);

=item ����������:

���.

=item �����������:

���.

=back

=head2 get_master_pages

��������� (����������) ID ���� ��������� ������ ��������.

=over 4

=item �����:

C<&get_master_pages($page_id);>

=item ������ ������:

 &get_master_pages(8);

=item ����������:

���������� �������� ��� ����.

=item �����������:

���.

=back

=head2 level

����������� ������ �������� (������� � ���� ������� ����������� � ��������� ����).

=over 4

=item �����:

C<&level($page_id);>

=item ������ ������:

 &level(8);

=item ����������:

���.

=item �����������:

���.

=back

=head2 refers_ary

����������� ������� ����������� �������.
���������� ������ � id ����������� ������� � ������� �� �������� ������ � �������.

=over 4

=item �����:

C<&refers_ary("page_id");>

=item ������ ������:

 &refers_ary("8");

=item ����������:

���.

=item �����������:

���.

=back

=head2 extract_content

���������� �� �������� ����� ������ ����� "������" C<< <!--\\START\\--> >> � C<< <!--\\END\\--> >>.

=over 4

=item �����:

C<&extract_content("���_�����");>

=item ������ ������:

 &extract_content("/ssi/index.shtml");

=item ����������:

��� ����� ������� � ���� ����������� ���� �� ����� �����, ��������, B<F</ssi/index.shtml>>.

=item �����������:

���.

=back

=head2 print_template

������ �������� � �����_�������, ���� �� �������� ��� ��������.

=over 4

=item �����:

C<&print_template($page_id);>

=item ������ ������:

 &print_template(8);

=item ����������:

���.

=item �����������:

L<extract_content|"extract_content">.

=back

=head2 edit_keywords

��������� ������� ��������� ������ �������� � ����� �� � ������� ��� ����������� �������� ���� �� ���.

=over 4

=item �����:

C<&edit_keywords();>

=item ������ ������:

 &edit_keywords();

=item ����������:

��������� ���������� ����� B<%FORM>.

=item �����������:

L<get_master_pages|"get_master_pages">, L<get_setting|::ModSet/"get_setting">.

=back

=head2 module_settings_list

��������� HTML-���� ������ �������� ������.

=over 4

=item �����:

C<&module_settings_list("���_������");>

=item ������ ������:

 &module_settings_list("poll");

=item ����������:

���.

=item �����������:

L<logpass|"logpass">.

=back

=head2 get_id_by_URL

��������� �� �� ID ��������, ����������� ���������� �� ������ ���������� CGI � �������.

=over 4

=item �����:

C<&get_id_by_URL($url);>

=item ������ ������:

 &get_id_by_URL($url);

=item ����������:

Pre-Alpha version. Do not use for production!

=item �����������:

���.

=back

=head2 get_result_message

��������� ���������� �������� �� ����������.

=over 4

=item �����:

C<&get_result_message();>

=item ������ ������:

 &get_result_message();

=item ����������:

���.

=item �����������:

L<extract_fld|"extract_fld">.

=back

=head2 extract_fld

����� �� �� �������� "����_fld", ��������������� �������� "����_id",
�� ������ ���� "����_id|����_fld".

=over 4

=item �����:

C<&extract_fld($������_����_"����_id|����_fld");>

=item ������ ������:

 &extract_fld($1);

=item ����������:

���.

=item �����������:

���.

=back

=head2 get_array

�������� ������ �� ������ ���������.

=over 4

=item �����:

C<get_array($����������_������_����[,$clean]);>

=item ������ ������:

 get_array($modules::Security::FORM{propertytype_fld});

=item ����������:

���������� ������ ������. ���� �� �������� ������, ����� ������ ������. ���� �������� ��������� ������ ��������, �� �������� ���������� ������ �� ������/������������� ���������.

=item �����������:

���.

=back

=head2 info_msg

������� ����-��������� �� �����.

=over 4

=item �����:

C<info_msg($message);>

=item ������ ������:

 get_array(qq{����� ��������� ���!});

=item ����������:

���.

=item �����������:

���.

=back

=head2 alert_msg

������� ��������� �� ������ �� �����.

=over 4

=item �����:

C<alert_msg($message);>

=item ������ ������:

 alert_array(qq{����� ��������� ���!});

=item ����������:

��������� C<$msg> � ������ C<@{$modules::Security::ERROR{act}}>.

=item �����������:

���.

=back

=head2 start_table

������� ��� ������ ������� � �������.

=over 4

=item �����:

C<start_table();>

=item ������ ������:

 start_table();

=item ����������:

���.

=item �����������:

���.

=back

=head2 end_table

������� ��� ����� ������� � �������.

=over 4

=item �����:

C<end_table();>

=item ������ ������:

 end_table();

=item ����������:

���.

=item �����������:

���.

=back

=head2 head_table

������� ������ ���������� (TH) � ������� �������.

=over 4

=item �����:

C<head_table($text1,$text2,...);>

=item ������ ������:

 head_table('��������','����������',['&nbsp;',2]);

=item ����������:

���� ����� �� ���������� �������� ������ ���� C< [$���,$�������_���] >, �� ������� ������ ���� C<< <th colspan="$�������_���">$���</th> >>.

=item �����������:

���.

=back

=head2 bug_report

������� ������� ��������� ������� ( C<%modules::Security::FORM>, C<%modules::Security::ERROR> ).

=over 4

=item �����:

C<bug_report();>

=item ������ ������:

 bug_report();

=item ����������:

� ����� ������������ �������� ������ �������� ������������ "����������".

=item �����������:

���.

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003-2008, Method Lab

=cut
