package modules::NoSOAP;

use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(new getQuery getQueryHash doQuery batchUpdate getColumns
				doDBUpdate getFile getFileEx putFile putFileEx unlinkFile
				unlinkFileEx putXMLFile
				fileExists getStat getFileList getFileListEx shellFilter
				verifyFiles getBackupList);
our $VERSION=1.9;
use strict;
use Digest::MD5 qw(md5 md5_hex);
use File::Basename;
use File::Find;
use File::Path;
use DBI;
use modules::NoSOAP::Result qw(:result);
use modules::Debug;

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = {};
	bless($self,$class);
	my $site = shift;
	return undef unless $site;
	$self->{r} = modules::NoSOAP::Result->new;
	my @s = $modules::DBfunctions::dbh->selectrow_array("SELECT dbname_fld,dbhost_fld,dbuser_fld,dbpass_fld FROM site_tbl WHERE site_id=$site");
	$self->connectDB(@s);
	my ($dir,$htdocs,$cgi) = $modules::DBfunctions::dbh->selectrow_array("SELECT homedir_fld,htdocs_fld,cgidir_fld FROM site_tbl WHERE site_id=$site");
	$self->{_site} = $site;
	$self->{_htdocs} = $dir.$htdocs;
	$self->{_cgidir} = $dir.$cgi;
	return $self
}

sub connectDB {
	my $self = shift;
	my ($db,$host,$user,$pass) = @_;
	my $dbi = "dbi:mysql:$db:$host";
	$self->{dbh} = DBI->connect($dbi,$user,$pass);
	$self->{dbh}->do("SET NAMES cp1251") if $self->{dbh};
}


sub getQuery {
	my $self = shift;
	my $q = shift;
	$self->{r}->_die(qq{Empty QUERY!}) unless $q;
	$q =~ s/&lt;/</g;
	$q =~ s/&amp;/&/g;
	my @out;
	if ($q =~ /^(insert|update|delete|alter|change|drop)/i) {
		return $self->doQuery($q)
	} else {
		my $sth = $self->{dbh}->prepare($q);
		if ($DBI::error) {
			push @out=>qq{$DBI::error: $DBI::errstr};
			$self->{r}->setResult(shift @out);
			$self->{r}->_die(qq{_ERROR $DBI::error: $DBI::errstr})
		}
		$sth->execute();
		if ($sth->rows) {
			push @out, @{$sth->fetchall_arrayref};
			unshift @out, $out[0]->[0]
		}
		$self->{r}->setResult(shift @out);
		$self->{r}->setParams(@out);
		return $self->{r}
	}
}

sub getQueryHash {
	my $self = shift;
	my $q = shift;
	$self->{r}->_die(qq{Empty QUERY!}) unless $q;
	$q =~ s/&lt;/</g;
	$q =~ s/&amp;/&/g;
	my @out;
	if ($q =~ /^(insert|update|delete|alter|change|drop)/i) {
		return $self->doQuery($q)
	} else {
		my $sth = $self->{dbh}->prepare($q);
		if ($DBI::error) {
			push @out=>qq{$DBI::error: $DBI::errstr};
			$self->{r}->setResult(shift @out);
			$self->{r}->_die(qq{_ERROR $DBI::error: $DBI::errstr})
		}
		$sth->execute();
		if ($sth->rows) {
			push @out, $sth->{NUM_OF_FIELDS};
			while (my $row = $sth->fetchrow_hashref) {
				push @out, $row;
			}
		}
		$self->{r}->setResult(shift @out);
		$self->{r}->setParams(@out);
		return $self->{r}
	}
}

sub doQuery {
	my $self = shift;
	my $q = shift;
	$self->{r}->_die(qq{Empty QUERY!}) unless $q;
	$q =~ s/&lt;/</g;
	$q =~ s/&amp;/&/g;
	my $out;
	if ($q =~ /^(insert|update|delete|alter|change|drop)/i) {
		$self->{dbh}->do($q);
		if ($DBI::error) {
			push my @out=>qq{$DBI::error: $DBI::errstr};
			$self->{r}->setResult(shift @out);
			$self->{r}->_die(qq{_ERROR $DBI::error: $DBI::errstr})
		}
		if ($q =~ /^insert/i) {
			my $id = $self->{dbh}->selectrow_array("SELECT LAST_INSERT_ID()");
			$self->{r}->setResult($id);
			return $self->{r}
		}
	} else {
		return $self->getQuery($q)
	}
	return 0
}

