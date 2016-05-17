#!/usr/bin/perl

package modules::Page;

use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(get_actions);
our %EXPORT_TAGS = (
				actions => [qw(add_page edit_page edit_page_metadata swap_page
					edit_pagemaster edit_cache del_page edit_keywords edit_menu_setting add_related del_related
					edit_menupix edit_menupixurl edit_template add_template del_template edit_print_template
					add_print_template del_print_template add_related_group edit_related_group
					del_related_group edit_page_related_group del_page_related_group
					order_related add_servpage edit_servpage del_servpage
					del_page_batch order_related_group add_page_comment
					del_page_comment edit_page_comment del_page_xml
					reorder_page)],
				elements => [qw(masterpage_sel masterpage_id originalpage_sel originalpage_id page_id page_sel
					pageed_sel page_select page_select_master page_swap page_del template_downlist
					print_template_downlist page1st_downlist template_list print_template_list page_downlist
					page_sections_downlist page_section_downlist_sel check_template rebuild_pages
					menu_settings_list related_list page_edit template_edit print_template_edit menupix_edit
					keywords_edit validate_menu page_cache_list tmpl_downlist statistics page_title
					related_group_list related_group_downlist related_group_edit related_group_data
					related_group_switchlist page_select_xml page_cache_list_xml
					refers template_preview keyword_suggest keyword_stat
					page_ex_downlist related_order_drag servpage_list
					page_ex_list fixperm_list related_group_order_drag
					page_comment_form page_select_master_tree
					page_select_edit_tree page_select_tree _subtree_simple
					page_comment_list)],
				);
our @EXPORT_OK = (get_actions, @{$EXPORT_TAGS{actions}}, @{$EXPORT_TAGS{elements}});
our $VERSION=1.98;
use CGI;
use CGI(escapeHTML);
use File::Basename;
use strict;
use modules::Comfunctions qw(:DEFAULT :downlist :records :elements :file);
use modules::Validfunc;
use modules::Validate;
use modules::ModSet;
use modules::Debug;
use vars qw(%Validate);

my %words;

sub get_actions {
	return $EXPORT_TAGS{actions}
}

################################################################################
################################## Elements ####################################
################################################################################

sub page_title {
	my $title;
	if (defined $modules::Security::FORM{page_id}) {
		if ($modules::Security::FORM{page_id}!=0) {
			$title = $modules::Core::soap->getQuery("SELECT label_fld FROM page_tbl WHERE page_id=$modules::Security::FORM{page_id}")->result
		} else {
			$title = "Весь сайт"
		}
	}
	if ($modules::Security::FORM{page_id}!=0) {
		$title = qq{<h2>Страница &laquo;$title&raquo;</h2>}
	} else {
		$title = qq{<h2>$title</h2>}
	}
	return $title;
}

