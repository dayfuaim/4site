#!/usr/bin/perl

# Модуль функций работы с деревом
package modules::Tree;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw( get_tree get_subtree get_data db_children show_children show_children_trail show_all_children get_all_children check_child num_of_children get_tree_id build_tree);
our $VERSION=1.9;
use strict;

my $trail = 1;

my $menu = qq{<tr>
<td width="5"><img src="/img/1pix.gif" width="5" height="1" border="0"></td>
<td><nobr><p class="menu{LEVEL}p"><img src="/img/lmenu_bull.gif" width="18" height="11" border="0">&nbsp;<a href="{URL}" class="menu{LEVEL}p">{LABEL}</a> {PARENT}</p></nobr></td>
</tr>
};

my $menu_sel = qq{<tr>
<td width="5"><img src="/img/1pix.gif" width="5" height="1" border="0"></td>
<td><nobr><p class="menu{LEVEL}p"><img src="/img/lmenu_now.gif" width="19" height="12" border="0">&nbsp;{LABEL}</p></nobr></td>
</tr>
};

my $menu_before = qq{<tr>
<td class="brown1" width="11"><img src="/img/1pix.gif" width="10" height="1" border="0" align="right"></td>
<td colspan="4"><p class="menu{LEVEL}p"><a href="{URL}" class="menu{LEVEL}p">{LABEL}</a></p></td>
</tr>
};

my $parent = qq{<img src="/img/lmenu_arrow.gif" width="5" height="7" border="0">};

########## Tree functions ###############################################
#

