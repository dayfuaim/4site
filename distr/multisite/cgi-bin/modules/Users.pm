#!/usr/bin/perl
#
#

# Модуль
package modules::Users;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(get_actions);
our %EXPORT_TAGS = (
				actions => [qw(add_user del_user edit_user edit_users_setting)],
				elements => [qw(user_chars user_edit user_data users_settings_list
							 user_obj_downlist)],
					);
our @EXPORT_OK = (get_actions, @{$EXPORT_TAGS{actions}}, @{$EXPORT_TAGS{elements}});
our $VERSION=1.9;
use strict;
use modules::Settings;
use modules::DBfunctions;
use modules::ModSet;
use modules::Comfunctions qw(:DEFAULT :records :elements);
use modules::Objects qw(:elements :actions);
use modules::Debug;

$modules::DBfunctions::dbh = connectDB();

sub get_actions {
	return $EXPORT_TAGS{actions}
}

################################################################################
################################## Elements ####################################
################################################################################

sub user_chars {
	my $out;
	my @r = $modules::Core::soap->getQuery("SELECT DISTINCT LOWER(SUBSTRING(login_fld,1,1)) as c FROM users_tbl ORDER BY c")->paramsout;
	my @char;
	my @preload;
	foreach my $ch (@r) {
		next unless $ch->[0];
		if ($ch->[0] eq $modules::Security::FORM{char}) {
			push @char, qq{<img src="$modules::Settings::c{dir}{cgi_ref}/modules/$modules::Security::FORM{module}/img/badges/$ch->[0]-open.gif" alt="$ch->[0]" title="$ch->[0]" width="28" height="24" border="0" class="img1">}
		} else {
			push @char, qq{<a href="#" onclick="document.forms.ue.char.value='$ch->[0]';submit('ue')"><img src="$modules::Settings::c{dir}{cgi_ref}/modules/$modules::Security::FORM{module}/img/badges/$ch->[0].gif" alt="$ch->[0]" title="$ch->[0]" width="28" height="24" border="0" class="img1" onmouseover="this.src='$modules::Settings::c{dir}{cgi_ref}/modules/$modules::Security::FORM{module}/img/badges/$ch->[0]-select.gif'" onmouseout="this.src='$modules::Settings::c{dir}{cgi_ref}/modules/$modules::Security::FORM{module}/img/badges/$ch->[0].gif'"></a>};
			push @preload=>qq{'$modules::Settings::c{dir}{cgi_ref}/modules/$modules::Security::FORM{module}/img/badges/$ch->[0]-select.gif'}
		}
	}
	my $p = qq{<script>preloadImages(}.(join ","=>@preload).qq{);</script>};
	$out .= join " "=>@char;
	return $p.$out
}

sub user_edit {
	my $out;
	if ($modules::Security::FORM{show}) {
		$out .= qq{<table class="tab" cellpadding="0" cellspacing="0"><tr><td><table class="tab2" cellpadding="0" cellspacing="0" width="100%">
<tr>
<th>Логин</th>
<th><img src="/img/del.gif" border="0" hspace="4"></th></tr>
};
		my $i = 0;
		my $logpass = logpass();
		my @r = $modules::Core::soap->getQuery("SELECT * FROM users_tbl WHERE SUBSTRING(login_fld,1,1)='$modules::Security::FORM{char}' ORDER BY login_fld")->paramsout;
		foreach my $c (@r) {
			my @row = @{$c};
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tl" width="200"><a class="link" href="#" onclick="document.forms.edus.user_id.value='$row[0]';document.forms.edus.char.value='$modules::Security::FORM{char}';document.forms.edus.submit()">$row[1]</a></td>
			<td class="del-red"><input type="checkbox" name="del" value="$row[0]"></td>
			</tr>}
		}
		$out .= qq{<input type="hidden" name="char" value="$modules::Security::FORM{char}">
		<tr><td colspan="2" class="tar"><input type="Image" src="/img/but/delete1.gif" title="Удалить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></tr>};
		$out .= qq{</table></td></tr></table>};
	}
	return $out
}