sub masterpage_sel { # Текст выбранной родительской страницы
	my @page = $modules::Core::soap->getQuery("SELECT label_fld, url_fld
									  FROM page_tbl
									  WHERE page_id=$modules::Security::FORM{master_page_id}")->paramsout;
	return qq{$page[0]->[0] ($page[0]->[1])}
} # masterpage_sel

sub masterpage_id { $modules::Security::FORM{master_page_id} } # masterpage_id

sub originalpage_sel { # Текст выбранной страницы
	my @page = $modules::Core::soap->getQuery("SELECT label_fld, url_fld
									  FROM page_tbl
									  WHERE page_id=$modules::Security::FORM{original_page_id}")->paramsout;
	return qq{$page[0]->[0] ($page[0]->[1])}
} # originalpage_sel

sub originalpage_id { $modules::Security::FORM{original_page_id} } # originalpage_id

sub page_id { $modules::Security::FORM{page_id} } # page_id

sub page_sel { # Текст выбранной страницы
	my @page = $modules::Core::soap->getQuery("SELECT label_fld, url_fld
									  FROM page_tbl
									  WHERE page_id=$modules::Security::FORM{page_id}")->paramsout;
	return qq{$page[0]->[0] ($page[0]->[1])}
} # page_sel

sub pageed_sel { # Текст выбранной страницы для редактирования страниц
	my @page = $modules::Core::soap->getQuery("SELECT label_fld, url_fld
									  FROM page_tbl
									  WHERE page_id=$modules::Security::FORM{page_id}")->paramsout;
	return qq{$page[0]->[0] ($page[0]->[1])}
} # page_sel

sub page_select_xml {
	$|++;
	my $out;
	my $pp = shift;
	#modules::Debug::notice($modules::Security::FORM{returnact});
	#modules::Debug::dump($pp,$modules::Security::FORM{page_id});
	my $res = $modules::Core::soap->getQuery("SELECT page_id,master_page_id,
										label_fld,url_fld,
										enabled_fld,mainmenu_fld,
										index_fld,order_fld
										FROM page_tbl");
	my @tree = $res->paramsout;
	my $ml = $modules::Core::soap->getQuery("SHOW TABLES LIKE 'language%'")->result; # very long
		$out .= qq{<div class="divtree"><table class="tab" width="100%"><tr><th width="100%">Страница</th>
	<th width="14"><img src="/img/visible.gif" border="0" alt="Доступность" title="Доступность"></th>
	<th width="14"><img src="/img/active.gif" border="0" hspace="1" alt="В Главном меню" title="В Главном меню"></th>
	<th width="14"><img src="/img/index.gif" border="0" alt="Индексация" title="Индексация"></th>
	</tr></table><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="5" id="tree">} if ($modules::Security::FORM{returnact} eq 'edit_page_xml' or $modules::Security::FORM{returnact} eq 'del_page_xml') and not $pp;
		$out .= qq{};
		my $lev;
		if (defined $pp) {
			$lev = scalar getParent(\@tree,$pp)
		}
		$out .= drawChildren_xml(\@tree,defined($pp)?$pp:0,$pp?$lev:0,$ml);
		$out .= qq{</td></tr>};
		$out .= qq{<tr><td colspan="5" class="tar_tree"><input type="Image" }.($modules::Security::FORM{returnact} eq 'del_page_xml'?qq{src="/img/but/delete1.gif" title="Удалить"}:qq{src="/img/but/change1.gif" title="Изменить"}).qq{  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="}.($modules::Security::FORM{returnact} eq 'del_page_xml'?qq[if(confirm("")){massub('$modules::Security::FORM{returnact}')}]:qq{massub('$modules::Security::FORM{returnact}')}).qq{"></td></tr></table>} if ($modules::Security::FORM{returnact} eq 'edit_page_xml' or $modules::Security::FORM{returnact} eq 'del_page_xml') and not $pp;
		$out .= qq{};
	$out .= qq#
<script language="JavaScript">
function sw(oid) {
	var o = document.getElementById('dd'+oid)
	var im = document.getElementById('i'+oid)
	if (/\\/open\\./.test(im.src)) {
		o.innerHTML = ""
		im.src='/img/4site/menu/close.gif'
	} else {
		popup(oid,function() {attClick();chkclk(oid)});
		im.src='/img/4site/menu/open.gif'
	}
}

// Prototype stuff
function popup(oid,callback) {
	new Ajax.Updater('dd'+oid,
					CGI_REF+'/xmlget.pl?id='+oid+'&_4SITESID=$modules::Security::FORM{_4SITESID}',
					{method: 'get', onComplete: callback});
}

function tree_click(e) {
	if (!e) var e = window.event;
	var targ;
	if (e.target) targ = e.target;
	else if (e.srcElement) targ = e.srcElement;
	if (targ.tagName=='INPUT') { return }
	if (targ.tagName=='IMG') { return }
	var a = targ.id;
	a = a.replace(/l([0-9]+)/,'\$1')
	do_act(targ.act,a)
}

function _getEventTarg(evt) {
	var targ = null;
	if (evt.target) targ = evt.target;
	else if (evt.srcElement) targ = evt.srcElement;
	return targ
}

function _getTag(obj,tag) {
	if (obj.tagName==tag) {
		return obj
	} else {
		return _getTag(obj.parentNode,tag)
	}
}
#.(!$pp?qq|
function attClick() {
	var leaves = Ext.get('tree').dom.getElementsByTagName('li');
	for (var i = 0; i<leaves.length; i++) {
		addEvent(leaves[i],'click',tree_click)
		leaves[i].act = '$modules::Security::FORM{returnact}'
	}
}
attClick();|:'').qq{
</script>
};
	return $out
}

sub drawChildren_xml {
	my ($p,$id,$l,$ml) = @_;
	my $out;
	my $ch = getChildren($p,$id);
	my $ua = $ENV{HTTP_USER_AGENT};
	my $ie_hover = ($ua!~/msie/i)?'':qq{ onmouseover="this.className='over'" onmouseout="this.className='out'" class="out"};
	#modules::Debug::notice($ie_hover,$ua);
	if (scalar @$ch > 0) {
		$out .= qq{<ul id="d$id" class="tree">
		};
		my $i = 0;
		foreach my $page (@$ch) {
			$i++;
			#next unless $page->[4];
			my $chd = numChildren($p,$page->[0]);
			my $sib = numSibling($p,$page->[0]);
			# Timeout dirty hack ;)
			#print " ";
			$out .= qq{<li height="19" class="leaf}.($page->[0]==$modules::Security::FORM{spage_id}?'sel':'').qq{" title="$page->[3]" id="l$page->[0]"}.$ie_hover.qq{>
			};
			if ($chd) {
				$out .= qq{<img align="absmiddle" id="i$page->[0]" src="/img/4site/menu/close.gif" onclick="sw($page->[0])">}
			}
			$out .= qq{<img align="absmiddle" src="/img/4site/menu/}.($chd?'folder':'page').qq{.gif">};
			$out .= qq{$page->[2]};
			if ($modules::Security::FORM{returnact} eq 'edit_page_xml') {
				$out .= qq{<input type="checkbox" name="e$page->[0]"}.(($page->[4])?" checked":"").qq{ value="1" class="box3" title="Видимость">};
				if (!$ml and $l<1) {
					$out .= qq{<input type="checkbox" name="m$page->[0]"}.(($page->[5])?" checked":"").qq{ value="1" class="box2" title="В Главном меню">}
				} elsif ($ml and $l<2) {
					$out .= qq{<input type="checkbox" name="m$page->[0]"}.(($page->[5])?" checked":"").qq{ value="1" class="box2" title="В Главном меню">}
				} else {
					$out .= qq{<input type="checkbox" style="visibility: hidden" class="box2">}
				}
				$out .= qq{<input type="checkbox" name="i$page->[0]"}.(($page->[6])?" checked":"").qq{ value="1" class="box1" title="}.(($page->[6])?"И":"Не и").qq{ндексируется">};
			}
			if ($modules::Security::FORM{returnact} eq 'del_page_xml') {
				$out .= qq{<input type="checkbox" name="del" value="$page->[0]" id="d$page->[0]" p="$id" ch="}.($chd?1:0).qq{" class="box3" title="Удалить" onclick="chkclk($page->[0])">};
			}
			$out .= qq{<input type="hidden" name="page" value="$page->[0]">};
			$out .= qq{</li>
			};
			if ($chd) {
				$out .= qq{<div id="dd$page->[0]" class="_chld" style=""></div>};
			}
		}
		$out .= qq{</ul>};
	}
	return $out
}

sub page_select { # Элемент с выбором страницы (графическое представление)
	#use Time::HiRes qw(usleep);
	#$|++;
	my $out;
	my ($res,@tree);
	my $done = $modules::Settings::c{dir}{cgi}.qq{/_session/_ps}.(int(rand)*1_000_000);
	system 'touch', $done;
	#if (my $pid = fork) {
	#	print "FORK!!!<br/>";
	#	while (-e $done) {
	#		print " ";
	#		usleep(250000)
	#	}
	#	return
	#} else {
		#print "__CHILD...";
		my @tree = $modules::Core::soap->getQuery("SELECT page_id,master_page_id,
										label_fld,url_fld,
										enabled_fld,mainmenu_fld,
										index_fld,order_fld
										FROM page_tbl")->paramsout;
		unlink $done;
		my $ml = $modules::Core::soap->getQuery("SHOW TABLES LIKE 'language%'")->result; # very long
		$out .= qq{<div class="divtree"><table class="tab" width="100%"><tr><th width="100%">Страница</th>
		<th width="14"><img src="/img/visible.gif" border="0" alt="Доступность" title="Доступность"></th>
		<th width="14"><img src="/img/active.gif" border="0" hspace="1" alt="В Главном меню" title="В Главном меню"></th>
		<th width="14"><img src="/img/index.gif" border="0" alt="Индексация" title="Индексация"></th>
		</tr></table>} if $modules::Security::FORM{returnact} eq 'edit_page';
		$out .= qq{<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="5" id="tree">};

		$out .= drawChildren(\@tree,0,0,$ml);

		$out .= qq{</td></tr>};
		$out .= qq{<tr><td colspan="5" class="tar_tree"><input type="Image" src="/img/but/change1.gif" title="Изменить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="massub('edit_page')"></td></tr>} if $modules::Security::FORM{returnact} eq 'edit_page';
		$out .= qq{</table></div>};
		my @pr = getParent(\@tree,$modules::Security::FORM{page_id});
		my @ch;
		foreach my $p (@tree) {
			my @c = grep { $p->[0]==$_ } @pr;
			push @ch, $p->[0] unless scalar @c
		}
		my $ch = join ',', @ch;
		$out .= <<EOHT;
<script language="JavaScript">
var plus = 0;
function sw(oid) {
	var o = document.getElementById('d'+oid)
	var im = document.getElementById('i'+oid)
	if (o.style.display=='') {
		o.style.display='none'
		im.src='/img/4site/menu/close.gif'
	} else {
		o.style.display=''
		im.src='/img/4site/menu/open.gif'
	}
}

var ch = new Array($ch)
for (i=0;i<ch.length;i++) {
	var o = document.getElementById('d'+ch[i])
	var im = document.getElementById('i'+ch[i])
	if (o==null) continue;
	o.style.display='none'
	im.src='/img/4site/menu/close.gif'
}

function tree_click(e) {
	if (!e) var e = window.event;
	var targ;
	if (e.target) targ = e.target;
	else if (e.srcElement) targ = e.srcElement;
	if (targ.tagName=='INPUT') { return }
	if (targ.tagName=='IMG') { return }
	var a = targ.id;
	a = a.replace(/l([0-9]+)/,'\$1')
	do_act(targ.act,a)
}

function _getTag(obj,tag) {
	if (obj.tagName==tag) {
		return obj
	} else {
		return _getTag(obj.parentNode,tag)
	}
}

var leaves = document.getElementById('tree').getElementsByTagName('li');
for (i = 0; i<leaves.length; i++) {
	addEvent(leaves[i],'click',tree_click)
	leaves[i].act = '$modules::Security::FORM{returnact}'
}
</script>
EOHT
		return $out
	#}
} # page_select

sub drawChildren {
	my ($p,$id,$l,$ml) = @_;
	my $out;
	my $ch = getChildren($p,$id);
	my $ua = $ENV{HTTP_USER_AGENT};
	my $ie_hover = ($ua!~/msie/i)?'':qq{ onmouseover="this.className='over'" onmouseout="this.className='out'" class="out"};
	#modules::Debug::notice($ie_hover,$ua);
	if (scalar @$ch > 0) {
		$out .= qq{<ul id="d$id" class="tree">
		};
		my $i = 0;
		foreach my $page (@$ch) {
			$i++;
			# modules::Debug::dump($page);
			#next unless $page->[4];
			my $chd = numChildren($p,$page->[0]);
			my $sib = numSibling($p,$page->[0]);
			# Timeout dirty hack ;)
			print " ";
			$out .= qq{<li height="19" class="leaf}.($page->[0]==$modules::Security::FORM{spage_id}?'sel':'').qq{" title="$page->[3]" id="l$page->[0]"}.$ie_hover.qq{>
			};
			if ($chd) {
				$out .= qq{<img align="absmiddle" id="i$page->[0]" src="/img/4site/menu/open.gif" onclick="sw($page->[0])">}
			}
			$out .= qq{<img align="absmiddle" src="/img/4site/menu/}.($chd?'folder':'page').qq{.gif">};
			$out .= qq{$page->[2]};
			if ($modules::Security::FORM{returnact} eq 'edit_page') {
				$out .= qq{<input type="checkbox" name="e$page->[0]"}.(($page->[4])?" checked":"").qq{ value="1" class="box3">};
				if (!$ml and $l<1) {
					$out .= qq{<input type="checkbox" name="m$page->[0]"}.(($page->[5])?" checked":"").qq{ value="1" class="box2">}
				} elsif ($ml and $l<2) {
					$out .= qq{<input type="checkbox" name="m$page->[0]"}.(($page->[5])?" checked":"").qq{ value="1" class="box2">}
				} else {
					$out .= qq{<input type="checkbox" style="visibility: hidden" class="box2">}
				}
				$out .= qq{<input type="checkbox" name="i$page->[0]"}.(($page->[6])?" checked":"").qq{ value="1" class="box1">};
			}
			$out .= qq{<input type="hidden" name="page" value="$page->[0]">};
			$out .= qq{</li>
			};
			if ($chd) {
				$out .= drawChildren($p,$page->[0],$l+1,$ml)
			}
		}
		$out .= qq{</ul>};
	}
	return $out
}

# Only one level down
sub getChildren {
	my ($p,$id) = @_;
	my @ch;
	@ch = sort { $a->[7] <=> $b->[7] } grep { $_->[1]==$id } @$p; # and $_->[4]
	return \@ch
}

# Down from here on (XSLT-inspired)
sub getDescendants {
	my ($p,$id) = @_;
	my @ch = sort { $a->[7] <=> $b->[7] } grep { $_->[1]==$id } @$p;
	my @c = @ch;
	foreach (@c) {
		push @ch, @{getDescendants($p,$_->[0])}
	}
	return \@ch
}

sub getParent {
	my ($p,$id) = @_;
	my @p;
	my @par = grep { $_->[0] eq $id } @$p;
	push @p, $par[0]->[1];
	if ($par[0]->[1]) {
		push @p, getParent($p,$par[0]->[1])
	}
	return @p
}

sub numChildren {
	my ($p,$id) = @_;
	return scalar grep { $_->[1]==$id } @$p
}

sub numSibling {
	my ($p,$id) = @_;
	my @s = grep { $_->[0]==$id } @$p;
	my $spar = $s[0][1];
	return scalar grep { $_->[1]==$spar } @$p
}

# Simple JSON Tree
sub page_select_tree {
	my $out;
	$out = _subtree_simple(0);
	return $out

}

sub _subtree_simple {
	my ($mid) = @_;
	my $out;
	my @r1 = $modules::Core::soap->getQuery("SELECT page_id, label_fld, url_fld,
											mainmenu_fld, enabled_fld, index_fld
											FROM page_tbl
											WHERE master_page_id=$mid
											ORDER BY order_fld")->paramsout;
	#$out .= '[';
	if (@r1) {
		$out .= '[';
		my @p;
		foreach my $c (@r1) {
			my $sub = _subtree_simple($c->[0]);
			my $out1;
			$c->[1] = escapeHTML($c->[1]);
			$out1 .= qq({ id: 'c$c->[0]', text: ').qq{<b>$c->[1]</b> ($c->[2])}.qq(', listeners: { 'click' : function() { ).$modules::Security::FORM{returnact}.qq(($c->[0]) } }, );
			if ($sub ne '[]') {
				$out1 .= qq(expanded: false, leaf: false, children: $sub)
			} else {
				$out1 .= qq(leaf: true)
			}
			$out1 .= qq{, cls: 'x-tree-selected'} if $c->[0]==$modules::Security::FORM{spage_id};
			$out1 .= qq(, master: $mid });
			push @p => $out1
		}
		$out .= join ','=>@p;
		$out .= ']'
	} else {
		$out .= '[]'
	}
	#$out .= ']';
	return $out
}

sub page_select_edit_tree {
	my $out;
	$out = _subtree_edit(0);
	return $out
}

sub _subtree_edit {
	my ($mid) = @_;
	my $out;
	my @r1 = $modules::Core::soap->getQuery("SELECT page_id, label_fld, url_fld,
											mainmenu_fld, enabled_fld, index_fld
											FROM page_tbl
											WHERE master_page_id=$mid
											ORDER BY order_fld")->paramsout;
	if (@r1) {
		$out .= '[';
		my @p;
		foreach my $c (@r1) {
			my $sub = _subtree_edit($c->[0]);
			my $out1;
			$c->[1] = escapeHTML($c->[1]);
			$out1 .= qq({ id: 'c$c->[0]', text: ').qq{<span onclick="do_act(\\'edit_page\\',$c->[0])"><b>$c->[1]</b> ($c->[2])}.qq(<input type="hidden" name="page" value="$c->[0]"></span>', uiProvider:'col', );
			if ($sub) {
				$out1 .= qq(expanded: false, leaf: false, children: $sub)
			} else {
				$out1 .= qq(leaf: true)
			}
			$out1 .= qq(, master: $mid, mainmenu: ').(($mid==0)?qq{<input type="checkbox" name="m$c->[0]" value="1"}.(($c->[3])?" checked":"").qq{/>}:'&nbsp;').qq(', enbl: '<input type="checkbox" value="1" name="e$c->[0]").(($c->[4])?" checked":"").qq(/>', indx: '<input type="checkbox" name="i$c->[0]" value="1").(($c->[5])?" checked":"").qq(/>' });
			push @p => $out1
		}
		$out .= join ','=>@p;
		$out .=  ']'
	}
	return $out
}

sub page_select_master_tree {
	my $out;
	$out = _subtree(0);
	return $out
}

sub _subtree {
	my ($mid) = @_;
	my $out;
	my @r1 = $modules::Core::soap->getQuery("SELECT page_id, label_fld, url_fld
											FROM page_tbl
											WHERE master_page_id=$mid
											ORDER BY order_fld")->paramsout;
	if (@r1) {
		$out .= '[';
		my @p;
		foreach my $c (@r1) {
			my $sub = _subtree($c->[0]);
			my $out1;
			$c->[1] = escapeHTML($c->[1]);
			$out1 .= qq({ id: 'c$c->[0]', text: ').($c->[2] eq '/index.shtml'?qq{<b>$c->[1]</b> ($c->[2])}:"$c->[1]").qq(', qtip: '$c->[2]', allowDrag: true, );
			if ($sub) {
				$out1 .= qq(allowDrop: true, expanded: false, leaf: false, children: $sub)
			} else {
				$out1 .= qq(allowDrop: true, leaf: false, children: [])
			}
			$out1 .= qq(, master: $mid });
			push @p => $out1
		}
		$out .= join ','=>@p;
		$out .= ']'
	}
	return $out
}

sub page_select_master { # Элемент с выбором master-страницы (графическое представление)
	$|++;
	my $out;
	my @tree = $modules::Core::soap->getQuery("SELECT page_id,master_page_id,
										label_fld,url_fld,
										enabled_fld,mainmenu_fld,
										index_fld,order_fld
										FROM page_tbl")->paramsout;
	my $ml = $modules::Core::soap->getQuery("SHOW TABLES LIKE 'language%'")->result; # very long
	$out .= qq{<div class="divtree"><table width="60%" border="0" cellspacing="0" cellpadding="0"><tr><td id="tree">};
	$out .= drawChildren(\@tree,0,0,$ml);
	$out .= qq{</td></tr></table></div>};
	my @pr = getParent(\@tree,$modules::Security::FORM{page_id});
	my @ch;
	foreach my $p (@tree) {
		my @c = grep { $p->[0]==$_ } @pr;
		push @ch, $p->[0] unless scalar @c
	}
	my $ch = join ',', @ch;
	$out .= <<EOHT;
<script language="JavaScript">
var plus = 0;
function sw(oid) {
	var o = document.getElementById('d'+oid)
	var im = document.getElementById('i'+oid)
	if (o.style.display=='') {
		o.style.display='none'
		im.src='/img/4site/menu/close.gif'
	} else {
		o.style.display=''
		im.src='/img/4site/menu/open.gif'
	}
}

var ch = new Array($ch)
for (i=0;i<ch.length;i++) {
	var o = document.getElementById('d'+ch[i])
	var im = document.getElementById('i'+ch[i])
	if (o==null) continue;
	o.style.display='none'
	im.src='/img/4site/menu/close.gif'
}

function tree_hilite(e) {
	if (!e) var e = window.event;
	var targ;
	if (e.target) targ = e.target;
	else if (e.srcElement) targ = e.srcElement;
	if (targ.nodeType==3) { targ = targ.parentNode; }
	e.cancelBubble = true;
	if (e.stopPropagation) e.stopPropagation();
	if (targ.tagName=='TD') {
		targ.className = 'green'
	} else if (targ.tagName=='B' || targ.tagName=='NOBR') {
		_getTag(targ,'TD').className = 'green'
	} else { return }
}
function tree_unlite(e) {
	if (!e) var e = window.event;
	var targ;
	if (e.target) targ = e.target;
	else if (e.srcElement) targ = e.srcElement;
	if (targ.nodeType==3) { targ = targ.parentNode; }
	e.cancelBubble = true;
	if (e.stopPropagation) e.stopPropagation();
	if (targ.tagName=='TD') {
		targ.className = 'white'
	} else if (targ.tagName=='B' || targ.tagName=='NOBR') {
		_getTag(targ,'TD').className = 'white'
	} else { return }
}

function tree_click(e) {
	if (!e) var e = window.event;
	var targ;
	if (e.target) targ = e.target;
	else if (e.srcElement) targ = e.srcElement;
	if (targ.tagName=='INPUT') { return }
	if (targ.tagName=='IMG') { return }
	var a = targ.id;
	a = a.replace(/l([0-9]+)/,'\$1')
	do_act(targ.act,a)
}

function _getTag(obj,tag) {
	if (obj.tagName==tag) {
		return obj
	} else {
		return _getTag(obj.parentNode,tag)
	}
}

var leaves = document.getElementById('tree').getElementsByTagName('li');
for (i = 0; i<leaves.length; i++) {
	addEvent(leaves[i],'click',tree_click)
	leaves[i].act = '$modules::Security::FORM{returnact}'
}
</script>
EOHT
	return $out;
	} # page_select_master

sub page_swap { # Перемена страниц местами
	my $out;
	if ($modules::Security::FORM{page_id} and $modules::Security::FORM{show}) {
		my @page = $modules::Core::soap->getQuery("SELECT label_fld, url_fld,
										  master_page_id
										  FROM page_tbl
										  WHERE page_id=$modules::Security::FORM{page_id}")->paramsout;
		my $page_l;
		my @r = $modules::Core::soap->getQuery("SELECT page_id, label_fld,
								 url_fld, order_fld
								 FROM page_tbl
								 WHERE (master_page_id=$page[0]->[2])
								 AND (page_id!=$modules::Security::FORM{page_id})
								 ORDER BY order_fld ASC")->paramsout;
		my $i = 1;
		$out .= qq{<h2>Вставить <b>&laquo;$page[0]->[0]</b> ($page[0]->[1])<b>&raquo;</b>:</h2>
		<table class="tab" cellspacing="0" cellpadding="0" border="0"><tr><td>
		<table class="tab2" cellspacing="0" cellpadding="0" border="0">
		<tr><th>Куда</th><th>Название (URL)</th></tr>
		<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="ta"><input type="radio" name="order_fld" value="1"></td><td>&nbsp;</td></tr>
		};
		foreach (@r) {
				$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
				<td>&nbsp;</td><td class="tl"><b>$_->[1]</b> ($_->[2])</td></tr>
				<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="ta"><input type="radio" name="order_fld" value="}.($_->[3]+1).qq{"></td><td>&nbsp;</td></tr>};
		}
		$out .= qq{<tr><td colspan="2" class="tar"><input type="Image" src="/img/but/exchange1.gif" title="Поменять" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td></tr></table></td></tr></table>
		<input type="hidden" name="page_id1" value="$modules::Security::FORM{page_id}">}
	}
	#print $out;
	return $out;
} # page_swap

sub page_cache_list {
	my $out;
	$modules::Core::soap = shift;
	my %p = @_;
	$modules::Security::FORM{page_id} = $p{id};
	my $p = $modules::Security::FORM{page_id};
	my $label = $modules::Core::soap->getQuery("SELECT label_fld FROM page_tbl WHERE page_id=$p")->result;
	$label =~ s/<img[^>]+>//;
	my @r = $modules::Core::soap->getQuery("SELECT cache_fld,expires_fld FROM page_tbl WHERE page_id=$p")->paramsout;
	$out = qq{<h2>Кэширование страницы <b>&laquo;$label&raquo;</b></h2>
<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
<input type="hidden" name="spage_id" value="$p">}.start_table().qq{<tr class="tr_col1"><td class="tb"><input type="checkbox" id="c" name="cache_fld" value="1"}.($r[0]->[0] eq '1'?" checked":"").qq{ onclick="onoff()"></td><td class="tl" colspan="2"><label for="c">Кэшировать</label></td></tr>
	<tr class="tr_col2"><td class="tal"><input type="text" id="e" name="expires_fld" value="$r[0]->[1]" size="4">&nbsp;</td><td class="tl">Количество дней жизни кэша</td></tr><tr><td>&nbsp;</td><td class="tar" colspan="2"><input type="Image" src="/img/but/change1.gif" title="Изменить" class="but" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" /></td></tr>
<input type="hidden" name="act" value="edit_cache"><input type="hidden" name="returnact" value="cache_page"></tr>}.end_table().modules::Comfunctions::logpass().qq{</form>
	<input type="hidden" name="page_id" value="$p">
	<script type="text/javascript">
	function onoff() {
		var cc = document.getElementById('c')
		var ee = document.getElementById('e')
		if (cc.checked==true) {
			ee.disabled=false
		} else {
			ee.disabled=true
			ee.value=0
		}
	}
	onoff()
	</script>};
	modules::Security::extract_act($out);
	return $out
}

sub page_del { # Вывод кнопки для удаления страницы
	my $out;
	if ($modules::Security::FORM{page_id} and $modules::Security::FORM{show} and $modules::Security::FORM{spage_id}) {
		my @page = $modules::Core::soap->getQuery("SELECT label_fld, url_fld,
										  master_page_id
										  FROM page_tbl
										  WHERE page_id=$modules::Security::FORM{page_id}")->paramsout;
		$out .= qq{<br/>}.alert_msg('Вместе с выбранной будут удалены все подчиненные ей страницы!').qq{<br/><table cellpadding="0" cellspacing="0"><tr><td><p class="note-big">Удалить страницу <b>«$page[0]->[0] ($page[0]->[1])»</b></p></td><td><input type="Image" src="/img/but/delete1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td></tr></table>
		<input type="hidden" name="page_id1" value="$modules::Security::FORM{page_id}"></h2>};
	}
	return $out;
} # page_del

sub tmpl_downlist {
	my $out;
	my $id = $modules::Security::FORM{template_id} || ($modules::Security::FORM{printtemplate_id} % 10000);
	my $type = int($modules::Security::FORM{printtemplate_id}/10000) || 0;
	$out .= qq{<optgroup label="Обычные">};
	my @r = $modules::Core::soap->getQuery("SELECT * FROM template_tbl")->paramsout;
	for (@r) {
		$out .= qq{<option value="$_->[0]"}.(($_->[0]==$id and $type==0)?' selected':'').qq{>$_->[1]</option>}
	}
	$out .= qq{</optgroup>};
	$out .= qq{<optgroup label="Печатные">};
	@r = $modules::Core::soap->getQuery("SELECT * FROM printtemplate_tbl")->paramsout;
	for (@r) {
		$out .= qq{<option value="}.($_->[0]+10000).qq{"}.(($_->[0]==$id and $type==1)?' selected':'').qq{>$_->[1]</option>}
	}
	$out .= qq{</optgroup>};
	return $out
}

sub template_downlist {
	return qq{<option value="0">-- Без шаблона --</option>}.SOAPdownlist_sel("template","template_fld",shift||$modules::Security::FORM{template_id})
} # funcgroup_downlist

sub print_template_downlist { SOAPdownlist_sel("printtemplate","printtemplate_fld",$modules::Security::FORM{printtemplate_id})} # funcgroup_downlist

sub page1st_downlist { # Страницы-разделы
	page_section_downlist_sel($modules::Security::FORM{page_id});
} # page1st_downlist

sub template_list { #
	my $logpass = logpass();
	my @r = $modules::Core::soap->getQuery("SELECT t.*, COUNT(p.page_id)
											FROM template_tbl as t
												LEFT JOIN page_tbl as p ON (p.template_id=t.template_id)
											GROUP BY template_fld")->paramsout;
	my $out;
	if (scalar @r) {
		my $i = 1;
		$out .= qq{<tr class="tr_col3"><td colspan="2" class="tl"><b>Обычные</b></td></tr>};
		foreach (@r) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tl">$_->[1]</td>
			<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			<td class="del-red" title="}.($_->[4]>0?"Удалить нельзя: на этом шаблоне есть страницы ($_->[4])":"").qq{">}.(($_->[4]>0)?'&nbsp;&nbsp;&nbsp;':qq{<input type="Image" src="/img/but/delete_s1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)">}).qq{</td>
			<input type="hidden" name="act" value="del_template">
			<input type="hidden" name="type" value="0">
			<input type="hidden" name="template_id" value="$_->[0]">
			<input type="hidden" name="returnact" value="del_template">$logpass</form></tr>};
		}
		$out .= qq{<tr class="tr_col3"><td colspan="2" class="tl"><b>Печатные</b></td></tr>};
		@r = $modules::Core::soap->getQuery("SELECT *
								 FROM printtemplate_tbl
								 ORDER BY printtemplate_fld ASC")->paramsout;
		foreach (@r) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tl">$_->[1]</td>
			<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			<td class="del-red"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
			<input type="hidden" name="act" value="del_template">
			<input type="hidden" name="type" value="1">
			<input type="hidden" name="template_id" value="$_->[0]">
			<input type="hidden" name="returnact" value="del_template">$logpass</form></tr>};
		}
	} else {
		$out .= info_msg(qq{Нет ни одного шаблона})
	}
	return $out
} #  template_list

sub print_template_list { # список разделов Галереи
	my $logpass = logpass();
	my @r = $modules::Core::soap->getQuery("SELECT *
							 FROM printtemplate_tbl
							 ORDER BY printtemplate_fld ASC")->paramsout;
	my $out;
	my $i = 1;
	foreach (@r) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
		<td class="tl">$_->[1]</td>
		<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
		<td class="ta"><input type="Image" src="/img/but/delete1.gif" title="Удалить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
		<input type="hidden" name="act" value="del_print_template">
		<input type="hidden" name="printtemplate_id" value="$_->[0]">
		<input type="hidden" name="returnact" value="del_print_template">$logpass</form></tr>};
	}
	return $out
} # print_template_list

sub page_downlist { return SOAPdownlist2_sel("page","label_fld","url_fld",$modules::Security::FORM{page_id}||shift||undef) } # page_downlist

sub page_sections_downlist {
	my $out;
	my $id = shift || $modules::Security::FORM{page_id};
	my @r = $modules::Core::soap->getQuery("SELECT page_id, label_fld FROM page_tbl WHERE master_page_id=0 ORDER BY order_fld")->paramsout;
	foreach (@r) {
		$out .= qq{<option value="$_->[0]"}.(($_->[0]==$id)?' selected':'').qq{>$_->[1]</option>}
	}
	return $out
} # page_sections_downlist

sub page_section_downlist_sel {
	my $sel = shift || $modules::Security::FORM{page_id};
	my $out;
	my @r = $modules::Core::soap->getQuery("SELECT page_id,label_fld
	   						FROM page_tbl
							WHERE master_page_id=0
							ORDER BY order_fld")->paramsout;
	foreach (@r) {
		my @m = @$_;
		$out .= qq{<optgroup label="$m[1]">};
		$out .= qq{<option value="$m[0]"}.(($m[0]==$sel)?" selected":"").qq{>$m[1]</option>};
		my @r1 = $modules::Core::soap->getQuery("SELECT page_id,label_fld
								FROM page_tbl
								WHERE master_page_id=$m[0]
								ORDER BY order_fld")->paramsout;
		foreach (@r1) {
			$out .= qq{<option value="$_->[0]"}.(($_->[0]==$sel)?" selected":"").qq{>$_->[1]</option>}
		}
		$out .= qq{</optgroup>}
	}
	return $out
}

sub page_ex_downlist {
	my $out;
	my $sel;
	if ($_[0]) {
		$sel = shift;
	} else {
		$sel = $modules::Security::FORM{original_page_id} || $modules::Security::FORM{page_id};
	}
	my @r = $modules::Core::soap->getQuery("SELECT page_id,label_fld,
										   master_page_id,url_fld
										   FROM page_tbl
										   ORDER BY master_page_id,order_fld")->paramsout;
	my $l = 0;
	$out .= _pl(\@r,\@r,$l,$sel);
	return $out
}

sub _pl {
	my ($r,$r1,$l,$sel) = @_;
	my $out;
	#modules::Debug::notice($l);
	foreach my $c (@{$r1}) {
		$out .= qq{<option value="$c->[0]"}.(($sel==$c->[0])?" selected":"").qq{>}.('&nbsp;&nbsp;&nbsp;' x $l).qq{$c->[1] ($c->[3])</option>};
		my @r1 = grep { $_->[2]==$c->[0] } @{$r};
		next unless scalar @r1;
		@{$r} = grep { $_->[2]!=$c->[0] } @{$r};
		$out .= _pl($r,\@r1,$l+1,$sel);
	}
	return $out
}

sub page_ex_list {
	my $out;
	my $sel = shift || $modules::Security::FORM{original_page_id} || $modules::Security::FORM{page_id};
	my @r = $modules::Core::soap->getQuery("SELECT page_id,label_fld,
										   master_page_id,url_fld
										   FROM page_tbl
										   ORDER BY master_page_id,order_fld")->paramsout;
	my $l = 0;
	my $i = 1;
	$out .= start_table().head_table('Страница','<img src="/img/del.gif" border="0" align="absmiddle">');
	$out .= _pxl(\@r,\@r,$l,$sel,\$i);
	$out .= qq{<tr class="tr_col4"><td colspan="2" class="tar"><input type="Image" src="/img/but/delete1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="return checkDel('del_page')"></td></tr>};
	$out .= end_table();
	return $out
}

sub _pxl {
	my ($r,$r1,$l,$sel,$ri) = @_;
	my $out;
	#modules::Debug::notice($l);
	foreach my $c (@{$r1}) {
		$out .= qq{<tr class="tr_col}.(${$ri}++ % 2 +1).qq{"><td class="tl" alt="$c->[3]" title="$c->[3]">}.('&nbsp;&nbsp;&nbsp;' x $l).qq{<b alt="$c->[3]" title="$c->[3]">$c->[1]</b></td><td class="tal"><input type="checkbox" value="$c->[0]" name="del"></td></tr>};
		my @r1 = grep { $_->[2]==$c->[0] } @{$r};
		next unless scalar @r1;
		@{$r} = grep { $_->[2]!=$c->[0] } @{$r};
		$out .= _pxl($r,\@r1,$l+1,$sel,$ri);
	}
	return $out
}

sub menu_settings_list { module_settings_list("page",'menu_settings_tbl') } # menu_settings_list

sub related_order_drag {
    my $out;
	return unless $::SHOW;
	$out .= qq{<form name="fo" method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			   <input type="hidden" name="order_fld" value="">
			   <input type="hidden" name="show" value="1">
			   <input type="hidden" name="original_page_id" value="$modules::Security::FORM{original_page_id}">
   <p class="note"><b>Примечание:</b> чтобы поменять местами страницы, необходимо навести мышку на&nbsp;блок с&nbsp;названием страницы и&nbsp;перетащить в&nbsp;нужное место. Нажать кнопку &laquo;Изменить&raquo;.</p>
   <table class="tab_gal" border="0" cellpadding="0" cellspacing="0"><tr><td>};
	my @r = $modules::Core::soap->getQuery("SELECT rel_page_id,label_fld,url_fld
										  FROM related_tbl as r, page_tbl as p
						   WHERE original_page_id=$modules::Security::FORM{original_page_id}
						   AND p.page_id=rel_page_id
						   ORDER BY r.order_fld")->paramsout;
	if (scalar @r) {
		$out .= qq{<ul id="gpix" class="gpic">
		};
		my $i = 1;
		foreach (@r) {
			$out .= qq{<li id="p$i"><table class="tab" width="98%"><tr class="tr_col}.($i++ % 2 +1).qq{" id="pp$_->[0]">};
			$out .= qq{<td class="tl" valign="middle" nowrap="nowrap"><b>$_->[1]</b><br/>$_->[2]</td>
			</tr></table></li>
			};
		}
		$out .= qq{</ul>}
	} else {
		$out .= info_msg(qq{У данной страницы нет ни одной связанной страницы.})
	}
   $out .= qq{</td></tr>
   <tr><td class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="this.form.order.value=junkdrawer.serializeList(document.getElementById('gpix'));"></td></tr>
   </table>};
    return $out
}

sub related_group_order_drag {
    my $out;
	$out .= qq{<p class="note"><b>Примечание:</b> чтобы поменять местами рубрики, необходимо навести мышку на&nbsp;блок с&nbsp;рубрикой и&nbsp;перетащить в&nbsp;нужное место. Нажать кнопку &laquo;Изменить&raquo;.</p>
	<table class="tab_gal" border="0" cellpadding="0" cellspacing="0"><tr><td>};
	my @r = $modules::Core::soap->getQuery("SELECT * FROM related_group_tbl ORDER BY order_fld")->paramsout;
	$out .= qq{<ul id="gpix" class="gpic">
	};
	my $i = 1;
	foreach (@r) {
	   $out .= qq{<li id="gpix_$i"><table class="tab" width="98%"><tr class="tr_col}.($i++ % 2 +1).qq{" id="pp$_->[0]">};
	   $out .= qq{<td class="tl" valign="middle" nowrap="nowrap" height="22"><b>$_->[1]</b></td>
	   </tr></table></li>
	   };
	}
	$out .= qq{</ul></td></tr>
	<tr><td class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="this.form.order.value=Sortable.serialize('gpix');"></td></tr>
	</table>};
    return $out
}



sub related_list { # список связанных страниц
	my $logpass = logpass();
	my @r = $modules::Core::soap->getQuery("SELECT related_tbl.related_id, page_tbl.label_fld,
							 page_tbl.url_fld
							 FROM related_tbl, page_tbl
							 WHERE (page_tbl.page_id=related_tbl.rel_page_id)
							 AND (related_tbl.original_page_id=$modules::Security::FORM{original_page_id})
							 ORDER BY page_tbl.label_fld ASC")->paramsout;
	my $out;
	if (scalar @r) {
		$out .= qq{<table class="tab" border="0" cellpadding="0" cellspacing="0">
	<tr><td>
	<table class="tab2" border="0" cellpadding="0" cellspacing="0">
<tr><th>Название страницы</th>
<th>URL</th><th>&nbsp;</th></tr>};
		my $i = 1;
		foreach (@r) {
			next unless $_->[0];
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">}
			.qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">}
			.qq{<td class="tl">$_->[1]</td>}
			.qq{<td class="tl">$_->[2]</td>}
			.qq{<td class="tb"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>}
			.qq{<input type="hidden" name="act" value="del_related">}
			.qq{<input type="hidden" name="related_id" value="$_->[0]">}
			.qq{<input type="hidden" name="original_page_id" value="$modules::Security::FORM{original_page_id}">}
			.qq{<input type="hidden" name="returnact" value="edit_rel2">$logpass</form>};
		}
		if ($i>1) {
			$out = qq{<h2>Список связанных для страницы <b>&laquo;}.$modules::Core::soap->getQuery("SELECT label_fld FROM page_tbl WHERE page_id=$modules::Security::FORM{page_id}")->result.qq{&raquo;</b></h2>}.$out;
			$out .= qq{</table></td></tr></table>}
		} else {
			$out .= info_msg(qq{Связанных страниц нет})
		}
	} else {
		$out .= info_msg(qq{Связанных страниц нет})
	}
	return $out
} # related_list

sub related_group_switchlist {
	my @r = $modules::Core::soap->getQuery("SELECT * FROM related_group_tbl")->paramsout;
	my $out;
	$out .= qq{<table class="tab" align="left">
	<tr class="th">
		<th>&nbsp;</td>
		<td class="td_right" nowrap="nowrap">Показывать<br/>внутри раздела</td>
	</tr>};
	if (scalar @r) {
		my $i = 1;
		foreach (@r) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tal"><input type="checkbox" name="related_group_id" value="$_->[0]" id="rg$_->[0]"></td><td class="tl" width="150"><label for="rg$_->[0]">$_->[1]</label></td></tr>}
		}
	} else {
		$out .= qq{<tr class="tr_col1"><td colspan="2" class="tl">Нет ни одной группы связанных страниц</td></tr>}
	}
	$out .= qq{</table>};
	return $out
}

sub related_group_list { # список связанных страниц
	my $logpass = logpass();
	my @r = $modules::Core::soap->getQuery("SELECT * FROM related_group_tbl")->paramsout;
	my $out;
	if (defined $r[0]->[0]) {
		$out .= start_table().head_table('ID','Название');
		my $i = 1;
		foreach (@r) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">}
			.qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="rged$_->[0]">}
			.qq{<td class="tr">$_->[0]</td>
			<td class="tl"><b><a href="#" onclick="submit('rged$_->[0]')">$_->[1]</a></b></td>}
			.qq{<input type="hidden" name="related_group_id" value="$_->[0]"><input type="hidden" name="returnact" value="related_group_edit">$logpass}
			.qq{</form>}
		}
		$out .= qq{</table>
</td></tr></table>}
	} else {
		$out .= info_msg(qq{Нет ни одной группы связанных страниц})
	}
	return $out
} # related_list

sub related_group_downlist { SOAPdownlist_sel("related_group","related_group_fld",$modules::Security::FORM{related_group_id}) }

sub related_group_data {
	my $out;
	my @r = $modules::Core::soap->getQuery("SELECT * FROM related_group_tbl WHERE related_group_id=$modules::Security::FORM{related_group_id}")->paramsout;
	@r = @{$r[0]};
	$out .= qq{
<table class="tab_nobord">
<tr><form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl"><td class="tl">Название группы</td>
<td class="tal"><input type="text"  name="related_group_fld" size="30" value="$r[1]"></td></tr>
<tr><td class="tl">Страница привязки</td>
<td class="tal"><select name="page_id"><option>-- --</option>}.page_downlist($r[2]).qq{</select></td></tr>
<tr><td>&nbsp;</td><td class="tal"><input type="Image" src="/img/but/change1.gif" title="Изменить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"><input type="hidden" name="related_group_id" value="$r[0]"><input type="hidden" name="act" value="edit_related_group"><input type="hidden" name="returnact" value="related_group">}.logpass.qq{</form><form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl"><input type="Image" src="/img/but/delete1.gif" title="Удалить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"><input type="hidden" name="related_group_id" value="$r[0]"><input type="hidden" name="act" value="del_related_group"><input type="hidden" name="returnact" value="related_group">}.logpass.qq{</form></td>
</tr></table>};
	return $out
}


sub related_group_edit {
	my $out;
	if ($modules::Security::FORM{show}) {
		my $logpass = logpass();
		my $page_select = page_select();
		$out .= <<EOT;
<SCRIPT>
function massub(form) {
	var ff = eval('document.forms.'+form)
	ff.act.value='edit_page_metadata';
	ff.returnact.value='edit_page';
	submit('edit_page');
}

function do_act(form,page_id) {
	var ff = eval('document.forms.'+form)
	// ff.act.value='';
	ff.page_id.value=page_id;
	ff.rel_page_id.value=page_id;
	ff.spage_id.value=page_id;
	ff.submit()
}
</SCRIPT>
<h3>Добавить страницу в группу</h3><form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="edit_related_group">
$page_select
$logpass
<input type="hidden" name="page_id" value="">
<input type="hidden" name="rel_page_id" value="">
<input type="hidden" name="spage_id" value="">
<input type="hidden" name="related_group_id" value="$modules::Security::FORM{related_group_id}">
<input type="hidden" name="show" value="1">
<input type="hidden" name="act" value="edit_page_related_group">
EOT
		$out .= returnact().qq{</form>};
		my @r = $modules::Core::soap->getQuery("SELECT r.rel_page_id,label_fld,url_fld,related_id
												FROM related_group_tbl as rg,
												related_tbl as r, page_tbl as p
												WHERE rg.related_group_id=$modules::Security::FORM{related_group_id}
												AND r.related_group_id=rg.related_group_id
												AND p.page_id=r.rel_page_id")->paramsout;
		my $i = 1;
		$out .= qq{<br/><h3>Текущий состав группы</h3>}.start_table().head_table('Название страницы','URL','&nbsp');
		if (scalar @r) {
			foreach (@r) {
				$out .= qq{<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl"><input type="hidden" name="related_group_id" value="$modules::Security::FORM{related_group_id}">
	<input type="hidden" name="show" value="1"><tr class="tr_col}.($i++ % 2 +1).qq{">
					<td class="tl"><input type="hidden" name="related_id" value="$_->[3]">$_->[1]</td>
					<td class="tl">$_->[2]</td>
					<td class="tal"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
				</tr>$logpass<input type="hidden" name="act" value="del_page_related_group">}.returnact().qq{</form>}
			}
		} else {
			$out .= qq{<tr class="tr_col1"><td colspan="3" class="tl">Нет ни одной связанной страницы</td></tr>}
		}
		$out .= qq{</table>}
	}
	return $out
}

sub page_edit { # Редактирование страницы
	my $out;
	my $sel = pageed_sel();
	$out .= qq{<h2>Редактирование страницы <b>$sel</b></h2>};
	my @th = modules::DBfunctions::get_table_hash("page","page_id=$modules::Security::FORM{page_id}","");
	return "" unless scalar @th;
	my %th = %{$th[0]};
	my @r = $modules::Core::soap->getStat($th{url_fld})->paramsout;
	$modules::Core::soap->doQuery("UPDATE page_tbl SET lastmod_fld=FROM_UNIXTIME($r[9]) WHERE page_id=$modules::Security::FORM{page_id}");
	$th{label_fld} = escapeHTML($th{label_fld});
	$th{fulllabel_fld} = escapeHTML($th{fulllabel_fld});
	$th{title_fld} = escapeHTML($th{title_fld});
	my $tt = $th{title_fld};
	my $block_l;
	if ( $th{enabled_fld}==1 ) { $block_l = qq{checked} }
	my $index_l;
	if ( $th{index_fld}==1 ) { $index_l = qq{checked} }
	$th{exp_fld} =~ s/^(\d{4})-(\d\d)-(\d\d).+$/$3.$2.$1/;
	$th{exp_fld} = '' if $th{exp_fld} eq '00.00.0000';
	my $main_l;
	$out .= qq{<table class="tab" id="page">
	<tr><td class="tl">URL</td>
	<td class="tal" colspan="2"><input type="text"  name="url_fld" size="70" value="$th{url_fld}"></td></tr>
	<tr><td class="tl">Название в меню</td>
	<td colspan="2" class="tal" style="width: 150px !important;"><input type="text"  name="label_fld" size="30" value="$th{label_fld}">&nbsp;&nbsp;&nbsp;&nbsp;<span class="tl">Собств.стиль (класс)</span><input type="text" class="input_txt" name="customstyle_fld" size="16" value="$th{customstyle_fld}"></td>
	</tr>
	<tr><td class="tl">Название в заголовке</td>
	<td class="tal" colspan="2"><input type="text"  name="fulllabel_fld" size="70" value="$th{fulllabel_fld}"></td></tr>
<tr><td class="tl" title="Страница-ссылка, без шаблона и файла"><label for="no">Ссылка</td>
	<td colspan="2" class="tal"><input type="checkbox" id="no" name="notempl_fld" value="1" onchange="chlink()"}.($th{notempl_fld}==1?' checked':'').qq{></td></tr>
	<tr><td colspan="3" class="tl"><a href="#" onclick="add('page')">Дополнительные свойства</a></td></tr>
	<tr class="tr_col2"><td class="tl">Актульна до...</td><td class="tal" colspan="2"><input type="text" name="exp_fld" id="exp_fld" size="10" value="$th{exp_fld}" title="Дата"></td></tr>
	<tr class="tr_col2"><td class="tl"><label for="lm">Показывать Last-Modified</label></td>
	<td class="tal" colspan="2"><input type="checkbox" id="lm" name="lm_fld" value="1"}.($th{lm_fld}?' checked':'').qq{></td></tr>
	<tr class="tr_col2"><td class="tl"><label for="ex">Не раскрывать раздел</label></td>
	<td class="tal" colspan="2"><input type="checkbox" id="ex" name="expand_fld" value="1"}.($th{expand_fld}?' checked':'').qq{></td></tr>
	<tr class="tr_col2"><td class="tl"><label for="at">Авто-&lt;title&gt;</label></td>
	<td class="tal" colspan="2"><input type="checkbox" id="at" name="at" onchange="chtitle()"}.($tt?'':' checked').qq{ value="1"></td></tr>
	<tr id="att" class="tr_col2"><td class="tl">&lt;title&gt;</td>
	<td class="tal" colspan="2"><input type="text"  name="title_fld" size="70" value="$tt"}.($tt?'':' disabled').qq{></td></tr>};
	if ($modules::Core::soap->getQuery("SELECT COUNT(*) FROM page_tbl WHERE master_page_id=$modules::Security::FORM{page_id}")->result >0) {
		$out .= qq{<tr class="tr_col2"><td class="tl"><label for="as">Сортировка внутри раздела<br/>по алфавиту</label></td><td class="tl" colspan="2"><input type="checkbox" id="as" name="alphasort_fld" value="1"}.($th{alphasort_fld} eq '1'?' checked':'').qq{></td></tr>}
	}
	$out .= qq{<tr class="tr_col2"><td class="tl">Ключевые слова:</td><td class="tal" colspan="2"><textarea name="keywords_fld" rows="5" cols="60">}.$th{'keywords_fld'}.qq{</textarea></td></tr>
	<tr class="tr_col2"><td class="tl">Description</td>
	<td class="tal" colspan="2"><textarea name="descr_fld" cols="60" rows="5">}.$th{descr_fld}.qq{</textarea></td></tr>
	};
	# template_id
	$out .= qq{<tr class="tr_col2"><td class="tl">Название шаблона:</td><td class="tal" colspan="2"><select name="template_id">};
	$out .= qq{<option value="0">-- Без шаблона --</option>}.SOAPdownlist_sel("template","template_fld",$th{'template_id'});
	$out .= qq{</select></td></tr>};
	# print_template_id
	$out .= qq{<tr class="tr_col2"><td class="tl">Название шаблона для печати:</td><td class="tal" colspan="2"><select name="printtemplate_id">
				<option value="">Нет</option>};
	$out .= SOAPdownlist_sel("printtemplate","printtemplate_fld",$th{'printtemplate_id'});
	$out .= qq{</select></td></tr>};
	# Versions of...
	if ($modules::Core::soap->getQuery("SHOW TABLES LIKE 'pagelang_tbl'")->result) {
		my @r = modules::Language::get_all_versions($modules::Security::FORM{page_id});
		$out .= qq{<input type="hidden" name="otherlang" value="}.(join '|'=>@r).qq{">};
		$out .= qq{<tr class="tr_col2"><td class="tl"><label for="l">Редактировать<br/>все версии</label></td><td class="tal" colspan="2"><input type="checkbox" name="edit_lang" id="l" value="1"></td></tr>}
	}
	# Выдрать контент
	#modules::Debug::dump(extract_content($th{'url_fld'}));
	$out .= qq{<tr><td class="tl" valign="top">Содержимое страницы:</td><td class="tal" colspan="2" valign="top"><textarea name="pagecontent_fld" id="pagecontent_fld" rows="40" style="width: 603px">}.escapeHTML(extract_content($th{url_fld})).qq{</textarea></td></tr>};
	$out .= qq{<tr><td>&nbsp;</td>
	<td class="tar" width="58%"><input type="Image" src="/img/but/save1.gif" title="Сохранить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="javascript:document.forms.edit_page2.returnact.value='edit_page2';document.forms.edit_page2.submit()"></td>
	<td class="tar"><input type="Image" src="/img/but/savenexit1.gif" title="Сохранить и выйти"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
	<input type="hidden" name="page_id" value="$modules::Security::FORM{page_id}"><input type="hidden" name="old_url" value="$th{url_fld}">
	<input type="hidden" name="enabled_fld" value="$th{enabled_fld}"><input type="hidden" name="mainmenu_fld" value="$th{mainmenu_fld}"><input type="hidden" name="index_fld" value="$th{index_fld}"></tr>
	</table>
	<script type="text/javascript">
	function add(oid) {
		var d = document;
		var o = d.getElementsByTagName('TR');
		for(var i=0;i<o.length;i++) {
			if (/^tr_col/.test(o[i].className)) {
				if (o[i].style.display) {
					o[i].style.display = ''
				} else {
					o[i].style.display = 'none'
				}
			}
		}
	}
	add('page')
	</script>
	};
	return $out
} # page_edit

sub template_edit {
	my $out;
	if ($modules::Security::FORM{show}) {
		my $type = int($modules::Security::FORM{template_id}/10000);
		$type = $modules::Security::FORM{type} if exists $modules::Security::FORM{type};
		my $id = $modules::Security::FORM{"template_id"} % 10000;
		my @th;
		if ($type==0) {
			@th = modules::DBfunctions::get_table_hash("template","template_id=$id","");
		} else {
			@th = modules::DBfunctions::get_table_hash("printtemplate","printtemplate_id=$id","");
		}
		my %th = %{$th[0]};
		$th{top_fld} =~ s/&(?:amp;)#xd;//g;
		#$th{top_fld} =~ s/&lt;/</g;
		$th{bottom_fld} =~ s/&(?:amp;)#xd;//g;
		#$th{bottom_fld} =~ s/&lt;/</g;
		$out .= qq{<h2>Редактирование шаблона</h2>};
		$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
<input type="hidden" name="template_id" value="$id">
		<input type="hidden" name="type" value="$type">};
		$out .= qq{<table class="nobord">};
		$out .= qq{<tr><td class="tl">Название</td>
		<td class="tal"><input type="text"  name="template_fld" size="60" value="}.$th{(($type)?'print':'').'template_fld'}.qq{"></td></tr>
		<tr><td class="tl">Верх шаблона</td>
		<td class="tal"><textarea name="top_fld" rows="10" cols="60">}.$th{top_fld}.qq{</textarea></td></tr>
		<tr><td class="tl">Низ шаблона</td>
		<td class="tal"><textarea name="bottom_fld" rows="10" cols="60">}.$th{bottom_fld}.qq{</textarea></td></tr>};
			$out .= qq{<tr><td colspan="2" class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
		</tr>
		</table>}.logpass.returnact.qq{
		<input type="hidden" name="act" value="edit_template">
		<input type="hidden" name="show" value="1"></form>
		};
		$out .= qq{<h2>Предварительный просмотр шаблона</h2><form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site_popup.pl" name="fPr" target="wfb">
		<input type="hidden" name="template_id" value="$id">
		<table class="nobord">
			<tr>
				<td class="tl">Глубина страницы</td>
				<td class="tal"><input type="text"  size="4" maxlength="4" name="level">
				<td class="tal"><input type="Image" src="/img/but/do1.gif" title="Выполнить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="doSubmit('fPr')"></td>
			</tr>
		</table>}.logpass.qq{
		<input type="hidden" name="s" value="$modules::Security::FORM{site_id}">
		<input type="hidden" name="site_id" value="$modules::Security::FORM{site_id}">
		<input type="hidden" name="returnact" value="template_preview">
		<input type="hidden" name="act" value="template_preview">
		<input type="hidden" name="show" value="1"></form>
		};
	} # if ($modules::Security::FORM{show})
	return $out;
} # template_edit

sub template_preview {
	my $out;
	return if $modules::Security::FORM{template_id}>10000;
	my $tempname = '/_preview_.shtml';
	my $level = $modules::Security::FORM{level};
	my @t = $modules::Core::soap->getQuery("SELECT * FROM template_tbl WHERE template_id=$level")->paramsout;
	open(IN,$modules::Settings::c{dir}{cgi}.qq{/modules/Page/_lorem.html});
	my @tc = <IN>;
	close(IN);
	my $tempcont = join ''=>@tc;
	my $content = $t[0]->[2].$tempcont.$t[0]->[3];
	$content .= qq{<!--#exec cgi="/pcgi/del_prv.pl"-->};
	$modules::Core::soap->putXMLFile([$tempname,$content]);
	my $pid = 0;
	for my $i (1..$level) {
		my $title = 'PREVIEW';
		my $sql = qq{INSERT INTO page_tbl (url_fld,label_fld,fulllabel_fld,master_page_id,template_id,title_fld,enabled_fld,mainmenu_fld) VALUES ('}.($i!=$level?qq{/_temp_$i.shtml}:$tempname).qq{','$title','$title',$pid,$modules::Security::FORM{template_id},'$title','1','1')};
		$pid = $modules::Core::soap->doQuery($sql)->result;
	}
	$out .= qq{<meta http-equiv="Refresh" content="0;http://$modules::Security::FORM{host_fld}$tempname">};

	return $out
}

sub print_template_edit {
	my $out;
	if ( $modules::Security::FORM{show} )
	{
		my @th = modules::DBfunctions::get_table_hash("printtemplate","printtemplate_id=$modules::Security::FORM{printtemplate_id}","");
		my %th = %{$th[0]};

		$out .= qq{<input type="hidden" name="printtemplate_id" value="$modules::Security::FORM{printtemplate_id}">};
		$out .= qq{<table class="nobord">};
		$out .= qq{<tr><td class="tl">Название</td>
		<td class="tal"><input type="text"  name="printtemplate_fld" size="60" value="$th{printtemplate_fld}"></td></tr>
		<tr><td class="tl">Верх шаблона</td>
		<td class="tal"><textarea name="top_fld" rows="10" cols="60">}.escapeHTML($th{top_fld}).qq{</textarea></td></tr>
		<tr><td class="tl">Низ шаблона</td>
		<td class="tal"><textarea name="bottom_fld" rows="10" cols="60">}.escapeHTML($th{bottom_fld}).qq{</textarea></td></tr>};
			$out .= qq{<tr><td>&nbsp;</td>
		<td class="tal"><input type="Image" src="/img/but/change1.gif" title="Изменить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
		</tr>
		</table>};
	} # if ($modules::Security::FORM{show})
	return $out || " ";
} # print_template_edit

sub menupix_edit { # Привязка картинок разделов
	my $out;
	$modules::Core::soap = shift;
	my %p = @_;
	$modules::Security::FORM{page_id} = $p{id};
	#modules::Debug::dump($modules::Security::session);
	#modules::Debug::dump(\%modules::Security::FORM);
	#return unless $modules::Security::FORM{show};
	my @page = $modules::Core::soap->getQuery("SELECT menupix_id, menupix_fld,
									  page_id, menupixurl_fld,
									  menupixfolder_fld
									  FROM menupix_tbl
									  WHERE page_id=$modules::Security::FORM{page_id}")->paramsout;
	$out .= qq{<h2>Страница <b>&laquo;}.$modules::Core::soap->getQuery("SELECT label_fld FROM page_tbl WHERE page_id=$modules::Security::FORM{page_id}")->result.qq{&raquo;</b></h2><h3>Загрузка картинки</h3>
<p class="txt">Текущий путь к картинке: <b>}.(($page[0]->[1])?$page[0]->[1]:"[нет]").qq{</b></p>

<form method="POST" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" enctype="multipart/form-data" name="fff">		<input type="hidden" name="menupix_fld_old" value="$page[0]->[1]">
		<input type="hidden" name="upload" value="menupix_fld">
		<table class="tab" cellpadding="0" cellspacing="0">
		<tr>
			<td class="tl">Сервер (файл):</td>
			<td class="tal"><input type="text" name="menupix1_fld" size="40" value="$page[0]->[1]" >&nbsp;<a href="#" onclick="javascript:fs_open('/img','gif|jpg|png','fff','menupix1_fld'); return false;"><img src="/img/4site/folder_open.gif" border="0" align="absmiddle"></a></td>
		</tr>
		<tr>
			<td class="tl-gre">&nbsp;</td>
			<td class="tl-gre">или</td>
		</tr>
		<tr>
			<td class="tl">Сервер (папка):</td>
			<td class="tal"><input type="text" name="menupixfolder_fld" size="40" value="$page[0]->[4]" ></td>
		</tr>
		<tr>
			<td class="tl-gre">&nbsp;</td>
			<td class="tl-gre">или</td>
		</tr>
		<tr><td class="tl">Локально:</td>
			<td class="tal"><input type="file" name="menupix_fld" size="40"></td>
			<input type="hidden" name="menupix_id" value="$page[0]->[0]">
		</tr>
		<tr><td colspan="2" height="5"><img src="/img/1pix.gif" height="5"></td></tr>

		<tr>
			<td colspan="2" class="tar"><input type="Image" src="/img/but/change1.gif" title="Изменить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
			<input type="hidden" name="page_id" value="$modules::Security::FORM{page_id}"><input type="hidden" name="act" value="edit_menupix">}.returnact.logpass
			.qq{
		</tr>
		<tr><td colspan="2" height="5"><img src="/img/1pix.gif" height="5"></td></tr>
</table>
		</form>
<p class="note"><b>Примечание:</b> если вы хотите удалить картинку, то просто оставьте поля «Загрузка картинки» пустыми и&nbsp;нажмите кнопку «Изменить».</p>
<table class="tab_nobord">
<tr>
			<td class="tl">Вид картинки</td>
			<td class="tb"><img src="}.(($page[0]->[1])?qq{http://}.$modules::Security::session->param('host_fld').$page[0]->[1]:'/img/default.gif').qq{" border="0"}.(($page[0]->[1])?'':' alt="Нет картинки" title="Нет картинки"').qq{ style="border: 1px solid Silver" /></td>
		</tr>
		<tr><td colspan="2" height="5"><img src="/img/1pix.gif" height="5"></td></tr>
</table>
<h3>Редактирование ссылки</h3>
<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
<table class="tab_nobord">
		<tr>
			<td class="tl">Ссылка:</td>
			<td class="tal"><input type="text"  name="menupixurl_fld" size="60" value="$page[0]->[3]"></td>
			<input type="hidden" name="menupix_id" value="$page[0]->[0]">
			<input type="hidden" name="menupix_fld" value="$page[0]->[1]">
		</tr>
		<tr>
			<td colspan="2" class="tar"><input type="Image" src="/img/but/chng_link1.gif" title="Изменить только ссылку"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
			<input type="hidden" name="page_id" value="$modules::Security::FORM{page_id}">
		</tr>
	</table>};
	$out .= logpass.qq{<input type="hidden" name="act" value="edit_menupixurl">}.returnact.qq{</form>};
	modules::Security::extract_act($out);
	return $out
} # menupix_edit

sub keywords_edit {
	my $out;
	$modules::Core::soap = shift;
	my %p = @_;
	$modules::Security::FORM{page_id} = $p{id};
	my $sel = pageed_sel();
	my ($p,$u) = $sel =~ /(.+?)\s\(([^)]+)\)$/;
	$out .= qq{<h2>Редактирование description страницы <b>&laquo;$p</b> ($u)<b>&raquo;</b></h2>};
	$out .= start_table().head_table('Наследовать','Страница','description');
	$out .= modules::Comfunctions::edit_keywords($modules::Security::FORM{page_id});
	$out .= qq{<input type="hidden" name="page_id" value="$modules::Security::FORM{page_id}">};
	$out .= qq{<tr>
	<td class="tar" colspan="3"><input type="Image" src="/img/but/apply1.gif" title="Применить"  onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
	</tr><input type="hidden" name="act" value="edit_keywords">};
	$out .= end_table();
	modules::Security::extract_act($out);
	return $out;
} # keywords_edit

sub statistics {
	my $out;
	my $i = 1;
# 	$out .= qq{<tr><td colspan="2" class="tb">Статические</td></tr>};
	my $depth = get_setting("menu","stat_depth") || 1;
	my $total = $modules::Core::soap->getQuery("SELECT COUNT(*) FROM page_tbl")->result;
	my @r = $modules::Core::soap->getQuery("SELECT page_id,master_page_id,label_fld FROM page_tbl")->paramsout;
	my %dc;
	my %l;
	foreach (@r) {
		$dc{$_->[0]} = $_->[1];
		$l{$_->[0]} = $_->[2]
	}
	my %m;
	foreach (values %dc) { $m{$_}++ }

	my @pg = sort { $a <=> $b } grep { $dc{$_}==0 } keys %dc;
	next unless scalar @pg;
	foreach my $pp (@pg) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl"><b>}.$l{$pp}.qq{</b></td><td class="tr"><b>}.(_sum($pp,\%dc)||'').qq{</b></td></tr>};
		next if $depth==1;
		my @pg1 = sort { $a <=> $b } grep { $dc{$_}==$pp } keys %dc;
		next unless scalar @pg1;
		foreach my $ppp (@pg1) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">&nbsp;&nbsp;&nbsp;}.$l{$ppp}.qq{</td><td class="tr">}.(_sum($ppp,\%dc)||'').qq{</td></tr>};
			next if $depth==2;
			my @pg2 = sort { $a <=> $b } grep { $dc{$_}==$ppp } keys %dc;
			next unless scalar @pg1;
			foreach my $pppp (@pg2) {
				$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}.$l{$pppp}.qq{</td><td class="tr">}.(_sum($pppp,\%dc)||'').qq{</td></tr>};
			}
		}
	}
	$out .= qq{<tr class="tr_col3">
		<td class="total1" style="text-align: right">Всего:</td>
		<td class="total2" style="text-align: right">$total</td>
	</tr>
	};
	return $out;
	sub _sum {
		my $sum = 0;
		my $id = shift;
		my $dc = shift;
		return $sum unless $dc;
		my @ch = sort { $a <=> $b } grep { $dc->{$_}==$id } keys %$dc;
		if (scalar @ch) {
			$sum += scalar @ch;
			foreach my $c (@ch) {
				$sum += _sum($c,$dc)
			}
		}
		return $sum
	}
}

sub keyword_stat {
	my $out;
	my $i = 1;
	my @r = $modules::Core::soap->getQuery("SELECT page_id,master_page_id,label_fld,keywords_fld,descr_fld FROM page_tbl")->paramsout;
	my %dc;
	my %l;
	my %kw;
	my %d;
	foreach (@r) {
		$dc{$_->[0]} = $_->[1];
		$l{$_->[0]} = $_->[2];
		$kw{$_->[0]} = $_->[3];
		$d{$_->[0]} = $_->[4];
	}
	$out .= _drawStr(\@r,0,\$i,-1);
	#my @pg = sort { $a <=> $b } grep { $dc{$_}==0 } keys %dc;
	#next unless scalar @pg;
	#foreach my $pp (@pg) {
	#	$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl"><b>}.$l{$pp}.qq{</b></td><td class="tr" title="$kw{$pp}"><b>}.($kw{$pp}?'Yes':'').qq{</b></td><td class="tr" title="$d{$pp}"><b>}.($d{$pp}?'Yes':'').qq{</b></td></tr>};
	#	my @pg1 = sort { $a <=> $b } grep { $dc{$_}==$pp } keys %dc;
	#	next unless scalar @pg1;
	#	foreach my $ppp (@pg1) {
	#		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">&nbsp;&nbsp;&nbsp;}.$l{$ppp}.qq{</td><td class="tr" title="$kw{$ppp}">}.($kw{$ppp}?'Yes':'').qq{</td><td class="tr" title="$d{$ppp}">}.($d{$ppp}?'Yes':'').qq{</td></tr>};
	#		my @pg2 = sort { $a <=> $b } grep { $dc{$_}==$ppp } keys %dc;
	#		next unless scalar @pg1;
	#		foreach my $pppp (@pg2) {
	#			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}.$l{$pppp}.qq{</td><td class="tr" title="$kw{$pppp}">}.($kw{$pppp}?'Yes':'').qq{</td><td class="tr" title="$d{$pppp}">}.($d{$pppp}?'Yes':'').qq{</td></tr>};
	#		}
	#	}
	#}
	return $out
}

sub _drawStr {
	my $out;
	my ($rr,$par,$ri,$l) = @_;
	my @p = sort { $a->[0] <=> $b->[0] } grep { $_->[1]==$par } @$rr;
	return unless scalar @p;
	$l++;
	foreach my $pg (@p) {
		$out .= qq{<tr class="tr_col}.($$ri++ % 2 +1).qq{"><td class="tl"><b>}.('&nbsp;&nbsp;&nbsp;&nbsp;'x$l).qq{$pg->[2]</b></td><td class="tr" title="$pg->[3]">}.($pg->[3]?'Yes':qq{<b style="color: Red">No</b>}).qq{</td><td class="tr" title="$pg->[4]">}.($pg->[4]?'Yes':qq{<b style="color: Red">No</b>}).qq{</td></tr>};
		$out .= _drawStr($rr,$pg->[0],$ri,$l)
	}
	return $out
}

sub refers {
	return undef unless (my $id = shift);
    my $master = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
                                        FROM page_tbl
                                        WHERE page_id=$id");
    push my @refers=>$master;
    while ($master!=0) {
        $master = $sitemodules::DBfunctions::dbh->selectrow_array("SELECT master_page_id
                                         FROM page_tbl
                                         WHERE page_id=$master");
    	push @refers=>$master
	}
    return @refers;
}

sub keyword_suggest {
	my $out;
	$modules::Core::soap = shift;
	my %p = @_;
	$modules::Security::FORM{page_id} = $p{id};
	my $url = $modules::Core::soap->getQuery("SELECT url_fld FROM page_tbl WHERE page_id=$modules::Security::FORM{page_id}")->result;
	my @content = $modules::Core::soap->getFile($url)->paramsout;
	my $content = join ''=>@content;
	%Page::words = ();
	# Create parser object
	my $p = HTML::Parser->new( api_version => 3,
							start_h => [\&astart, "self, tagname, attr, text"],
							end_h   => [\&aend,   "self, tagname"],
							text_h   => [\&atext,   "self, text"],
							marked_sections => 1,
						  );
	######## HTML::Parser handlers ########
	sub astart {
		my($self, $tagname, $attr, $text) = @_;
		#...
		foreach (qw(alt title)) {
			next unless exists $attr->{$_};
			grep { $Page::words{lc $_}++ } split /\s+/=>$attr->{$_}
		}
	}
	sub aend {
		my($self, $tagname) = @_;
		#...
	}
	sub atext {
		my($self, $text, $is_cdata) = @_;
		#...
		$text =~ s/&#\d+/ /g;
		$text =~ s/&amp;/&/g;
		$text =~ s/&quot;/"/g;
		$text =~ s/&laquo;/«/g;
		$text =~ s/&rqauo;/»/g;
		$text =~ s/&lt;/</g;
		$text =~ s/&nbsp;/ /g;
		$text =~ s/\r?\n/ /g;
		$text =~ s/[.,;:?!"\(\)\[\]+*<>\/]/ /g;
		$text =~ s/^\s+//g;
		$text =~ s/\s+$//g;
		$text =~ s/\s+/ /g;
		grep { $Page::words{lc($_)}++ } split /\s/=>$text;
	}
	$p->parse($content);
	delete @Page::words{qw(и по на в из под над с для или что чтобы что-нибудь когда даже если но)};
	delete @Page::words{ grep { length $_ < 3 } keys %Page::words };
	if (scalar keys %Page::words) {
		my $i = 1;
		$out .= start_table().head_table('Слово','Частота');
		foreach (sort { $Page::words{$b} <=> $Page::words{$a} } sort { $a cmp $b } keys %Page::words) {
			$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">
				<td class="tl">$_</td>
				<td class="tr">$Page::words{$_}</td>
			</tr>};
		}
		$out .= end_table()
	} else {
		$out .= info_msg(qq{Нет ни одного слова...})
	}
	return $out
}

sub servpage_list {
	my $out;
	$out .= start_table().head_table('Шаблон / Путь', 'Контент', ['&nbsp;',2]);
	my @r = $modules::Core::soap->getQuery("SELECT * FROM servpage_tbl")->paramsout;
	my $i = 1;
	foreach (@r) {
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{" valign="top">
			<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			<input type="hidden" name="servpage_id" value="$_->[0]">
			<td class="tal"><select name="template_id">}.template_downlist($_->[2]).qq{</select><br/><input type="text"  name="url_fld" size="20" value="$_->[3]"></td>
			<td class="tal"><textarea  name="content_fld" rows="5" cols="40">}.escapeHTML($_->[1]).qq{</textarea></td>
			<td class="tal"><input type="Image" src="/img/but/apply_s1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
			<input type="hidden" name="act" value="edit_servpage">
			}.logpass().returnact().qq{</form>
			<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
			<input type="hidden" name="servpage_id" value="$_->[0]">
			<td class="tal"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td>
			<input type="hidden" name="act" value="del_servpage">
			}.logpass().returnact().qq{</form>
		</tr>}
	}
	$out .= end_table();
	return $out
}

sub fixperm_list {
	my $out;
	return unless $::SHOW;
	my @r = $modules::Core::soap->getQuery("SELECT page_id,url_fld,label_fld,
										   lm_fld,lastmod_fld
										   FROM page_tbl")->paramsout;
	$out .= start_table().head_table('URL','Название','lm','Last-Modified','Результат');
	my $i = 1;
	foreach (@r) {
		my @t = @$_;
		$out .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{">};
		$out .= qq{<td class="tl">$t[1]</td>
				<td class="tl"><b>$t[2]</b></td>
				<td class="tl">$t[3]</td>
				<td class="tl">$t[4]</td>};
		$out .= qq{<td class="tl">};
#		if (!$t[3]) {
#			$out .= qq{&mdash;}
#		} else {
			my $res = $modules::Core::soap->fixPerm([$t[1],$t[3]])->result;
			$out .= qq{<b style="color: }.($res=~/^NOT/?'red':'green').qq{">$res</b>};
#		}
		$out .= qq{</td>};
		$out .= qq{</tr>}
	}
	$out .= end_table();
	return $out
}

sub page_comment_form {
	my $out;
	$modules::Core::soap = shift;
	my %p = @_;
	$modules::Security::FORM{page_id} = $p{id};
	my @r = $modules::Core::soap->getQuery("SELECT label_fld,url_fld FROM page_tbl WHERE page_id=$modules::Security::FORM{page_id}")->paramsout;
	$out .= qq{<h2>Комментарии к странице &laquo;<b>$r[0]->[0]</b>&raquo; ($r[0]->[1])</h2>};
	$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl">
	<table class="tab_nobord">
	<tr><td class="tl">Имя пользователя</td>
	<td class="tal"><input type="text"  name="username_fld" size="40"></td></tr>
	<tr><td class="tl">E-Mail</td>
	<td class="tal"><input type="text"  name="email_fld" size="40"></td></tr>
	<tr><td class="tl">Комментарий</td>
	<td class="tal"><textarea name="comment_fld" rows="10" cols="50"></textarea></td></tr>
	<tr><td>&nbsp;</td><td class="tar"><input type="Image" src="/img/but/add1.gif" title="Добавить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)"></td></tr>
	</table>}.logpass.returnact.qq{
	<input type="hidden" name="show" value="1">
	<input type="hidden" name="page_id" value="$modules::Security::FORM{page_id}">
	<input type="hidden" name="spage_id" value="$modules::Security::FORM{page_id}">
	<input type="hidden" name="act" value="add_page_comment"></form>};
	modules::Security::extract_act($out);
	return $out
}

sub page_comment_list {
	my $out;
	$modules::Core::soap = shift;
	my %p = @_;
	$modules::Security::FORM{page_id} = $p{id};
	my @r = $modules::Core::soap->getQuery("SELECT * FROM page_comment_tbl WHERE page_id=$modules::Security::FORM{page_id} ORDER BY dt_fld DESC")->paramsout;
	if (scalar @r) {
		$out .= start_table().head_table('Дата и время','User / E-Mail','Комментарий',['&nbsp;',2]);
		my $i = 1;
		$out .= qq{<form method="post" action="$modules::Settings::c{dir}{cgi_ref}/4site.pl" name="ecm" id="ecm">
		<input type="hidden" name="page_comment_id" value="">};
		foreach (@r) {
			$out .= qq{
			<input type="hidden" name="show" value="1">
			<input type="hidden" name="page_id" value="$_->[1]">
			<input type="hidden" name="spage_id" value="$_->[1]">
			<tr class="tr_col}.($i++ % 2 +1).qq{">
			<td class="tl" valign="top">$_->[-1]</td>
			<td class="tal" valign="top"><input type="text" name="username_fld" size="20" value="$_->[2]" /><br />
			<input type="text" name="email_fld" size="20" value="$_->[3]" /></td>
			<td class="tal"><textarea name="comment_fld" rows="6" cols="40">$_->[-2]</textarea></td>
			<td class="tal"><input type="Image" src="/img/but/apply_s1.gif" title="Изменить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick=" onclick="this.form.act.value='edit_page_comment';this.form.submit()" /></td>
			<td class="tal"><input type="Image" src="/img/but/delete_s1.gif" title="Удалить" onmouseover="b_hilite(this)" onmouseout="b_unlite(this)" onclick="alert(this.form.name)" /></td>
			</tr>};
		}
		$out .= qq{<input type="hidden" name="act" value="">}.returnact.logpass.qq{</form>};
		$out .= end_table()
	} else {
		$out .= info_msg(qq{К данной странице нет ни одного комментария})
	}
	modules::Security::extract_act($out);
	return $out
}

################################################################################
################################### Actions ####################################
################################################################################

############################## меню (страницы) #################################

sub add_servpage { add_record("servpage_tbl") }

sub edit_servpage { edit_record("servpage_tbl") }

sub del_servpage { del_record("servpage_tbl") }

sub add_page { # Добавление страницы
	my $err = $Validate{page}->($modules::Security::FORM{no});
	if (!$err) {
		$modules::Security::FORM{exp_fld} =~ s/^(\d\d)-(\d\d)-(\d{4})$/$3-$2-$1/;
		if ($modules::Security::FORM{no}) {
			# Страница-ссылка, без шаблона и без файла
			$modules::Security::FORM{notempl_fld} = $modules::Security::FORM{no};
			$modules::Security::FORM{order_fld} = $modules::Core::soap->getQuery("SELECT MAX(order_fld)+1
													  FROM page_tbl
													  WHERE master_page_id=$modules::Security::FORM{master_page_id}")->result;
			$modules::Security::FORM{fulllabel_fld} = $modules::Security::FORM{label_fld} unless $modules::Security::FORM{fulllabel_fld};
			$modules::Security::FORM{index_fld} = 0;
			$modules::Security::FORM{template_id} = 0;
			my $page_id = add_record("page_tbl");
			$modules::Core::soap->doQuery("UPDATE page_tbl SET lastmod_fld=NOW() WHERE page_id=$page_id");
			$modules::Core::soap->doQuery("INSERT INTO keywords_tbl (page_id) VALUES ($page_id)");
		} else {
			# Обычная страница
			my $url = $modules::Security::FORM{url_fld};
			unless (defined $url) {
				push @{$modules::Security::ERROR{act}}=>qq{Пустое имя файла!<br/>Задайте имя.};
				return 'err'
			}
			my $pid = $modules::Core::soap->getQuery("SELECT page_id FROM page_tbl WHERE url_fld=$url")->result;
			if (defined($pid)) {
				push @{$modules::Security::ERROR{act}}=>qq{Страница с адресом '$url' уже есть!<br/>Задайте другое имя.};
				return 'err'
			}
			my @stat_url = $modules::Core::soap->getStat($url)->paramsout;
			my $md5_url = pop @stat_url;
			if (defined $md5_url) {
				push @{$modules::Security::ERROR{act}}=>qq{Файл '$url' уже существует!<br/>Задайте другое имя.};
				return 'err'
			}
			# return;
			$modules::Security::FORM{order_fld} = $modules::Core::soap->getQuery("SELECT MAX(order_fld)+1
													  FROM page_tbl
													  WHERE master_page_id=$modules::Security::FORM{master_page_id}")->result;
			$modules::Security::FORM{fulllabel_fld} = $modules::Security::FORM{label_fld} unless $modules::Security::FORM{fulllabel_fld};
			my $temp_id = $modules::Security::FORM{template_id};
			$modules::Security::FORM{index_fld} = 1;
			my $page_id = add_record("page_tbl");
			$modules::Core::soap->doQuery("UPDATE page_tbl SET lastmod_fld=NOW() WHERE page_id=$page_id");
			my @r = $modules::Core::soap->getQuery("SELECT top_fld,bottom_fld FROM template_tbl WHERE template_id=$modules::Security::FORM{template_id}")->paramsout;
			my ($templ_top,$templ_bottom) = @{$r[0]}; # Получили верх и низ шаблона
			grep { s/\r//g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&#xd;//g; } ($templ_top,$templ_bottom);
			$modules::Core::soap->doQuery("INSERT INTO keywords_tbl (page_id) VALUES ($page_id)");
			$modules::Core::soap->putXMLFile([$url,"$templ_top\n<!--\\\\START\\\\-->\n\n<!--\\\\END\\\\-->\n$templ_bottom",1]);
		}
	} else {
		return "err"
	}
} # add_page

sub edit_page {
	my $url = $modules::Security::FORM{url_fld};
	unless (defined $url) {
		push @{$modules::Security::ERROR{act}}=>qq{Пустое имя файла!<br/>Задайте имя.};
		return 'err'
	}
	my $pid = $modules::Core::soap->getQuery("SELECT page_id FROM page_tbl WHERE url_fld='$url'")->result;
	if (defined($pid)) {
		if ($pid!=$modules::Security::FORM{page_id}) {
			push @{$modules::Security::ERROR{act}}=>qq{Страница с адресом '$url' уже есть!<br/>Задайте другое имя.};
			return 'err'
		}
	}
	my $old_url = $modules::Security::FORM{old_url};
	my @stat_url = $modules::Core::soap->getStat($url)->paramsout;
	my @stat_old = $modules::Core::soap->getStat($old_url)->paramsout;
	my $md5_url = pop @stat_url;
	my $md5_old = pop @stat_old;
	if (defined $md5_url and $md5_old ne $md5_url) {
		push @{$modules::Security::ERROR{act}}=>qq{Файл '$url' уже существует!<br/>Задайте другое имя.};
		return 'err'
	}
	my $content = $modules::Security::FORM{pagecontent_fld};
	$modules::Security::FORM{title_fld} = '' if $modules::Security::FORM{at};
	$modules::Security::FORM{lm_fld} = 0 unless $modules::Security::FORM{lm_fld};
	$modules::Security::FORM{expand_fld} = 0 unless $modules::Security::FORM{expand_fld};
	$modules::Security::FORM{exp_fld} =~ s/^(\d\d)\.(\d\d)\.(\d{4})$/$3-$2-$1/;
	$modules::Security::FORM{printtemplate_id} = 0 unless $modules::Security::FORM{printtemplate_id};
	#modules::Debug::notice('Page itself');
	edit_record("page_tbl");
	my @backup = @modules::Security::FORM{qw{page_id template_id url_fld}};
	if ($modules::Security::FORM{edit_lang}) {
		delete $modules::Security::FORM{url_fld};
		delete $modules::Security::FORM{template_id};
		#modules::Debug::notice('Other languages?',$modules::Security::FORM{otherlang});
		foreach (split /\|/=>$modules::Security::FORM{otherlang}) {
			#modules::Debug::notice($_,$modules::Security::FORM{page_id});# next;
			$modules::Security::FORM{page_id} = $_;
			edit_record("page_tbl")
		}
	}
	@modules::Security::FORM{qw{page_id template_id url_fld}} = @backup;
	$modules::Core::soap->doQuery("UPDATE page_tbl SET lastmod_fld=NOW() WHERE page_id=$modules::Security::FORM{page_id}");
	unless ($modules::Security::FORM{notempl_fld}) {
		my @r = $modules::Core::soap->getQuery("SELECT top_fld,bottom_fld FROM template_tbl WHERE template_id=$modules::Security::FORM{template_id}")->paramsout;
		my ($templ_top,$templ_bottom) = @{$r[0]}; # Получили верх и низ шаблона
		grep { s/\r//g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&#xd;//g; } ($templ_top,$templ_bottom,$content);
		#$content =~ s/\r\n$//g;
		## $content =~ s/\s+/ /g;
		#$content =~ s/&amp;/&/g;
		#$content =~ s/&lt;/</g;
		#$content =~ s/&gt;/>/g;
		#$content =~ s/&quot;/"/g;
		$modules::Core::soap->putXMLFile([$url,"$templ_top\n<!--\\\\START\\\\-->\n$content\n<!--\\\\END\\\\-->\n$templ_bottom",$modules::Security::FORM{lm_fld}])->result;
		$modules::Core::soap->unlinkFile($old_url) if $url ne $old_url;
	}
} # edit_page

sub edit_page_metadata {
	#modules::Debug::dump(\%modules::Security::FORM); return;
	my @page = (ref $modules::Security::FORM{page} eq 'ARRAY')?@{$modules::Security::FORM{page}}:($modules::Security::FORM{page});
	my @h;
	push @h,'page_tbl';
	my %h;
	foreach (@page) {
		my $no = $modules::Security::FORM{'i'.$_};
		my $en = $modules::Security::FORM{'e'.$_};
		my $main = $modules::Security::FORM{'m'.$_};
		$modules::Security::FORM{page_id} = $_;
		$modules::Security::FORM{enabled_fld} = $en;
		$modules::Security::FORM{enabled_fld} = '0' unless $en;
		$modules::Security::FORM{index_fld} = $no;
		$modules::Security::FORM{index_fld} = '0' unless $no;
# 		$modules::Security::FORM{index_fld} = '0' unless $en;
		$modules::Security::FORM{mainmenu_fld} = (defined $main)?'1':'0';
		%{$h{$_}} = (
					 enabled_fld => $modules::Security::FORM{enabled_fld},
					 index_fld   => $modules::Security::FORM{index_fld},
					 mainmenu_fld   => $modules::Security::FORM{mainmenu_fld},
					 );
	}
	push @h, \%h;
	$modules::Core::soap->batchUpdate(\@h);
	$modules::Security::FORM{page_id} = 0
}

sub swap_page {
	if ($modules::Security::FORM{page_id1} && $modules::Security::FORM{order_fld}) {
		my $master = $modules::Core::soap->getQuery("SELECT master_page_id FROM page_tbl WHERE page_id=$modules::Security::FORM{page_id1}")->result;
		$modules::Core::soap->doQuery("UPDATE page_tbl SET order_fld=order_fld+1 WHERE order_fld>".($modules::Security::FORM{order_fld}-1)." AND master_page_id=$master");
		$modules::Core::soap->doQuery("UPDATE page_tbl SET order_fld=$modules::Security::FORM{order_fld} WHERE page_id=$modules::Security::FORM{page_id1}");
	} else {
		return "err"
	}
} # swap_page

sub reorder_page {
	my $tree = $modules::Security::FORM{tree};
	#modules::Debug::notice($tree);
	my @p = split m!,\s!=>$tree;
	#modules::Debug::dump(\@p);
	my %po;
	foreach my $p (@p) {
		my ($mid,$pid) = $p =~ m!c(\d+)/c(\d+)$!;
		unless(exists $po{$mid}) {
			$po{$mid} = 1
		} else {
			$po{$mid}++
		}
		#modules::Debug::notice(qq{ID: $pid, master: $mid, order: $po{$mid}});
		$modules::Core::soap->doQuery("UPDATE page_tbl SET master_page_id=$mid, order_fld=$po{$mid} WHERE page_id=$pid");
	}
}

sub edit_cache {
	$modules::Security::FORM{expires_fld} = 0 unless $modules::Security::FORM{expires_fld};
	$modules::Security::FORM{cache_fld} = 0 unless $modules::Security::FORM{cache_fld};
	$modules::Security::FORM{page_id} ||= $modules::Security::FORM{spage_id};
	$modules::Core::soap->doQuery("UPDATE page_tbl SET cache_fld='$modules::Security::FORM{cache_fld}', expires_fld=$modules::Security::FORM{expires_fld} WHERE page_id=$modules::Security::FORM{page_id}");
}

sub edit_pagemaster { # Редактирование подчинения страницы
	$modules::Security::FORM{enabled_fld} = $modules::Core::soap->getQuery("SELECT enabled_fld
												FROM page_tbl
												WHERE page_id=$modules::Security::FORM{page_id}")->result;
	$modules::Security::FORM{order_fld} = $modules::Core::soap->getQuery("SELECT MAX(order_fld)+1
											  FROM page_tbl
											  WHERE master_page_id=$modules::Security::FORM{master_page_id}")->result;
	edit_record("page_tbl");
} # edit_pagemaster

sub del_page { # Удаление страницы со всеми подчиненными
	#modules::Debug::dump(\%modules::Security::FORM);
	my @th = $modules::Core::soap->getQueryHash("SELECT * FROM page_tbl WHERE page_id=$modules::Security::FORM{page_id}")->paramsout;
	my %th=%{$th[0]};
	my $page = $modules::Security::FORM{page_id};
	my @tree = $modules::Core::soap->getQuery("SELECT page_id,master_page_id,
										label_fld,url_fld,
										enabled_fld,mainmenu_fld,
										index_fld,order_fld,
										notempl_fld
										FROM page_tbl")->paramsout;
	my @ch = @{getDescendants(\@tree,$modules::Security::FORM{page_id})};
	foreach (@ch) {
		unless ($_->[8]) {
			my $sr = $modules::Core::soap->unlinkFile($_->[3]);
			return error_return($sr->faultstring) if $sr->faultstring;
		}
		# push @{$modules::Security::ERROR{act}}, modules::Debug::dump($sr->faultstring) if $sr->faultstring;
		$modules::Security::FORM{page_id} = $_->[0];
		del_record("page_tbl");
		del_record("keywords_tbl");
		del_record("searchkw_tbl");
		del_record("searchsection_tbl");
		eval { modules::Infoblock::del_cascade_infotemppage($_->[0]) }
	}
	unless ($th{notempl_fld}) {
		my $url = (split /\?/,$th{url_fld})[0];
		my $sr = $modules::Core::soap->unlinkFile($url);
		push @{$modules::Security::ERROR{act}}, modules::Debug::dump($sr->faultstring) if $sr->faultstring;
	}
	$modules::Validate::result_msg .= modules::DBfunctions::get_erased_msg_text("page_tbl",$th{page_id});
	$modules::Security::FORM{page_id} = $th{page_id};
	del_record("page_tbl");
	del_record("keywords_tbl");
	del_record("searchkw_tbl");
	del_record("searchsection_tbl");
	eval { modules::Infoblock::del_cascade_infotemppage($th{page_id}) }
} # del_page

sub del_page_xml { # Удаление страницы со всеми подчиненными
	my @tree = $modules::Core::soap->getQuery("SELECT page_id,master_page_id,
										label_fld,url_fld,
										enabled_fld,mainmenu_fld,
										index_fld,order_fld,
										notempl_fld
										FROM page_tbl")->paramsout;
	my @cch;
	foreach my $p (get_array($modules::Security::FORM{del})) {
		push @cch=>grep { $_->[0]==$p } @tree;
		push @cch=>@{getDescendants(\@tree,$p)};
	}
	foreach (@cch) {
		unless ($_->[8]) {
			my $sr = $modules::Core::soap->unlinkFile($_->[3]);
			return error_return($sr->faultstring) if $sr->faultstring;
		}
		$modules::Validate::result_msg .= modules::DBfunctions::get_erased_msg_text("page_tbl",$_->[0]);
		# push @{$modules::Security::ERROR{act}}, modules::Debug::dump($sr->faultstring) if $sr->faultstring;
		$modules::Security::FORM{page_id} = $_->[0];
		del_record("page_tbl");
		del_record("keywords_tbl");
		del_record("searchkw_tbl");
		del_record("searchsection_tbl");
		eval { modules::Infoblock::del_cascade_infotemppage($_->[0]) }
	}
} # del_page

sub del_page_batch {
	my @del = get_array($modules::Security::FORM{del});
	my @tree = $modules::Core::soap->getQuery("SELECT page_id,master_page_id,
										label_fld,url_fld,
										enabled_fld,mainmenu_fld,
										index_fld,order_fld
										FROM page_tbl")->paramsout;
	my @ch;
	foreach (@del) {
		push @ch=>@{getDescendants(\@tree,$_)}
	}
	my %m;
	foreach (sort { $a->[0] <=> $b->[0] } @ch) {
		!$m{$_->[0]}++ || next;
		my @th = $modules::Core::soap->getQueryHash("SELECT * FROM page_tbl WHERE page_id=$_->[0]")->paramsout;
		my %th=%{$th[0]};
		#modules::Debug::notice($_->[0]); next;
		my $sr = $modules::Core::soap->unlinkFile($_->[3]);
		return error_return($sr->faultstring) if $sr->faultstring;
		push @{$modules::Security::ERROR{act}}, modules::Debug::dump($sr->faultstring) if $sr->faultstring;
		$modules::Security::FORM{page_id} = $_->[0];
		del_record("page_tbl");
		del_record("keywords_tbl");
		del_record("searchkw_tbl");
		del_record("searchsection_tbl");
		eval { modules::Infoblock::del_cascade_infotemppage($_->[0]) }
	}
	foreach (@del) {
		my @th = $modules::Core::soap->getQueryHash("SELECT * FROM page_tbl WHERE page_id=$_")->paramsout;
		my %th=%{$th[0]};
		my $url = (split /\?/,$th{url_fld})[0];
		my $sr = $modules::Core::soap->unlinkFile($url);
		push @{$modules::Security::ERROR{act}}, modules::Debug::dump($sr->faultstring) if $sr->faultstring;
		$modules::Validate::result_msg .= modules::DBfunctions::get_erased_msg_text("page_tbl",$th{page_id});
		$modules::Security::FORM{page_id} = $th{page_id};
		del_record("page_tbl");
		del_record("keywords_tbl");
		del_record("searchkw_tbl");
		del_record("searchsection_tbl");
		eval { modules::Infoblock::del_cascade_infotemppage($th{page_id}) }
	}
}

sub edit_keywords {
	del_rel("keywords_tbl");
	my @kwd = (ref $modules::Security::FORM{kwd_id} eq 'ARRAY')?@{$modules::Security::FORM{kwd_id}}:($modules::Security::FORM{kwd_id});
	foreach my $k (@kwd) {
		$k=0 if $k==65535;
		$modules::Core::soap->doQuery("INSERT INTO keywords_tbl (page_id,add_page_id) VALUES ($modules::Security::FORM{page_id},$k)");
	}
} # edit_keywords

sub edit_menu_setting {
	edit_record("menu_settings_tbl");
} # edit_menu_setting

sub add_related {
	if ($modules::Security::FORM{original_page_id}==$modules::Security::FORM{rel_page_id}) {
		return error_return(qq{Нельзя сделать страницу связанной с собой!<br/>Исправьте, пожалуйста.})
	}
	add_record("related_tbl")
}

sub del_related {
 	$modules::Validate::result_msg = modules::DBfunctions::get_erased_msg_text("page_tbl",$modules::Security::FORM{page_id})."<br/>";
	del_record("related_tbl")
} # del_related Удаление связанной страницы

sub order_related {
	my @order = grep { s/^p// } split /\|/=>$modules::Security::FORM{order};
	my %o;
	@o{@order} = (1..scalar @order);
	unshift @order=>0;
	$o{'0'} = '_';
	# %o = reverse %o;
	my @r = $modules::Core::soap->getQuery("SELECT related_id,order_fld
							FROM related_tbl
							WHERE original_page_id=$modules::Security::FORM{original_page_id}
							ORDER BY order_fld")->paramsout;
	my $i = 0;
	foreach (@r) {
		$modules::Core::soap->doQuery("UPDATE related_tbl
									  SET order_fld=".$o{$i+1}."
									  WHERE original_page_id=$modules::Security::FORM{original_page_id}
									  AND related_id=".$_->[0]);
		$i++;
	}
}

sub order_related_group {
	my @order = grep { s/^gpix\[\]=// } split /&/=>$modules::Security::FORM{order};
	my %o;
	@o{@order} = (1..scalar @order);
	unshift @order=>0;
	$o{'0'} = '_';
	# %o = reverse %o;
	my @r = $modules::Core::soap->getQuery("SELECT related_group_id,order_fld
							FROM related_group_tbl
							ORDER BY order_fld")->paramsout;
	my $i = 0;
	foreach (@r) {
		$modules::Core::soap->doQuery("UPDATE related_group_tbl
									  SET order_fld=".$o{$i+1}."
									  WHERE related_group_id=".$_->[0]);
		$i++;
	}
}

sub add_related_group { add_record("related_group_tbl") }

sub edit_related_group { edit_record("related_group_tbl") }

sub del_related_group { del_record("related_group_tbl") }

sub edit_page_related_group { add_record("related_tbl") }

sub del_page_related_group { del_record("related_tbl") }

sub edit_menupix { # Изменение/создание картинки раздела
	# Если задали новый путь (если _вообще_ его задали) — закачать картинку, а потом идти дальше
	# ...Иначе приравнять пути и тоже пойти дальше.
	my $f = $modules::Security::FORM{upload};
	foreach my $fld (split ",",$f) {
		if ($modules::Security::FORM{$fld} ne '') {
			my $fname = $modules::Security::FORM{$fld};
			$fname =~ m!^__tmp_([^,]+),(.+)$! ;
			$modules::Security::FORM{$fld} = '/img/'.$2;
			open(IN,"<".$modules::Settings::c{dir}{cgi}.$fname);
			binmode IN;
			my $content = join "",<IN>;
			close(IN);
			$modules::Core::soap->putFile([$modules::Security::FORM{$fld},$content]);
			unlink $modules::Settings::c{dir}{cgi}.$fname;
			if ($modules::Security::FORM{menupix_id}) {
				edit_record("menupix_tbl")
			} else {
				add_record("menupix_tbl")
			}
		} else {
			if ($modules::Security::FORM{menupix1_fld}) {
				if ($modules::Security::FORM{menupix1_fld} ne $modules::Security::FORM{menupix_fld_old}) {
					$modules::Security::FORM{menupix_fld} = $modules::Security::FORM{menupix1_fld};
				}
			}
			$modules::Security::FORM{menupixfolder_fld} = '' unless $modules::Security::FORM{menupixfolder_fld};
			if ($modules::Security::FORM{menupix_id}) {
				if ($modules::Security::FORM{menupix1_fld}) {
					edit_record("menupix_tbl")
				} else {
					del_record("menupix_tbl")
				}
			} else {
				add_record("menupix_tbl")
			}
		}

		#if ($modules::Security::FORM{menupix_id}) {
		#	edit_record("menupix_tbl")
		#}
	}
} # edit_menupix

sub edit_menupixurl { # Изменение/создание
	my $pid = $modules::Security::FORM{page_id};
	my $url_fld = $modules::Core::soap->getQuery("SELECT url_fld FROM page_tbl WHERE page_id=$pid")->result;
	if ($url_fld eq $modules::Security::FORM{menupixurl_fld}) {
		return error_return();
	}
	my $mpid = $modules::Core::soap->getQuery("SELECT menupix_id FROM menupix_tbl WHERE page_id=$pid")->result;
	if ($mpid) {
		$modules::Core::soap->doQuery("UPDATE menupix_tbl SET menupixurl_fld='$modules::Security::FORM{menupixurl_fld}' WHERE menupix_id=$mpid")
	} else {
		add_record('menupix_tbl')
	}
} # edit_menupixurl

####################### Шаблоны (incl. print_templates) ########################

sub edit_template {
	#modules::Debug::dump(\%modules::Security::FORM); return;
	unless ($modules::Security::FORM{type}) {
		$modules::Security::FORM{top_fld} =~ s/&(?:amp;)#xd;//g;
		$modules::Security::FORM{top_fld} =~ s/&(?:amp;)lt;/</g;
		$modules::Security::FORM{bottom_fld} =~ s/&(?:amp;)#xd;//g;
		$modules::Security::FORM{bottom_fld} =~ s/&(?:amp;)lt;/</g;
		edit_record("template_tbl");
		modules::Validate::rebuild_pages_templ($modules::Security::FORM{template_id});
	} else {
		$modules::Security::FORM{printtemplate_id} = $modules::Security::FORM{template_id};
		$modules::Security::FORM{printtemplate_fld} = $modules::Security::FORM{template_fld};
		edit_record("printtemplate_tbl");
	}
} # edit_template

sub add_template {
	unless ($modules::Security::FORM{type}) {
		add_record("template_tbl");
	} else {
		$modules::Security::FORM{printtemplate_fld} = $modules::Security::FORM{template_fld};
		add_record("printtemplate_tbl");
	}
} # add_template

sub del_template {
	my $type = $modules::Security::FORM{type};
	my $pg = $modules::Core::soap->getQuery("SELECT COUNT(*) FROM page_tbl WHERE ".(($type)?'print':'')."template_id=$modules::Security::FORM{template_id}")->result;
	if ($pg==0) {
		$modules::Validate::result_msg = modules::DBfunctions::get_erased_msg_text((($type)?'print':'')."template_tbl",$modules::Security::FORM{template_id})."<br/>";
		$modules::Security::FORM{printtemplate_id} = $modules::Security::FORM{template_id} if $type;
		del_record((($type)?'print':'')."template_tbl");
	} else {
		return error_return("Существует одна или более страниц, использующих данный шаблон".(($type)?' для печати':'').".<br/>Сначала переведите их на другой шаблон либо удалите их.")
	}
} # del_template

sub edit_print_template {
	edit_record("printtemplate_tbl");
	#&modules::Validate::rebuild_pages_templ($modules::Security::FORM{printtemplate_id});
	} # edit_print_template

sub add_print_template {
	add_record("printtemplate_tbl");
	} # add_print_template

sub del_print_template {
	my $pg = $modules::Core::soap->getQuery("SELECT COUNT(*) FROM page_tbl WHERE printtemplate_id=$modules::Security::FORM{printtemplate_id}")->result;
	if ($pg==0) {
	 	$modules::Validate::result_msg = modules::DBfunctions::get_erased_msg_text("printtemplate_tbl",$modules::Security::FORM{printtemplate_id})."<br/>";
		del_record("printtemplate_tbl");
	} else {
		return error_return("Существует одна или более страниц, использующих данный шаблон для печати.<br/>Переведите их на другой шаблон либо удалите их.")
	}
} # del_print_template

sub check_template {
	my @pages;
	my $str;
	my @r = $modules::Core::soap->getQuery("SELECT url_fld,template_fld,label_fld
											FROM page_tbl as p, template_tbl as t
											WHERE p.template_id = t.template_id
											ORDER BY url_fld")->paramsout;
	# Got @pages
	my $i = 1;
	foreach (@r) {
		my $tl = qq{$_->[1]*$_->[2]};
		push @pages,qq{$_->[0]|$tl}
	}
	@r = $modules::Core::soap->getQuery("SELECT url_fld,template_fld,label_fld
										FROM servpage_tbl as p, template_tbl as t
										WHERE p.template_id = t.template_id
										ORDER BY url_fld")->paramsout;
	foreach (@r) {
		my $tl = qq{$_->[1]*$_->[2]};
		push @pages,qq{$_->[0]|$tl}
	}
	my @fe = $modules::Core::soap->fileExists(\@pages)->paramsout;
	foreach my $p (@fe) {
		my @f = split /\|/,$p;
		my ($t,$l) = split /\*/,$f[1];
		my $perm = substr sprintf("%o",$f[2]),-3;
		$perm =~ s!(\d)(\d)(\d)!$1<b>$2</b>$3!;
		my $lt = length(modules::Comfunctions::extract_content($f[0]));
		$str .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">}.$f[0].qq{</td><td class="tl"><b>}.$l.qq{</b></td><td class="tl">}.(($lt>0)?"<b style='color:#006600'>OK</b>":"<b style='color: red'>Not OK</b>").qq{</td><td class="tl">}.(($lt>0)?$t:"<i>Без шаблона</i>").qq{</td><td class="tr">$perm</td></tr>};
	}
	return $str
}

sub validate_menu {
	my $str;
	my %err = %{modules::Validate::validate_menu()};
	my @r = $modules::Core::soap->getQuery("SELECT url_fld,label_fld FROM page_tbl ORDER BY url_fld")->paramsout;
	my $i = 1;
	foreach (@r) {
		my @t = @$_;
		my ($OK) = $err{$t[0]} =~ m!(<b\s[^>]+>OK</b>)(?:\s(<span\sstyle='color:Grey'>[^<]+</span>))?!;
		my $err = ($2)?$2:'';
		$str .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">$t[0]</td><td class="tl"><b>$t[1]</b><td class="tl">$OK</td><td class="tr">$err</td></tr>};
	}
	return $str
} # validate_menu

sub rebuild_pages {
	my $str;
	my @err = modules::Validate::rebuild_pages();
	#modules::Debug::dump(\@err);
	if (scalar @err) {
		$str .= qq{<table class="tab" border="0" cellpadding="0" cellspacing="0"><tr><td>
<table class="tab2" border="0" cellpadding="0" cellspacing="0">
<tr><th>Имя неперестроенного файла</th><th>Название страницы</th></tr>};
		my $i = 1;
		foreach (@err) {
			my $t = $modules::Core::soap->getQuery("SELECT fulllabel_fld FROM page_tbl WHERE url_fld='$_'")->result;
			$str .= qq{<tr class="tr_col}.($i++ % 2 +1).qq{"><td class="tl">$_</td><td class="tl">$t</td></tr>};
		}
		$str .= qq{</table></td></tr></table>}
	} else {
		$str .= info_msg(qq{<b>Всё в порядке.</b><br/>Ошибочных страниц нет})
	}
	return $str;
} # rebuild_pages

sub add_page_comment {
	my $cid = $modules::Core::soap->doQuery("INSERT INTO page_comment_tbl (page_id,username_fld,email_fld,comment_fld,dt_fld)
								  VALUES
								  ($modules::Security::FORM{page_id},
								  '$modules::Security::FORM{username_fld}',
								  '$modules::Security::FORM{email_fld}',
								  ".$modules::DBfunctions::dbh->quote($modules::Security::FORM{comment_fld}).",
								  NOW())");
	my $me = $modules::Core::soap->getQuery("SELECT moder_entity_id
											FROM moder_entity_tbl
											WHERE moder_object_fld='table'
											AND name_fld='page_comment_tbl'")->result;
	if ($me) {
		$modules::Core::soap->doQuery("INSERT INTO moder_object_tbl (moder_entity_id,moder_objself_id,moder_status_id) VALUES ($me,$cid,1)")
	}
}

sub edit_page_comment {
	$modules::Core::soap->doQuery("UPDATE page_comment_tbl SET
								  username_fld='$modules::Security::FORM{username_fld}',
								  email_fld='$modules::Security::FORM{email_fld}',
								  comment_fld=".$modules::DBfunctions::dbh->quote($modules::Security::FORM{comment_fld})."
								  WHERE page_id=$modules::Security::FORM{page_id}");
}

sub del_page_comment {
	del_record('page_comment_tbl')
}

1;
__END__

=head1 NAME

B<Page.pm> — Модуль, содержащий операции со страницами сайта.

=head1 SYNOPSIS

Модуль, содержащий операции со страницами сайта.

=head1 DESCRIPTION

Модуль, содержащий операции со страницами сайта. Один из двух основных модулей для минимальной работоспособности 4Site.

=head2 masterpage_sel

Текст выбранной родительской страницы.

=over 4

=item Вызов:

C<< <!--#include virtual="masterpage_sel"--> >>

=item Пример вызова:

C<< <!--#include virtual="masterpage_sel"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 masterpage_id

Говорит само за себя ;)

=over 4

=item Вызов:

C<< <!--#include virtual="masterpage_id"--> >>

=item Пример вызова:

C<< <!--#include virtual="masterpage_id"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 originalpage_id

Туда же ;)

=over 4

=item Вызов:

C<< <!--#include virtual="originalpage_id"--> >>

=item Пример вызова:

C<< <!--#include virtual="originalpage_id"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_id

ID страницы, переданной через форму.

=over 4

=item Вызов:

C<< <!--#include virtual="page_id"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_id"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 originalpage_sel

Название и URL выбранной страницы.

=over 4

=item Вызов:

C<< <!--#include virtual="originalpage_sel"--> >>

=item Пример вызова:

C<< <!--#include virtual="originalpage_sel"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_sel

То же.

=over 4

=item Вызов:

C<< <!--#include virtual="page_sel"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_sel"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 pageed_sel

То же.

=over 4

=item Вызов:

C<< <!--#include virtual="pageed_sel"--> >>

=item Пример вызова:

C<< <!--#include virtual="pageed_sel"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_select

Дерево выбора страницы (графическое представление). Используется для выбора страницы на всех формах, кроме "Наследования ключевых слов", "Связанных страниц" и "Подчинения страниц".

=over 4

=item Вызов:

C<< <!--#include virtual="page_select"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_select"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_select_master

Дерево выбора master-страницы (графическое представление). Используется на формах "Наследования ключевых слов", "Связанных страниц" и "Подчинения страниц".

=over 4

=item Вызов:

C<< <!--#include virtual="page_select_master"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_select_master"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_swap

Таблица со списком страниц (исключая выбранную) и выбором места для вставки для обмена страниц местами.

=over 4

=item Вызов:

C<< <!--#include virtual="page_select_master"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_select_master"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_cache_list

Изменение данных о кэшировании страницы в броузерах и поисковых машинах.

=over 4

=item Вызов:

C<< <!--#include virtual="page_cache_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_cache_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_del

Вывод уведомления об удалении страницы.

=over 4

=item Вызов:

C<< <!--#include virtual="page_del"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_del"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 template_downlist

Выпадающий список шаблонов страниц сайта.

=over 4

=item Вызов:

C<< <!--#include virtual="template_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="template_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 print_template_downlist

Выпадающий список шаблонов для печати страниц сайта.

=over 4

=item Вызов:

C<< <!--#include virtual="print_template_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="print_template_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page1st_downlist

Выпадающий список страниц сайта по разделам с выделением нужной страницы.

=over 4

=item Вызов:

C<< <!--#include virtual="page1st_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="page1st_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_downlist

Выпадающий список страниц сайта.

=over 4

=item Вызов:

C<< <!--#include virtual="page_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_sections_downlist

Выпадающий список страниц первого уровня.

=over 4

=item Вызов:

C<< <!--#include virtual="page_sections_downlist"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_sections_downlist"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_section_downlist_sel

Выпадающий список страниц сайта, по разделам (страницам первого уровня).

=over 4

=item Вызов:

C<< <!--#include virtual="page_section_downlist_sel"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_section_downlist_sel"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 menu_settings_list

Список настроек меню сайта.

=over 4

=item Вызов:

C<< <!--#include virtual="menu_settings_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="menu_settings_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 related_list

Список связанных страниц для выбранной страницы с возможностью удаления.

=over 4

=item Вызов:

C<< <!--#include virtual="related_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="related_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 page_edit

Форма редактирования страницы сайта и всех данных, связанных с содержимым страницы.

=over 4

=item Вызов:

C<< <!--#include virtual="page_edit"--> >>

=item Пример вызова:

C<< <!--#include virtual="page_edit"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 template_list

Список шаблонов страниц сайта с кнопками для удаления.

=over 4

=item Вызов:

C<< <!--#include virtual="template_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="template_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 print_template_list

Список шаблонов для печати страниц сайта с кнопками для удаления.

=over 4

=item Вызов:

C<< <!--#include virtual="print_template_list"--> >>

=item Пример вызова:

C<< <!--#include virtual="print_template_list"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 template_edit

Форма изменения шаблона страниц сайта.

=over 4

=item Вызов:

C<< <!--#include virtual="template_edit"--> >>

=item Пример вызова:

C<< <!--#include virtual="template_edit"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 print_template_edit

Форма изменения шаблона для печати страниц для сайта.

=over 4

=item Вызов:

C<< <!--#include virtual="print_template_edit"--> >>

=item Пример вызова:

C<< <!--#include virtual="print_template_edit"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 menupix_edit

Редактирование привязки картинок разделов.

=over 4

=item Вызов:

C<< <!--#include virtual="menupix_edit"--> >>

=item Пример вызова:

C<< <!--#include virtual="menupix_edit"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 keywords_edit

Таблица для редактирования наследования ключевых слов выбранной страницы.

=over 4

=item Вызов:

C<< <!--#include virtual="keywords_edit"--> >>

=item Пример вызова:

C<< <!--#include virtual="keywords_edit"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 statistics

Выводит статистику страниц по уровням вложенности.

=over 4

=item Вызов:

C<< <!--#include virtual="statistics"--> >>

=item Пример вызова:

C<< <!--#include virtual="statistics"--> >>

=item Примечания:

Напрямую не вызывается. Только в виде SSI-like include.

=item Зависимости:

Нет.

=back

=head2 edit_page_metadata

Изменение информации о страницах сайта, не относящейся к содержимому страниц.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 (add|del|edit|swap)_page

Добавление/удаление/изменение/обмен_местами страниц сайта.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 edit_pagemaster

Редактирование подчинения страницы сайта.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 edit_keywords

Изменение подключения к данной странице сайта ключевых слов страниц-родителей.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 (add|del)_related[_group]

Добавление/удаление связанной страницы (группы связанных страниц) к/от одной из других страниц сайта.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 (add|del|edit)_template

Добавление/удаление/изменение шаблонов страниц сайта.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 edit_menupix

Добавление/изменение картинки для раздела сайта.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 edit_menupixurl

Добавление/изменение ссылки на картинке раздела.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 (add|del|edit)_print_template

Добавление/удаление/изменение шаблонов для печати страниц сайта.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 check_template

Проверка присутствия и доступности шаблонов и построенных на них страниц.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 validate_menu

Проверка соответствия меню сайта дереву страниц.

=over 2

=item Примечания:

Напрямую не вызывается. Передаётся только через поле B<act> вызывающей HTML-формы.

=item Зависимости:

Нет.

=back

=head2 rebuild_pages

Перестройка всех страниц сайта по имеющимся шаблонам.

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

L<modules::Settings|::Settings>,
L<modules::DBfunctions|::DBfunctions>,
L<modules::Security|::Security>,
L<modules::Validfunc|::Validfunc>,
L<modules::Comfunctions|::Comfunctions>.

=head1 COPYRIGHT

E<copy> Copyright 2003, Method Lab

=cut