sub batchUpdate {
	my $self = shift;
	my $parm = shift;
	my @p = @$parm;
	my $tbl = shift @p;			# [0] table
	my %d = %{ shift @p };		# [1] data hash
	$tbl =~ /(.+?)_tbl/;
	my $id = $1."_id";
	foreach (keys %d) {
		my %data = %{$d{$_}};
		my $sql = "UPDATE $tbl SET ";
		my @f;
		while (my ($f,$v) = each %data) {
			push @f, qq{$f='$v'}
		}
		$sql .= join ", "=>@f;
		$sql .= " WHERE $id=$_";
		$self->{dbh}->do($sql)
	}
}

sub getColumns {
	my $self = shift;
	my $table = shift;
	my %h;
	foreach my $t (@$table)  {
		my $sth = $self->{dbh}->prepare("SHOW COLUMNS FROM $t");
		$sth->execute();
		while (my @row = $sth->fetchrow_array) {
			push @{$h{$t}}, $row[0]
		}
	}
	$self->{r}->setResult(\%h);
	$self->{r}->setParams();
	return $self->{r}
}

sub doDBUpdate {
	my $self = shift;
	my ($db,undef,$sql) = @{$_[0]};
	open (MYSQL,">$self->{_htdocs}/mysql_dump") or $self->{r}->_die("Can't write into mysql_dump: $!");
	print MYSQL $sql;
	close(MYSQL);
	my @s = $modules::DBfunctions::dbh->selectrow_array("SELECT dbname_fld,dbhost_fld,dbuser_fld,dbpass_fld FROM site_tbl WHERE site_id=$self->{_site}");
	system "mysql -u $s[2] --password=$s[3] -D $db < $self->{_htdocs}/mysql_dump";
	unlink "$self->{_htdocs}/mysql_dump";
	$self->{r}->setResult("mysql -u $s[2] --password=$s[3] -D $db < $self->{_htdocs}/mysql_dump");
	$self->{r}->setParams();
	return $self->{r}
}

sub doBackupDB {
	my $self = shift;
	my ($db,@tabs) = @{$_[0]};
	my ($d,$m,$y,@t) = (localtime)[3..5,0..2];
	$m++; $y += 1900;
	my $date = sprintf "%d%02d%02d-%02d%02d%02d",$y,$m,$d,reverse @t;
	my @s = $modules::DBfunctions::dbh->selectrow_array("SELECT dbname_fld,dbhost_fld,dbuser_fld,dbpass_fld FROM site_tbl WHERE site_id=$self->{_site}");
	my $sql = "$self->{_htdocs}/../db_backup/dump_$date.sql";
	$sql =~ s!(?:([^/]+)/\.\./)!!g;
	#my $zip = "$self->{_htdocs}/../db_backup/dump_$date.tar.bz2";
	#$zip =~ s!(?:([^/]+)/\.\./)!!g;
	#my $cd = "$self->{_htdocs}/../db_backup";
	#$cd =~ s!(?:([^/]+)/\.\./)!!g;
	my $cmd = "mysqldump -u $s[2] ".($s[3]?"--password=$s[3] ":'')."$db ".join(' ',@tabs)." > $sql";
	system $cmd;
	#qx{cd $cd; tar -cjf ./dump_$date.tar.bz2 ./dump_$date.sql};
	$self->{r}->setResult($cmd);
	$self->{r}->setParams();
	return $self->{r}
}

