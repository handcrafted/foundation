$(document).ready(function() {
	
	// Setup example text for inputs
	$('input:text.example').example(function() {
		return $(this).attr('title');
		}, {className: 'blur'});
	
	// Set textarea's to use the elastic feature
	$('textarea.elastic').livequery(function() {
		$(this).elastic();
	});

	// I'm on the outside
	hostname = window.location.hostname
	$("a[href^=http]")
		.not("a[href*='" + hostname + "']")
		.addClass('link external')
		.attr('target', '_blank');

	// -- place bootstrap specific jQuery above this line -- //	
	// -- place application specific jQuery below this line -- //
	
});

jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} 
});