sub get_tree {
	my $id = shift;
	my @overall = $modules::Core::soap->getQuery("SELECT page_id,label_fld,url_fld,master_page_id
											FROM page_tbl
											WHERE enabled_fld=1")->paramsout;
	my $tree = build_tree($id,\@overall);
	return $tree
}

sub build_tree {
	my ($id,$o) = @_;
	my @overall = @{$o};
	my @data = get_data($id,\@overall);
 	my @chld = db_children($id,\@overall);
 	my @child;
	if (scalar @chld) {
		foreach my $ch (@chld) {
			my $chid = $ch->[0];
			push @child, { $chid => build_tree($chid,\@overall) };
		}
	}
	return [\@data,@child];
}

sub get_tree_id {
	my $tree = shift;
	my @id;
	my @chld = @$tree;
	shift @chld;
	for my $ch (@chld) {
		my ($chid,$data) = %{$ch};
		push @id, $chid;
		push @id, get_tree_id($data);
	}
	return @id
}

# sub get_subtree {
# 	my $id = shift;
# 	my @data = get_data($id);
# 	my @chld = db_children($id);
# 	return [\@data,@chld];
# }

sub get_data {
	my ($id,$o) = @_;
	my @overall = @{$o};
	my @data = grep { $_->[0] == $id } @overall;
	return @{$data[0]}[1,2]
}

sub db_children {
	my ($id,$o) = @_;
	my @overall = @{$o};
	my @children = grep { $_->[3] == $id } @overall;
	return @children
}

sub children {
	my $tree = shift;
	my @chld = @$tree;
	shift @chld;
}

sub show_children {
	my $tree = shift;
	my $id = shift;
	my $level = shift;
	my $p = shift || $menu;
	my $p_sel = shift || $menu_sel;
	my $par = shift || $parent;
	my $bullets = shift;	# @bullets array reference
	my @chld = @$tree;
	shift @chld;
	for my $ch (@chld) {
		my ($chid,$data) = %{$ch};
		my ($label,$url) = @{$data->[0]};
		if ($id eq $chid) {
			my $t = $p_sel;
			$t =~ s/{LEVEL}/ $level+1 /gex;
			$t =~ s/{URL}/$url/g;
			$t =~ s/{LABEL}/$label/g;
			$t =~ s/{PARENT}//g;
			$t =~ s/{BULLET}/ $bullets->[$level-1] /gx if $bullets;
			print $t;
			show_children($data,$id,$level+1,$p,$p_sel,$par,$bullets);
		} else {
			my $t = $p;
			$t =~ s/{LEVEL}/ $level+1 /gex;
			$t =~ s/{URL}/$url/g;
			$t =~ s/{LABEL}/$label/g;
			if (num_of_children($id,$data,0) && !check_child($id,$data,0)) {
				$t =~ s/{PARENT}/$par/g
			} else {
				$t =~ s/{PARENT}//g;
			}
			$t =~ s/{BULLET}/ $bullets->[$level-1] /gx if $bullets;
			my $title = $modules::Core::soap->getQuery("SELECT fulllabel_fld FROM page_tbl WHERE page_id=$chid")->result||"";
			$t =~ s/{TITLE}/$title/gx;
			print $t;
			show_children($data,$id,$level+1,$p,$p_sel,$par,$bullets) if check_child($id,$data,0);
		}
	}
}

sub show_children_trail {
	my ($tree,$id,$level,$p,$p_sel,$p_before,$par,$bullets,$trail) = @_;
	my $out;
	$p ||= $menu;
	$p_sel ||= $menu_sel;
	$p_before ||= $menu_before;
	$par ||= $parent;
	$bullets ||= 0;	# @bullets array reference
	$modules::Tree::trail = 1 if $trail;
	my @chld = @$tree;
	shift @chld;
	for my $ch (@chld) {
		my ($chid,$data) = %{$ch};
		my ($label,$url) = @{$data->[0]};
		if ($id eq $chid) {
			$modules::Tree::trail = 0;
			my $t = $p_sel;
			$t =~ s/{LEVEL}/ $level /gex;
			$t =~ s/{LEV_WIDTH}/ ($level>2)?7+($level-3)*10:0 /gex;
			$t =~ s/{URL}/$url/g;
			$t =~ s/{LABEL}/$label/g;
			$t =~ s/{PARENT}//g;
			$t =~ s/{BULLET}/ $bullets->[$level-1] /gx if $bullets;
			$out .= $t;
			$out .= show_children_trail($data,$id,$level+1,$p,$p_sel,$p_before,$par,$bullets);
		} else {
			my $t = ($modules::Tree::trail==0)?$p:$p_before;
			$t =~ s/{LEVEL}/ $level /gex;
			$t =~ s/{LEV_WIDTH}/ ($level>2)?7+($level-3)*10:0 /gex;
			$t =~ s/{URL}/$url/g;
			$t =~ s/{LABEL}/$label/g;
			if (num_of_children($id,$data,0) && !check_child($id,$data,0)) {
				$t =~ s/{PARENT}/$par/g
			} else {
				$t =~ s/{PARENT}//g;
			}
			$t =~ s/{BULLET}/ $bullets->[$level-1] /gx if $bullets;
			$out .= $t;
			$out .= show_children_trail($data,$id,$level+1,$p,$p_sel,$p_before,$par,$bullets) if check_child($id,$data,0);
		}
	}
	return $out;
}

sub show_all_children {
	my $tree = shift;
	my $id = shift;
	my $level = shift;
	my $p = shift || $menu;
	my $p_sel = shift || $menu_sel;
	my $bullets = shift;	# @bullets array reference
	my @chld = @$tree;
	shift @chld;
	for my $ch (@chld) {
		my ($chid,$data) = %{$ch};
		my ($label,$url) = @{$data->[0]};
		my $t = ($id eq $chid)?$p_sel:$p;
		$t =~ s/{LEVEL}/ $level+1 /gex;
		$t =~ s/{URL}/$url/g;
		$t =~ s/{LABEL}/$label/g;
		$t =~ s/{PARENT}//g;
		$t =~ s/{BULLET}/ $bullets->[$level-1] /gx if $bullets;
		my $title = $modules::Core::soap->getQuery("SELECT fulllabel_fld FROM page_tbl WHERE page_id=$chid")->result||"";
		$t =~ s/{TITLE}/$title/gx;
		print $t;
		show_all_children($data,$id,$level+1,$p,$p_sel,$bullets);
	}
}

sub get_all_children {
 	my $out;
	my $tree = shift;
	my $id = shift;
	my $level = shift;
	my $p = shift || $menu;
	my $p_sel = shift || $menu_sel;
	my $bullets = shift;	# @bullets array reference
	my @chld = @$tree;
	shift @chld;
	for my $ch (@chld) {
		my ($chid,$data) = %{$ch};
		my ($label,$url) = @{$data->[0]};
		my $t = ($id eq $chid)?$p_sel:$p;
		$label =~ s!<?img[^>]*?>!!g;
		$t =~ s/{LEVEL}/ $level+1 /gex;
		$t =~ s/{URL}/$url/g;
		$t =~ s/{LABEL}/$label/g;
		$t =~ s/{PARENT}//g;
		$t =~ s/{BULLET}/ $bullets->[$level-1] /gx if $bullets;
		$out .= $t;
		$out .= get_all_children($data,$id,$level+1,$p,$p_sel,$bullets);
	}
	return $out;
}

sub check_child {
	my ($chid,$tree,$dive_in) = @_;
	my $is = undef;
	my @chld = @$tree;
	shift @chld;
	for my $ch (@chld) {
		last if $is;
		my ($id,$data) = %{$ch};
		if ($id eq $chid) {
			$is = 1;
		} else {
			$is = check_child($chid,$data,$dive_in) if $dive_in;
		}
	}
	return $is;
}

sub num_of_children {
	my ($id,$tree,$dive_in) = @_;
	my @chld = @$tree;
	shift @chld;
	my $num = scalar @chld;
	if ($dive_in) {
		for my $ch (@chld) {
			my ($id,$data) = %{$ch};
			$num += num_of_children($id,$data,$dive_in);
	 	}
	}
	return $num;
}

1;
__END__

=head1 NAME

B<Tree.pm> — Модуль функций работы с деревом

=head1 SYNOPSIS

Модуль функций работы с деревом

=head1 DESCRIPTION

Модуль функций работы с деревом

=head2 get_tree

Строит из БД дерево с корнем в $id.

=over 4

=item Вызов:

C<get_tree($id)>

=item Пример вызова:

 get_tree($id);

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 get_subtree

Строит из БД поддерево с корнем в $id.

=over 4

=item Вызов:

C<get_subtree($id)>

=item Пример вызова:

 get_subtree($id);

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 get_data

Получает из БД данные текущего узла.

=over 4

=item Вызов:

C<get_data($id)>

=item Пример вызова:

 get_data($id);

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 db_children

Получает из БД массив детей текущего узла.

=over 4

=item Вызов:

C<db_children($id)>

=item Пример вызова:

 db_children($id);

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 children

Отдаёт массив детей текущего узла.

=over 4

=item Вызов:

C<children($tree)>

=item Пример вызова:

 children($tree);

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 show_children

Показывает поддерево текущего узла в виде меню с текущими шаблонами.

=over 4

=item Вызов:

C<show_children($tree,$current_ID,$level,$menu,$menu_sel)>

=item Пример вызова:

 show_children($tree,$current_ID,1,$menu,$menu_sel);

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 show_children_trail

Показывает поддерево текущего узла в виде меню с текущими шаблонами (шаблоны для элементов до и после выбранного — разные).

=over 4

=item Вызов:

C<show_children_trail($tree,$current_ID,$level,$menu,$menu_sel,$menu_before,$parentID,\@bullets,$trail)>

=item Пример вызова:

 show_children_trail($tree,$current_ID,2,$menu,$menu_sel,$menu_before,"",0,(scalar @$tree ==2 || $parent_ID==0)?0:1);

=item Примечания:

blah.

=item Зависимости:

L<num_of_children|"num_of_children">, L<check_child|"check_child">.

=back

=head2 show_all_children

Показывает развёрнутое поддерево текущего узла в виде меню с текущими шаблонами.

=over 4

=item Вызов:

C<show_all_children($tree,$id,$level,$menu,$menu_sel,\@bullets)>

=item Пример вызова:

 show_all_children($tree,$current_ID,1,$p,$p_sel,\@bullets);

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 get_all_children

Возвращает развёрнутое поддерево текущего узла в виде меню с текущими шаблонами.

=over 4

=item Вызов:

C<get_all_children($tree,$id,$level,$menu,$menu_sel,\@bullets)>

=item Пример вызова:

 get_all_children($tree,$current_ID,1,$p,$p_sel,\@bullets);

=item Примечания:

Нет.

=item Зависимости:

Нет.

=back

=head2 check_child

Проверка наличия ребёнка с ID=$chid в любом поддереве текущего узла.

=over 4

=item Вызов:

C<check_child($chid,$tree,$dive_in)>

=item Пример вызова:

 check_child($chid,$tree,1);

=item Примечания:

Если C<$dive_in>, то рекурсивно углубляется в поддеревья, иначе проверяет только детей текущего узла.

=item Зависимости:

Нет.

=back

=head2 num_of_children

Находит количество детей текущего узла.

=over 4

=item Вызов:

C<num_of_children($id,$tree,$dive_in)>

=item Пример вызова:

 num_of_children($id,$tree,1);

=item Примечания:

Если C<$dive_in>, то включаются все дети всех дочерних узлов.

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