sub user_obj_downlist {
	$modules::Security::FORM{objtype_id} = get_setting('users','default_objtype') unless $modules::Security::FORM{objtype_id};
	my $sel = shift;
	obj_by_type_downlist($sel)
}

sub user_data {
	my $out;
	my $logpass = logpass();
	my @r = $modules::Core::soap->getQuery("SELECT * FROM users_tbl WHERE user_id=$modules::Security::FORM{user_id}")->paramsout;
	my @row = @{$r[0]};
	$modules::Security::FORM{objtype_id} = get_setting('users','default_objtype');
	$out .= qq{
	<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
	<input type="hidden" name="user_id" value="$row[0]">$logpass
	<table class="tab_nobord">
<tr><td class="tl">Логин</td>
<td class="tal"><input type="text"  name="login_fld" size="20" value="$row[1]"></td></tr>
<tr><td class="tl">Пароль</td>
<td class="tal"><input type="text"  name="pass_fld" size="20" value="$row[2]"></td></tr>
<tr><td class="tl">Объект</td>
<td class="tal"><select name="obj_id"><option value="0">-- Нет --</option>}.user_obj_downlist($row[3]).qq{</select><input type="Image" src="/img/arrow_right1.gif" title="Редактировать объект" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="this.form.act.value='';this.form.returnact.value='obj';this.form.submit()" /></td></tr>
<tr><td class="tl">E-Mail</td>
<td class="tal"><input type="text"  name="email_fld" size="20" value="$row[4]"></td></tr>
<tr><td class="tl">Блокировка</td>
<td class="tal"><input type="checkbox" name="block_fld" value="1"}.($row[5]?' checked':'').qq{></td></tr>
<tr><td>&nbsp;</td>
<td><input type="Image" src="/img/but/change1.gif" title="Изменить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
</tr>
</table>
<input type="hidden" name="char" value="$modules::Security::FORM{char}">
<input type="hidden" name="act" value="edit_user">
<input type="hidden" name="objtype_id" value="$modules::Security::FORM{objtype_id}">
<input type="hidden" name="show" value="1">
<input type="hidden" name="returnact" value="edit_user"></form>
};
	return $out
}

sub users_settings_list {
	module_settings_list("users");
}

################################################################################
################################### Actions ####################################
################################################################################

sub edit_users_setting {
	edit_record("users_settings_tbl");
}

sub add_user {
	if ($modules::Security::FORM{obj_fld}) {
		$modules::Security::FORM{objtype_id} = get_setting('users','default_objtype');
		$modules::Security::FORM{obj_id} = add_obj()
	}
	add_record("users_tbl")
}

sub del_user {
	my @del = (ref $modules::Security::FORM{del} eq 'ARRAY')?@{$modules::Security::FORM{del}}:($modules::Security::FORM{del});
	foreach (@del) {
		$modules::Security::FORM{user_id} = $_;
		del_record("users_tbl")
	}
}

sub edit_user {
	edit_record("users_tbl")
}

1;
__END__

=head1 NAME

B<Users.pm> — Модуль для управления данными пользователей сайта.

=head1 SYNOPSIS

Модуль для управления данными пользователей сайта.

=head1 DESCRIPTION

Модуль для управления данными пользователей сайта.

=head2 user_chars

Выводит строку первых букв логинов пользователей.

=over 4

=item Вызов:

C<< <!--#include virtual="user_chars"--> >>

=item Пример вызова:

C<< <!--#include virtual="user_chars"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 user_edit

Таблица пользователей со статистикой писем по каждому.

=over 4

=item Вызов:

C<< <!--#include virtual="user_edit"--> >>

=item Пример вызова:

C<< <!--#include virtual="user_edit"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 user_data

Данные пользователя для редактирования.

=over 4

=item Вызов:

C<< <!--#include virtual="user_data"--> >>

=item Пример вызова:

C<< <!--#include virtual="user_data"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 users_settings_list

Выводит список настроек модуля.

=over 4

=item Вызов:

C<< <!--#include virtual="users_settings_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="users_settings_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 edit_users_setting

Изменяет настройки модуля.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 (add|edit|del)_user

Добавление|редактирование|удаление пользователя.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
