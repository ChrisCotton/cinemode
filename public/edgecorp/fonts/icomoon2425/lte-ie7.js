/* Load this script using conditional IE comments if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'icomoon\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-facebook' : '&#xe000;',
			'icon-google-plus' : '&#xe001;',
			'icon-vimeo' : '&#xe002;',
			'icon-link' : '&#xe003;',
			'icon-pie' : '&#xe004;',
			'icon-stats' : '&#xe005;',
			'icon-bars' : '&#xe006;',
			'icon-bars-2' : '&#xe007;',
			'icon-chart' : '&#xe008;',
			'icon-stats-2' : '&#xe009;',
			'icon-flickr' : '&#xe00a;',
			'icon-flickr-2' : '&#xe00b;',
			'icon-flickr-3' : '&#xe00c;',
			'icon-flickr-4' : '&#xe00d;',
			'icon-blog' : '&#xe00e;',
			'icon-connection' : '&#xe00f;',
			'icon-podcast' : '&#xe010;',
			'icon-feed' : '&#xe011;',
			'icon-feed-2' : '&#xe012;',
			'icon-feed-3' : '&#xe013;',
			'icon-feed-4' : '&#xe014;',
			'icon-zoom-in' : '&#xe015;',
			'icon-zoom-out' : '&#xe016;',
			'icon-play' : '&#xe017;',
			'icon-film' : '&#xe018;',
			'icon-camera' : '&#xe019;',
			'icon-cog' : '&#xe01a;',
			'icon-cogs' : '&#xe01b;',
			'icon-cog-2' : '&#xe01c;',
			'icon-arrow-left' : '&#xe01d;',
			'icon-arrow-right' : '&#xe01e;',
			'icon-arrow-left-2' : '&#xe01f;',
			'icon-arrow-right-2' : '&#xe020;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, html, c, el;
	for (i = 0; ; i += 1) {
		el = els[i];
		if(!el) {
			break;
		}
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};