sub getBackupList {
	my $self = shift;
	my $path = "$self->{_htdocs}/../db_backup";
	$path =~ s!(?:([^/]+)/\.\./)!!g;
	my @flist = glob "$path/dump_*.sql";
	my %bl;
	foreach my $f (@flist) {
		my @t = sort grep { s/^.+`([^`]+)`.+$/$1/; chomp } qx{grep 'CREATE TAB' $f};
		$f = (split '/'=>$f)[-1];
		$bl{$f} = [ @t ]
	}
	$self->{r}->setResult($path);
	$self->{r}->setParams(%bl);
	return $self->{r}
}

sub doRestore {
	my $self = shift;
	my $file = shift;
	if (ref $file eq 'ARRAY') {
	    $file = $file->[2]
	}
	my $path = "$self->{_htdocs}/../db_backup";
	$path =~ s!(?:([^/]+)/\.\./)!!g;
	$path .= "/$file";
	my @s = $modules::DBfunctions::dbh->selectrow_array("SELECT dbname_fld,dbhost_fld,dbuser_fld,dbpass_fld FROM site_tbl WHERE site_id=$self->{_site}");
	my $str = qq{mysql -D $s[0] -u $s[2]}.($s[3]?" --password=$s[3]":'').qq{ < $path};
	my $res = qx{$str};
	$self->{r}->setResult($str);
	$self->{r}->setParams([$str,$res]);
	return $self->{r}
}

sub getFile {
	my $self = shift;
	my $path = shift;
	$path = $self->_cleanPath($path);
	$self->{r}->_die(qq{File error: Non-existent file '$self->{_htdocs}/$path'!!!}) unless -e $self->{_htdocs}.'/'.$path;
	my @file;
	open (IN, "<"."$self->{_htdocs}/$path");
	@file = <IN>;
	close(IN);
	$self->{r}->setResult($path);
	$self->{r}->setParams(@file);
	return $self->{r}
}

sub getFileEx {
	my $self = shift;
	my $path = shift;
	$self->{r}->_die(qq{File error: Non-existent file '$path'!!!}) unless -e $path;
	my @file;
	open (IN, "<"."$path");
	@file = <IN>;
	close(IN);
	$self->{r}->setResult($path);
	$self->{r}->setParams(@file);
	return $self->{r}
}

sub putXMLFile {
	my $self = shift;
	my ($path,$content,$mod) = @{$_[0]};
	$content =~ s/\r//g;
	$content =~ s/&amp;/&/g;
	$content =~ s/&lt;/</g;
	$content =~ s/&gt;/>/g;
	$content =~ s/&quot;/"/g;
	$content =~ s/&#xd;//g;
	$self->_putFile($path,$content,$mod);
	$self->{r}->setResult("OK");
	$self->{r}->setParams();
	return $self->{r}
}

sub putFile {
	my $self = shift;
	my ($path,$content,$mod) = @{$_[0]};
	$self->_putFile($path,$content,$mod);
	$self->{r}->setResult("OK");
	$self->{r}->setParams();
	return $self->{r}
}

sub _putFile {
	my $self = shift;
	my ($path,$content,$mod) = @_;
	my $d = dirname($path);
	if ($d =~ /\//) {
		my @d = split /\//,dirname($path);
		foreach (0..$#d) {
			my $td = join "/"=>@d[0..$_];
			my $fulldir = $self->{_htdocs}.'/'.$td;
			unless (-e $fulldir) {
				mkdir $fulldir,0775;
				`chmod 0775 $fulldir`
			}
		}
	}
	open (IN, ">"."$self->{_htdocs}/$path") or die "Can't write to $self->{_htdocs}/$path";
	binmode IN;
	print IN $content;
	close(IN);
	my $f = "$self->{_htdocs}/$path";
	my $m = $mod==1?'0674':'0664';
	`chmod $m $f`;
}

sub putFileEx {
	my $self = shift;
	my ($path,$content) = @{$_[0]};
	my $d = dirname($path);
	if ($d =~ /\//) {
		my @d = split /\//,dirname($path);
		foreach (0..$#d) {
			my $td = join "/"=>@d[0..$_];
			my $fulldir = $self->{_htdocs}.'/../'.$td;
			unless (-e $fulldir) {
				mkdir $fulldir,0775 or $self->{r}->_die("Can't mkdir $fulldir: $!");
				`chmod 0775 $fulldir`;
			}
		}
	}
	open (IN, ">"."$self->{_htdocs}/../$path") or $self->{r}->_die("Can't write to $self->{_htdocs}/../$path: $!");
	binmode IN;
	print IN $content;
	close(IN);
	$self->{r}->setResult("OK");
	$self->{r}->setParams();
	return $self->{r}
}

sub unlinkFile {
	my @out;
	my $self = shift;
	my $path = shift;
	unlink "$self->{_htdocs}$path";
	my @d = split /\//,dirname($self->_cleanPath($path));
	if (scalar @d) {
		my $fulldir = $self->{_htdocs}.'/'.$d[0];
		find {
			bydepth  => 1,
			no_chdir => 1,
			wanted   => sub {
							if (!-l && -d _) {
								rmdir
							}
						}
		} => ($fulldir);
	}
	$self->{r}->setResult($path);
	$self->{r}->setParams(@d);
	return $self->{r}
}

sub unlinkFileEx {
	my $self = shift;
	my $path = shift;
	rmtree($path) or unlink "$path" or $self->{r}->_die("Can't unlink $path: $!");
	my @d = split /\//,dirname($self->_cleanPath($path));
	if (scalar @d) {
		my $fulldir = $self->{_htdocs}.'/'.$d[0];
		find {
			bydepth  => 1,
			no_chdir => 1,
			wanted   => sub {
							if (!-l && -d _) {
								rmdir
							}
						}
		} => ($fulldir);
	}
	$self->{r}->setResult($path);
	$self->{r}->setParams(@d);
	return $self->{r}
}

sub fileExists {
	my $self = shift;
	my $ra = shift;
	my $path = $self->{_htdocs};
	my @out;
	foreach (@$ra) {
	    my @f = split /\|/;
	    if (-e $path.$f[0]) {
			push @out,qq{$f[0]|$f[1]|}.(stat $path.$f[0])[2]
	    } else {
			push @out,qq{$f[0]|$f[1]|0}
	    }
	}
	$self->{r}->setResult($out[0]);
	$self->{r}->setParams(@out);
	return $self->{r}
}

sub getStat {
	my $self = shift;
	my $path = shift;
	my @out = stat $self->{_htdocs}.$path;
    if (open(FILE, $self->{_htdocs}.$path)) {
    	binmode(FILE);
		my $md5 = Digest::MD5->new;
    	while (<FILE>) {
        	$md5->add($_);
    	}
    	close(FILE);
		push @out=>$md5->hexdigest
	}
	$self->{r}->setResult($self->{_htdocs}.$path);
	$self->{r}->setParams(@out);
	return $self->{r}
}

sub _cleanPath {
	my $self = shift;
	my $path = shift;
	$path =~ s!^/?(.+?)/?$!$1!;
	return $path
}

sub getFileList {
	my $self = shift;
	my ($dir,$type) = @{$_[0]};
	my $pat = $type?qr/\.($type)/i:qr{([^/]+)};
	my $home = $self->{_htdocs};
	$home = qq{/home/httpd/multisite}.$home unless $home =~ m!^/home!;
	opendir(DIR, $home.$dir) || $self->{r}->_die("can't opendir $home$dir: $!");
		my @dir = readdir(DIR);
	closedir DIR;
	@dir = sort { $a cmp $b } @dir;
	my @out;
	my @dirs;
	my @files;
	foreach (@dir) {
		next if /^\.\.?$/;
		if (-d qq{$home$dir/$_}) {
			push @dirs, ['d',$_]
		} else {
			my $t = (/$pat$/)?'_':'f';
			push @files, [$t,$_]
		}
	}
	@out = (@dirs,@files);
	$self->{r}->setResult($home.$dir);
	$self->{r}->setParams(@out);
	return $self->{r}
}

sub getFileListEx {
	my $self = shift;
	my ($dir,$type) = @{$_[0]};
	my $pat = qr/\.($type)/i;
	opendir(DIR, $dir) || $self->{r}->_die("can't opendir $dir: $!");
		my @dir = readdir(DIR);
	closedir DIR;
	@dir = sort { $a cmp $b } @dir;
	my @out;
	my @dirs;
	my @files;
	foreach (@dir) {
		next if /^\.$/;
		if (-d qq{$dir/$_}) {
			push @dirs, ['d',$_]
		} else {
			my $t = (/$pat$/)?'_':'f';
			push @files, [$t,$_]
		}
	}
	@out = (@dirs,@files);
	$self->{r}->setResult("");
	$self->{r}->setParams(@out);
	return $self->{r}
}

sub shellFilter {
	my $self = shift;
	my $path = shift;
	$path = qq{$self->{_htdocs}$path};
	my @f = glob $path;
	$self->{r}->setResult("");
	$self->{r}->setParams(@f);
	return $self->{r}
}

sub fixPerm {
	my $self = shift;
	my @out;
	my ($url,$lm) = @{$_[0]};
	my $home = $self->{_htdocs};
	my $file = qq{$home/$url};
	my $res = qx{stat $file | grep 'Access: ('};
	my ($perm) = $res =~ /^Access:\s\((\d+)/;
	my $r;
	if ($perm) {
		if ($perm eq '0674') {
			$r = 'OK';
			unless ($lm) {
				qx{chmod 0664 $file};
				$r .= qq{, FIXED $perm to 0664}
			}
		} elsif ($perm eq '0664') {
			my $pp;
			unless ($lm) {
				$r = qq{OK};
				$pp = '0664'
			} else {
				$r .= qq{, FIXED $perm to };
				$pp = '0674'
			}
			qx{chmod $pp $file};
			$r .= $pp if $lm;
		}
	} else {
		$r = 'NOT OK, Unexistent file'
	}
	$self->{r}->setResult($r);
	$self->{r}->setParams(@out);
	return $self->{r}
}

sub verifyFiles {
	my $self = shift;
	my @out;
	my ($path,$fl) = @{$_[0]};
	my $home = $self->{_htdocs};
	my $r;
	foreach my $f (sort {$a cmp $b} keys %$fl) {
		if (my @s = stat qq{$home$path$f}) {
			push @out=>$f if $fl->{$f}!=$s[7]
		} else {
			push @out=>$f
		}
	}
	$self->{r}->setResult($r);
	$self->{r}->setParams(@out);
	return $self->{r}
}

1;
__END__

=head1 NAME

B<NoSOAP.pm> — Модуль обработки низкоуровневых функций Системы без использования SOAP.

=head1 SYNOPSIS

Модуль обработки низкоуровневых функций Системы без использования SOAP по образцу %PERLLIB%/site_perl/5.8.x/SOAP/4Site/ServerAuth.pm.

=head1 DESCRIPTION

Модуль обработки низкоуровневых функций Системы без использования SOAP по образцу %PERLLIB%/site_perl/5.8.x/SOAP/4Site/ServerAuth.pm.

I<Примечание:> Ввиду того, что возврат значений методами в SOAP отличается от общепринятого в Perl, т.е. для скаляра это вызов метода B<result> от результата функции, а для списка E<150> метода paramsout, описания методов, возвращающих скаляр, будут предваряться "B<[R]>", а возвращающих список E<150> "B<[P]>" соответственно.

=head2 new

Конструктор объекта. Принимает ID сайта.

=over 4

=item Вызов:

C<< $modules::Core::soap = modules::NoSOAP->new($site_id) >>

=item Пример вызова:

C<< $modules::Core::soap = modules::NoSOAP->new($site_id) >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 [R][P] getQuery

Выполняет запрос к БД, возвращающий результаты (типа SELECT). Вызывает L<doQuery> при необходимости.

=over 4

=item Вызов:

C<< $soap->getQuery($sql) >>

=item Пример вызова:

C<< $modules::Core::soap->getQuery("SELECT MAX(order_fld) FROM objproperty_tbl WHERE obj_id=$id") >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 doQuery

Выполняет запрос к БД (типа UPDATE, т.е. не возвращающий результатов). Вызывает L<getQuery|"[R][P] getQuery"> при необходимости.

=over 4

=item Вызов:

C<< $soap->doQuery($sql) >>

=item Пример вызова:

C<< $modules::Core::soap->doQuery($sql) >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 getColumns

Возвращает хэш результатов команды "SHOW COLUMNS". Принимает список имён таблиц.

=over 4

=item Вызов:

C<< $soap->getColumns(\@t) >>

=item Пример вызова:

C<< $modules::Core::soap->getColumns(\@t) >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 doDBUpdate

Делает update БД. Принимает имя БД, U<undef> (пустое значение для совместимости с SOAP-версией) и SQL-запрос (одной строкой). SOAP-версия принимает имя БД, U<пароль БД> и SQL-запрос.

=over 4

=item Вызов:

C<< $soap->doDBUpdate([$db,$pass,$sql]) >>

=item Пример вызова:

C<< $soap->doDBUpdate([$db,undef,$sql]) >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 [P] getFile

Возвращает контент заданного файла. Путь задаётся от корня текущего сайта.

=over 4

=item Вызов:

C<< $soap->getFile($url) >>

=item Пример вызова:

C<< $modules::Core::soap->getFile($url) >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 [P] getFileEx

Делает то же, что и L<getFile|"[R] getFile">, но путь задаётся любой.

=over 4

=item Вызов:

C<< $soap->getFileEx($url) >>

=item Пример вызова:

C<< $modules::Core::soap->getFileEx($url) >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 [R] putFile

Сохраняет в файл заданный контент. Создаёт (если нужно) директории. Путь задаётся от корня текущего сайта.

=over 4

=item Вызов:

C<< $soap->putFile([$url,$content]) >>

=item Пример вызова:

C<< $modules::Core::soap->putFile([$url,"$templ_top\n<!--\\\\START\\\\-->\n\n<!--\\\\END\\\\-->\n$templ_bottom"]) >>

=item Примечания:

Возвращает "OK" при удачной операции.

=item Зависимости:

Нет.

=back

=head2 [R] putFileEx

Делает то же, что и L<putFile|"[R] putFile">, но путь задаётся любой.

=over 4

=item Вызов:

C<< $soap->putFileEx([$url,$content]) >>

=item Пример вызова:

C<< $modules::Core::soap->putFileEx([$modules::Security::FORM{cgiref_fld}.'/mailsend/m'.$md.'/'.$modules::Security::FORM{f},$content]) >>

=item Примечания:

Используется в основном в модуле L<modules::System|::System>.

=item Зависимости:

Нет.

=back

=head2 [R] unlinkFile

Удаляет файл. Также удаляет (рекурсивно) освободившиеся в результате этого директории. Путь задаётся от корня текущего сайта.

=over 4

=item Вызов:

C<< $soap->unlinkFile($url) >>

=item Пример вызова:

C<< $modules::Core::soap->unlinkFile($old_url) >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 [R] unlinkFileEx

Делает то же, что и L<unlinkFile|"[R] unlinkFile">, но путь задаётся любой.

=over 4

=item Вызов:

C<< $soap->unlinkFileEx($url) >>

=item Пример вызова:

C<< $modules::Core::soap->unlinkFileEx($old_url) >>

=item Примечания:

Используется в модуле L<modules::System|::System>.

=item Зависимости:

Нет.

=back

=head2 [P] fileExists

Возвращает признаки существования для файлов по списку. Путь задаётся от корня текущего сайта.

=over 4

=item Вызов:

C<< $soap->fileExists(\@files) >>

=item Пример вызова:

C<< $modules::Core::soap->fileExists(\@pages) >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 [P] getStat

Возвращает stat заданного файла. Путь задаётся от корня текущего сайта.

=over 4

=item Вызов:

C<< $soap->getStat($path) >>

=item Пример вызова:

C<< $modules::Core::soap->getStat('/img/gallery/'.$folder.$_f) >>

=item Примечания:

Последним элементом списка возвращает его контрольную сумму.

=item Зависимости:

Нет.

=back

=head2 _cleanPath

Очищает путь от начального и конечного слэшей.

=over 4

=item Вызов:

C<< $self->_cleanPath($path) >>

=item Пример вызова:

C<< $self->_cleanPath($path) >>

=item Примечания:

Внутренняя функция. Не экспортируется.

=item Зависимости:

Нет.

=back

=head2 [P] getFileList

Возвращает список файлов и подкаталогов заданного каталога по маске (задаётся маска для расширения файла) с пометками типа и соответствия маске для каждого элемента. Путь задаётся от корня текущего сайта.

=over 4

=item Вызов:

C<< $soap->getFileList([$dir,$type]) >>

=item Пример вызова:

C<< $soap->getFileList([$dir,$type]) >>

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 [P] getFileListEx

Делает то же, что и L<getFileList|"[P] getFileList">, но путь задаётся любой.

=over 4

=item Вызов:

C<< $soap->getFileListEx([$dir,$type]) >>

=item Пример вызова:

C<< $modules::Core::soap->getFileListEx([$path,'p[lm]']) >>

=item Примечания:

Используется в модуле L<modules::System|::System>.

=item Зависимости:

Нет.

=back

=head2 [R] fixPerm

Исправляет права доступа файлов в дереве сайта, по параметрам. Возвращает строку результата.

=over 4

=item Вызов:

C<< $soap->fixPerm([$path,$lm]) >>

=item Пример вызова:

C<< $modules::Core::soap->fixPerm([$path,1]) >>

=item Примечания:

Используется в модуле L<modules::Page|::Page>.

=item Зависимости:

Нет.

=back

=head2 [P] verifyFiles

Проверяет присутствие и размер файлов по списку. Принимает путь в дереве сайта и список файлов с их длинами (ссылка на хэш). Путь задаётся от корня текущего сайта.

Возвращает список файлов из списка: (а) отсутствующих, (б) с несовпавшей длиной.

=over 4

=item Вызов:

C<< $soap->verifyFiles([$path,$fl]) >>

=item Пример вызова:

C<< $s->verifyFiles([$path,\%m])->paramsout >>

=item Примечания:

Используется в модуле L<modules::Update|::Update>.

=item Зависимости:

Нет.

=back

=head1 AUTHOR

DAY, Method Lab.

=head1 BUGS

No known ones yet. ;))

=head1 SEE ALSO

=head1 COPYRIGHT

E<copy> Copyright 2005-2008 Method Lab

=cut
