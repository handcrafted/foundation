$(document).ready(function() {

	// -- This file is for Bootstrap Admin views ONLY -- //

	// Go Facebox go!	
	$('a[rel*=facebox]').facebox();
	
	// I'm on the outside
	var internalLink = window.location.hostname
	$("a[href^=http]")
		.not("a[href*='" + internalLink + "']")
		.addClass('link external')
		.attr('target', '_blank');

	$('.sortable').tablesorter({ widgets: ['zebra'], sortList:[[0,1]] });
	
	$('.tabs').tabs();

	$('#nav_main ul li:first-child').addClass('first');
	$('#nav_main ul li:last-child').addClass('last');
	
	$('table.listings tbody tr').hover(function() {
		$(this).addClass('hover');
	}, function() {
		$(this).removeClass('hover');
	});
	
	$('table.listings thead th:first-child').addClass('first');
	$('table.listings thead th:last-child').addClass('last');
	
	$('.approve_invite_link').click(function() {
		parent = $(this).parents(".invite_row")
		$.get($(this).attr('href'), function(data) {
			parent.after(data);
			parent.next().effect("highlight", {}, 2000);
			parent.remove();
		});
		return false;
	});
	
	$('input:text.example').example(function() {
		return $(this).attr('title');
		}, {className: 'blur'});
		
	
	$('textarea').livequery(function(){
		$(this).elastic();
	});
	
	$('form *:last-child').addClass('last')

	// -- place application specific jQuery below this line -- //
	
});

jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} 
});