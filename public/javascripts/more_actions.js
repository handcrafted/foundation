$(document).ready(function(){
	
	$("a.select_all").click(function(){
		$(this).parents("div.resource_form form").find("input[type='checkbox']").attr("checked", "checked");
		return false;
	});

	$("a.unselect_all").click(function(){
		$(this).parents("div.resource_form form").find("input[type='checkbox']").attr("checked", "");
		return false;
	});
	
	$(".more_action").change(function(){
    switch($(this).val()) {
      case "none":
        break;
			default:
				var selected_ids = []
				var form = $(this).parents("form")
				form.find("input:checked").each(function(){
					selected_ids.push($(this).val());
				});
				if(selected_ids.length > 0) {
					$.post(
	          form.attr("action"),
	          {'ids[]': selected_ids, 'authenticity_token': form.find("input[name=\"authenticity_token\"]").val(),'more_action': $(this).val()},
						function(data) {
							if(data.length > 0){
                var headers = [];
                $(form).find(".resource_table th").each(function(){
                  headers.push($(this).attr("class").split(" ")[0]);
                });
								$.each(data, function(key, value){
									$.each(value, function(resource_type, resource_data) {
										var row_id		= "#" + resource_type + "_" + resource_data.id;
										var rows			= $(form).find(".resource_table tbody tr");
	                  var new_row		= $(rows[0]).clone(true);
										var new_row_id= resource_type + "_" + resource_data.id;
										$.each(headers, function(){
											var header_id = this.split("resource_")[1];
	                    $(new_row).find("td." + this).text(resource_data[header_id]);
	                  });
										if($(row_id).length > 0){
	                    $(row_id).replaceWith(new_row);
	                  } else {
											var last = rows.length - 1;
											$(new_row).attr("id", new_row_id);
											$(new_row).find("input[type='checkbox']").val(resource_data.id);
											$(new_row).find("input[type='checkbox']").attr("checked", "");
	                    $(new_row).insertAfter(rows[last]);
	                  }
									});
								});
							}
						},
						"json"
					);
				}
		}
	});
	
	$(".more_actions %input[type=submit]").hide();
});