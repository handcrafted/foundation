$(document).ready(function() {

	$('.posts .post:first-child, .posts_admin ul li:first-child').addClass('first');
	
	$('.posts .post p:last-child, .posts .post:last-child').addClass('last');
	
	// I'm on the outside
	$("a[href^=http]")
		.not("[href*='bootstrap.local/']")
		.addClass('link external')
		.attr('target', '_blank');

	// -- place bootstrap specific jQuery above this line -- //	
	// -- place application specific jQuery below this line -- //

});